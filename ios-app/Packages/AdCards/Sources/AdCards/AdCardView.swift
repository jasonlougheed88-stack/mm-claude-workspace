import SwiftUI
@preconcurrency import GoogleMobileAds
import CoreTaxonomy

// MARK: - Ad Card View

/// Renders a single ad card in the job deck using Google's native ad format.
/// Shows a styled placeholder while the ad loads from AdMob servers.
///
/// MV pattern: no ViewModel. Loader state lives here as @StateObject.
/// Thompson constraint: caller (DeckScreen) must NOT call processInteraction() when swiping this card.
@MainActor
public struct AdCardView: View {
    @StateObject private var loader = NativeAdLoader()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init() {}

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            if let ad = loader.nativeAd {
                NativeAdView(nativeAd: ad)
            } else {
                placeholderContent
            }
            sponsoredBadge.padding(10)
        }
        .task { loader.load() }
        .frame(height: 200)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(SacredUI.SemanticColor.teal, lineWidth: 2)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Sponsored content. Swipe to continue.")
    }

    // MARK: - Placeholder (shown while ad loads)

    private var placeholderContent: some View {
        VStack(alignment: .leading, spacing: SacredUI.Spacing.compact) {
            RoundedRectangle(cornerRadius: 8)
                .fill(SacredUI.SemanticColor.teal.opacity(0.08))
                .frame(height: 80)
                .overlay(
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(SacredUI.SemanticColor.teal.opacity(0.4))
                )

            Text("Advance Your Career")
                .font(SacredUI.Typography.title3)

            Text("Top-rated courses matched to your skill gaps and career goals.")
                .font(SacredUI.Typography.body2)
                .foregroundStyle(SacredUI.SemanticColor.textSecondary)
                .lineLimit(2)

            HStack {
                Spacer()
                Text("Learn More")
                    .font(SacredUI.Typography.buttonPrimary)
                    .foregroundStyle(.white)
                    .padding(.horizontal, SacredUI.Spacing.large)
                    .padding(.vertical, SacredUI.Spacing.compact)
                    .background(SacredUI.SemanticColor.teal)
                    .clipShape(Capsule())
                Spacer()
            }
            .padding(.top, SacredUI.Spacing.compact)
        }
        .padding(SacredUI.Spacing.standard)
    }

    // MARK: - Sponsored Badge

    private var sponsoredBadge: some View {
        Text("SPONSORED")
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(.black)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.yellow)
            .clipShape(RoundedRectangle(cornerRadius: 3))
            .accessibilityLabel("Sponsored advertisement")
    }
}
