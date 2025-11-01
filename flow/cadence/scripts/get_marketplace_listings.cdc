// scripts/get_marketplace_listings.cdc
import MovieMarketplace from "../contracts/MovieMarketplace.cdc"

// Get all marketplace listings for a seller
access(all) fun main(sellerAddress: Address): [{String: AnyStruct}] {
    let storefront = getAccount(sellerAddress)
        .capabilities.get<&MovieMarketplace.Storefront>(MovieMarketplace.StorefrontPublicPath)
        .borrow() ?? panic("Could not borrow storefront")
    
    let listingIDs = storefront.getListingIDs()
    let listings: [{String: AnyStruct}] = []
    
    for id in listingIDs {
        if let details = storefront.getListingDetails(nftID: id) {
            listings.append(details)
        }
    }
    
    return listings
}