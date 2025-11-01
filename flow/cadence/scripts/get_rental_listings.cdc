// scripts/get_rental_listings.cdc
import MovieRental from "../contracts/MovieRental.cdc"

// Get all rental listings for an owner
access(all) fun main(ownerAddress: Address): [{String: AnyStruct}] {
    let rentalCollection = getAccount(ownerAddress)
        .capabilities.get<&MovieRental.RentalCollection>(MovieRental.RentalCollectionPublicPath)
        .borrow() ?? panic("Could not borrow rental collection")
    
    let listingIDs = rentalCollection.getListingIDs()
    let listings: [{String: AnyStruct}] = []
    
    for id in listingIDs {
        if let details = rentalCollection.getListingDetails(nftID: id) {
            listings.append(details)
        }
    }
    
    return listings
}