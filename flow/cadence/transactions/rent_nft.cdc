// transactions/rent_nft.cdc
import FungibleToken from 0xf233dcee88fe0abe
import FlowToken from 0x1654653399040a61
import MovieRental from "../contracts/MovieRental.cdc"

// Rent an NFT for a specified duration
transaction(ownerAddress: Address, nftID: UInt64, durationDays: UInt64, totalPrice: UFix64) {
    let paymentVault: @{FungibleToken.Vault}
    let ownerRentalCollection: &MovieRental.RentalCollection
    let renterAddress: Address
    
    prepare(renter: auth(Storage) &Account) {
        self.renterAddress = renter.address
        
        // Get renter's Flow vault
        let vaultRef = renter.storage.borrow<auth(FungibleToken.Withdraw) &FlowToken.Vault>(
            from: /storage/flowTokenVault
        ) ?? panic("Could not borrow renter's Flow vault")
        
        // Withdraw payment
        self.paymentVault <- vaultRef.withdraw(amount: totalPrice)
        
        // Get owner's rental collection
        self.ownerRentalCollection = getAccount(ownerAddress)
            .capabilities.get<&MovieRental.RentalCollection>(MovieRental.RentalCollectionPublicPath)
            .borrow() ?? panic("Could not borrow owner's rental collection")
    }
    
    execute {
        // Rent the NFT
        self.ownerRentalCollection.rentNFT(
            nftID: nftID,
            payment: <-self.paymentVault,
            renter: self.renterAddress,
            durationDays: durationDays
        )
        
        log("Rented NFT ID: ".concat(nftID.toString()).concat(" for ").concat(durationDays.toString()).concat(" days"))
    }
}