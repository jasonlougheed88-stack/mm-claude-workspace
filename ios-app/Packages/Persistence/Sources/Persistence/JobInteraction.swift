import CoreData
import Foundation

@objc(JobInteraction)
public final class JobInteraction: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var timestamp: Date?
    @NSManaged public var sessionID: UUID?
    @NSManaged public var jobID: UUID?
    @NSManaged public var jobTitle: String
    @NSManaged public var jobCompany: String
    @NSManaged public var jobRole: String
    @NSManaged public var jobSkillsData: Data?
    @NSManaged public var jobONETCode: String?
    @NSManaged public var thompsonScore: Double
    @NSManaged public var amberTealPosition: Double
    @NSManaged public var userSkillsSnapshotData: Data?
    @NSManaged public var action: String
    @NSManaged public var actionWeight: Double
    @NSManaged public var informationGain: Double
    @NSManaged public var isAspirationSignal: Bool
    @NSManaged public var userProfile: UserProfile?

    public var jobSkills: [String] {
        guard let data = jobSkillsData else { return [] }
        return (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }

    public static func fetchAll(in context: NSManagedObjectContext) -> [JobInteraction] {
        let request = NSFetchRequest<JobInteraction>(entityName: "JobInteraction")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }
}
