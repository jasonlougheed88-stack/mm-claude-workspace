# Checkpoint — 2026-05-20 (end of session)

## CURRENT STATE
Phase 5 is fully complete. Real GoogleMobileAds SDK (11.13.0) is wired with Google's test IDs.
Test ad rendered in simulator, AdMob native ad validator confirmed no implementation issues.
Build: zero errors, zero warnings. Committed `53c908f`, pushed to GitHub.

## WHAT WAS DONE THIS SESSION
- Added GoogleMobileAds 11.13.0 via SPM to AdCards/Package.swift
- Created NativeAdLoader.swift — @MainActor ObservableObject, GADAdLoader + delegate, @preconcurrency import for Swift 6 compliance
- Created NativeAdView.swift — UIViewRepresentable wrapping GADNativeAdView with styled layout
- Rewrote AdCardView.swift — dropped #if USE_REAL_ADS, always uses real SDK, placeholder as loading state
- Cleared AdPlaceholderTypes.swift (real SDK replaces stubs)
- Gate PASSED: test ad rendered with "Test mode: Google Ads" headline, INSTALL CTA, teal border, SPONSORED badge, AdMob validator shows no issues

## PRODUCTION SWAP (no code changes needed, just string constants)
- `ios-app/Packages/AdCards/Sources/AdCards/NativeAdLoader.swift:14` — replace `ca-app-pub-3940256099942544/3986624511` with real native ad unit ID
- `ios-app/ManifestAndMatch/Info.plist` — replace `ca-app-pub-3940256099942544~3347511713` with real AdMob App ID
- `ios-app/Packages/CareerGrowth/Sources/CareerGrowth/Services/AffiliateTracker.swift` — AffiliateURLBuilder has empty Coursera/Udemy credential strings

## NEXT ACTION (Phase 6 — Connection)
1. Read `new_build_requirements/` — find the Phase 6 plan file and read it in full
2. Read `schematics/SYSTEM_INVENTORY.md` for any system from Phase 6 scope
3. Check `DECISIONS.md` and `OPEN_QUESTIONS.md` for anything blocking Phase 6
4. Fix `JobInteraction.sessionID nil` bug — swipe interactions never reach Core Data (pre-existing, noted in Phase 5)
5. Wire orphaned components per Untangling Guide decisions
6. App Store prep

## OPEN BUGS (carry into Phase 6)
- `JobInteraction.sessionID` is nil on every swipe — interaction records never saved to Core Data
- `ZINFERREDMANIFESTPROFILE` test record inserted directly into simulator DB last session — reset simulator or clear app data before next gate test if manifest inference is being tested

## KEY COMMITS THIS SESSION
- `53c908f` — Phase 5 AdMob real SDK with test IDs (this session)
- `6c9e60e` — Previous session end
