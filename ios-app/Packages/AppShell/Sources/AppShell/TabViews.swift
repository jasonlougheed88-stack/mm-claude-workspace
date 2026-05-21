import SwiftUI
import CoreData
import CoreTaxonomy
import CareerGrowth
import Persistence

// MARK: - Tracker Tab

@MainActor
public struct TrackerTab: View {
    public init() {}

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \JobInteraction.timestamp, ascending: false)],
        predicate: NSPredicate(format: "action == %@ OR action == %@", "interested", "applied")
    ) private var interactions: FetchedResults<JobInteraction>

    public var body: some View {
        NavigationStack {
            Group {
                if interactions.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("Tracker")
        }
    }

    private var emptyState: some View {
        VStack(spacing: SacredUI.Spacing.section) {
            Spacer()
            Image(systemName: "checklist")
                .font(.system(size: SacredUI.Icon.hero))
                .foregroundStyle(SacredUI.SemanticColor.textSecondary)
            Text("No applications yet")
                .font(SacredUI.Typography.title2)
            Text("Jobs you swipe right on will appear here.")
                .font(SacredUI.Typography.body2)
                .foregroundStyle(SacredUI.SemanticColor.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
    }

    private var list: some View {
        List(interactions, id: \.id) { interaction in
            VStack(alignment: .leading, spacing: SacredUI.Spacing.xxsmall) {
                Text(interaction.jobTitle)
                    .font(SacredUI.Typography.body1)
                    .foregroundStyle(SacredUI.SemanticColor.text)
                Text(interaction.jobCompany)
                    .font(SacredUI.Typography.body2)
                    .foregroundStyle(SacredUI.SemanticColor.textSecondary)
                if let date = interaction.timestamp {
                    Text(date, style: .date)
                        .font(SacredUI.Typography.caption1)
                        .foregroundStyle(SacredUI.SemanticColor.textSecondary)
                }
            }
            .padding(.vertical, SacredUI.Spacing.xxsmall)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(interaction.jobTitle) at \(interaction.jobCompany)")
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
