@preconcurrency import GoogleMobileAds
import Foundation
import os

private let logger = Logger(subsystem: "com.manifestandmatch.app", category: "NativeAds")

// REPLACE WITH PRODUCTION AD UNIT ID BEFORE APP STORE SUBMISSION
private let nativeAdUnitID = "ca-app-pub-3940256099942544/3986624511"

@MainActor
public final class NativeAdLoader: NSObject, ObservableObject {
    @Published public var nativeAd: GADNativeAd?
    @Published public var loadFailed = false

    private var adLoader: GADAdLoader?

    public override init() { super.init() }

    public func load() {
        // start(completionHandler:) is idempotent — safe to call on every ad load.
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        adLoader = GADAdLoader(
            adUnitID: nativeAdUnitID,
            rootViewController: nil,
            adTypes: [.native],
            options: nil
        )
        adLoader?.delegate = self
        adLoader?.load(GADRequest())
    }
}

extension NativeAdLoader: GADAdLoaderDelegate {
    nonisolated public func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        logger.error("Native ad load failed: \(error.localizedDescription)")
        MainActor.assumeIsolated { self.loadFailed = true }
    }
}

extension NativeAdLoader: GADNativeAdLoaderDelegate {
    nonisolated public func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        logger.debug("Native ad loaded: \(nativeAd.headline ?? "no headline")")
        MainActor.assumeIsolated { self.nativeAd = nativeAd }
    }
}
