import CoreData
import Foundation
import os

private let logger = Logger(subsystem: "com.manifestandmatch.app", category: "PersistenceController")

@available(iOS 17.0, *)
@MainActor
public final class PersistenceController: ObservableObject, @unchecked Sendable {

    // MARK: - Shared Instance

    nonisolated public static let shared: PersistenceController = {
        MainActor.assumeIsolated {
            PersistenceController()
        }
    }()

    nonisolated public static let preview: PersistenceController = {
        MainActor.assumeIsolated {
            PersistenceController(inMemory: true)
        }
    }()

    // MARK: - Properties

    nonisolated public let container: NSPersistentContainer

    public var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    public lazy var backgroundContext: NSManagedObjectContext = {
        let ctx = container.newBackgroundContext()
        ctx.automaticallyMergesChangesFromParent = true
        ctx.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return ctx
    }()

    // MARK: - Init

    init(inMemory: Bool = false) {
        guard let modelURL = Bundle.module.url(forResource: "ManifestAndMatch", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("ManifestAndMatch.momd not found in Persistence package bundle")
        }

        container = NSPersistentContainer(name: "ManifestAndMatch", managedObjectModel: model)

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error {
                logger.error("Failed to load persistent stores: \(error.localizedDescription)")
                fatalError("Core Data store failed to load: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }

    // MARK: - Save

    public func save() {
        let ctx = container.viewContext
        guard ctx.hasChanges else { return }
        do {
            try ctx.save()
        } catch {
            logger.error("ViewContext save failed: \(error.localizedDescription)")
        }
    }
}
