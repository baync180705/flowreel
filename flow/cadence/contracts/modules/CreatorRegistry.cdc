import GTokenDAO from "../core/GTokenDAO.cdc"

/// CreatorRegistry
///
/// Module for managing creator verification and registry
/// Works in conjunction with GTokenDAO for verification workflow
///
access(all) contract CreatorRegistry {

    /// Storage
    access(contract) var creatorMetadata: {Address: CreatorMetadata}
    access(contract) var creatorsByCategory: {String: [Address]}
    access(contract) var totalCreators: UInt64

    /// Paths
    access(all) let RegistryAdminStoragePath: StoragePath

    /// Events
    access(all) event CreatorMetadataUpdated(creator: Address, timestamp: UFix64)
    access(all) event CreatorCategoryAdded(creator: Address, category: String, timestamp: UFix64)
    access(all) event CreatorCategoryRemoved(creator: Address, category: String, timestamp: UFix64)
    access(all) event CreatorFeatured(creator: Address, timestamp: UFix64)
    access(all) event CreatorUnfeatured(creator: Address, timestamp: UFix64)

    /// CreatorMetadata
    ///
    /// Extended metadata for verified creators
    ///
    access(all) struct CreatorMetadata {
        access(all) let creator: Address
        access(all) var bio: String
        access(all) var categories: [String] // e.g., "documentary", "short-film", "animation"
        access(all) var socialLinks: {String: String}
        access(all) var contentCount: UInt64
        access(all) var totalViews: UInt64
        access(all) var totalRevenue: UFix64
        access(all) var isFeatured: Bool
        access(all) let registeredAt: UFix64
        access(all) var lastUpdated: UFix64

        init(creator: Address, bio: String, categories: [String]) {
            self.creator = creator
            self.bio = bio
            self.categories = categories
            self.socialLinks = {}
            self.contentCount = 0
            self.totalViews = 0
            self.totalRevenue = 0.0
            self.isFeatured = false
            self.registeredAt = getCurrentBlock().timestamp
            self.lastUpdated = getCurrentBlock().timestamp
        }

        access(all) fun updateBio(newBio: String) {
            self.bio = newBio
            self.lastUpdated = getCurrentBlock().timestamp
        }

        access(all) fun addCategory(category: String) {
            if !self.categories.contains(category) {
                self.categories.append(category)
                self.lastUpdated = getCurrentBlock().timestamp
            }
        }

        access(all) fun removeCategory(category: String) {
            var i = 0
            while i < self.categories.length {
                if self.categories[i] == category {
                    self.categories.remove(at: i)
                    self.lastUpdated = getCurrentBlock().timestamp
                    break
                }
                i = i + 1
            }
        }

        access(all) fun addSocialLink(platform: String, url: String) {
            self.socialLinks[platform] = url
            self.lastUpdated = getCurrentBlock().timestamp
        }

        access(all) fun incrementContentCount() {
            self.contentCount = self.contentCount + 1
            self.lastUpdated = getCurrentBlock().timestamp
        }

        access(all) fun addViews(count: UInt64) {
            self.totalViews = self.totalViews + count
            self.lastUpdated = getCurrentBlock().timestamp
        }

        access(all) fun addRevenue(amount: UFix64) {
            self.totalRevenue = self.totalRevenue + amount
            self.lastUpdated = getCurrentBlock().timestamp
        }

        access(all) fun setFeatured(featured: Bool) {
            self.isFeatured = featured
            self.lastUpdated = getCurrentBlock().timestamp
        }
    }

    /// CreatorStats
    ///
    /// Aggregated statistics for a creator
    ///
    access(all) struct CreatorStats {
        access(all) let creator: Address
        access(all) let isVerified: Bool
        access(all) let contentCount: UInt64
        access(all) let totalViews: UInt64
        access(all) let totalRevenue: UFix64
        access(all) let categories: [String]
        access(all) let isFeatured: Bool
        access(all) let registeredAt: UFix64

        init(
            creator: Address,
            isVerified: Bool,
            contentCount: UInt64,
            totalViews: UInt64,
            totalRevenue: UFix64,
            categories: [String],
            isFeatured: Bool,
            registeredAt: UFix64
        ) {
            self.creator = creator
            self.isVerified = isVerified
            self.contentCount = contentCount
            self.totalViews = totalViews
            self.totalRevenue = totalRevenue
            self.categories = categories
            self.isFeatured = isFeatured
            self.registeredAt = registeredAt
        }
    }

    /// RegistryAdmin
    ///
    /// Resource for registry administration
    ///
    access(all) resource RegistryAdmin {

        /// initializeCreatorMetadata
        ///
        /// Initialize metadata for a newly verified creator
        ///
        access(all) fun initializeCreatorMetadata(
            creator: Address,
            bio: String,
            categories: [String]
        ) {
            pre {
                GTokenDAO.isCreatorVerified(creator: creator): "Creator must be verified first"
                CreatorRegistry.creatorMetadata[creator] == nil: "Metadata already exists"
            }

            let metadata = CreatorMetadata(
                creator: creator,
                bio: bio,
                categories: categories
            )

            CreatorRegistry.creatorMetadata[creator] = metadata
            CreatorRegistry.totalCreators = CreatorRegistry.totalCreators + 1

            // Add to category indices
            for category in categories {
                if CreatorRegistry.creatorsByCategory[category] == nil {
                    CreatorRegistry.creatorsByCategory[category] = []
                }
                CreatorRegistry.creatorsByCategory[category]!.append(creator)
            }

            emit CreatorMetadataUpdated(creator: creator, timestamp: getCurrentBlock().timestamp)
        }

        /// updateCreatorBio
        ///
        /// Update creator's bio
        ///
        access(all) fun updateCreatorBio(creator: Address, newBio: String) {
            pre {
                CreatorRegistry.creatorMetadata[creator] != nil: "Creator metadata not found"
            }

            CreatorRegistry.creatorMetadata[creator]!.updateBio(newBio: newBio)
            emit CreatorMetadataUpdated(creator: creator, timestamp: getCurrentBlock().timestamp)
        }

        /// addCreatorCategory
        ///
        /// Add a category to creator's profile
        ///
        access(all) fun addCreatorCategory(creator: Address, category: String) {
            pre {
                CreatorRegistry.creatorMetadata[creator] != nil: "Creator metadata not found"
            }

            CreatorRegistry.creatorMetadata[creator]!.addCategory(category: category)

            if CreatorRegistry.creatorsByCategory[category] == nil {
                CreatorRegistry.creatorsByCategory[category] = []
            }
            if !CreatorRegistry.creatorsByCategory[category]!.contains(creator) {
                CreatorRegistry.creatorsByCategory[category]!.append(creator)
            }

            emit CreatorCategoryAdded(creator: creator, category: category, timestamp: getCurrentBlock().timestamp)
        }

        /// removeCreatorCategory
        ///
        /// Remove a category from creator's profile
        ///
        access(all) fun removeCreatorCategory(creator: Address, category: String) {
            pre {
                CreatorRegistry.creatorMetadata[creator] != nil: "Creator metadata not found"
            }

            CreatorRegistry.creatorMetadata[creator]!.removeCategory(category: category)

            // Remove from category index
            if let creators = CreatorRegistry.creatorsByCategory[category] {
                var i = 0
                while i < creators.length {
                    if creators[i] == creator {
                        CreatorRegistry.creatorsByCategory[category]!.remove(at: i)
                        break
                    }
                    i = i + 1
                }
            }

            emit CreatorCategoryRemoved(creator: creator, category: category, timestamp: getCurrentBlock().timestamp)
        }

        /// setCreatorFeatured
        ///
        /// Feature or unfeature a creator
        ///
        access(all) fun setCreatorFeatured(creator: Address, featured: Bool) {
            pre {
                CreatorRegistry.creatorMetadata[creator] != nil: "Creator metadata not found"
            }

            CreatorRegistry.creatorMetadata[creator]!.setFeatured(featured: featured)

            if featured {
                emit CreatorFeatured(creator: creator, timestamp: getCurrentBlock().timestamp)
            } else {
                emit CreatorUnfeatured(creator: creator, timestamp: getCurrentBlock().timestamp)
            }
        }

        /// recordContentPublished
        ///
        /// Record when a creator publishes new content
        ///
        access(all) fun recordContentPublished(creator: Address) {
            pre {
                CreatorRegistry.creatorMetadata[creator] != nil: "Creator metadata not found"
            }

            CreatorRegistry.creatorMetadata[creator]!.incrementContentCount()
        }

        /// recordViews
        ///
        /// Record views for a creator's content
        ///
        access(all) fun recordViews(creator: Address, viewCount: UInt64) {
            pre {
                CreatorRegistry.creatorMetadata[creator] != nil: "Creator metadata not found"
            }

            CreatorRegistry.creatorMetadata[creator]!.addViews(count: viewCount)
        }

        /// recordRevenue
        ///
        /// Record revenue earned by a creator
        ///
        access(all) fun recordRevenue(creator: Address, amount: UFix64) {
            pre {
                CreatorRegistry.creatorMetadata[creator] != nil: "Creator metadata not found"
            }

            CreatorRegistry.creatorMetadata[creator]!.addRevenue(amount: amount)
        }
    }

    /// Public Functions

    /// getCreatorMetadata
    ///
    /// Get extended metadata for a creator
    ///
    access(all) fun getCreatorMetadata(creator: Address): CreatorMetadata? {
        return self.creatorMetadata[creator]
    }

    /// getCreatorStats
    ///
    /// Get aggregated stats for a creator
    ///
    access(all) fun getCreatorStats(creator: Address): CreatorStats? {
        let metadata = self.creatorMetadata[creator]
        if metadata == nil {
            return nil
        }

        return CreatorStats(
            creator: creator,
            isVerified: GTokenDAO.isCreatorVerified(creator: creator),
            contentCount: metadata!.contentCount,
            totalViews: metadata!.totalViews,
            totalRevenue: metadata!.totalRevenue,
            categories: metadata!.categories,
            isFeatured: metadata!.isFeatured,
            registeredAt: metadata!.registeredAt
        )
    }

    /// getCreatorsByCategory
    ///
    /// Get all creators in a specific category
    ///
    access(all) fun getCreatorsByCategory(category: String): [Address] {
        return self.creatorsByCategory[category] ?? []
    }

    /// getFeaturedCreators
    ///
    /// Get all featured creators
    ///
    access(all) fun getFeaturedCreators(): [Address] {
        var featured: [Address] = []
        for creator in self.creatorMetadata.keys {
            if self.creatorMetadata[creator]!.isFeatured {
                featured.append(creator)
            }
        }
        return featured
    }

    /// getTotalCreators
    ///
    /// Get total number of registered creators
    ///
    access(all) fun getTotalCreators(): UInt64 {
        return self.totalCreators
    }

    /// getAllCategories
    ///
    /// Get all available categories
    ///
    access(all) fun getAllCategories(): [String] {
        return self.creatorsByCategory.keys
    }

    /// createRegistryAdmin
    ///
    /// Create a new RegistryAdmin resource
    ///
    access(all) fun createRegistryAdmin(): @RegistryAdmin {
        return <- create RegistryAdmin()
    }

    init() {
        self.creatorMetadata = {}
        self.creatorsByCategory = {}
        self.totalCreators = 0

        self.RegistryAdminStoragePath = /storage/FlowReelCreatorRegistryAdmin

        // Create and save registry admin
        let admin <- create RegistryAdmin()
        self.account.storage.save(<-admin, to: self.RegistryAdminStoragePath)
    }
}