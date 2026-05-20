import SwiftUI
import CoreData
import CareerGrowth
import Persistence
import CoreTaxonomy

@MainActor
public struct CoursesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.openURL) private var openURL

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \InferredManifestProfile.lastUpdated, ascending: false)],
        predicate: NSPredicate(format: "hasConverged == YES"),
        animation: .default
    )
    private var manifestProfiles: FetchedResults<InferredManifestProfile>

    @State private var courses: [RecommendedCourse] = []
    @State private var isLoading = false

    public init() {}

    private var manifest: InferredManifestProfile? { manifestProfiles.first }

    public var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if courses.isEmpty {
                emptyState
            } else {
                courseList
            }
        }
        .task(id: manifest?.objectID) {
            await loadCourses()
        }
    }

    private var courseList: some View {
        ScrollView {
            LazyVStack(spacing: SacredUI.Spacing.compact) {
                if let manifest, let narrative = manifest.careerNarrative {
                    narrativeBanner(narrative)
                }
                ForEach(courses) { course in
                    CourseCardView(course: course) {
                        openCourse(course)
                    }
                }
            }
            .padding(SacredUI.Spacing.compact)
        }
    }

    private var emptyState: some View {
        VStack(spacing: SacredUI.Spacing.section) {
            Spacer()
            Image(systemName: "sparkles")
                .font(.system(size: SacredUI.Icon.hero))
                .foregroundStyle(SacredUI.SemanticColor.teal)
            Text("Keep Swiping")
                .font(SacredUI.Typography.title2)
            Text("Course recommendations appear once you've swiped enough jobs for the system to identify your skill gaps.")
                .font(SacredUI.Typography.body2)
                .foregroundStyle(SacredUI.SemanticColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, SacredUI.Spacing.section)
            Spacer()
        }
    }

    private func narrativeBanner(_ narrative: String) -> some View {
        Text(narrative)
            .font(SacredUI.Typography.body2)
            .foregroundStyle(SacredUI.SemanticColor.textSecondary)
            .padding(SacredUI.Spacing.compact)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(SacredUI.SemanticColor.teal.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: SacredUI.CardStyle.mediumCornerRadius))
    }

    private func loadCourses() async {
        guard let manifest else {
            courses = []
            return
        }
        // Extract Sendable data from managed object on @MainActor before crossing actor boundary
        let skills = manifest.targetSkills
        let role = manifest.targetRole ?? ""

        isLoading = true
        defer { isLoading = false }

        courses = await CourseRecommendationEngine.shared.getRecommendations(
            targetSkills: skills,
            targetRole: role,
            limit: 20
        )
    }

    private func openCourse(_ course: RecommendedCourse) {
        let affiliateURL = AffiliateURLBuilder.shared.buildAffiliateURL(for: course)
        Task {
            try? await AffiliateTracker.shared.recordClickInCoreData(
                course: course,
                affiliateURL: affiliateURL,
                context: viewContext
            )
        }
        openURL(affiliateURL)
    }
}
