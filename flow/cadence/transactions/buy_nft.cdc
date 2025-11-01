// transactions/buy_nft.cdc
import FungibleToken from 0xf233dcee88fe0abe
import FlowToken from 0x1654653399040a61
import MovieNFT from "../contracts/MovieNFT.cdc"
import MovieMarketplace from "../contracts/MovieMarketplace.cdc"

// Buy an NFT from the marketplace
transaction(sellerAddress: Address, nftID: UInt64, price: UFix64) {
    let paymentVault: @{FungibleToken.Vault}
    let sellerStorefront: &MovieMarketplace.Storefront
    let buyerCollection: &MovieNFT.Collection
    
    prepare(buyer: auth(Storage) &Account) {
        // Get buyer's Flow vault
        let vaultRef = buyer.storage.borrow<auth(FungibleToken.Withdraw) &FlowToken.Vault>(
            from: /storage/flowTokenVault
        ) ?? panic("Could not borrow buyer's Flow vault")
        
        // Withdraw payment
        self.paymentVault <- vaultRef.withdraw(amount: price)
        
        // Get seller's storefront
        self.sellerStorefront = getAccount(sellerAddress)
            .capabilities.get<&MovieMarketplace.Storefront>(MovieMarketplace.StorefrontPublicPath)
            .borrow() ?? panic("Could not borrow seller's storefront")
        
        // Get buyer's collection
        self.buyerCollection = buyer.storage.borrow<&MovieNFT.Collection>(
            from: MovieNFT.CollectionStoragePath
        ) ?? panic("Could not borrow buyer's collection")
    }
    
    execute {
        // Purchase the NFT
        self.sellerStorefront.buyNFT(
            nftID: nftID,
            payment: <-self.paymentVault,
            buyerCollection: self.buyerCollection
        )
        
        log("Purchased NFT ID: ".concat(nftID.toString()).concat(" for ").concat(price.toString()).concat(" FLOW"))
    }
}