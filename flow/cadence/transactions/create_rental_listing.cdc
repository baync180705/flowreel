// transactions/create_rental_listing.cdc
import MovieRental from "../contracts/MovieRental.cdc"

// Create a rental listing for an NFT
transaction(nftID: UInt64, pricePerDay: UFix64) {
    let rentalCollection: &MovieRental.RentalCollection
    
    prepare(signer: auth(Storage) &Account) {
        // Borrow rental collection
        self.rentalCollection = signer.storage.borrow<&MovieRental.RentalCollection>(
            from: MovieRental.RentalCollectionStoragePath
        ) ?? panic("Could not borrow rental collection")
    }
    
    execute {
        // Create rental listing
        self.rentalCollection.createRentalListing(nftID: nftID, pricePerDay: pricePerDay)
        
        log("Created rental listing for NFT ID: ".concat(nftID.toString()).concat(" at ").concat(pricePerDay.toString()).concat(" FLOW per day"))
    }
}