import SwiftUI
import Persistence
import ScoringEngine
import AppShell

@main
struct ManifestAndMatchApp: App {
    var body: some Scene {
        WindowGroup {
            AppShell.RootView()
                .environment(
                    \.managedObjectContext,
                    PersistenceController.shared.container.viewContext
                )
                .task {
                    await OptimizedThompsonEngine.shared.initialize()
                }
        }
    }
}
