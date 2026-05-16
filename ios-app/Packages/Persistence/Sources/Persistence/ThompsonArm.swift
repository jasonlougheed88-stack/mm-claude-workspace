import CoreData
import Foundation

@objc(ThompsonArm)
public final class ThompsonArm: NSManagedObject {
    @NSManaged public var armId: String
    @NSManaged public var domain: String
    @NSManaged public var alpha: Double
    @NSManaged public var beta: Double
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var explorationBonus: Double
    @NSManaged public var crossDomainMultiplier: Double
    @NSManaged public var confidence: Double

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        alpha = 1.0
        beta = 1.0
        explorationBonus = 0.0
        crossDomainMultiplier = 1.0
        confidence = 0.0
        lastUpdated = Date()
    }

    public func recordSuccess() {
        alpha += 1
        lastUpdated = Date()
    }

    public func recordFailure() {
        beta += 1
        lastUpdated = Date()
    }

    @discardableResult
    public static func createOrUpdate(
        armId: String,
        domain: String,
        in context: NSManagedObjectContext
    ) -> ThompsonArm {
        if let existing = fetch(armId: armId, in: context) {
            return existing
        }
        let arm = ThompsonArm(context: context)
        arm.armId = armId
        arm.domain = domain
        return arm
    }

    public static func fetch(armId: String, in context: NSManagedObjectContext) -> ThompsonArm? {
        let request = NSFetchRequest<ThompsonArm>(entityName: "ThompsonArm")
        request.predicate = NSPredicate(format: "armId == %@", armId)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
}
