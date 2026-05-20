import AppTrackingTransparency
import Foundation
import os

private let logger = Logger(subsystem: "com.manifestandmatch.app", category: "ATTConsent")

/// Manages App Tracking Transparency consent. Privacy-first: contextual ads work
/// without authorization — behavioral targeting is opt-in upside only.
public actor ATTConsentManager {
    public static let shared = ATTConsentManager()

    private enum Keys {
        static let hasRequested = "att.has_requested"
    }

    private init() {}

    // MARK: - Public API

    /// Request ATT authorization. Safe to call multiple times — exits immediately
    /// if already determined. Must be called after onboarding (not on cold launch).
    @discardableResult
    public func requestTrackingAuthorization() async -> ATTrackingManager.AuthorizationStatus {
        let current = ATTrackingManager.trackingAuthorizationStatus
        guard current == .notDetermined else {
            logger.info("ATT already determined: \(self.statusDescription(current))")
            return current
        }

        let status = await ATTrackingManager.requestTrackingAuthorization()
        UserDefaults.standard.set(true, forKey: Keys.hasRequested)
        logger.info("ATT result: \(self.statusDescription(status))")
        return status
    }

    /// True if the system prompt has not been shown yet.
    public func shouldShowPrompt() -> Bool {
        ATTrackingManager.trackingAuthorizationStatus == .notDetermined
            && !UserDefaults.standard.bool(forKey: Keys.hasRequested)
    }

    public func isAuthorized() -> Bool {
        ATTrackingManager.trackingAuthorizationStatus == .authorized
    }

    // MARK: - Private

    private func statusDescription(_ status: ATTrackingManager.AuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "notDetermined"
        case .restricted:    return "restricted"
        case .denied:        return "denied"
        case .authorized:    return "authorized"
        @unknown default:    return "unknown"
        }
    }
}
