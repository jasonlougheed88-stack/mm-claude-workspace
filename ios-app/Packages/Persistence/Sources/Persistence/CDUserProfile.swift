import CoreData
import Foundation

@objc(UserProfile)
public final class UserProfile: NSManagedObject {

    // MARK: - Scalar attributes (@NSManaged — safe for non-Transformable types)

    @NSManaged public var id: UUID?
    @NSManaged public var name: String
    @NSManaged public var email: String
    @NSManaged public var createdDate: Date?
    @NSManaged public var lastModified: Date?
    @NSManaged public var primaryLocationCity: String?
    @NSManaged public var primaryLocationCountry: String?
    @NSManaged public var primaryLocationTimezone: String?
    @NSManaged public var primaryLocationLatitude: Double
    @NSManaged public var primaryLocationLongitude: Double
    @NSManaged public var remotePreference: String
    @NSManaged public var amberTealPosition: Double
    @NSManaged public var currentDomain: String
    @NSManaged public var experienceLevel: String

    // MARK: - Transformable arrays (KVC access avoids Swift ↔ NSArray bridging ambiguity)

    public var desiredRoles: [String] {
        get { (value(forKey: "desiredRoles") as? [String]) ?? [] }
        set { setValue(newValue as NSArray, forKey: "desiredRoles") }
    }

    public var skills: [String] {
        get { (value(forKey: "skills") as? [String]) ?? [] }
        set { setValue(newValue as NSArray, forKey: "skills") }
    }

    // MARK: - Lifecycle

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
        createdDate = Date()
        lastModified = Date()
        remotePreference = "hybrid"
        amberTealPosition = 0.5
        currentDomain = "technology"
        experienceLevel = "mid"
    }

    // MARK: - Fetch helpers

    public static func fetchCurrent(in context: NSManagedObjectContext) -> UserProfile? {
        let request = NSFetchRequest<UserProfile>(entityName: "UserProfile")
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: false)]
        return try? context.fetch(request).first
    }

    public static func createNew(in context: NSManagedObjectContext) -> UserProfile {
        UserProfile(context: context)
    }
}
