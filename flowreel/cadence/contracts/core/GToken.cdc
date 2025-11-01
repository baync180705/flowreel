import "FungibleToken"
import "MetadataViews"
import "FungibleTokenMetadataViews"
import "ViewResolver"

/// GToken (GVT) - Governance token for FlowReel DAO
/// Total supply: 600M tokens
/// Used for: Governance voting, creator verification, lending collateral
access(all) contract GToken: FungibleToken {
    /// Total supply of GTokens in existence
    access(all) var totalSupply: UFix64
    
    /// Storage and Public Paths
    access(all) let VaultStoragePath: StoragePath
    access(all) let VaultPublicPath: PublicPath
    access(all) let ReceiverPublicPath: PublicPath
    access(all) let AdminStoragePath: StoragePath

    /// Events
    access(all) event TokensInitialized(initialSupply: UFix64)
    access(all) event TokensWithdrawn(amount: UFix64, from: Address?)
    access(all) event TokensDeposited(amount: UFix64, to: Address?)
    access(all) event TokensMinted(amount: UFix64)
    access(all) event TokensBurned(amount: UFix64)
    access(all) event MinterCreated(allowedAmount: UFix64)
    access(all) event BurnerCreated()

    /// Vault
    ///
    /// Each user stores an instance of only the Vault in their storage
    /// The functions in the Vault are governed by the pre and post conditions
    /// in FungibleToken when they are called.
    ///
    access(all) resource Vault: FungibleToken.Vault {

        /// The total balance of this vault
        access(all) var balance: UFix64

        /// Initialize the balance at resource creation time
        init(balance: UFix64) {
            self.balance = balance
        }

        /// Called when a fungible token is burned via withdraw.
        access(contract) fun burnCallback() {
            if self.balance > 0.0 {
                GToken.totalSupply = GToken.totalSupply - self.balance
            }
        }

        /// withdraw
        ///
        /// Function that takes an amount as an argument
        /// and withdraws that amount from the Vault.
        ///
        /// @param amount: The amount of tokens to be withdrawn from the vault
        /// @return The Vault resource containing the withdrawn funds
        ///
        access(FungibleToken.Withdraw) fun withdraw(amount: UFix64): @GToken.Vault {
            self.balance = self.balance - amount
            emit TokensWithdrawn(amount: amount, from: self.owner?.address)
            return <-create Vault(balance: amount)
        }

        /// deposit
        ///
        /// Function that takes a Vault object as an argument and adds
        /// its balance to the balance of the owners Vault.
        ///
        /// @param from: The Vault resource containing the funds that will be deposited
        ///
        access(all) fun deposit(from: @{FungibleToken.Vault}) {
            let vault <- from as! @GToken.Vault
            self.balance = self.balance + vault.balance
            emit TokensDeposited(amount: vault.balance, to: self.owner?.address)
            vault.balance = 0.0
            destroy vault
        }

        /// getSupportedVaultTypes
        ///
        /// Returns the types of Vaults that this Vault can accept in deposit
        ///
        access(all) view fun getSupportedVaultTypes(): {Type: Bool} {
            return {Type<@GToken.Vault>(): true}
        }

        /// isSupportedVaultType
        ///
        /// Returns whether the Vault can accept the given type
        ///
        access(all) view fun isSupportedVaultType(type: Type): Bool {
            return type == Type<@GToken.Vault>()
        }

        access(all) view fun isAvailableToWithdraw(amount: UFix64): Bool {
            return self.balance >= amount
        }

        /// getViews
        ///
        /// @return An array of Types defining the implemented views.
        ///
        access(all) view fun getViews(): [Type] {
            return [
                Type<FungibleTokenMetadataViews.FTView>(),
                Type<FungibleTokenMetadataViews.FTDisplay>(),
                Type<FungibleTokenMetadataViews.FTVaultData>()
            ]
        }

        /// resolveView
        ///
        /// @param view: The Type of the desired view.
        /// @return A structure representing the requested view.
        ///
        access(all) fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<FungibleTokenMetadataViews.FTView>():
                    return FungibleTokenMetadataViews.FTView(
                        ftDisplay: self.resolveView(Type<FungibleTokenMetadataViews.FTDisplay>()) as! FungibleTokenMetadataViews.FTDisplay?,
                        ftVaultData: self.resolveView(Type<FungibleTokenMetadataViews.FTVaultData>()) as! FungibleTokenMetadataViews.FTVaultData?
                    )
                case Type<FungibleTokenMetadataViews.FTDisplay>():
                    let media = MetadataViews.Media(
                        file: MetadataViews.HTTPFile(
                            url: "https://www.flowreel.xyz/img/logo.png"
                        ),
                        mediaType: "image/png"
                    )
                    let medias = MetadataViews.Medias([media])
                    return FungibleTokenMetadataViews.FTDisplay(
                        name: "FlowReel Governance Token",
                        symbol: "GVT",
                        description: "Governance token for FlowReel DAO - a decentralized streaming platform on Flow",
                        externalURL: MetadataViews.ExternalURL("https://www.flowreel.xyz/"),
                        logos: medias,
                        socials: {
                            "twitter": MetadataViews.ExternalURL("https://twitter.com/FlowReel")
                        }
                    )
                case Type<FungibleTokenMetadataViews.FTVaultData>():
                    return FungibleTokenMetadataViews.FTVaultData(
                        storagePath: GToken.VaultStoragePath,
                        receiverPath: GToken.ReceiverPublicPath,
                        metadataPath: GToken.VaultPublicPath,
                        receiverLinkedType: Type<&GToken.Vault>(),
                        metadataLinkedType: Type<&GToken.Vault>(),
                        createEmptyVaultFunction: (fun(): @{FungibleToken.Vault} {
                            return <-GToken.createEmptyVault(vaultType: Type<@GToken.Vault>())
                        })
                    )
            }
            return nil
        }

        /// createEmptyVault
        ///
        access(all) fun createEmptyVault(): @GToken.Vault {
            return <-create Vault(balance: 0.0)
        }
    }

    /// createEmptyVault
    ///
    /// Function that creates a new Vault with a balance of zero
    /// and returns it to the calling context.
    ///
    /// @return The new Vault resource
    ///
    access(all) fun createEmptyVault(vaultType: Type): @GToken.Vault {
        return <-create Vault(balance: 0.0)
    }

    /// getContractViews
    ///
    /// Function to return the types of views supported at the contract level
    ///
    access(all) view fun getContractViews(resourceType: Type?): [Type] {
        return [
            Type<FungibleTokenMetadataViews.FTView>(),
            Type<FungibleTokenMetadataViews.FTDisplay>(),
            Type<FungibleTokenMetadataViews.FTVaultData>(),
            Type<FungibleTokenMetadataViews.TotalSupply>()
        ]
    }

    /// resolveContractView
    ///
    /// Function to resolve contract-level views
    ///
    access(all) fun resolveContractView(resourceType: Type?, viewType: Type): AnyStruct? {
        switch viewType {
            case Type<FungibleTokenMetadataViews.FTView>():
                return FungibleTokenMetadataViews.FTView(
                    ftDisplay: self.resolveContractView(resourceType: nil, viewType: Type<FungibleTokenMetadataViews.FTDisplay>()) as! FungibleTokenMetadataViews.FTDisplay?,
                    ftVaultData: self.resolveContractView(resourceType: nil, viewType: Type<FungibleTokenMetadataViews.FTVaultData>()) as! FungibleTokenMetadataViews.FTVaultData?
                )
            case Type<FungibleTokenMetadataViews.FTDisplay>():
                let media = MetadataViews.Media(
                    file: MetadataViews.HTTPFile(
                        url: "https://www.flowreel.xyz/img/logo.png"
                    ),
                    mediaType: "image/png"
                )
                let medias = MetadataViews.Medias([media])
                return FungibleTokenMetadataViews.FTDisplay(
                    name: "FlowReel Governance Token",
                    symbol: "GVT",
                    description: "Governance token for FlowReel DAO - a decentralized streaming platform on Flow",
                    externalURL: MetadataViews.ExternalURL("https://www.flowreel.xyz/"),
                    logos: medias,
                    socials: {
                        "twitter": MetadataViews.ExternalURL("https://twitter.com/FlowReel")
                    }
                )
            case Type<FungibleTokenMetadataViews.FTVaultData>():
                return FungibleTokenMetadataViews.FTVaultData(
                    storagePath: GToken.VaultStoragePath,
                    receiverPath: GToken.ReceiverPublicPath,
                    metadataPath: GToken.VaultPublicPath,
                    receiverLinkedType: Type<&GToken.Vault>(),
                    metadataLinkedType: Type<&GToken.Vault>(),
                    createEmptyVaultFunction: (fun(): @{FungibleToken.Vault} {
                        return <-GToken.createEmptyVault(vaultType: Type<@GToken.Vault>())
                    })
                )
            case Type<FungibleTokenMetadataViews.TotalSupply>():
                return FungibleTokenMetadataViews.TotalSupply(
                    totalSupply: GToken.totalSupply
                )
        }
        return nil
    }

    /// Administrator
    ///
    /// Resource object that admin accounts can hold to mint and burn tokens.
    ///
    access(all) resource Administrator {

        /// createNewMinter
        ///
        /// Function that creates and returns a new minter resource
        ///
        /// @param allowedAmount: The maximum quantity of tokens that the minter could create
        /// @return The Minter resource that would allow to mint tokens
        ///
        access(all) fun createNewMinter(allowedAmount: UFix64): @Minter {
            emit MinterCreated(allowedAmount: allowedAmount)
            return <-create Minter(allowedAmount: allowedAmount)
        }

        /// createNewBurner
        ///
        /// Function that creates and returns a new burner resource
        ///
        /// @return The Burner resource
        ///
        access(all) fun createNewBurner(): @Burner {
            emit BurnerCreated()
            return <-create Burner()
        }
    }

    /// Minter
    ///
    /// Resource object that token admin accounts can hold to mint new tokens.
    ///
    access(all) resource Minter {

        /// The amount of tokens that the minter is allowed to mint
        access(all) var allowedAmount: UFix64

        /// mintTokens
        ///
        /// Function that mints new tokens, adds them to the total supply,
        /// and returns them to the calling context.
        ///
        /// @param amount: The quantity of tokens to mint
        /// @return The Vault resource containing the minted tokens
        ///
        access(all) fun mintTokens(amount: UFix64): @GToken.Vault {
            pre {
                amount > 0.0: "Amount minted must be greater than zero"
                amount <= self.allowedAmount: "Amount minted must be less than the allowed amount"
            }
            GToken.totalSupply = GToken.totalSupply + amount
            self.allowedAmount = self.allowedAmount - amount
            emit TokensMinted(amount: amount)
            return <-create Vault(balance: amount)
        }

        init(allowedAmount: UFix64) {
            self.allowedAmount = allowedAmount
        }
    }

    /// Burner
    ///
    /// Resource object that token admin accounts can hold to burn tokens.
    ///
    access(all) resource Burner {

        /// burnTokens
        ///
        /// Function that destroys a Vault instance, effectively burning the tokens.
        ///
        /// @param from: The Vault resource containing the tokens to burn
        ///
        access(all) fun burnTokens(from: @{FungibleToken.Vault}) {
            let vault <- from as! @GToken.Vault
            let amount = vault.balance
            GToken.totalSupply = GToken.totalSupply - amount
            emit TokensBurned(amount: amount)
            destroy vault
        }
    }

    init() {
        // Total supply of GVT is 600M
        self.totalSupply = 600_000_000.0

        self.VaultStoragePath = /storage/GTokenVault
        self.VaultPublicPath = /public/GTokenMetadata
        self.ReceiverPublicPath = /public/GTokenReceiver
        self.AdminStoragePath = /storage/GTokenAdmin

        // Create the Vault with the total supply of tokens and save it in storage.
        let vault <- create Vault(balance: self.totalSupply)
        self.account.storage.save(<-vault, to: self.VaultStoragePath)

        // Create public capabilities
        let receiverCap = self.account.capabilities.storage.issue<&GToken.Vault>(
            self.VaultStoragePath
        )
        self.account.capabilities.publish(receiverCap, at: self.ReceiverPublicPath)

        let metadataCap = self.account.capabilities.storage.issue<&GToken.Vault>(
            self.VaultStoragePath
        )
        self.account.capabilities.publish(metadataCap, at: self.VaultPublicPath)

        // Create and save the Administrator resource
        let admin <- create Administrator()
        self.account.storage.save(<-admin, to: self.AdminStoragePath)

        // Emit an event that shows that the contract was initialized
        emit TokensInitialized(initialSupply: self.totalSupply)
    }
}