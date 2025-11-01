import "FungibleToken"
import "NonFungibleToken"
import GToken from "../core/GToken.cdc"
import ProposalTypes from "../structs/ProposalTypes.cdc"

/// GTokenDAO
///
/// Main DAO contract for FlowReel governance
/// Manages proposals, voting, and DAO operations
///
access(all) contract GTokenDAO {
    
    /// Storage
    access(contract) var proposals: [Proposal]
    access(contract) var votedRecords: [{Address: Int}]
    access(contract) var totalProposals: Int
    access(all) var tokensForProposal: UFix64

    /// Creator Verification Storage
    access(contract) var verifiedCreators: {Address: CreatorProfile}
    access(contract) var pendingCreatorApplications: {Address: CreatorApplication}
    access(contract) var creatorVerificationProposals: {Int: Address}

    /// Paths
    access(all) let ProposerStoragePath: StoragePath
    access(all) let VoterStoragePath: StoragePath
    access(all) let VoterPublicPath: PublicPath
    access(all) let AdminStoragePath: StoragePath

    /// Events
    access(all) event ContractInitialized()
    access(all) event ProposalCreated(Title: String, Proposer: Address, MinHoldedGVTAmount: UFix64?)
    access(all) event VoteSubmitted(Voter: Address, ProposalId: Int, OptionIndex: Int)
    
    /// Creator Verification Events
    access(all) event CreatorApplicationSubmitted(applicant: Address, timestamp: UFix64)
    access(all) event CreatorVerificationProposalCreated(proposalId: Int, applicant: Address)
    access(all) event CreatorVerified(creator: Address, timestamp: UFix64)
    access(all) event CreatorRejected(creator: Address, timestamp: UFix64)
    access(all) event CreatorRevoked(creator: Address, timestamp: UFix64)

    /// CreatorProfile
    ///
    /// Struct containing verified creator information
    ///
    access(all) struct CreatorProfile {
        access(all) let address: Address
        access(all) let name: String 
        access(all) let portfolioUrl: String
        access(all) let verifiedAt: UFix64
        access(all) var isActive: Bool

        init(address: Address, name: String, portfolioUrl: String) {
            self.address = address
            self.portfolioUrl = portfolioUrl
            self.name = name
            self.verifiedAt = getCurrentBlock().timestamp
            self.isActive = true
        }

        access(all) fun deactivate() {
            self.isActive = false
        }
    }

    /// CreatorApplication
    ///
    /// Struct for pending creator applications
    ///
    access(all) struct CreatorApplication {
        access(all) let applicant: Address
        access(all) let name: String
        access(all) let portfolioUrl: String
        access(all) let appliedAt: UFix64

        init(applicant: Address, name: String, portfolioUrl: String) {
            self.applicant = applicant
            self.name = name
            self.portfolioUrl = portfolioUrl
            self.appliedAt = getCurrentBlock().timestamp
        }
    }

    /// Proposer
    ///
    /// Resource object that can create new proposals
    ///
    access(all) resource Proposer {

        /// addProposal
        ///
        /// Function that creates new proposals
        ///
        access(all) fun addProposal(
            title: String,
            description: String,
            options: [String],
            startAt: UFix64?,
            endAt: UFix64?,
            minHoldedGVTAmount: UFix64?
        ) {
            // Validate proposer has enough tokens
            let proposerGVT = GTokenDAO.getHoldedGVT(address: self.owner!.address)
            assert(proposerGVT >= GTokenDAO.tokensForProposal, message: "Proposer doesn't have enough GVT")

            GTokenDAO.proposals.append(Proposal(
                proposer: self.owner!.address,
                title: title,
                description: description,
                options: options,
                startAt: startAt,
                endAt: endAt,
                minHoldedGVTAmount: minHoldedGVTAmount,
                proposalType: ProposalTypes.ProposalType.General
            ))

            GTokenDAO.votedRecords.append({})
            GTokenDAO.totalProposals = GTokenDAO.totalProposals + 1
        }

        /// addCreatorVerificationProposal
        ///
        /// Create a proposal for creator verification
        ///
        access(all) fun addCreatorVerificationProposal(
            applicantAddress: Address,
            startAt: UFix64?,
            endAt: UFix64?,
            minHoldedGVTAmount: UFix64?
        ) {
            pre {
                GTokenDAO.pendingCreatorApplications[applicantAddress] != nil: "No pending application for this address"
                GTokenDAO.verifiedCreators[applicantAddress] == nil: "Creator already verified"
            }

            let proposerGVT = GTokenDAO.getHoldedGVT(address: self.owner!.address)
            assert(proposerGVT >= GTokenDAO.tokensForProposal, message: "Proposer doesn't have enough GVT")

            let application = GTokenDAO.pendingCreatorApplications[applicantAddress]!
            let title = "Creator Verification: ".concat(application.name)
            let description = "Verify ".concat(application.name).concat(" as a content creator.\n\n")
                .concat("Portfolio: ").concat(application.portfolioUrl)

            let proposalId = GTokenDAO.totalProposals
            GTokenDAO.proposals.append(Proposal(
                proposer: self.owner!.address,
                title: title,
                description: description,
                options: ["Approve", "Reject"],
                startAt: startAt,
                endAt: endAt,
                minHoldedGVTAmount: minHoldedGVTAmount,
                proposalType: ProposalTypes.ProposalType.CreatorVerification
            ))

            GTokenDAO.votedRecords.append({})
            GTokenDAO.creatorVerificationProposals[proposalId] = applicantAddress
            GTokenDAO.totalProposals = GTokenDAO.totalProposals + 1
            
            emit CreatorVerificationProposalCreated(proposalId: proposalId, applicant: applicantAddress)
        }

        /// updateProposal
        ///
        /// Function to update an existing proposal
        ///
        access(all) fun updateProposal(
            id: Int,
            title: String?,
            description: String?,
            startAt: UFix64?,
            endAt: UFix64?,
            voided: Bool?
        ) {
            pre {
                GTokenDAO.proposals[id].proposer == self.owner!.address: "Only original proposer can update"
            }

            GTokenDAO.proposals[id].update(
                title: title,
                description: description,
                startAt: startAt,
                endAt: endAt,
                voided: voided
            )
        }
    }

    /// Administrator
    ///
    /// Resource for admin operations
    ///
    access(all) resource Administrator {
        
        /// verifyCreatorDirectly
        ///
        /// Admin can verify a creator without DAO vote
        ///
        access(all) fun verifyCreatorDirectly(applicantAddress: Address) {
            pre {
                GTokenDAO.pendingCreatorApplications[applicantAddress] != nil: "No pending application"
                GTokenDAO.verifiedCreators[applicantAddress] == nil: "Already verified"
            }

            let application = GTokenDAO.pendingCreatorApplications[applicantAddress]!
            
            let profile = CreatorProfile(
                address: applicantAddress,
                name: application.name,
                portfolioUrl: application.portfolioUrl
            )

            GTokenDAO.verifiedCreators[applicantAddress] = profile
            GTokenDAO.pendingCreatorApplications.remove(key: applicantAddress)

            emit CreatorVerified(creator: applicantAddress, timestamp: getCurrentBlock().timestamp)
        }

        /// revokeCreator
        ///
        /// Admin can revoke creator status
        ///
        access(all) fun revokeCreator(creatorAddress: Address) {
            pre {
                GTokenDAO.verifiedCreators[creatorAddress] != nil: "Creator not verified"
            }

            GTokenDAO.verifiedCreators[creatorAddress]?.deactivate()
            emit CreatorRevoked(creator: creatorAddress, timestamp: getCurrentBlock().timestamp)
        }

        /// rejectApplication
        ///
        /// Admin can reject a pending application
        ///
        access(all) fun rejectApplication(applicantAddress: Address) {
            pre {
                GTokenDAO.pendingCreatorApplications[applicantAddress] != nil: "No pending application"
            }

            GTokenDAO.pendingCreatorApplications.remove(key: applicantAddress)
            emit CreatorRejected(creator: applicantAddress, timestamp: getCurrentBlock().timestamp)
        }
    }

    /// VoterPublic
    ///
    /// Public interface for Voter resource
    ///
    access(all) resource interface VoterPublic {
        access(all) fun getVotedOption(proposalId: UInt64): Int?
        access(all) fun getVotedOptions(): {UInt64: Int}
    }

    /// Voter
    ///
    /// Resource holder can vote on proposals
    ///
    access(all) resource Voter: VoterPublic {
        access(self) var records: {UInt64: Int}

        /// vote
        ///
        /// Function to submit a vote on a proposal
        ///
        access(all) fun vote(proposalId: UInt64, optionIndex: Int) {
            pre {
                self.records[proposalId] == nil: "Already voted"
                Int(proposalId) < GTokenDAO.proposals.length: "Invalid proposal ID"
                optionIndex < GTokenDAO.proposals[proposalId].options.length: "Invalid option"
            }

            let voterAddr = self.owner!.address
            let proposal = GTokenDAO.proposals[proposalId]
            
            assert(proposal.isStarted(), message: "Vote not started")
            assert(!proposal.isEnded(), message: "Vote ended")
            
            let voterGVT = GTokenDAO.getHoldedGVT(address: voterAddr)
            assert(voterGVT >= proposal.minHoldedGVTAmount, message: "Not enough GVT in your Vault to vote")
            
            GTokenDAO.proposals[proposalId].vote(voterAddr: voterAddr, optionIndex: optionIndex)
            self.records[proposalId] = optionIndex
        }

        access(all) fun getVotedOption(proposalId: UInt64): Int? {
            return self.records[proposalId]
        }

        access(all) fun getVotedOptions(): {UInt64: Int} {
            return self.records
        }

        init() {
            self.records = {}
        }
    }

    /// Proposal
    ///
    /// Struct representing a governance proposal
    ///
    access(all) struct Proposal {
        access(all) let id: Int
        access(all) let proposer: Address
        access(all) var title: String
        access(all) var description: String
        access(all) var options: [String]
        access(all) let proposalType: ProposalTypes.ProposalType
        access(all) var votesCountActual: [UInt64]
        access(all) let createdAt: UFix64
        access(all) var updatedAt: UFix64
        access(all) var startAt: UFix64
        access(all) var endAt: UFix64
        access(all) var sealed: Bool
        access(all) var countIndex: Int
        access(all) var voided: Bool
        access(all) let minHoldedGVTAmount: UFix64
        access(all) var executed: Bool

        init(
            proposer: Address,
            title: String,
            description: String,
            options: [String],
            startAt: UFix64?,
            endAt: UFix64?,
            minHoldedGVTAmount: UFix64?,
            proposalType: ProposalTypes.ProposalType
        ) {
            pre {
                title.length <= 1000: "New title too long"
                description.length <= 1000: "New description too long"
            }

            self.proposer = proposer
            self.title = title
            self.options = options
            self.description = description
            self.votesCountActual = []
            self.minHoldedGVTAmount = minHoldedGVTAmount ?? 0.0
            self.proposalType = proposalType

            for option in options {
                self.votesCountActual.append(0)
            }

            self.id = GTokenDAO.totalProposals
            self.sealed = false
            self.countIndex = 0
            self.executed = false

            self.createdAt = getCurrentBlock().timestamp
            self.updatedAt = getCurrentBlock().timestamp
            self.startAt = startAt ?? getCurrentBlock().timestamp
            self.endAt = endAt ?? (self.createdAt + 86400.0 * 14.0) // 14 days default
            self.voided = false

            emit ProposalCreated(Title: title, Proposer: proposer, MinHoldedGVTAmount: minHoldedGVTAmount)
        }

        /// update
        ///
        /// Function to update proposal details
        ///
        access(all) fun update(
            title: String?,
            description: String?,
            startAt: UFix64?,
            endAt: UFix64?,
            voided: Bool?
        ) {
            pre {
                title?.length ?? 0 <= 1000: "Title too long"
                description?.length ?? 0 <= 1000: "Description too long"
                getCurrentBlock().timestamp < self.startAt: "Can't update after started"
            }

            self.title = title ?? self.title
            self.description = description ?? self.description
            self.endAt = endAt ?? self.endAt
            self.startAt = startAt ?? self.startAt
            self.voided = voided ?? self.voided
            self.updatedAt = getCurrentBlock().timestamp
        }

        /// vote
        ///
        /// Function to record a vote
        ///
        access(all) fun vote(voterAddr: Address, optionIndex: Int) {
            pre {
                GTokenDAO.votedRecords[self.id][voterAddr] == nil: "Already voted"
            }

            GTokenDAO.votedRecords[self.id][voterAddr] = optionIndex
            emit VoteSubmitted(Voter: voterAddr, ProposalId: self.id, OptionIndex: optionIndex)
        }

        /// count
        ///
        /// Function to count votes in batches
        ///
        access(all) fun count(size: Int): [UInt64] {
            if self.isEnded() == false {
                return self.votesCountActual
            }
            if self.sealed {
                return self.votesCountActual
            }
            
            let votedList = GTokenDAO.votedRecords[self.id].keys
            var batchEnd = self.countIndex + size
            
            if batchEnd > votedList.length {
                batchEnd = votedList.length
            }

            while self.countIndex != batchEnd {
                let address = votedList[self.countIndex]
                let votedOptionIndex = GTokenDAO.votedRecords[self.id][address]!
                self.votesCountActual[votedOptionIndex] = self.votesCountActual[votedOptionIndex] + 1
                self.countIndex = self.countIndex + 1
            }

            self.sealed = self.countIndex == votedList.length
            return self.votesCountActual
        }

        access(all) fun isEnded(): Bool {
            return getCurrentBlock().timestamp >= self.endAt
        }

        access(all) fun isStarted(): Bool {
            return getCurrentBlock().timestamp >= self.startAt
        }

        access(all) fun getTotalVoted(): Int {
            return GTokenDAO.votedRecords[self.id].keys.length
        }

        access(all) fun getWinningOption(): Int? {
            if !self.sealed {
                return nil
            }

            var maxVotes: UInt64 = 0
            var winningIndex: Int = 0

            for i, votes in self.votesCountActual {
                if votes > maxVotes {
                    maxVotes = votes
                    winningIndex = i
                }
            }

            return winningIndex
        }

        access(all) fun markExecuted() {
            self.executed = true
        }
    }

    /// submitCreatorApplication
    ///
    /// Submit an application for creator verification
    ///
    access(all) fun submitCreatorApplication(
        applicant: Address,
        name: String,
        bio: String,
        portfolioUrl: String,
        sampleWorkUrl: String?
    ) {
        pre {
            self.verifiedCreators[applicant] == nil: "Already verified"
            self.pendingCreatorApplications[applicant] == nil: "Application already pending"
            name.length > 0 && name.length <= 100: "Name must be 1-100 characters"
            bio.length > 0 && bio.length <= 500: "Bio must be 1-500 characters"
        }

        let application = CreatorApplication(
            applicant: applicant,
            name: name,
            portfolioUrl: portfolioUrl
        )

        self.pendingCreatorApplications[applicant] = application
        emit CreatorApplicationSubmitted(applicant: applicant, timestamp: getCurrentBlock().timestamp)
    }

    /// executeCreatorVerification
    ///
    /// Execute a creator verification proposal after voting ends
    ///
    access(all) fun executeCreatorVerification(proposalId: Int) {
        pre {
            proposalId < self.proposals.length: "Invalid proposal ID"
            self.proposals[proposalId].proposalType == ProposalTypes.ProposalType.CreatorVerification: "Not a creator verification proposal"
            self.proposals[proposalId].sealed: "Proposal not sealed yet"
            !self.proposals[proposalId].executed: "Already executed"
            self.creatorVerificationProposals[proposalId] != nil: "No creator linked to this proposal"
        }

        assert(getCurrentBlock().timestamp >= self.proposals[proposalId].endAt, message: "Voting not ended")

        let proposal = self.proposals[proposalId]
        let applicantAddress = self.creatorVerificationProposals[proposalId]!
        let winningOption = proposal.getWinningOption()!

        // Option 0 = Approve, Option 1 = Reject
        if winningOption == 0 {
            let application = self.pendingCreatorApplications[applicantAddress]!
            
            let profile = CreatorProfile(
                address: applicantAddress,
                name: application.name,
                portfolioUrl: application.portfolioUrl
            )

            self.verifiedCreators[applicantAddress] = profile
            self.pendingCreatorApplications.remove(key: applicantAddress)

            emit CreatorVerified(creator: applicantAddress, timestamp: getCurrentBlock().timestamp)
        } else {
            self.pendingCreatorApplications.remove(key: applicantAddress)
            emit CreatorRejected(creator: applicantAddress, timestamp: getCurrentBlock().timestamp)
        }

        self.proposals[proposalId].markExecuted()
    }

    /// Public Functions
    
    access(all) view fun isCreatorVerified(creator: Address): Bool {
        if let profile = self.verifiedCreators[creator] {
            return profile.isActive
        }
        return false
    }

    access(all) fun getCreatorProfile(creator: Address): CreatorProfile? {
        return self.verifiedCreators[creator]
    }

    access(all) fun getPendingApplication(applicant: Address): CreatorApplication? {
        return self.pendingCreatorApplications[applicant]
    }

    access(all) fun getAllVerifiedCreators(): [Address] {
        return self.verifiedCreators.keys
    }

    access(all) fun getAllPendingApplications(): [Address] {
        return self.pendingCreatorApplications.keys
    }

    access(all) view fun getHoldedGVT(address: Address): UFix64 {
        let acct = getAccount(address)
        let vaultRef = acct.capabilities.borrow<&{FungibleToken.Balance}>(GToken.VaultPublicPath)
            ?? panic("Could not borrow Balance reference to the Vault")
        return vaultRef.balance
    }

    access(all) fun getProposals(): [Proposal] {
        return self.proposals
    }

    access(all) fun getProposalsLength(): Int {
        return self.proposals.length
    }

    access(all) fun getProposal(id: UInt64): Proposal {
        return self.proposals[id]
    }

    access(all) fun count(proposalId: UInt64, maxSize: Int): [UInt64] {
        return self.proposals[proposalId].count(size: maxSize)
    }

    access(all) fun getVotedRecords(): [{Address: Int}] {
        return self.votedRecords
    }

    access(all) fun claimProposer(): @GTokenDAO.Proposer {
        return <-create Proposer()
    }

    access(all) fun initVoter(): @GTokenDAO.Voter {
        return <-create Voter()
    }

    access(all) fun claimAdmin(): @GTokenDAO.Administrator {
        return <-create Administrator()
    }

    init() {
        self.proposals = []
        self.votedRecords = []
        self.totalProposals = 0
        self.tokensForProposal = 10.0

        self.verifiedCreators = {}
        self.pendingCreatorApplications = {}
        self.creatorVerificationProposals = {}
    
        self.ProposerStoragePath = /storage/GTokenDAOProposer
        self.VoterStoragePath = /storage/GTokenDAOVoter
        self.VoterPublicPath = /public/GTokenDAOVoter
        self.AdminStoragePath = /storage/GTokenDAOAdmin

        self.account.storage.save(<-create Proposer(), to: self.ProposerStoragePath)
        self.account.storage.save(<-create Voter(), to: self.VoterStoragePath)
        self.account.storage.save(<-create Administrator(), to: self.AdminStoragePath)
        
        let voterCap = self.account.capabilities.storage.issue<&GTokenDAO.Voter>(
            self.VoterStoragePath
        )
        self.account.capabilities.publish(voterCap, at: self.VoterPublicPath)

        emit ContractInitialized()
    }
}