// transactions/mint_movie_nft.cdc
import NonFungibleToken from 0x1d7e57aa55817448
import MovieNFT from "../contracts/MovieNFT.cdc"

// Mint a new Movie NFT
transaction(
    recipientAddress: Address,
    videoCID: String,
    thumbnailCID: String,
    name: String,
    description: String,
    metadata: {String: String}
) {
    let minter: &MovieNFT.NFTMinter
    let recipientCollection: &{NonFungibleToken.CollectionPublic}
    
    prepare(signer: auth(Storage) &Account) {
        // Borrow minter reference
        self.minter = signer.storage.borrow<&MovieNFT.NFTMinter>(from: MovieNFT.MinterStoragePath)
            ?? panic("Could not borrow minter reference")
        
        // Get recipient's collection
        self.recipientCollection = getAccount(recipientAddress)
            .capabilities.get<&{NonFungibleToken.CollectionPublic}>(MovieNFT.CollectionPublicPath)
            .borrow() ?? panic("Could not borrow recipient's collection")
    }
    
    execute {
        let nftID = self.minter.mintNFT(
            recipient: self.recipientCollection,
            videoCID: videoCID,
            thumbnailCID: thumbnailCID,
            name: name,
            description: description,
            creator: recipientAddress,
            metadata: metadata
        )
        
        log("Minted Movie NFT with ID: ".concat(nftID.toString()))
    }
}