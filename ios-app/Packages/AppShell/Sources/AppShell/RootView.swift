import SwiftUI
import CoreData
import Persistence
import JobNormalizer
import DeckUI
import CoreTaxonomy

// Both Persistence and JobNormalizer define UserProfile.
// RootView reads Persistence.UserProfile from Core Data and converts it to JobNormalizer.UserProfile
// for scoring. Disambiguate with explicit module qualifiers.
private typealias CDProfile = Persistence.UserProfile
private typealias ScoringProfile = JobNormalizer.UserProfile

@MainActor
public struct RootView: View {
    @State private var showOnboarding: Bool
    @State private var scoringProfile: ScoringProfile = ScoringProfile()

    @Environment(\.managedObjectContext) private var context

    public init() {
        _showOnboarding = State(
            initialValue: !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        )
    }

    public var body: some View {
        if showOnboarding {
            OnboardingView {
                showOnboarding = false
                loadScoringProfile()
            }
        } else {
            mainTabs
                .onAppear { loadScoringProfile() }
        }
    }

    // MARK: - Main tabs

    private var mainTabs: some View {
        TabView {
            DeckScreen(userProfile: scoringProfile)
                .tabItem { Label("Discover", systemImage: "rectangle.stack.fill") }
                .tag(0)

            TrackerTab()
                .tabItem { Label("Tracker", systemImage: "checklist") }
                .tag(1)

            ProfileTab()
                .tabItem { Label("Profile", systemImage: "person.circle.fill") }
                .tag(2)

            ManifestTab()
                .tabItem { Label("Manifest", systemImage: "sparkles") }
                .tag(3)
        }
        .tint(SacredUI.SemanticColor.teal)
    }

    // MARK: - Profile loading

    private func loadScoringProfile() {
        guard let cd = CDProfile.fetchCurrent(in: context) else { return }
        scoringProfile = buildScoringProfile(from: cd)
    }

    private func buildScoringProfile(from cd: CDProfile) -> ScoringProfile {
        let preferences = UserPreferences(
            desiredRoles: cd.desiredRoles,
            primaryLocation: buildLocation(from: cd)
        )
        let professional = ProfessionalProfile(skills: cd.skills)
        return ScoringProfile(preferences: preferences, professionalProfile: professional)
    }

    private func buildLocation(from cd: CDProfile) -> LocationData? {
        guard let city = cd.primaryLocationCity, !city.isEmpty,
              let country = cd.primaryLocationCountry, !country.isEmpty else { return nil }
        let tz = cd.primaryLocationTimezone.flatMap { TimeZone(identifier: $0) } ?? .current
        return LocationData(
            city: city,
            country: country,
            countryCode: countryCode(for: country),
            timezone: tz,
            latitude: cd.primaryLocationLatitude,
            longitude: cd.primaryLocationLongitude
        )
    }

    private func countryCode(for name: String) -> String {
        switch name.lowercased() {
        case "united states", "usa", "us": return "US"
        case "canada": return "CA"
        case "united kingdom", "uk": return "GB"
        case "australia": return "AU"
        case "germany": return "DE"
        case "france": return "FR"
        default: return "XX"
        }
    }
}
