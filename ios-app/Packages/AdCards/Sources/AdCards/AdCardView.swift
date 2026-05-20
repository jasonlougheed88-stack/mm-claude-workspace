import SwiftUI
import CoreTaxonomy

#if USE_REAL_ADS
import GoogleMobileAds
#endif

// MARK: - Ad Card View

/// Renders a single ad card in the job deck. In development mode (no USE_REAL_ADS),
/// shows a styled placeholder. Flip USE_REAL_ADS + wire AdMob credentials for production.
///
/// MV pattern: no ViewModel. State lives here as @State properties.
/// Thompson constraint: caller (DeckScreen) is responsible for NOT calling
/// processInteraction() when swiping this card.
@MainActor
public struct AdCardView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init() {}

    public var body: some View {
#if USE_REAL_ADS
        realAdContent
#else
        placeholderContent
#endif
    }

    // MARK: - Placeholder (development)

    private var placeholderContent: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: SacredUI.Spacing.compact) {
                // Image area
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

            sponsoredBadge
                .padding(10)
        }
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

    // MARK: - Real Ad Content (USE_REAL_ADS only)

#if USE_REAL_ADS
    // PHASE5-ADS: Implement GADNativeAdView loading here when credentials are ready.
    // Pattern: load via GADAdLoader, update @State var nativeAd: GADNativeAd? on callback.
    @State private var nativeAd: GADNativeAd?

    private var realAdContent: some View {
        Group {
            if let ad = nativeAd {
                loadedAdView(ad: ad)
            } else {
                placeholderContent
                    .task { await loadRealAd() }
            }
        }
    }

    private func loadedAdView(ad: GADNativeAd) -> some View {
        // Wire up GADNativeAdView here — implement when AdMob account is configured.
        placeholderContent
    }

    private func loadRealAd() async {
        // PHASE5-ADS: Initialize GADAdLoader with real ad unit ID.
        // Test ID: ca-app-pub-3940256099942544/3986624511
    }
#endif

    // MARK: - Supporting Views

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
