/// ICreatorRegistry
///
/// Interface for creator registry management
///
access(all) contract interface ICreatorRegistry {

    /// Events
    access(all) event CreatorApplicationSubmitted(applicant: Address, timestamp: UFix64)
    access(all) event CreatorVerificationProposalCreated(proposalId: Int, applicant: Address)
    access(all) event CreatorVerified(creator: Address, timestamp: UFix64)
    access(all) event CreatorRejected(creator: Address, timestamp: UFix64)
    access(all) event CreatorRevoked(creator: Address, timestamp: UFix64)

    /// Submit a creator application
    access(all) fun submitCreatorApplication(
        applicant: Address,
        name: String,
        bio: String,
        portfolioUrl: String,
        sampleWorkUrl: String?
    )

    /// Check if an address is a verified and active creator
    access(all) view fun isCreatorVerified(creator: Address): Bool

    /// Get a creator's profile if verified
    /// Returns dictionary with keys: address, name, portfolioUrl, verifiedAt, isActive
    access(all) fun getCreatorProfile(creator: Address): {String: AnyStruct}?

    /// Get a pending creator application
    /// Returns dictionary with keys: applicant, name, portfolioUrl, appliedAt
    access(all) fun getPendingApplication(applicant: Address): {String: AnyStruct}?

    /// Get all verified creator addresses
    access(all) fun getAllVerifiedCreators(): [Address]

    /// Get all pending application addresses
    access(all) fun getAllPendingApplications(): [Address]
}