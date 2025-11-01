// scripts/get_nft_details.cdc
import MovieNFT from "../contracts/MovieNFT.cdc"

// Get details of a specific NFT
access(all) fun main(ownerAddress: Address, nftID: UInt64): {String: AnyStruct} {
    let collection = getAccount(ownerAddress)
        .capabilities.get<&MovieNFT.Collection>(MovieNFT.CollectionPublicPath)
        .borrow() ?? panic("Could not borrow collection")
    
    let nft = collection.borrowMovieNFT(id: nftID) 
        ?? panic("NFT does not exist")
    
    return {
        "id": nft.id,
        "videoCID": nft.videoCID,
        "thumbnailCID": nft.thumbnailCID,
        "name": nft.name,
        "description": nft.description,
        "creator": nft.creator,
        "mintedAt": nft.mintedAt,
        "metadata": nft.metadata
    }
}