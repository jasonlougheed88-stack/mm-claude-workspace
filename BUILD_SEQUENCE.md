# Build Sequence — Manifest & Match
**Read this first. Every session. Before touching anything.**
Last updated: 2026-05-20

---

## ⚠️ CURRENT SESSION STATUS — READ BEFORE DOING ANYTHING

**Phases 1–6 COMPLETE. Phase 7 is next.**
**Last updated: 2026-05-21. Build: zero errors, zero warnings. Commit: see Phase 6 gate below.**

---

## IMMEDIATE NEXT TASK — Phase 7: Taxonomy + Job Pipeline

Read Phase 7 detail below before starting. CoreTaxonomy and JobPipeline packages exist as stubs — Phase 7 fills them with real data and systems.

⚠️ Phase 7 is 2–3 sessions of heavy work. Read the full scope before starting any session.

---

## SESSION TOOLING NOTES (read before building)

**XcodeBuildMCP in web sessions:** XcodeBuildMCP connects (`claude mcp list` shows ✓) but its tools do not surface via ToolSearch in the web interface. Use terminal Claude Code sessions for any work that requires simulator interaction (build-and-run, screenshot, tap, swipe). The web session can write code and do builds via `xcodebuild` CLI, but cannot drive the simulator UI.

**Git commit workflow:** Always commit using the worktree path, not the main repo root:
```bash
# CORRECT — commits to worktree branch
git -C "/Users/jasonl/Desktop/Claudes-Man&Man-build/.claude/worktrees/<worktree-name>" add ...
git -C "/Users/jasonl/Desktop/Claudes-Man&Man-build/.claude/worktrees/<worktree-name>" commit ...

# WRONG — commits directly to main (bypasses branch workflow)
git -C "/Users/jasonl/Desktop/Claudes-Man&Man-build" commit ...
```
In session 2026-05-20, the Phase 6 step 1 commit landed on `main` directly due to this. Code is correct but the PR workflow was bypassed. Future sessions should commit to the worktree branch and open a PR.

---

## IMMEDIATE NEXT TASK — Phase 6: Connection

### Phase 5 final state:
- Ad cards inject at correct ratio — real GoogleMobileAds SDK (11.13.0) with test IDs ✅
- AdMob native ad validator: no implementation issues ✅
- ATT consent fires on onboarding ✅
- Affiliate links built — empty production credential strings (swap when accounts ready) ✅
- Real jobs from JSearch ✅

### Still needs production credentials (swap when ready, no code changes needed):
- `NativeAdLoader.swift:14` — replace test native ad unit ID
- `Info.plist` — replace test App ID with real AdMob App ID
- `AffiliateURLBuilder` — Coursera Rakuten ID + Udemy affiliate ID

### What is NOT live yet (blocked on external accounts):
- **Ads**: AdMob SDK not added. Placeholder UI only. Needs: AdMob account → App ID → Native Ad Unit ID → swap `AdPlaceholderTypes.swift` stubs for real SDK
- **Course affiliates**: Credential strings are empty. Links fall back to direct course URLs. Needs: Coursera Rakuten LinkShare ID + Udemy affiliate ID → add to `AffiliateURLBuilder` (or via Cloudflare proxy in Phase 6)

### Next session options:
1. If Jason has AdMob account ready — wire real AdMob SDK
2. If Jason has affiliate IDs ready — add to AffiliateURLBuilder
3. Otherwise — move to Phase 6 (Connection) and come back to credentials later

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

**Phase 5 gate — Step 4 (COMPLETE ✅ 2026-05-20):**
- ManifestTab shows CoursesView (not stub) ✅
- Empty state renders correctly — "Keep Swiping", teal sparkles ✅
- Course list loads after 3+ swipes ✅ (70% match scores visible)
- AffiliateTracker uses background context — save can never fail from viewContext dirty objects ✅
- Committed: `71940e5` — pushed to GitHub ✅

**Secondary bug noted for Phase 6:** JobInteraction.sessionID is nil on every swipe — those records are never saved. Not blocking Phase 5.

**Step 5 — Real jobs via JobPipeline: COMPLETE ✅**
- `JobPipelineClient.swift` — actor, RapidAPI JSearch endpoint, reads `JSEARCH_API_KEY` from scheme env var
- Exponential backoff on 429, persisted cross-launch in UserDefaults
- Falls back to `SyntheticJobs.all` silently if key missing or fetch fails
- `DeckScreen.loadJobs/reloadJobs/appendMoreJobs` updated — query = `desiredRoles.first ?? "Software Engineer"`
- Committed: `8a1367c` — pushed to GitHub ✅
- API key added to Xcode scheme by Jason ✅

**External blockers (still needed for Phase 6):**
| What | Status |
|---|---|
| Google AdMob account + App ID + Native Ad Unit ID | Not started |
| Coursera affiliate (Rakuten LinkShare) | Not started |
| Udemy affiliate | Not started |
| Job API key (JSearch on RapidAPI) | ✅ Done — in Xcode scheme |

**Phase 5 gate — INFRASTRUCTURE GATE PASSED ✅ (2026-05-20). Revenue gate PENDING credentials:**
- Ad card renders at ~position 10 in deck ✅
- Swipe on ad card does NOT update Thompson arms ✅
- Manifest tab shows CoursesView with empty state / course list ✅
- AffiliateTracker uses background context ✅
- Real jobs fetched from JSearch ✅
- Real AdMob ads serving ← BLOCKED on AdMob account
- Real affiliate commission links ← BLOCKED on Coursera + Udemy affiliate IDs

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

**Phase 6 — Close the Gaps: IN PROGRESS**

---

### Phase 6 Step 1 — 2026-05-20 ✅ (runtime verified 2026-05-21)

**What was fixed:**
| Fix | File | Detail |
|---|---|---|
| `JobInteraction.sessionID` nil | `DeckUI/Sources/DeckUI/DeckScreen.swift` | Added `@State private var sessionID = UUID()`. Set on every `recordInteraction()` call. Swipe records now carry a session identifier that groups interactions by app session. |
| Card color identical across all cards | `DeckUI/Sources/DeckUI/JobCardView.swift` | `scoreColor` was using global `profileBlend` (slider) — every card was the same hue. Now uses `job.thompsonScore?.personalScore ?? profileBlend`. Each card gets a unique color from its per-job Thompson signal. |
| TrackerTab stub | `AppShell/Sources/AppShell/TabViews.swift` | Replaced placeholder with `@FetchRequest` on `JobInteraction` filtered to `action == "interested" OR "applied"`. Shows job title, company, date. Empty state when no interactions. |

**Runtime verification — PASSED 2026-05-21:**
- Swipe right → job appears in Tracker tab ✅
- JobInteraction records save with non-nil sessionID ✅ (4 records confirmed in SQLite)
- UserProfile created by onboarding, saves cleanly ✅
- Root cause found and fixed: 5 required Core Data attributes/relationships had no
  values set at creation time, silently blocking ALL viewContext saves. Fixed by making
  them optional in the schema + proper initialization in awakeFromInsert.

**Commit:** `72ee087` (step 1 code) + `2a9b8f1` (gate fix) on `main` — pushed to GitHub ✅

---

### Phase 6 Remaining — COMPLETE ✅ (2026-05-21)

1. **Question card injection** ✅ — fires after every 10 job swipes. Career-exploration questions mapped to RIASEC. Answer writes `riasecXxxDirect` + `riasecDirectConfidence` to InferredManifestProfile.
2. **SwipePatternAnalyzer → ManifestInferenceActor** ✅ — stateless analyzer extracts investigative/enterprising signals from swipe history. ManifestInferenceActor calls it on every inference cycle.

**New files (Phase 6 step 2):**
- `Intelligence/Sources/Intelligence/SwipePatternAnalyzer.swift`
- `Intelligence/Sources/Intelligence/QuestionCard.swift`
- `DeckUI/Sources/DeckUI/QuestionCardSheet.swift`

**Phase 6 gate — PASSED ✅ 2026-05-21:**
- Tracker tab captures right-swipes ✅
- Card colors are per-job ✅
- Question card fires after 10 swipes ✅
- RIASEC answer saved: enterprising=0.15, direct_conf=0.15 (confirmed SQLite) ✅
- SwipePatternAnalyzer: investigative_inferred=0.20 from swipe patterns ✅
- Build: zero errors, zero warnings ✅

---

## ROADMAP TO COMPLETION

This is the honest picture of what remains. The skeleton is complete (15 packages, 21 Core Data entities, clean build). The systems that make the app what it's supposed to be are mostly unbuilt — they exist in the V7/V8 reference and the Untangling Guide has decisions for all of them.

**Why this order:** `riasecScore` and `workActivitiesScore` need data on the JOB side (O*NET enrichment — Phase 7) AND the USER side (question cards — Phase 8). Taxonomy before Intelligence means as soon as question cards fire, both sides have data and scoring becomes fully functional immediately.

### Phase 6 — Close the Gaps ✅ COMPLETE (2026-05-21)
- ✅ SessionID on swipe records
- ✅ Card color per-job signal
- ✅ Tracker tab live
- ✅ Runtime verification (2026-05-21)
- ✅ Question card injection in DeckScreen
- ✅ SwipePatternAnalyzer → ManifestInferenceActor
- **Gate passed 2026-05-21** ✅

### Phase 7 — Taxonomy + Job Pipeline *(2–3 sessions)*
Fill CoreTaxonomy and rebuild JobPipeline properly. Must happen BEFORE Phase 8 — O*NET enrichment feeds the job side of riasecScore and workActivitiesScore. Without it, question cards fire but scoring can't use the answers.
- `CoreTaxonomy` filled: SkillTaxonomy (787 skills, 36 categories), O*NET data bundle (13 JSON files), EnhancedSkillsMatcher, OccupationAdjacencyService, CareerRelationshipDiscovery, AppState
- `JobPipeline` filled: JobONetEnricher, ONetCodeMapper, LocationScoringEngine, JobDiscoveryCoordinator, SmartSourceSelector, RateLimitManager, ProfileEnrichmentService
- At profile creation: run JobONetEnricher on user's declared role → populates onetWorkActivities + RIASEC on UserProfile
- **Gate:** Jobs have real O*NET data. workActivitiesScore and riasecScore have job-side data. Skills matching is semantic.

### Phase 8 — Intelligence Pipeline *(3–4 sessions)*
Lift ~18 systems from V7/V8 reference into Intelligence package. All are "lift as-is" per Untangling Guide. Read reference files BEFORE writing anything.
- Question cards end-to-end: QuestionTimingCoordinator, SmartQuestionGenerator, ManifestAwareQuestionGenerator, FallbackQuestionCoordinator, CareerQuestionsSeed
- Answer pipeline: UserTruthsExtractionActor, AnswerParsingActor, RIASECScorer (iOS 26 Foundation Models), RIASECKeywordMapper (fallback)
- FastBehavioralLearning, DeepBehavioralAnalysis, SwipePatternAnalyzer (full implementation)
- KeychainManager, CoverLetterService, MatchExplanationGenerator, TealPathGenerator, AICareerProfileBuilder
- ThompsonBridge + ThompsonCareerIntegrator — port from reference, inline bonus calls into OptimizedThompsonEngine.scoreJobs()
- **Gate:** Question cards fire when RIASEC data gaps exist. User RIASEC profile builds from answers. ThompsonBridge applies UserTruths bonus. Both sides of riasecScore populated — Teal mode works end-to-end. Cover letters generate.

### Phase 9 — Career Track *(1–2 sessions)*
Wire Manifest tab career intelligence. Requires Phase 7 (SkillTaxonomy) and Phase 8 (InferredManifestProfile quality).
- CareerPathEngine wired into ManifestTabView
- SkillsGapAnalyzer wired
- MarketDemandAPI (bundled BLS labor demand data)
- **Gate:** Manifest tab is a map — career paths, skill gaps, courses that close specific gaps. Track 2 complete.

### Phase 10 — Resume + Profile *(1–2 sessions)*
Fill ResumeParsing package and wire into onboarding.
- ResumeParsingService, OpenAIClient, PDFTextExtractor, SkillsExtractor
- Onboarding resume upload parses (currently fails silently — ResumeParser called with nil API key)
- KeychainManager wired at call site
- **Gate:** Resume upload populates skills, work history, RIASEC data on day one.

### Phase 11 — User Flow Polish *(1 session)*
No dead ends. Legal pages required for App Store.
- ProfileScreen settings stubs → real views (Privacy Policy, Terms of Service, Data Management — required for App Store + GDPR/CCPA)
- Onboarding preview → real scored jobs (currently hardcoded 87%/72%/91%)
- ThompsonExplanationEngine inline card explanation
- **Gate:** End-to-end user flow test passes. No blank screens. Legal requirements met.

### Phase 12 — Backend + Launch *(1–2 sessions)*
- Cloudflare Workers proxy (API keys never in app binary — BACKEND_PLAN.md exists)
- Production credentials: AdMob App ID (swap 2 string constants), Coursera Rakuten ID + Udemy affiliate ID
- Privacy manifest (required for App Store 2025)
- TestFlight build → App Store submission
- **Gate:** App ships.

---

## External Credentials Needed (no code changes required — just swap constants)

| What | Where to swap | Status |
|---|---|---|
| AdMob App ID | `Info.plist` → `GADApplicationIdentifier` | ⬜ Pending AdMob account |
| AdMob Native Ad Unit ID | `NativeAdLoader.swift:14` | ⬜ Pending AdMob account |
| Coursera Rakuten ID | `AffiliateURLBuilder` | ⬜ Pending affiliate account |
| Udemy affiliate ID | `AffiliateURLBuilder` | ⬜ Pending affiliate account |
| JSearch API key | Xcode scheme env var `JSEARCH_API_KEY` | ✅ Done |

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
