access(all) contract ProposalTypes {
    access(all) enum ProposalType: UInt8 {
        access(all) case General
        access(all) case CreatorVerification
        access(all) case CreatorRevocation
        access(all) case TreasuryAllocation
        access(all) case LoanApproval
        access(all) case ParameterChange
    }

    access(all) enum ProposalStatus: UInt8 {
        access(all) case Pending
        access(all) case Active
        access(all) case Passed
        access(all) case Rejected
        access(all) case Executed
        access(all) case Voided
    }

    /// BaseProposal
    ///
    /// Base struct containing common proposal fields
    ///
    access(all) struct BaseProposal {
        access(all) let id: Int
        access(all) let proposer: Address
        access(all) var title: String
        access(all) var description: String
        access(all) let proposalType: ProposalType
        access(all) let createdAt: UFix64
        access(all) var updatedAt: UFix64
        access(all) var startAt: UFix64
        access(all) var endAt: UFix64
        access(all) var voided: Bool
        access(all) let minHoldedGVTAmount: UFix64
        access(all) var executed: Bool

        init(
            id: Int,
            proposer: Address,
            title: String,
            description: String,
            proposalType: ProposalType,
            startAt: UFix64?,
            endAt: UFix64?,
            minHoldedGVTAmount: UFix64?
        ) {
            pre {
                title.length <= 1000: "Title too long"
                description.length <= 1000: "Description too long"
            }

            self.id = id
            self.proposer = proposer
            self.title = title
            self.description = description
            self.proposalType = proposalType
            self.minHoldedGVTAmount = minHoldedGVTAmount ?? 0.0
            
            self.createdAt = getCurrentBlock().timestamp
            self.updatedAt = getCurrentBlock().timestamp
            self.startAt = startAt ?? getCurrentBlock().timestamp
            self.endAt = endAt ?? (self.createdAt + 86400.0 * 14.0) // 14 days default
            
            self.voided = false
            self.executed = false
        }
    }

    /// VotingRecord
    ///
    /// Struct to track voting information
    ///
    access(all) struct VotingRecord {
        access(all) let proposalId: Int
        access(all) let voter: Address
        access(all) let optionIndex: Int
        access(all) let votingPower: UFix64
        access(all) let timestamp: UFix64

        init(proposalId: Int, voter: Address, optionIndex: Int, votingPower: UFix64) {
            self.proposalId = proposalId
            self.voter = voter
            self.optionIndex = optionIndex
            self.votingPower = votingPower
            self.timestamp = getCurrentBlock().timestamp
        }
    }

    /// ProposalResult
    ///
    /// Struct containing the results of a proposal
    ///
    access(all) struct ProposalResult {
        access(all) let proposalId: Int
        access(all) let options: [String]
        access(all) let voteCounts: [UInt64]
        access(all) let totalVotes: Int
        access(all) let winningOption: Int?
        access(all) let sealed: Bool

        init(
            proposalId: Int,
            options: [String],
            voteCounts: [UInt64],
            totalVotes: Int,
            winningOption: Int?,
            sealed: Bool
        ) {
            self.proposalId = proposalId
            self.options = options
            self.voteCounts = voteCounts
            self.totalVotes = totalVotes
            self.winningOption = winningOption
            self.sealed = sealed
        }
    }

    init() {}
}