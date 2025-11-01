// contracts/MovieNFT.cdc
import NonFungibleToken from 0x631e88ae7f1d7c20
import ViewResolver from 0x631e88ae7f1d7c20
import MetadataViews from 0x631e88ae7f1d7c20
import FungibleToken from 0x9a0766d93b6608b7
import FlowToken from 0x7e60df042a9c0868

access(all) contract MovieNFT: NonFungibleToken {
    
    // Events
    access(all) event ContractInitialized()
    access(all) event Withdraw(id: UInt64, from: Address?)
    access(all) event Deposit(id: UInt64, to: Address?)
    access(all) event MovieNFTMinted(id: UInt64, videoCID: String, thumbnailCID: String, creator: Address)
    
    // Paths
    access(all) let CollectionStoragePath: StoragePath
    access(all) let CollectionPublicPath: PublicPath
    access(all) let MinterStoragePath: StoragePath
    
    // Total supply tracker
    access(all) var totalSupply: UInt64
    
    // NFT Resource
    access(all) resource NFT: NonFungibleToken.NFT {
        access(all) let id: UInt64
        access(all) let videoCID: String
        access(all) let thumbnailCID: String
        access(all) let name: String
        access(all) let description: String
        access(all) let creator: Address
        access(all) let mintedAt: UFix64
        access(all) var metadata: {String: String}
        
        init(
            id: UInt64,
            videoCID: String,
            thumbnailCID: String,
            name: String,
            description: String,
            creator: Address,
            metadata: {String: String}
        ) {
            self.id = id
            self.videoCID = videoCID
            self.thumbnailCID = thumbnailCID
            self.name = name
            self.description = description
            self.creator = creator
            self.mintedAt = getCurrentBlock().timestamp
            self.metadata = metadata
        }
        
        access(all) view fun getViews(): [Type] {
            return [
                Type<MetadataViews.Display>(),
                Type<MetadataViews.NFTCollectionData>(),
                Type<MetadataViews.NFTCollectionDisplay>()
            ]
        }
        
        access(all) fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<MetadataViews.Display>():
                    return MetadataViews.Display(
                        name: self.name,
                        description: self.description,
                        thumbnail: MetadataViews.IPFSFile(
                            cid: self.thumbnailCID,
                            path: nil
                        )
                    )
                case Type<MetadataViews.NFTCollectionData>():
                    return MetadataViews.NFTCollectionData(
                        storagePath: MovieNFT.CollectionStoragePath,
                        publicPath: MovieNFT.CollectionPublicPath,
                        publicCollection: Type<&MovieNFT.Collection>(),
                        publicLinkedType: Type<&MovieNFT.Collection>(),
                        createEmptyCollectionFunction: (fun(): @{NonFungibleToken.Collection} {
                            return <-MovieNFT.createEmptyCollection(nftType: Type<@MovieNFT.NFT>())
                        })
                    )
            }
            return nil
        }
        
        access(all) fun createEmptyCollection(): @{NonFungibleToken.Collection} {
            return <-MovieNFT.createEmptyCollection(nftType: Type<@MovieNFT.NFT>())
        }
    }
    
    // Collection Resource
    access(all) resource Collection: NonFungibleToken.Collection {
        access(all) var ownedNFTs: @{UInt64: {NonFungibleToken.NFT}}
        
        init() {
            self.ownedNFTs <- {}
        }
        
        access(NonFungibleToken.Withdraw) fun withdraw(withdrawID: UInt64): @{NonFungibleToken.NFT} {
            let token <- self.ownedNFTs.remove(key: withdrawID) 
                ?? panic("NFT not found in collection")
            emit Withdraw(id: token.id, from: self.owner?.address)
            return <-token
        }
        
        access(all) fun deposit(token: @{NonFungibleToken.NFT}) {
            let token <- token as! @MovieNFT.NFT
            let id = token.id
            let oldToken <- self.ownedNFTs[id] <- token
            emit Deposit(id: id, to: self.owner?.address)
            destroy oldToken
        }
        
        access(all) view fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }
        
        access(all) view fun borrowNFT(_ id: UInt64): &{NonFungibleToken.NFT}? {
            return &self.ownedNFTs[id]
        }
        
        access(all) fun borrowMovieNFT(id: UInt64): &MovieNFT.NFT? {
            if self.ownedNFTs[id] != nil {
                let ref = &self.ownedNFTs[id] as &{NonFungibleToken.NFT}?
                return ref as! &MovieNFT.NFT
            }
            return nil
        }
        
        access(all) view fun getSupportedNFTTypes(): {Type: Bool} {
            let supportedTypes: {Type: Bool} = {}
            supportedTypes[Type<@MovieNFT.NFT>()] = true
            return supportedTypes
        }
        
        access(all) view fun isSupportedNFTType(type: Type): Bool {
            return type == Type<@MovieNFT.NFT>()
        }
        
        access(all) fun createEmptyCollection(): @{NonFungibleToken.Collection} {
            return <-MovieNFT.createEmptyCollection(nftType: Type<@MovieNFT.NFT>())
        }
    }
    
    // Minter Resource
    access(all) resource NFTMinter {
        
        access(all) fun mintNFT(
            recipient: &{NonFungibleToken.CollectionPublic},
            videoCID: String,
            thumbnailCID: String,
            name: String,
            description: String,
            creator: Address,
            metadata: {String: String}
        ): UInt64 {
            let newNFT <- create NFT(
                id: MovieNFT.totalSupply,
                videoCID: videoCID,
                thumbnailCID: thumbnailCID,
                name: name,
                description: description,
                creator: creator,
                metadata: metadata
            )
            
            let nftId = newNFT.id
            recipient.deposit(token: <-newNFT)
            
            MovieNFT.totalSupply = MovieNFT.totalSupply + 1
            
            emit MovieNFTMinted(id: nftId, videoCID: videoCID, thumbnailCID: thumbnailCID, creator: creator)
            
            return nftId
        }
    }
    
    access(all) fun createEmptyCollection(nftType: Type): @{NonFungibleToken.Collection} {
        return <- create Collection()
    }
    
    access(all) view fun getContractViews(resourceType: Type?): [Type] {
        return [Type<MetadataViews.NFTCollectionData>()]
    }
    
    access(all) fun resolveContractView(resourceType: Type?, viewType: Type): AnyStruct? {
        switch viewType {
            case Type<MetadataViews.NFTCollectionData>():
                return MetadataViews.NFTCollectionData(
                    storagePath: MovieNFT.CollectionStoragePath,
                    publicPath: MovieNFT.CollectionPublicPath,
                    publicCollection: Type<&MovieNFT.Collection>(),
                    publicLinkedType: Type<&MovieNFT.Collection>(),
                    createEmptyCollectionFunction: (fun(): @{NonFungibleToken.Collection} {
                        return <-MovieNFT.createEmptyCollection(nftType: Type<@MovieNFT.NFT>())
                    })
                )
        }
        return nil
    }
    
    init() {
        self.totalSupply = 0
        
        self.CollectionStoragePath = /storage/MovieNFTCollection
        self.CollectionPublicPath = /public/MovieNFTCollection
        self.MinterStoragePath = /storage/MovieNFTMinter
        
        // Create minter and save to storage
        self.account.storage.save(<-create NFTMinter(), to: self.MinterStoragePath)
        
        emit ContractInitialized()
    }
}