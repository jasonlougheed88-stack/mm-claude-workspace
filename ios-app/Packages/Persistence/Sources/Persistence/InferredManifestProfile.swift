import CoreData
import Foundation

@objc(InferredManifestProfile)
public final class InferredManifestProfile: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var userProfileID: UUID?
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var totalSwipesAnalyzed: Int32
    @NSManaged public var targetRole: String?
    @NSManaged public var targetRoleConfidence: Double
    @NSManaged public var careerNarrative: String?
    @NSManaged public var targetSkillsData: Data?
    @NSManaged public var skillConfidencesData: Data?
    @NSManaged public var riasecRealisticDirect: Double
    @NSManaged public var riasecInvestigativeDirect: Double
    @NSManaged public var riasecArtisticDirect: Double
    @NSManaged public var riasecSocialDirect: Double
    @NSManaged public var riasecEnterprisingDirect: Double
    @NSManaged public var riasecConventionalDirect: Double
    @NSManaged public var riasecDirectConfidence: Double
    @NSManaged public var riasecRealisticInferred: Double
    @NSManaged public var riasecInvestigativeInferred: Double
    @NSManaged public var riasecArtisticInferred: Double
    @NSManaged public var riasecSocialInferred: Double
    @NSManaged public var riasecEnterprisingInferred: Double
    @NSManaged public var riasecConventionalInferred: Double
    @NSManaged public var riasecInferredConfidence: Double
    @NSManaged public var workActivitiesData: Data?
    @NSManaged public var workActivitiesConfidence: Double
    @NSManaged public var weeklyGoalsData: Data?
    @NSManaged public var hiddenStrengthsData: Data?
    @NSManaged public var confidenceBoostsData: Data?
    @NSManaged public var unexpectedPathsData: Data?
    @NSManaged public var convergenceError: Double
    @NSManaged public var minSwipesForConfident: Int32
    @NSManaged public var hasConverged: Bool

    public var targetSkills: [String] {
        get { decodeJSON([String].self, from: targetSkillsData) ?? [] }
        set { targetSkillsData = encodeJSON(newValue) }
    }

    public var skillConfidences: [String: Double] {
        get { decodeJSON([String: Double].self, from: skillConfidencesData) ?? [:] }
        set { skillConfidencesData = encodeJSON(newValue) }
    }

    private func decodeJSON<T: Decodable>(_ type: T.Type, from data: Data?) -> T? {
        guard let data else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private func encodeJSON<T: Encodable>(_ value: T) -> Data? {
        try? JSONEncoder().encode(value)
    }

    public static func fetchOrCreate(in context: NSManagedObjectContext) -> InferredManifestProfile {
        let request = NSFetchRequest<InferredManifestProfile>(entityName: "InferredManifestProfile")
        request.fetchLimit = 1
        if let existing = try? context.fetch(request).first {
            return existing
        }
        let profile = InferredManifestProfile(context: context)
        profile.id = UUID()
        profile.convergenceError = 1.0
        profile.minSwipesForConfident = 100
        return profile
    }
}
