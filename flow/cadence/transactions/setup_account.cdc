// transactions/setup_account.cdc
import NonFungibleToken from 0x1d7e57aa55817448
import MovieNFT from "../contracts/MovieNFT.cdc"
import MovieMarketplace from "../contracts/MovieMarketplace.cdc"
import MovieRental from "../contracts/MovieRental.cdc"

// Setup user account with all necessary collections
transaction {
    prepare(signer: auth(Storage, Capabilities) &Account) {
        
        // Setup MovieNFT Collection
        if signer.storage.borrow<&MovieNFT.Collection>(from: MovieNFT.CollectionStoragePath) == nil {
            let collection <- MovieNFT.createEmptyCollection(nftType: Type<@MovieNFT.NFT>())
            signer.storage.save(<-collection, to: MovieNFT.CollectionStoragePath)
            
            let collectionCap = signer.capabilities.storage.issue<&MovieNFT.Collection>(
                MovieNFT.CollectionStoragePath
            )
            signer.capabilities.publish(collectionCap, at: MovieNFT.CollectionPublicPath)
        }
        
        // Setup Marketplace Storefront
        if signer.storage.borrow<&MovieMarketplace.Storefront>(from: MovieMarketplace.StorefrontStoragePath) == nil {
            let storefront <- MovieMarketplace.createStorefront()
            signer.storage.save(<-storefront, to: MovieMarketplace.StorefrontStoragePath)
            
            let storefrontCap = signer.capabilities.storage.issue<&MovieMarketplace.Storefront>(
                MovieMarketplace.StorefrontStoragePath
            )
            signer.capabilities.publish(storefrontCap, at: MovieMarketplace.StorefrontPublicPath)
        }
        
        // Setup Rental Collection
        if signer.storage.borrow<&MovieRental.RentalCollection>(from: MovieRental.RentalCollectionStoragePath) == nil {
            let rentalCollection <- MovieRental.createRentalCollection()
            signer.storage.save(<-rentalCollection, to: MovieRental.RentalCollectionStoragePath)
            
            let rentalCap = signer.capabilities.storage.issue<&MovieRental.RentalCollection>(
                MovieRental.RentalCollectionStoragePath
            )
            signer.capabilities.publish(rentalCap, at: MovieRental.RentalCollectionPublicPath)
        }
    }
    
    execute {
        log("Account setup complete")
    }
}