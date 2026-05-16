import SwiftUI

@main
struct ManifestAndMatchApp: App {
    var body: some Scene {
        WindowGroup {
            ContentPlaceholderView()
        }
    }
}

// Replaced in Phase 4 when AppShell.RootView is ready.
private struct ContentPlaceholderView: View {
    var body: some View {
        Text("Manifest & Match")
            .font(.largeTitle)
    }
}
