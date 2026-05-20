# Build Sequence — Manifest & Match
**Read this first. Every session. Before touching anything.**
Last updated: 2026-05-20

---

## ⚠️ CURRENT SESSION STATUS — READ BEFORE DOING ANYTHING

**Phases 1–4 are COMPLETE. Phase 5 (Revenue) is IN PROGRESS.**
**Last updated: 2026-05-20. Build: zero errors, zero warnings. Phase 5 ad cards committed ✅**

---

## IMMEDIATE NEXT TASK — Phase 5: Revenue (IN PROGRESS)

**Ad cards: COMPLETE and committed. Next: CareerGrowth package (Step 4).**

### Phase 5 Step-by-Step Status

**Step 1 — AdCards package: COMPLETE ✅**
- `AdPlaceholderTypes.swift` — placeholder GADNativeAd/GADNativeAdImage stubs for development (no real SDK needed)
- `AdCardInjector.swift` — actor, 1:10 ratio, ±1 variance, anti-clustering, session limits
- `ATTConsentManager.swift` — actor, ATT prompt, persists hasRequested to UserDefaults
- `AdCardView.swift` — MV-compliant (no ViewModel), placeholder content, SPONSORED badge, teal border
- `AdCards/Package.swift` — CoreTaxonomy + Monitoring deps. GoogleMobileAds NOT added yet (needs AdMob account first — see PHASE5-ADS comments in file)

**Step 2 — DeckScreen ad injection: COMPLETE ✅**
- `CardItem` enum added: `.job(Job)` and `.ad`
- `buildCards(from:)` calls `AdCardInjector.shared.calculateAdPositions()` and inserts `.ad` at calculated positions
- `triggerSwipe()`: `.job` path calls Thompson + recordInteraction; `.ad` path increments sessionAdsSeen + records ad shown — Thompson is NOT called
- `DeckUI/Package.swift` updated to depend on AdCards
- `AppShell/Package.swift` updated to depend on AdCards

**Step 3 — ATT consent in OnboardingView: COMPLETE ✅**
- `import AdCards` added to OnboardingView.swift
- `ATTConsentManager.shared.requestTrackingAuthorization()` called in `completeOnboarding()` after Core Data save
- `Info.plist`: `NSUserTrackingUsageDescription` + `GADApplicationIdentifier` (test value) added

**Build status: zero errors, zero warnings ✅ App launches ✅**

**Gate test — PASSED ✅ (2026-05-20):**
- Ad card rendered at position 15 (new-user protection: 1:15 ratio for first 50 interactions, expected)
- AdCardView confirmed: teal border, graduation cap, "Advance Your Career", "Learn More" CTA
- Swipe on ad card advances deck only — Thompson NOT called ✅
- Committed: `4f71aed` — pushed to GitHub ✅

**Step 4 — CareerGrowth package: COMPLETE ✅**
- `AffiliateClick.swift` — NSManagedObject subclass in Persistence package
- `CourseModels.swift` — RecommendedCourse, CourseProvider, CoursePrice, DifficultyLevel, Skill, SkillsGap
- `CourseDatabase.swift` — actor, Bundle.module, correct flat-array JSON schema
- `CourseRecommendationEngine.swift` — actor, NSCache nonisolated(unsafe), getRecommendations(targetSkills:targetRole:limit:)
- `AffiliateTracker.swift` — actor + AffiliateURLBuilder, empty credential strings for Phase 6
- `Color+Hex.swift` — SwiftUI extension in AppShell
- `CourseCardView.swift` — provider icon, match %, price, accessibility labels
- `CoursesView.swift` — @FetchRequest on InferredManifestProfile, LazyVStack, empty state, openURL affiliate tap
- `CareerGrowth/Package.swift` — resources: .copy("Resources/Courses.bundle") added
- `TabViews.swift` — ManifestTab stub replaced with NavigationStack { CoursesView() }
- `courses_v1.json` (3.9MB) copied to CareerGrowth/Resources/Courses.bundle/
- Build: zero errors, zero warnings ✅
- Port `courses_v1.json` from V7 reference into CareerGrowth package Resources
- Build `CourseRecommendationEngine.swift` — reads InferredManifestProfile, matches skill gaps to courses
- Build `CourseCardView.swift` — provider, match %, price, CTA
- Build `CoursesView.swift` — LazyVStack, empty state, affiliate click tracking
- Build `AffiliateTracker.swift` — writes AffiliateClick to Core Data; affiliate URL construction goes through Cloudflare Workers proxy (credentials NOT in binary — see DECISIONS.md)
- Wire ManifestTab stub → CoursesView

**Phase 5 gate — Step 4:**
- ManifestTab shows CoursesView (not stub) ✅
- Empty state renders when no converged InferredManifestProfile ← verify in simulator
- Course tap writes AffiliateClick to Core Data ← verify in simulator
- Build: zero errors, zero warnings ✅

**Step 5 — Real jobs via JobPipeline: NOT STARTED**
- Build `JobPipelineClient.swift` in JobPipeline package
- Replace `SyntheticJobs.all` call in `DeckScreen.loadJobs()` (one line change)
- Needs a job API key — Jason to obtain

**External blockers (Jason needs to do these):**
| What | Status |
|---|---|
| Google AdMob account + App ID + Native Ad Unit ID | Not started |
| Coursera affiliate (Rakuten LinkShare) | Not started |
| Udemy affiliate | Not started |
| Job API key (JSearch on RapidAPI) | Not started |

**Phase 5 gate:**
- Ad card renders at ~position 10 in deck ✅ (position 15 — new-user ratio, correct)
- Swipe on ad card does NOT update Thompson arms ✅
- Manifest tab shows course list ← NOT STARTED
- Course tap writes AffiliateClick to Core Data ← NOT STARTED

---

## Where We Are

**Phase 0 — Workspace Setup: COMPLETE**
All planning docs, folder structure, repos, and session tooling are in place.

**Pre-Phase 1 work (session 2026-05-15): COMPLETE**
- Package naming audit: ✅
- System inventory: ✅ `schematics/SYSTEM_INVENTORY.md`
- Untangling guide: ✅ `schematics/UNTANGLING_GUIDE.md`
- Architecture diagrams: ✅ `diagrams/`
- Controller skill: ✅ v3.0.0

**Phase 1 — Scaffold: COMPLETE (2026-05-15)**
- 15-package DAG: ✅ `ios-app/Packages/`
- Xcode project: ✅ `ios-app/ManifestAndMatch.xcodeproj`
- SacredUIConstants: ✅ `CoreTaxonomy/Sources/CoreTaxonomy/SacredUIConstants.swift`
- Core Data model (21 entities): ✅ `Persistence/Sources/Persistence/ManifestAndMatch.xcdatamodeld/`
- PersistenceController: ✅ `Persistence/Sources/Persistence/PersistenceController.swift`
- Clean build: ✅ zero errors, zero warnings

**Phase 2 — Data Flow: COMPLETE (2026-05-16)**
- ThompsonArm NSManagedObject: ✅
- JobInteraction NSManagedObject: ✅
- InferredManifestProfile NSManagedObject: ✅
- FastBetaSampler (Kumaraswamy + SIMD): ✅
- OptimizedThompsonEngine (actor + persistence): ✅
- ManifestInferenceActor (threshold=3): ✅
- Clean build: ✅ zero errors, zero warnings

**Phase 3 — Scoring: IN PROGRESS (2026-05-16)**
- Job/ThompsonScore/SwipeAction types → `JobNormalizer/Sources/JobNormalizer/Job.swift` ✅
- LocationData/JobLocationData/WorkLocationType/RIASECProfile → `JobNormalizer/Sources/JobNormalizer/Location.swift` ✅
- UserProfile/UserPreferences/ProfessionalProfile → `JobNormalizer/Sources/JobNormalizer/UserProfile.swift` ✅
- ScoringEngine Package.swift wired to JobNormalizer ✅
- SwipeAction moved from ScoringEngine to JobNormalizer (single source of truth) ✅
- Clean build: ✅ zero errors, zero warnings

**Phase 3 — Remaining (do in this order):**
1. ✅ `ThompsonWeights` struct — slider interpolation (t=0 Match → t=1 Manifest), weights sum to 1.0
2. ✅ `scoreJobs([Job], profile: UserProfile) -> [Job]` on OptimizedThompsonEngine
3. ✅ 3-tier title match: exact substring=1.0, shared significant words=0.6–0.8, no match=0.0
4. ✅ 6-component combinedScore: 5 professional components × 0.92 + baseThompsonScore × 0.08
5. ✅ Location scoring (Haversine + timezone-aware for remote, distance-aware for onsite/hybrid)
6. ✅ RIASEC cosine similarity (RIASECProfile.cosineSimilarity() wired)
7. ✅ Work activities cosine similarity (dict-based, falls back to 0.5 when no O*NET data)
8. ✅ Performance gate test: `ScoringEngine/Tests/ScoringEngineTests/ScoringEngineTests.swift`
   - testScoringPerformance() asserts <10ms for 100-job batch
   - testCombinedScore_alwaysInZeroToOne() asserts score bounds
   - testTitleMatch_* asserts 3-tier match ordering
   - NOTE: Tests compile clean. Execution requires simulator (Core Data bundle) — run in Phase 4 once app boots

**Phase 3 — Scoring: COMPLETE (2026-05-16)**
Clean build confirmed. Performance test written — execution deferred to Phase 4 simulator.

**Phase 4 — User Flow: COMPLETE (2026-05-16)**
- 4-tab root (Discover/Tracker/Profile/Manifest) in AppShell ✅
- DeckScreen: card stack, drag gesture, triggerSwipe, Thompson wiring ✅
- JobCardView: score badge, swipe overlays, skills chips ✅
- SyntheticJobs: 20 hardcoded jobs, isolated for Phase 5 replacement ✅
- OnboardingView: 3-step (name → roles → location) → writes Core Data UserProfile ✅
- CDUserProfile NSManagedObject with KVC for Transformable arrays ✅
- OptimizedThompsonEngine.scoreJobs signature: `JobNormalizer.UserProfile` (resolved ambiguity) ✅
- ManifestAndMatchApp.swift wired: initialize() at launch, viewContext injected ✅
- Gate PASSED: amber_primary alpha=4.0 (was 1.0), teal_primary alpha=14.0 — persistence confirmed across kill+relaunch ✅

**Current task: Phase 5 — Revenue**
Read `new_build_requirements/` for Phase 5 plan before writing any code.

---

## Pre-Build Audit: COMPLETE (2026-05-15)

Package naming audit done. All 15 packages audited against live workspace (confirmed via XcodeBuildMCP). Names approved. Authoritative mapping: `context/PACKAGE_NAMES.md`. DECISIONS.md updated.

---

## Key Decisions Already Made (read DECISIONS.md for full detail)

- App structure: use existing V7 as guide — keep working parts, rebuild clean
- 4 tabs: Discover (0), Tracker (1), Profile (2), Manifest (3)
- The role slider: one slider, controls Thompson Sampling weights, current role vs future role intent
- Job card color: per-card amber→teal spectrum showing current/future fit ratio — this is the score made visual
- Question cards: need-based pull, not scheduled — triggered by RIASEC data gaps + slider position
- Revenue: ads in job card space + course affiliates in Manifest tab
- Backend: Cloudflare Workers API proxy (keys never in app binary)
- No redesign — take the working guts, build them correctly once

## What Is NOT Decided Yet

- AI systems implementation — READ THE CODE FIRST
- Ad card implementation — READ THE CODE FIRST
- OPEN_QUESTIONS.md contains questions that may have wrong assumptions — treat as drafts, not decisions

---

## Phase Sequence (after pre-build audit)

1. **Phase 1 — Foundation:** Package DAG, Core Data schema (21 entities), SacredUIConstants
2. **Phase 2 — Data Flow:** ThompsonArm persistence, ManifestInferenceActor threshold = 3
3. **Phase 3 — Scoring:** 6-component combinedScore, 3-tier title match, ThompsonBridge wired correctly
4. **Phase 4 — User Flow:** Deck screen, tab structure, onboarding, Tracker tab CRM
5. **Phase 5 — Revenue:** Ad cards + course affiliates wired into card space
6. **Phase 6 — Connection:** Remaining orphaned components cleaned up

**Completion gate for each phase is in the relevant build plan in `new_build_requirements/`**

---

## Files to Read at Session Start

1. This file (BUILD_SEQUENCE.md)
2. DECISIONS.md — what has been decided
3. CLAUDE_CAPABILITIES.md — tools and session workflow
4. CLAUDE.md — communication rules and folder map

---

## Session End Checklist

1. Update this file — mark done, note blockers
2. Log any new decisions in DECISIONS.md
3. Commit and push to both repos if code was written
