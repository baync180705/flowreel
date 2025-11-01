// transactions/create_listing.cdc
import NonFungibleToken from 0x1d7e57aa55817448
import MovieNFT from "../contracts/MovieNFT.cdc"
import MovieMarketplace from "../contracts/MovieMarketplace.cdc"

// Create a marketplace listing for an NFT
transaction(nftID: UInt64, price: UFix64) {
    let storefront: &MovieMarketplace.Storefront
    let collection: auth(NonFungibleToken.Withdraw) &MovieNFT.Collection
    
    prepare(signer: auth(Storage) &Account) {
        // Borrow storefront
        self.storefront = signer.storage.borrow<&MovieMarketplace.Storefront>(
            from: MovieMarketplace.StorefrontStoragePath
        ) ?? panic("Could not borrow storefront")
        
        // Borrow collection to withdraw NFT
        self.collection = signer.storage.borrow<auth(NonFungibleToken.Withdraw) &MovieNFT.Collection>(
            from: MovieNFT.CollectionStoragePath
        ) ?? panic("Could not borrow collection")
    }
    
    execute {
        // Withdraw NFT from collection
        let nft <- self.collection.withdraw(withdrawID: nftID) as! @MovieNFT.NFT
        
        // Create listing
        self.storefront.createListing(nft: <-nft, price: price)
        
        log("Created listing for NFT ID: ".concat(nftID.toString()).concat(" at price: ").concat(price.toString()))
    }
}