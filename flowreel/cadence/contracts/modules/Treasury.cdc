import "FungibleToken"
import "GToken"
import "GTokenDAO"

/// Treasury
///
/// Module for managing FlowReel DAO treasury
/// Collects 10% of all rental fees and manages fund allocation
///
access(all) contract Treasury {

    /// Storage
    access(contract) var totalCollected: UFix64
    access(contract) var totalDistributed: UFix64
    access(contract) var transactionCounter: UInt64
    access(contract) var transactions: [TransactionRecord]
    
    /// Treasury percentage from rental fees (10%)
    access(all) let treasuryPercentage: UFix64

    /// Paths
    access(all) let TreasuryVaultStoragePath: StoragePath
    access(all) let TreasuryAdminStoragePath: StoragePath

    /// Events
    access(all) event TreasuryDeposit(amount: UFix64, from: Address?, timestamp: UFix64)
    access(all) event TreasuryWithdrawal(amount: UFix64, to: Address, purpose: String, timestamp: UFix64)
    access(all) event RentalFeeCollected(amount: UFix64, movieId: String, renter: Address, timestamp: UFix64)
    access(all) event RevenueDistributed(
        totalAmount: UFix64,
        treasuryAmount: UFix64,
        creatorAmount: UFix64,
        creator: Address,
        timestamp: UFix64
    )

    /// TreasuryStats
    ///
    /// Struct containing treasury statistics
    ///
    access(all) struct TreasuryStats {
        access(all) let totalCollected: UFix64
        access(all) let totalDistributed: UFix64
        access(all) let currentBalance: UFix64
        access(all) let treasuryPercentage: UFix64
        access(all) let lastUpdated: UFix64

        init(
            totalCollected: UFix64,
            totalDistributed: UFix64,
            currentBalance: UFix64,
            treasuryPercentage: UFix64,
            lastUpdated: UFix64
        ) {
            self.totalCollected = totalCollected
            self.totalDistributed = totalDistributed
            self.currentBalance = currentBalance
            self.treasuryPercentage = treasuryPercentage
            self.lastUpdated = lastUpdated
        }
    }

    /// TransactionRecord
    ///
    /// Struct for recording treasury transactions
    ///
    access(all) struct TransactionRecord {
        access(all) let id: UInt64
        access(all) let type: String
        access(all) let amount: UFix64
        access(all) let from: Address?
        access(all) let to: Address?
        access(all) let description: String
        access(all) let timestamp: UFix64

        init(
            id: UInt64,
            type: String,
            amount: UFix64,
            from: Address?,
            to: Address?,
            description: String
        ) {
            self.id = id
            self.type = type
            self.amount = amount
            self.from = from
            self.to = to
            self.description = description
            self.timestamp = getCurrentBlock().timestamp
        }
    }

    /// TreasuryAdmin
    ///
    /// Resource for treasury administration
    ///
    access(all) resource TreasuryAdmin {

        /// withdraw
        ///
        /// Withdraw funds from treasury for approved purposes
        ///
        access(all) fun withdraw(amount: UFix64, recipient: Address, purpose: String): @GToken.Vault {
            pre {
                amount > 0.0: "Amount must be greater than zero"
            }

            let treasuryVault = Treasury.account.storage.borrow<auth(FungibleToken.Withdraw) &GToken.Vault>(
                from: Treasury.TreasuryVaultStoragePath
            ) ?? panic("Could not borrow treasury vault")

            // Check balance without calling view function in precondition
            assert(amount <= treasuryVault.balance, message: "Insufficient treasury balance")

            let tokens <- treasuryVault.withdraw(amount: amount) as! @GToken.Vault

            Treasury.totalDistributed = Treasury.totalDistributed + amount

            // Record transaction
            let record = TransactionRecord(
                id: Treasury.transactionCounter,
                type: "withdrawal",
                amount: amount,
                from: Treasury.account.address,
                to: recipient,
                description: purpose
            )
            Treasury.transactions.append(record)
            Treasury.transactionCounter = Treasury.transactionCounter + 1

            emit TreasuryWithdrawal(amount: amount, to: recipient, purpose: purpose, timestamp: getCurrentBlock().timestamp)

            return <- tokens
        }

        /// depositToTreasury
        ///
        /// Admin can deposit funds directly to treasury
        ///
        access(all) fun depositToTreasury(from: @{FungibleToken.Vault}) {
            let amount = from.balance
            let treasuryVault = Treasury.account.storage.borrow<&GToken.Vault>(
                from: Treasury.TreasuryVaultStoragePath
            ) ?? panic("Could not borrow treasury vault")

            treasuryVault.deposit(from: <-from)

            Treasury.totalCollected = Treasury.totalCollected + amount

            // Record transaction
            let record = TransactionRecord(
                id: Treasury.transactionCounter,
                type: "deposit",
                amount: amount,
                from: nil,
                to: Treasury.account.address,
                description: "Direct deposit to treasury"
            )
            Treasury.transactions.append(record)
            Treasury.transactionCounter = Treasury.transactionCounter + 1

            emit TreasuryDeposit(amount: amount, from: nil, timestamp: getCurrentBlock().timestamp)
        }
    }

    /// collectRentalFee
    ///
    /// Collect rental fee and distribute between treasury and creator
    /// 10% goes to treasury, 90% goes to creator
    ///
    access(all) fun collectRentalFee(
        payment: @{FungibleToken.Vault},
        movieId: String,
        creator: Address,
        renter: Address
    ): @{FungibleToken.Vault} {
        pre {
            GTokenDAO.isCreatorVerified(creator: creator): "Creator must be verified"
        }

        let totalAmount = payment.balance
        let treasuryAmount = totalAmount * self.treasuryPercentage
        let creatorAmount = totalAmount - treasuryAmount

        // Split the payment
        let treasuryVault = self.account.storage.borrow<&GToken.Vault>(
            from: self.TreasuryVaultStoragePath
        ) ?? panic("Could not borrow treasury vault")

        let treasuryPayment <- payment.withdraw(amount: treasuryAmount)
        treasuryVault.deposit(from: <-treasuryPayment)

        self.totalCollected = self.totalCollected + treasuryAmount

        // Record transaction
        let record = TransactionRecord(
            id: self.transactionCounter,
            type: "rental",
            amount: treasuryAmount,
            from: renter,
            to: self.account.address,
            description: "Rental fee for movie: ".concat(movieId)
        )
        self.transactions.append(record)
        self.transactionCounter = self.transactionCounter + 1

        emit RentalFeeCollected(
            amount: totalAmount,
            movieId: movieId,
            renter: renter,
            timestamp: getCurrentBlock().timestamp
        )

        emit RevenueDistributed(
            totalAmount: totalAmount,
            treasuryAmount: treasuryAmount,
            creatorAmount: creatorAmount,
            creator: creator,
            timestamp: getCurrentBlock().timestamp
        )

        // Return the creator's portion
        return <- payment
    }

    /// Public Functions

    /// getTreasuryBalance
    ///
    /// Get current treasury balance
    ///
    access(all) view fun getTreasuryBalance(): UFix64 {
        let treasuryVault = self.account.storage.borrow<&GToken.Vault>(
            from: self.TreasuryVaultStoragePath
        ) ?? panic("Could not borrow treasury vault")

        return treasuryVault.balance
    }

    /// getTreasuryStats
    ///
    /// Get treasury statistics
    ///


    /// getTransactionHistory
    ///
    /// Get transaction history (limited to most recent)
    ///
    access(all) view fun getTransactionHistory(limit: Int): [TransactionRecord] {
        let length = self.transactions.length
        if length == 0 {
            return []
        }

        let startIndex = length > limit ? length - limit : 0
        return self.transactions.slice(from: startIndex, upTo: length)
    }

    /// getTreasuryPercentage
    ///
    /// Get treasury percentage
    ///
    access(all) view fun getTreasuryPercentage(): UFix64 {
        return self.treasuryPercentage
    }

    /// getTransaction
    ///
    /// Get a specific transaction by ID
    ///
    access(all) view fun getTransaction(id: UInt64): TransactionRecord? {
        if id >= UInt64(self.transactions.length) {
            return nil
        }
        return self.transactions[id]
    }

    /// getTotalTransactions
    ///
    /// Get total number of transactions
    ///
    access(all) view fun getTotalTransactions(): UInt64 {
        return self.transactionCounter
    }

    /// createTreasuryAdmin
    ///
    /// Create a new TreasuryAdmin resource
    ///
    access(all) fun createTreasuryAdmin(): @TreasuryAdmin {
        return <- create TreasuryAdmin()
    }

    init() {
        self.totalCollected = 0.0
        self.totalDistributed = 0.0
        self.transactionCounter = 0
        self.transactions = []
        self.treasuryPercentage = 0.10 // 10%

        self.TreasuryVaultStoragePath = /storage/FlowReelTreasuryVault
        self.TreasuryAdminStoragePath = /storage/FlowReelTreasuryAdmin

        // Create and save treasury vault
        let treasuryVault <- GToken.createEmptyVault(vaultType: Type<@GToken.Vault>())
        self.account.storage.save(<-treasuryVault, to: self.TreasuryVaultStoragePath)

        // Create and save treasury admin
        let admin <- create TreasuryAdmin()
        self.account.storage.save(<-admin, to: self.TreasuryAdminStoragePath)
    }
}