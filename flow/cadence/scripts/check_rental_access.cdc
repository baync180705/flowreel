// scripts/check_rental_access.cdc
import MovieRental from "../contracts/MovieRental.cdc"

// Check if a renter has access to a rented NFT
access(all) fun main(nftID: UInt64, renterAddress: Address, ownerAddress: Address): Bool {
    return MovieRental.hasRentalAccess(
        nftID: nftID,
        renter: renterAddress,
        ownerAddress: ownerAddress
    )
}