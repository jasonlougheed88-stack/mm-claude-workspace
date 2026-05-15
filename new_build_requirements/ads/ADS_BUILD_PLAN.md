# Ads Build Plan
**Manifest & Match V8 | Created: 2026-05-14**
**Based on:** SCHEMATIC_07_ads.md

---

## What We're Solving

SCHEMATIC_07 confirmed the V7Ads package is production-ready infrastructure that has never run in production. All five components (AdCardView, AdCardInjector, AdCacheManager, ATTConsentManager, AdPerformanceTracker) are built, compile cleanly, and are architecturally sound. The entire package is wired to nothing.

Activation requires:
1. **AdMob SDK** — no SPM dependency declared anywhere
2. **Ad Unit IDs** — placeholder strings throughout, need real IDs from AdMob dashboard
3. **USE_REAL_ADS flag** — `AdCacheManager.enableRealAds = false` blocks all real ad loading
4. **DeckScreen injection** — zero AdCardView references in the active job feed
5. **ATTConsentManager call** — never invoked, Apple requires ATT prompt before first ad request on iOS 14.5+
6. **AdPerformanceTracker start** — never started, anonymous revenue tracking sits idle

**Revenue baseline:** $0.75 eCPM contextual (conservative). At 1 ad per 10 jobs, 500 sessions/day × 20 jobs = 1,000 impressions/day = $0.75/day baseline. Contextual targeting for career/professional content typically reaches $2–5 eCPM. Target: $3.00 eCPM post-optimization.

---

## What Does NOT Change

- AdCardInjector ratios (1:10 standard, 1:15 new user) — designed to be non-intrusive
- AdCardView visual design (200pt height, teal accent, SPONSORED badge) — already matches app design language
- ATTConsentManager graceful degradation to contextual (no tracking required for contextual revenue)
- AdPerformanceTracker data model (anonymous aggregates only — no PII)
- DeckScreen's core swipe/scoring logic — ads are interleaved, not scored

---

## Fix 1: Add Google AdMob SDK

### Current State

No SPM dependency for AdMob exists in any Package.swift. `GADNativeAd` and related types are referenced in `AdCardView.swift` under `#if USE_REAL_ADS` compile flag — they are currently hidden from the compiler by this guard, which is why the package compiles despite the missing SDK.

### Fix

**Add to `V7Ads/Package.swift`:**

```swift
// V7Ads/Package.swift — dependencies array
dependencies: [
    .package(
        url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git",
        from: "11.0.0"
    )
],

// V7Ads target dependencies:
targets: [
    .target(
        name: "V7Ads",
        dependencies: [
            .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads")
        ]
    )
]
```

**Also required in `Info.plist` (App Target):**
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX</string>
```
This is an App Store requirement — AdMob will reject SDK initialization without it.

**Files to modify:**
- `V7Ads/Package.swift` — add SPM dependency + target dependency
- App target `Info.plist` — add `GADApplicationIdentifier` key

**Estimated effort:** 30 minutes. SPM resolution + Info.plist entry.

---

## Fix 2: Create AdMob Account + Ad Unit IDs

### Current State

Placeholder strings throughout V7Ads. No AdMob account registered for this app bundle ID.

### Steps (External — not code)

1. Create Google AdMob account at `admob.google.com`
2. Register app (iOS, bundle ID: `com.jasonlougheed.ManifestAndMatchV7` — verify from Xcode)
3. Create **Native Ad unit** (not Banner, not Interstitial — the AdCardView is built for native format)
4. Copy App ID and Ad Unit ID from dashboard
5. Replace placeholders in V7Ads source

### Code changes after credentials obtained

```swift
// V7Ads/Sources/V7Ads/Services/ — wherever Ad Unit IDs are defined:
// Replace:
static let nativeAdUnitID = "ca-app-pub-3940256099942544/3986624511"  // test ID
// With real ID:
static let nativeAdUnitID = "ca-app-pub-XXXXXXXX/XXXXXXXX"
```

**For development:** Leave Google's test Ad Unit ID (`ca-app-pub-3940256099942544/3986624511`) active until production release. Using real IDs on test builds violates AdMob policy.

**Files to modify:**
- V7Ads Ad Unit ID constants file (exact file — search for `ca-app-pub` after reading V7Ads sources)

**Estimated effort:** 1–2 hours (account creation + form, ID replacement in code). AdMob account approval is typically same-day.

---

## Fix 3: Enable USE_REAL_ADS Flag + AdCacheManager

### Current State

```swift
// AdCacheManager
static var enableRealAds = false  // returns placeholder when false
```

The `#if USE_REAL_ADS` compile flag guards all actual GADAdLoader code in AdCardView. The flag is not set in any build configuration.

### Fix

**Add to App target build settings (Debug + Release separately):**

```
// Xcode Build Settings → Swift Compiler — Custom Flags
// Release configuration only:
OTHER_SWIFT_FLAGS = $(inherited) -DUSE_REAL_ADS

// Debug: leave unset → use placeholders during development
```

**Enable at runtime:**

```swift
// App entry point (ManifestAndMatchV7App.swift) — in init() or onAppear:
#if USE_REAL_ADS
AdCacheManager.enableRealAds = true
#endif
```

**Important:** Keep Debug builds on `enableRealAds = false`. Testing with real ad impressions on a device owned by the developer counts against AdMob quotas and can trigger invalid traffic detection.

**Files to modify:**
- App target Xcode build settings — add `USE_REAL_ADS` flag to Release configuration
- `ManifestAndMatchV7App.swift` — set `AdCacheManager.enableRealAds = true` in Release path

**Estimated effort:** 30 minutes.

---

## Fix 4: ATTConsentManager — First Launch Call

### Current State

`ATTConsentManager` is never called. Apple requires apps to request ATT permission before accessing the device's IDFA. Failing to do so doesn't crash the app but risks App Store review rejection and prevents behavioral targeting even when users would consent.

### Fix

Call ATTConsentManager on the first launch, before any ad is requested. The right moment is after onboarding is complete (not on first app open — don't ask for ad tracking permission before the user has seen the app value).

```swift
// ProfileCompletionView or final onboarding step — on completion:
Task {
    await ATTConsentManager.shared.requestTrackingPermission()
}
```

**Privacy note:** ATT consent is required for behavioral targeting only. Contextual ads (based on app context, not user data) work without ATT consent and without IDFA. The revenue difference: contextual ~$0.75–3 eCPM vs behavioral ~$8–15 eCPM. Either path is compatible with the privacy-first product model — contextual is the baseline, behavioral is opt-in upside.

**Files to modify:**
- Final onboarding view (identify exact file by reading onboarding flow) — add ATT call on completion

**Estimated effort:** 30 minutes.

---

## Fix 5: Wire AdCardInjector into DeckScreen

### Current State

DeckScreen.swift has a `CardItem` enum (or equivalent) that drives the card stack. It has zero references to `AdCardView` or `AdCardInjector`. The ad injection infrastructure sits idle.

### Target State

The deck card loop interleaves ad cards at positions determined by `AdCardInjector`. The ad card renders as `AdCardView`. Swipe on an ad card advances the position counter but does not trigger Thompson updates.

### Implementation

**Step 1: Read DeckScreen.swift's CardItem enum before touching anything.** Understand the current card type structure. The ad integration must fit this pattern, not replace it.

**Step 2: Add `.ad` case to CardItem (or equivalent):**

```swift
// DeckScreen.swift — CardItem enum (find the actual definition first)
enum CardItem: Identifiable {
    case job(JobItem)
    case question(QuestionCard)
    case ad(AdCardViewModel)  // ADD THIS
    
    var id: String { /* ... */ }
}
```

**Step 3: Inject ad positions after job fetch:**

```swift
// DeckScreen — after loadInitialJobs() returns:
func injectAdsIntoJobFeed(_ jobs: [JobItem]) -> [CardItem] {
    let positions = AdCardInjector.standard.injectionPositions(
        for: jobs.count,
        sessionAdCount: currentSessionAdCount
    )
    var cards: [CardItem] = jobs.map { .job($0) }
    for position in positions.reversed() {
        let adViewModel = AdCardViewModel()
        cards.insert(.ad(adViewModel), at: min(position, cards.count))
    }
    return cards
}
```

**Step 4: Render AdCardView in card stack:**

```swift
// DeckScreen — in card rendering switch:
case .ad(let viewModel):
    AdCardView(viewModel: viewModel)
        .onAppear { AdPerformanceTracker.shared.recordImpression() }
```

**Step 5: Exclude ad cards from Thompson processing:**

```swift
// DeckScreen — swipe handler:
case .ad:
    // Advance deck position, do NOT call processInteraction()
    // Do NOT call ManifestInferenceActor
    // DO call AdPerformanceTracker.recordSwipeDismiss() if swiped away
    break
```

**Critical prerequisite:** Read DeckScreen.swift lines 1–100 to find the actual CardItem definition and card rendering loop before writing a single line. DeckScreen is 3,353 lines — the card type enum may have a different name or structure.

**Files to modify:**
- `DeckScreen.swift` — add `.ad` case to card enum, add injection call, add rendering case, exclude from Thompson

**Estimated effort:** 1–2 days. The injection logic itself is trivial. The work is understanding DeckScreen's card architecture before modifying it.

---

## Fix 6: Start AdPerformanceTracker

### Current State

`AdPerformanceTracker` is never started. No impressions are logged. No revenue estimates are calculated.

### Fix

```swift
// ManifestAndMatchV7App.swift — in init():
#if USE_REAL_ADS
AdPerformanceTracker.shared.startSession()
#endif
```

The tracker writes daily aggregates to the app's Documents directory as a JSON file. No server, no network call. Anonymous (no PII). Safe to read from Settings or a debug screen.

**Files to modify:**
- `ManifestAndMatchV7App.swift` — add tracker start in Release builds

**Estimated effort:** 15 minutes.

---

## Implementation Sequence

```
Day 1 (External — no code):
  Create AdMob account
  Register app, create Native Ad Unit
  Copy App ID + Ad Unit ID

Day 2:
  Fix 1 — Add AdMob SDK to V7Ads/Package.swift
  Add GADApplicationIdentifier to Info.plist
  Clean build — verify GAD types resolve
  
  Fix 2 — Replace placeholder Ad Unit IDs with real (or Google test) IDs
  
Day 3:
  Fix 3 — Add USE_REAL_ADS flag to Release build settings
  AdCacheManager.enableRealAds = true in Release path
  
  Fix 4 — ATTConsentManager call in final onboarding step
  Test on device: verify ATT sheet appears once

Day 4–5:
  Fix 5 — Wire AdCardInjector into DeckScreen
  READ DeckScreen.swift CardItem enum fully first
  Add .ad case, injection call, rendering, exclude from Thompson
  Test: install on sim, scroll deck, verify ad appears ~position 10

Day 5:
  Fix 6 — Start AdPerformanceTracker
  End-to-end test: impression logged → tracker JSON written → revenue estimate visible
```

---

## Files to Modify

| File | Change |
|---|---|
| `V7Ads/Package.swift` | Add GoogleMobileAds SPM dependency |
| App target `Info.plist` | Add `GADApplicationIdentifier` |
| V7Ads Ad Unit ID constants | Replace placeholders with real/test IDs |
| App target Xcode build settings | Add `USE_REAL_ADS` to Release Swift flags |
| `ManifestAndMatchV7App.swift` | Set `enableRealAds = true` in Release, start tracker |
| Final onboarding view | Add ATT consent request on completion |
| `DeckScreen.swift` | Add `.ad` card case, injection call, rendering, Thompson exclusion |

---

## Success Criteria

| Metric | Before | After |
|---|---|---|
| Ad cards in deck | Never appear | Appear ~every 10 jobs |
| AdMob SDK present | ❌ | ✅ |
| Real ads loading | Never | ✅ (Release only) |
| ATT prompt shown | Never | ✅ After onboarding complete |
| Impression tracking | Never | ✅ Daily aggregate JSON |
| Estimated revenue per 1,000 impressions | $0 | $0.75 (baseline) → $3.00 (target) |
| Thompson updates on ad swipe | N/A | Excluded (correct behavior) |
