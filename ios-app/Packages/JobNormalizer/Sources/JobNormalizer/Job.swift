import Foundation

// MARK: - Swipe Action

public enum SwipeAction: String, Codable, Sendable {
    case interested
    case pass
    case save
    case applied
}

// MARK: - Thompson Score

public struct ThompsonScore: Codable, Equatable, Sendable {
    /// Amber/teal sample blend — the exploration signal from Beta arm history
    public let personalScore: Double
    /// Weighted sum of the 5 professional components × 0.92 scale factor
    public let professionalScore: Double
    /// Final combined score: professionalScore + personalScore × 0.08
    public let combinedScore: Double
    public let explorationBonus: Double
    public let timestamp: Date

    public init(
        personalScore: Double,
        professionalScore: Double,
        combinedScore: Double,
        explorationBonus: Double = 0,
        timestamp: Date = Date()
    ) {
        self.personalScore = personalScore
        self.professionalScore = professionalScore
        self.combinedScore = combinedScore
        self.explorationBonus = explorationBonus
        self.timestamp = timestamp
    }
}

// MARK: - Job

/// Single source of truth flowing through: API response → JobNormalizer → ScoringEngine → DeckUI
public struct Job: Identifiable, Sendable {
    public let id: UUID
    public let title: String
    public let company: String
    public let location: String
    public let description: String
    /// All requirements/skills combined — used as the primary input for skills matching
    public let requirements: [String]
    public let url: URL
    public let sector: String

    // O*NET
    public let onetCode: String?
    public let riasecProfile: RIASECProfile?
    /// O*NET work activities: activityId → importance score (0–7)
    public let workActivities: [String: Double]?

    // Display metadata
    public let benefits: [String]
    public let jobType: String?
    public let experienceLevel: String?
    public let postedDate: Date?
    public let isRemote: Bool
    public let salary: String?
    public let requiredSkills: [String]
    public let preferredSkills: [String]
    public let experienceYears: String?

    // Location
    public let workLocationType: WorkLocationType
    public let jobLocationData: JobLocationData?

    // Scoring — set by ScoringEngine, mutable
    public var thompsonScore: ThompsonScore?
    public var matchScore: Double
    public var cachedSkillsScore: Double?

    public init(
        id: UUID = UUID(),
        title: String,
        company: String,
        location: String = "Remote",
        description: String = "",
        requirements: [String] = [],
        url: URL? = nil,
        sector: String = "Technology",
        onetCode: String? = nil,
        riasecProfile: RIASECProfile? = nil,
        workActivities: [String: Double]? = nil,
        benefits: [String] = [],
        jobType: String? = nil,
        experienceLevel: String? = nil,
        postedDate: Date? = nil,
        isRemote: Bool = false,
        salary: String? = nil,
        requiredSkills: [String] = [],
        preferredSkills: [String] = [],
        experienceYears: String? = nil,
        workLocationType: WorkLocationType = .remote,
        jobLocationData: JobLocationData? = nil,
        thompsonScore: ThompsonScore? = nil,
        matchScore: Double = 0.5,
        cachedSkillsScore: Double? = nil
    ) {
        self.id = id
        self.title = title
        self.company = company
        self.location = location
        self.description = description
        self.requirements = requirements
        self.url = url ?? URL(string: "https://example.com")!
        self.sector = sector
        self.onetCode = onetCode
        self.riasecProfile = riasecProfile
        self.workActivities = workActivities
        self.benefits = benefits
        self.jobType = jobType
        self.experienceLevel = experienceLevel
        self.postedDate = postedDate
        self.isRemote = isRemote
        self.salary = salary
        self.requiredSkills = requiredSkills
        self.preferredSkills = preferredSkills
        self.experienceYears = experienceYears
        self.workLocationType = workLocationType
        self.jobLocationData = jobLocationData
        self.thompsonScore = thompsonScore
        self.matchScore = matchScore
        self.cachedSkillsScore = cachedSkillsScore
    }
}
