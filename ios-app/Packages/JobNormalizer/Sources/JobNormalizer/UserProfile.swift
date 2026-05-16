import Foundation

// MARK: - User Profile

public struct UserProfile: Sendable {
    public let id: UUID
    public var preferences: UserPreferences
    public var professionalProfile: ProfessionalProfile

    public init(
        id: UUID = UUID(),
        preferences: UserPreferences = UserPreferences(),
        professionalProfile: ProfessionalProfile = ProfessionalProfile()
    ) {
        self.id = id
        self.preferences = preferences
        self.professionalProfile = professionalProfile
    }
}

// MARK: - User Preferences

public struct UserPreferences: Sendable {
    public var preferredLocations: [String]
    public var industries: [String]
    /// Job titles the user is targeting — drives title match scoring in Amber mode
    public var desiredRoles: [String]
    public var primaryLocation: LocationData?
    public var remotePreference: WorkLocationType?

    public init(
        preferredLocations: [String] = [],
        industries: [String] = [],
        desiredRoles: [String] = [],
        primaryLocation: LocationData? = nil,
        remotePreference: WorkLocationType? = nil
    ) {
        self.preferredLocations = preferredLocations
        self.industries = industries
        self.desiredRoles = desiredRoles
        self.primaryLocation = primaryLocation
        self.remotePreference = remotePreference
    }
}

// MARK: - Professional Profile

public struct ProfessionalProfile: Sendable {
    /// All skills combined — used as fallback for scoring
    public var skills: [String]
    /// Resume-extracted skills — confidence 1.0
    public var resumeSkills: [String]
    /// O*NET-inferred skills from role selection — confidence 0.7
    public var onetSkills: [String]
    public var educationLevel: Int?
    public var yearsOfExperience: Double?
    /// O*NET work activities: activityId → importance (0–7)
    public var workActivities: [String: Double]?
    /// RIASEC personality profile from career questions
    public var interests: RIASECProfile?

    public init(
        skills: [String] = [],
        resumeSkills: [String] = [],
        onetSkills: [String] = [],
        educationLevel: Int? = nil,
        yearsOfExperience: Double? = nil,
        workActivities: [String: Double]? = nil,
        interests: RIASECProfile? = nil
    ) {
        self.skills = skills
        self.resumeSkills = resumeSkills
        self.onetSkills = onetSkills
        self.educationLevel = educationLevel
        self.yearsOfExperience = yearsOfExperience
        self.workActivities = workActivities
        self.interests = interests
    }
}
