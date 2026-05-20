import CoreData

@objc(AffiliateClick)
public final class AffiliateClick: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var timestamp: Date?
    @NSManaged public var courseID: String
    @NSManaged public var courseTitle: String
    @NSManaged public var provider: String
    @NSManaged public var affiliateURL: String
    @NSManaged public var converted: Bool
    @NSManaged public var conversionTimestamp: Date?
    @NSManaged public var estimatedCommission: Double
    @NSManaged public var coursePrice: Double
    @NSManaged public var userProfile: UserProfile?
}

extension AffiliateClick {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AffiliateClick> {
        NSFetchRequest<AffiliateClick>(entityName: "AffiliateClick")
    }

    public static func create(in context: NSManagedObjectContext) -> AffiliateClick {
        let click = AffiliateClick(context: context)
        click.id = UUID()
        click.timestamp = Date()
        click.converted = false
        click.estimatedCommission = 0.0
        return click
    }
}
