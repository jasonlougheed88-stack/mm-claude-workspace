// Placeholder types for Google Mobile Ads SDK.
// Compiled only when USE_REAL_ADS is NOT defined — provides identical interface to
// the real GAD types so AdCardView compiles without the SDK during development.
//
// PHASE5-ADS: When USE_REAL_ADS is active, delete this file and import GoogleMobileAds.

#if !USE_REAL_ADS

import Foundation

@MainActor
public final class GADNativeAd: @unchecked Sendable {
    public var headline: String?
    public var body: String?
    public var advertiser: String?
    public var callToAction: String?
    public var images: [GADNativeAdImage]?

    public init(
        headline: String? = "Advance Your Career",
        body: String? = "Top-rated courses matched to your skill gaps.",
        advertiser: String? = "Career Development",
        callToAction: String? = "Learn More"
    ) {
        self.headline = headline
        self.body = body
        self.advertiser = advertiser
        self.callToAction = callToAction
        self.images = []
    }

    public static func placeholder() -> GADNativeAd { GADNativeAd() }
}

public final class GADNativeAdImage: @unchecked Sendable {
    public let imageURL: URL?
    public init(url: URL?) { self.imageURL = url }
}

#endif // !USE_REAL_ADS
