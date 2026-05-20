import SwiftUI
import CoreTaxonomy
import CareerGrowth

// MARK: - Tracker Tab
// Phase 4 stub. Full CRM (applied jobs list, status tracking) is Phase 4 continued / Phase 5.

@MainActor
public struct TrackerTab: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: SacredUI.Spacing.section) {
                Spacer()
                Image(systemName: "checklist")
                    .font(.system(size: SacredUI.Icon.hero))
                    .foregroundStyle(SacredUI.SemanticColor.textSecondary)
                Text("Application Tracker")
                    .font(SacredUI.Typography.title2)
                Text("Jobs you've applied to will appear here.")
                    .font(SacredUI.Typography.body2)
                    .foregroundStyle(SacredUI.SemanticColor.textSecondary)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .padding()
            .navigationTitle("Tracker")
        }
    }
}

// MARK: - Profile Tab
// Phase 4 stub. Full profile editing is a later phase.

@MainActor
public struct ProfileTab: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: SacredUI.Spacing.section) {
                Spacer()
                Image(systemName: "person.circle.fill")
                    .font(.system(size: SacredUI.Icon.hero))
                    .foregroundStyle(SacredUI.SemanticColor.textSecondary)
                Text("Your Profile")
                    .font(SacredUI.Typography.title2)
                Text("Profile editing coming soon.")
                    .font(SacredUI.Typography.body2)
                    .foregroundStyle(SacredUI.SemanticColor.textSecondary)
                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
        }
    }
}

// MARK: - Manifest Tab

@MainActor
public struct ManifestTab: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            CoursesView()
                .navigationTitle("Manifest")
        }
    }
}
