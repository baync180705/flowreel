// contracts/MovieMarketplace.cdc
import FungibleToken from 0xee82856bf20e2aa6
import FlowToken from 0x0ae53cb6e3f42a79
import NonFungibleToken from 0xf8d6e0586b0a20c7
import MovieNFT from 0xf8d6e0586b0a20c7

access(all) contract MovieMarketplace {
    
    // Events
    access(all) event ListingCreated(nftID: UInt64, price: UFix64, seller: Address)
    access(all) event ListingRemoved(nftID: UInt64, seller: Address)
    access(all) event NFTPurchased(nftID: UInt64, price: UFix64, buyer: Address, seller: Address)
    
    // Paths
    access(all) let StorefrontStoragePath: StoragePath
    access(all) let StorefrontPublicPath: PublicPath
    
    // Listing Resource
    access(all) resource Listing {
        access(all) let nftID: UInt64
        access(all) let price: UFix64
        access(all) let seller: Address
        access(self) var nft: @MovieNFT.NFT?
        
        init(nft: @MovieNFT.NFT, price: UFix64, seller: Address) {
            self.nftID = nft.id
            self.price = price
            self.seller = seller
            self.nft <- nft
        }
        
        // Purchase the NFT
        access(all) fun purchase(payment: @{FungibleToken.Vault}, buyerCollection: &MovieNFT.Collection) {
            pre {
                payment.balance == self.price: "Payment does not match the listing price"
                self.nft != nil: "NFT has already been sold"
            }
            
            // Get seller's Flow vault to receive payment
            let sellerVault = getAccount(self.seller)
                .capabilities.get<&FlowToken.Vault>(/public/flowTokenReceiver)
                .borrow() ?? panic("Could not borrow seller's Flow vault")
            
            sellerVault.deposit(from: <-payment)
            
            // Transfer NFT to buyer
            let nft <- self.nft <- nil
            buyerCollection.deposit(token: <-nft!)
        }
        
        // Withdraw NFT (for removing listing)
        access(contract) fun withdrawNFT(): @MovieNFT.NFT {
            pre {
                self.nft != nil: "NFT has already been withdrawn"
            }
            let nft <- self.nft <- nil
            return <-nft!
        }
    }
    
    // Storefront Resource
    access(all) resource Storefront {
        access(self) var listings: @{UInt64: Listing}
        
        init() {
            self.listings <- {}
        }
        
        // Create a new listing
        access(all) fun createListing(nft: @MovieNFT.NFT, price: UFix64) {
            let nftID = nft.id
            let seller = self.owner?.address ?? panic("Could not get seller address")
            
            let listing <- create Listing(nft: <-nft, price: price, seller: seller)
            
            let oldListing <- self.listings[nftID] <- listing
            destroy oldListing
            
            emit ListingCreated(nftID: nftID, price: price, seller: seller)
        }
        
        // Remove a listing
        access(all) fun removeListing(nftID: UInt64): @MovieNFT.NFT {
            let listing <- self.listings.remove(key: nftID) 
                ?? panic("Listing does not exist")
            
            let seller = self.owner?.address ?? panic("Could not get seller address")
            emit ListingRemoved(nftID: nftID, seller: seller)
            
            let nft <- listing.withdrawNFT()
            destroy listing
            return <-nft
        }
        
        // Buy an NFT from the storefront
        access(all) fun buyNFT(nftID: UInt64, payment: @{FungibleToken.Vault}, buyerCollection: &MovieNFT.Collection) {
            let listing = self.borrowListing(nftID: nftID) 
                ?? panic("Listing does not exist")
            
            let price = listing.price
            let seller = listing.seller
            let buyer = buyerCollection.owner?.address ?? panic("Could not get buyer address")
            
            listing.purchase(payment: <-payment, buyerCollection: buyerCollection)
            
            // Remove the listing after purchase
            let purchased <- self.listings.remove(key: nftID)!
            destroy purchased
            
            emit NFTPurchased(nftID: nftID, price: price, buyer: buyer, seller: seller)
        }
        
        // Get listing details
        access(all) fun getListingIDs(): [UInt64] {
            return self.listings.keys
        }
        
        access(all) fun borrowListing(nftID: UInt64): &Listing? {
            if self.listings[nftID] != nil {
                return &self.listings[nftID]
            }
            return nil
        }
        
        access(all) fun getListingDetails(nftID: UInt64): {String: AnyStruct}? {
            if let listing = self.borrowListing(nftID: nftID) {
                return {
                    "nftID": listing.nftID,
                    "price": listing.price,
                    "seller": listing.seller
                }
            }
            return nil
        }
    }
    
    // Create an empty storefront
    access(all) fun createStorefront(): @Storefront {
        return <- create Storefront()
    }
    
    init() {
        self.StorefrontStoragePath = /storage/MovieMarketplaceStorefront
        self.StorefrontPublicPath = /public/MovieMarketplaceStorefront
    }
}