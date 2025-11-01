/// TreasuryStructs
///
/// Contains common structs used by treasury contracts
///
access(all) contract TreasuryStructs {

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
            treasuryPercentage: UFix64
        ) {
            self.totalCollected = totalCollected
            self.totalDistributed = totalDistributed
            self.currentBalance = currentBalance
            self.treasuryPercentage = treasuryPercentage
            self.lastUpdated = getCurrentBlock().timestamp
        }
    }

    /// TransactionRecord
    ///
    /// Struct for recording treasury transactions
    ///
    access(all) struct TransactionRecord {
        access(all) let id: UInt64
        access(all) let type: String // "deposit", "withdrawal", "rental", "distribution"
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
}