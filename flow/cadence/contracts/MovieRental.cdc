// contracts/MovieRental.cdc
import FungibleToken from 0x9a0766d93b6608b7
import FlowToken from 0x7e60df042a9c0868
import MovieNFT from 0x21bcdad218e253c9

access(all) contract MovieRental {
    
    // Events
    access(all) event RentalListingCreated(nftID: UInt64, pricePerDay: UFix64, owner: Address)
    access(all) event RentalListingRemoved(nftID: UInt64, owner: Address)
    access(all) event NFTRented(nftID: UInt64, renter: Address, owner: Address, duration: UInt64, totalPrice: UFix64, expiresAt: UFix64)
    access(all) event RentalExpired(nftID: UInt64, renter: Address)
    
    // Paths
    access(all) let RentalCollectionStoragePath: StoragePath
    access(all) let RentalCollectionPublicPath: PublicPath
    
    // Rental details for a specific NFT
    access(all) struct RentalDetails {
        access(all) let renter: Address
        access(all) let expiresAt: UFix64
        access(all) let nftID: UInt64
        
        init(renter: Address, expiresAt: UFix64, nftID: UInt64) {
            self.renter = renter
            self.expiresAt = expiresAt
            self.nftID = nftID
        }
    }
    
    // Rental listing for an NFT
    access(all) resource RentalListing {
        access(all) let nftID: UInt64
        access(all) let pricePerDay: UFix64
        access(all) var currentRental: RentalDetails?
        
        init(nftID: UInt64, pricePerDay: UFix64) {
            self.nftID = nftID
            self.pricePerDay = pricePerDay
            self.currentRental = nil
        }
        
        access(all) fun getOwnerAddress(): Address {
            return self.owner?.address ?? panic("Could not get owner address")
        }
        
        // Rent the NFT
        access(all) fun rentNFT(payment: @{FungibleToken.Vault}, renter: Address, durationDays: UInt64) {
            pre {
                self.currentRental == nil || getCurrentBlock().timestamp >= self.currentRental!.expiresAt: "NFT is currently rented"
                durationDays > 0: "Duration must be at least 1 day"
            }
            
            let totalPrice = self.pricePerDay * UFix64(durationDays)
            
            if payment.balance != totalPrice {
                panic("Payment does not match the rental price")
            }
            
            let ownerAddress = self.getOwnerAddress()
            
            // Send payment to owner
            let ownerVault = getAccount(ownerAddress)
                .capabilities.get<&FlowToken.Vault>(/public/flowTokenReceiver)
                .borrow() ?? panic("Could not borrow owner's Flow vault")
            
            ownerVault.deposit(from: <-payment)
            
            // Calculate expiration time (days in seconds)
            let expiresAt = getCurrentBlock().timestamp + (UFix64(durationDays) * 86400.0)
            
            self.currentRental = RentalDetails(
                renter: renter,
                expiresAt: expiresAt,
                nftID: self.nftID
            )
            
            emit NFTRented(
                nftID: self.nftID,
                renter: renter,
                owner: ownerAddress,
                duration: durationDays,
                totalPrice: totalPrice,
                expiresAt: expiresAt
            )
        }
        
        // Check if rental is active
        access(all) fun isRented(): Bool {
            if self.currentRental == nil {
                return false
            }
            
            if getCurrentBlock().timestamp >= self.currentRental!.expiresAt {
                emit RentalExpired(nftID: self.nftID, renter: self.currentRental!.renter)
                self.currentRental = nil
                return false
            }
            
            return true
        }
        
        // Get current renter
        access(all) fun getCurrentRenter(): Address? {
            if self.isRented() {
                return self.currentRental!.renter
            }
            return nil
        }
        
        // Get rental expiration time
        access(all) fun getRentalExpiration(): UFix64? {
            if self.isRented() {
                return self.currentRental!.expiresAt
            }
            return nil
        }
    }
    
    // Collection of rental listings
    access(all) resource RentalCollection {
        access(self) var listings: @{UInt64: RentalListing}
        
        init() {
            self.listings <- {}
        }
        
        // Create a rental listing
        access(all) fun createRentalListing(nftID: UInt64, pricePerDay: UFix64) {
            let owner = self.owner?.address ?? panic("Could not get owner address")
            
            // Verify owner has the NFT
            let collection = getAccount(owner)
                .capabilities.get<&MovieNFT.Collection>(MovieNFT.CollectionPublicPath)
                .borrow() ?? panic("Could not borrow owner's collection")
            
            let nftRef = collection.borrowMovieNFT(id: nftID) 
                ?? panic("NFT does not exist in owner's collection")
            
            let listing <- create RentalListing(nftID: nftID, pricePerDay: pricePerDay)
            
            let oldListing <- self.listings[nftID] <- listing
            destroy oldListing
            
            emit RentalListingCreated(nftID: nftID, pricePerDay: pricePerDay, owner: owner)
        }
        
        // Remove a rental listing
        access(all) fun removeRentalListing(nftID: UInt64) {
            let listing <- self.listings.remove(key: nftID) 
                ?? panic("Rental listing does not exist")
            
            if listing.isRented() {
                panic("Cannot remove listing while NFT is rented")
            }
            
            let owner = self.owner?.address ?? panic("Could not get owner address")
            emit RentalListingRemoved(nftID: nftID, owner: owner)
            
            destroy listing
        }
        
        // Rent an NFT
        access(all) fun rentNFT(nftID: UInt64, payment: @{FungibleToken.Vault}, renter: Address, durationDays: UInt64) {
            let listing = self.borrowRentalListing(nftID: nftID) 
                ?? panic("Rental listing does not exist")
            
            listing.rentNFT(payment: <-payment, renter: renter, durationDays: durationDays)
        }
        
        // Get all listing IDs
        access(all) fun getListingIDs(): [UInt64] {
            return self.listings.keys
        }
        
        // Borrow a rental listing
        access(all) fun borrowRentalListing(nftID: UInt64): &RentalListing? {
            if self.listings[nftID] != nil {
                return &self.listings[nftID]
            }
            return nil
        }
        
        // Get listing details
        access(all) fun getListingDetails(nftID: UInt64): {String: AnyStruct}? {
            if let listing = self.borrowRentalListing(nftID: nftID) {
                return {
                    "nftID": listing.nftID,
                    "pricePerDay": listing.pricePerDay,
                    "owner": listing.getOwnerAddress(),
                    "isRented": listing.isRented(),
                    "currentRenter": listing.getCurrentRenter(),
                    "expiresAt": listing.getRentalExpiration()
                }
            }
            return nil
        }
    }
    
    // Create an empty rental collection
    access(all) fun createRentalCollection(): @RentalCollection {
        return <- create RentalCollection()
    }
    
    // Check if an address has access to a rented NFT
    access(all) fun hasRentalAccess(nftID: UInt64, renter: Address, ownerAddress: Address): Bool {
        let rentalCollection = getAccount(ownerAddress)
            .capabilities.get<&RentalCollection>(MovieRental.RentalCollectionPublicPath)
            .borrow()
        
        if rentalCollection == nil {
            return false
        }
        
        if let listing = rentalCollection!.borrowRentalListing(nftID: nftID) {
            if listing.isRented() {
                return listing.getCurrentRenter() == renter
            }
        }
        
        return false
    }
    
    init() {
        self.RentalCollectionStoragePath = /storage/MovieRentalCollection
        self.RentalCollectionPublicPath = /public/MovieRentalCollection
    }
}