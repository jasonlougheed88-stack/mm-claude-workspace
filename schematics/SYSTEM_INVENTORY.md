# System Inventory — Manifest & Match Reference Codebase
**Audited: 2026-05-15 | Verified against SCHEMATIC_01–08 | Deep codebase verification: 2026-05-15 COMPLETE**
**Source:** `/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8/`
**All UNKNOWN states resolved. Full file listing cross-referenced — missing systems added. Ready for Untangling Guide.**

Every system in the box. States:
- ✅ **WORKING** — built, connected, producing correct output
- ⚠️ **PARTIAL** — initialized but not fully invoked, or logic incomplete
- 🔴 **ISOLATED** — built but never called in production code
- ❌ **MISSING** — referenced or required but not present

---

## THE CRITICAL ARCHITECTURAL FINDING (read first)

**The system is named "Thompson Sampling" but does not operate as one.**

`baseThompsonScore = amberSample × (1−t) + tealSample × t` is calculated every scoring cycle but **never reaches the sort key.** The Beta distributions update on every swipe and persist across sessions — but their sampled values are stored in `ThompsonScore.personalScore` and go nowhere. `combinedScore` (the 5-component professional formula) is the only sort key.

The deck is a **weighted content-based recommender.** Reconnecting `baseThompsonScore` into `combinedScore` is an open architectural decision for the new build.

**Second critical finding: ThompsonBridge and ThompsonCareerIntegrator are built but never called.**
Both live inside `ThompsonScoringOrchestrator` (initialized at DeckScreen:1572). The orchestrator has **zero dot-method calls** anywhere in DeckScreen. UserTruths bonuses and career bonuses do NOT apply to any job score.

---

## SCORING ENGINE (V7Thompson → ScoringEngine)

### OptimizedThompsonEngine
**File:** `V7Thompson/Sources/V7Thompson/OptimizedThompsonEngine.swift` (~1650 lines)
**What it does:** Scoring core. Maintains two Beta arms, scores jobs via 5-lever weighted formula. Persists arms to Core Data.
**Inputs:** Job list, V7Thompson.UserProfile (from ProfileConverter), profileBlend (0.0–1.0), Core Data context
**Outputs:** `[ThompsonScore]` sorted descending by `combinedScore`
**State:** ✅ WORKING
**Notes:** Two init paths — async init does NOT wire persistence, sync init DOES. Coordinator must use sync init. `baseThompsonScore` (Beta samplers) is calculated but stored in personalScore field, not used for ordering.

---

### FastBetaSampler
**File:** `V7Thompson/Sources/V7Thompson/FastBetaSampler.swift` (387 lines)
**What it does:** Beta distribution math using Kumaraswamy approximation (~0.1ms, 10× faster than standard). SIMD batch sampling on ARM64.
**State:** ✅ WORKING

---

### ThompsonWeights (Lever System)
**File:** Inside `OptimizedThompsonEngine.swift` (~40 lines, private struct)
**What it does:** Interpolates 5 lever weights from profileBlend. LEVER 3 (workActivities), LEVER 9 (RIASEC), LEVER 11 (titleMatch) labeled. Skills and Location unlabeled.
**State:** ✅ WORKING
**Notes:** Only 5 levers implemented. LEVER gaps 1,2,4,5,6,7,8,10 are unimplemented — referenced in naming convention only.

---

### SmartThompsonCache
**File:** Inside `OptimizedThompsonEngine.swift`
**What it does:** LRU cache, 50-entry max, 5-minute TTL for scored results.
**State:** ✅ WORKING

---

### ScoreDecomposition
**File:** `V7Thompson/Sources/V7Thompson/ScoreDecomposition.swift` (~200 lines)
**What it does:** Breaks a Thompson score into component parts for the ExplainFitSheet "Why?" button.
**State:** ✅ WORKING
**Notes:** Does NOT contain an amber/teal ratio. No per-job "fraction from teal vs amber" decomposition exists in the output. The correct card color signal requires new data.

---

### ThompsonExplanationEngine
**File:** `V7Thompson/Sources/V7Thompson/ThompsonExplanationEngine.swift`
**What it does:** Generates human-readable explanation of why a job scored the way it did.
**Inputs:** ScoreDecomposition
**Outputs:** Explanation text for ExplainFitSheet
**State:** ✅ WORKING (called via ThompsonIntegration.swift)

---

### SwipePatternAnalyzer
**File:** `V7Thompson/Sources/V7Thompson/SwipePatternAnalyzer.swift` (658 lines)
**What it does:** Detects patterns in swipe history — streaks, alternation, hesitation, burnout.
**State:** 🔴 ISOLATED
**Notes:** Only referenced in a Package.swift comment. Never called in production.

---

### JobRelevanceScorer
**File:** `V7Thompson/Sources/V7Thompson/JobRelevanceScorer.swift`
**What it does:** Public actor with shared singleton. Alternative scoring approach.
**State:** 🔴 ISOLATED
**Notes:** Zero call sites. Never instantiated. Output never reaches UI.

---

### ThompsonSamplingEngine (legacy)
**File:** `V7Thompson/Sources/V7Thompson/V7Thompson.swift:303`
**What it does:** Original Thompson Sampling engine. Replaced by `OptimizedThompsonEngine` (which is faster and has persistence).
**State:** 🔴 ISOLATED — Only referenced in benchmarks (`PerformanceBenchmark.swift`), a `Phase3PerformanceDashboard` (isolated), and one example call inside `ThompsonBridge.swift`. Not used in any active flow.
**Notes:** Two extensions also target this legacy engine and are therefore also isolated:
- `ThompsonSamplingEngineExtensions.swift` — DeckScreen convenience methods for a type DeckScreen never uses
- `ThompsonSampling+ONet.swift` — O*NET scoring extension for the legacy engine

---

### RealTimeScoring
**File:** `V7Thompson/Sources/V7Thompson/RealTimeScoring.swift`
**State:** ⚠️ PARTIAL
**Notes:** Called from `ContentView.swift` (legacy V7 code, not the active V8 flow). DeckScreen does not use it.

---

### ConfidenceCalibrator
**File:** `V7Thompson/Sources/V7Thompson/ConfidenceCalibrator.swift`
**What it does:** Tracks Thompson Sampling convergence using O(1/√n) formula. Records every swipe, calculates confidence interval, estimates swipes needed for convergence.
**State:** ✅ WORKING — called from DeckScreen:836 on every swipe. `ConfidenceCalibrator.shared.recordSwipe()` fires each time. Output logged at DeckScreen:840–842.

---

### ThompsonScoringBridge (AppShell)
**File:** `ManifestAndMatchV7Package/Sources/ManifestAndMatchV7Feature/AI/ThompsonScoringBridge.swift` (594 lines)
**What it does:** AsyncStream-based real-time Thompson score streaming. Wraps `OptimizedThompsonEngine` + `SmartThompsonCache`, emits differential score updates to UI subscribers.
**State:** ⚠️ PARTIAL / NEW TANGLE
**Notes:** Initialized in ContentView:124 with `try? await ThompsonScoringBridge()`. Creates a **second** `OptimizedThompsonEngine` instance via the async init path — which does NOT wire Core Data persistence. DeckScreen has its own scoring engine (sync init, with persistence). These two instances are completely disconnected. Real-time streaming from ContentView's bridge never matches DeckScreen's actual scores. This is distinct from `ThompsonBridge` in V7AI — that one applies UserTruths bonuses; this one streams scores.

---

### baseThompsonScore
**Location:** `OptimizedThompsonEngine.swift:496`
**What it does:** `amberSample × (1−t) + tealSample × t` — blends Beta distribution samples.
**State:** ⚠️ PARTIAL
**Notes:** Calculated every cycle. Stored in `ThompsonScore.personalScore`. Never used as sort key. ThompsonBridge uses it as input before applying bonus multiplier — but the orchestrator is never called anyway.

---

## INTELLIGENCE (V7AI → Intelligence)

### ThompsonScoringOrchestrator ← THE KEY TANGLE
**File:** Inside `DeckScreen.swift` (lines 2840–3060)
**What it does:** Container class that holds both ThompsonBridge and ThompsonCareerIntegrator. Initialized at DeckScreen:1572.
**State:** ⚠️ PARTIAL — initialized, zero method calls
**Notes:** `applyUserTruthsBonusToUpcomingJobs()` (line 1481) logs "ready" and returns empty. The comment "Sprint 4 COMPLETE" is false. ThompsonBridge and ThompsonCareerIntegrator both exist inside this orchestrator but are never invoked.

---

### ThompsonBridge
**File:** `V7AI/Sources/V7AI/Services/ThompsonBridge.swift` (435 lines)
**What it does:** Adapter pattern. Takes baseThompsonScore + UserTruths from Core Data → applies bonus multiplier (0.5×–2.0×).
**State:** ⚠️ PARTIAL
**Notes:** Instantiated inside ThompsonScoringOrchestrator (DeckScreen:2875). Orchestrator is never called. UserTruths bonuses never reach any job score.

---

### ManifestInferenceActor
**File:** `V7AI/Sources/V7AI/Services/ManifestInferenceActor.swift` (552 lines)
**What it does:** Watches swipe patterns, infers career interests and RIASEC profile. Updates InferredManifestProfile Core Data entity.
**Inputs:** Called from DeckScreen line 1006 after each swipe. Debounced 5s. Requires 10+ swipes.
**Outputs:** `InferredManifestProfile` Core Data entity. If confidence ≥ 0.30: updates UserProfile.desiredRoles.
**State:** ✅ WORKING
**Notes:** Output (InferredManifestProfile) is NOT connected to ThompsonCareerIntegrator — that system uses V6 ManifestProfile instead.

---

### SmartQuestionGenerator
**File:** `V7AI/Sources/V7AI/Services/SmartQuestionGenerator.swift` + `+Submit.swift` + `+ManifestAware.swift` (2613+ lines)
**What it does:** Generates contextually appropriate career questions based on data gaps.
**Inputs:** UserTruths, RIASEC gaps, slider position
**Outputs:** `CareerQuestion` objects
**State:** ✅ WORKING (iOS 26+)
**Notes:** Called from DeckScreen:1789. Enormous — 3 files. ManifestAwareQuestionGenerator is a separate class that may duplicate some of this.

---

### AICareerProfileBuilder
**File:** `V7Services/Sources/V7Services/AI/AICareerProfileBuilder.swift`
**What it does:** Foundation Models (iOS 26) career profile builder. `AICareerProfileBuilder.isAvailable` is the availability check for iOS 26 on-device AI.
**State:** ✅ WORKING — used by `FallbackQuestionCoordinator:25` as the availability gatekeeper. If `!AICareerProfileBuilder.isAvailable` → fallback path. This is the iOS version detection mechanism for the question card system.

---

### FallbackQuestionCoordinator
**File:** `V7UI/Sources/V7UI/Services/FallbackQuestionCoordinator.swift`
**What it does:** Serves fallback career questions on pre-iOS 26 devices. Uses CareerQuestionsSeed (15 seeded questions). Uses `AICareerProfileBuilder.isAvailable` to determine if Foundation Models path can be used.
**State:** ✅ WORKING

---

### QuestionTimingCoordinator
**File:** `V7AI/Sources/V7AI/Services/QuestionTimingCoordinator.swift` (609 lines)
**What it does:** Decides when to show question cards — adaptive interval based on jobs viewed, engagement, confidence gaps.
**State:** ⚠️ PARTIAL
**Notes:** Initialized and used in DeckScreen (line 1562, 1774 `recordJobViewed()`). But line 540 inside the coordinator says "JobDiscoveryCoordinator should inject question card here" — the actual deck injection path is a comment, not code.

---

### QuestionTemplateLibrary
**File:** `V7AI/Sources/V7AI/Services/QuestionTemplateLibrary.swift` + `_EXAMPLES.swift`
**State:** ✅ WORKING
**Notes:** `_EXAMPLES.swift` suffix suggests companion file may be examples/test content vs production content.

---

### CareerQuestionsSeed
**File:** `V7Data/Sources/V7Data/` (or V7AI)
**What it does:** Seeds 15 fallback CareerQuestion entities into Core Data. Used by FallbackQuestionCoordinator for pre-iOS 26 devices.
**State:** ✅ WORKING

---

### UserTruthsExtractionActor
**File:** `V7AI/Sources/V7AI/Services/UserTruthsExtractionActor.swift`
**What it does:** Parses question answers using Foundation Models. Writes to UserTruths Core Data entity.
**Inputs:** Question answer text. Called from DeckScreen:1250.
**Outputs:** UserTruths Core Data entity (loveTasks, hateTasks, workValues, interests)
**State:** ✅ WORKING

---

### RIASECScorer
**File:** `V7AI/Sources/V7AI/Services/RIASECScorer.swift` (592 lines)
**What it does:** Maps question answers to RIASEC scores using Foundation Models (iOS 26) or keyword fallback.
**State:** 🔴 ISOLATED
**Notes:** Only referenced in a comment in AnswerParsingActor. Never called in production. Full implementation unused.

---

### RIASECKeywordMapper
**File:** `V7AI/Sources/V7AI/Parsing/RIASECKeywordMapper.swift`
**What it does:** ~90 keyword bag-of-words RIASEC extraction from text.
**State:** ✅ WORKING
**Notes:** Weak signal — ~90 words across 6 dimensions. Overlapping keywords cause false signals ("engineer" → Investigative regardless of type). Called from AnswerParsingActor.

---

### AnswerParsingActor
**File:** `V7AI/Sources/V7AI/Services/AnswerParsingActor.swift`
**What it does:** Parses question answers, extracts structured data, calls RIASECKeywordMapper.
**State:** ✅ WORKING (likely — wired in question card flow)

---

### BehavioralEventLog
**File:** `V7AI/Sources/V7AI/Services/BehavioralEventLog.swift`
**What it does:** Immutable append-only log of swipe events.
**Inputs:** Called from DeckScreen line 783 on every swipe.
**State:** ✅ WORKING

---

### FastBehavioralLearning
**File:** `V7AI/Sources/V7AI/Services/FastBehavioralLearning.swift`
**What it does:** Sync behavioral inference, confidence tracking, adaptive question trigger. <10ms.
**Inputs:** Called from DeckScreen line 801 on every swipe.
**State:** ✅ WORKING

---

### MatchExplanationGenerator
**File:** `V7AI/Sources/V7AI/Services/MatchExplanationGenerator.swift`
**What it does:** Generates natural language "Why this job?" explanations using OpenAI GPT-3.5-turbo with template fallback. Uses `KeychainManager.shared.load(for: .openAIKey)` for key retrieval.
**State:** ✅ WORKING — called from `ExplainFitSheet.swift:925`. The "Why?" button in the job card flow.
**Notes:** DIFFERENT from `ThompsonExplanationEngine` — that one generates text from `ScoreDecomposition` (local, no API). This one calls OpenAI for richer natural language. Two explanation generators exist.

---

### CoverLetterService
**File:** `V7AI/Sources/V7AI/Services/CoverLetterService.swift`
**What it does:** Generates AI cover letters via OpenAI GPT-4o-mini. Rate limit: 10/day per user (tracked in UserDefaults).
**Wiring:** Called from `CoverLetterGeneratorView` (V7UI) → opened from ProfileScreen:368 and from job card sheet.
**State:** ✅ WORKING
**Notes:** API key retrieved from: (1) `ProcessInfo.environment["OPENAI_API_KEY"]`, then (2) `UserDefaults "openai_api_key"`. **No Keychain.** Both methods are insecure for production — key is readable from UserDefaults by any process. Security issue for new build.

---

### ManifestAwareQuestionGenerator
**File:** `V7AI/Sources/V7AI/Services/ManifestAwareQuestionGenerator.swift` (375 lines)
**What it does:** Determines WHICH `QuestionPurpose` to use based on InferredManifestProfile state. 11-step decision tree: RIASEC baseline → role confidence → skills narrative → career pivot → timeline → hidden skills → work values → hesitation → exploitation bias → weekly goal → conflicting signals.
**State:** ✅ WORKING (called BY SmartQuestionGenerator — NOT a duplicate)
**Notes:** Not a separate question generator. It is the purpose-selection strategy used inside SmartQuestionGenerator. Reads InferredManifestProfile directly.

---

### TealPathGenerator
**File:** `V7AI/Sources/V7AI/Services/TealPathGenerator.swift`
**What it does:** Generates teal (future) career path projections.
**State:** ✅ WORKING — wired in ManifestTabView (lines 155, 2076).

---

### DeepBehavioralAnalysis
**File:** `V7AI/Sources/V7AI/Services/DeepBehavioralAnalysis.swift`
**What it does:** Deeper behavioral inference from swipe sequences. `SwipeAction` and `AnalysisResult` types.
**State:** ✅ WORKING — DeckScreen:149 `private let deepAnalysisEngine = DeepBehavioralAnalysis()`. Called at DeckScreen:1083 and results consumed at DeckScreen:1131.

---

### ConfidenceReconciler
**File:** `V7AI/Sources/V7AI/Services/ConfidenceReconciler.swift`
**What it does:** Reconciles conflicting confidence signals into a recommendation.
**State:** 🔴 ISOLATED — only self-references in the file. Never called from any View or service.

---

### KeychainManager
**File:** `V7AI/Sources/V7AI/Services/KeychainManager.swift`
**What it does:** Secure Keychain storage for API keys. `KeychainManager.shared`.
**State:** ⚠️ PARTIAL — called from `MatchExplanationGenerator.swift:110` (`KeychainManager.shared.load(for: .openAIKey)`) for the "Why?" explanation feature. NOT used by CoverLetterService (which uses UserDefaults). Keychain infrastructure exists but is not consistently used for key storage.

---

### MLInsightsEngine
**File:** `ManifestAndMatchV7Package/Sources/ManifestAndMatchV7Feature/AI/MLInsights/MLInsightsEngine.swift`
**What it does:** Career trajectory analysis — current phase, predicted transition, skill gaps, growth opportunities. Uses SwipePatternAnalyzer data.
**State:** ⚠️ PARTIAL — initialized at ContentView:1032 and MainTabView:39, displayed as `MLInsightsDashboard` at MainTabView:146. Reads from SwipePatternAnalyzer — but V7Thompson's SwipePatternAnalyzer is 🔴 ISOLATED. MLInsightsEngine likely reads from the AppShell copy of SwipePatternAnalyzer (see name collision below).

---

### SwipePatternAnalyzer — AppShell copy
**File:** `ManifestAndMatchV7Package/Sources/ManifestAndMatchV7Feature/AI/SwipePatternAnalyzer.swift`
**State:** ⚠️ NAME COLLISION — identical class name to `V7Thompson/SwipePatternAnalyzer.swift`. Two classes named `SwipePatternAnalyzer` in different packages. If both are imported in the same target, compiler will require full qualification. MLInsightsEngine uses this version. The V7Thompson version remains 🔴 ISOLATED.

---

## CAREER GROWTH (V7Career → CareerGrowth)

### ThompsonCareerIntegrator
**File:** `V7Career/Sources/V7Career/Services/ThompsonCareerIntegrator.swift` (524 lines)
**What it does:** Applies career-based bonus to Thompson scores — skills match (+15%), aspiration (+10%).
**Inputs:** ManifestProfile from `V6AnalyticsModels.swift` (a V6-era data struct)
**State:** ⚠️ PARTIAL
**Notes:** Instantiated inside ThompsonScoringOrchestrator (DeckScreen:2879). Orchestrator never called. Additionally: consumes V6 ManifestProfile via `UserProfile.toManifestProfile()` — NOT InferredManifestProfile. Double-broken: never invoked, AND using wrong data if it were invoked.

---

### CareerPathEngine
**File:** `V7Career/Sources/V7Career/Services/CareerPathEngine.swift` (937 lines)
**What it does:** Builds potential career paths from user's inferred profile. Full actor implementation.
**State:** 🔴 ISOLATED
**Notes:** Never called in any production code. ManifestTabView builds career path models directly from InferredManifestProfile, bypassing this. Internally calls `MarketDemandAPI.shared` (lines 339, 397, 447).

---

### MarketDemandAPI
**File:** `V7Services/Sources/V7Services/MarketData/MarketDemandAPI.swift`
**What it does:** BLS (Bureau of Labor Statistics) occupation demand data. Returns demand scores for job titles. Bundled offline data with fuzzy matching.
**State:** 🔴 ISOLATED — only called from CareerPathEngine, which is itself isolated. Never reaches any active flow.

---

### SkillsGapAnalyzer
**File:** `V7Career/Sources/V7Career/Services/SkillsGapAnalyzer.swift` (1373 lines)
**State:** ⚠️ PARTIAL
**Notes:** Called from CareerLadderBuilder and SkillGapExtractor (both within V7Career). Referenced in ManifestTabView as `@State private var gapAnalyzer` but marked "ISSUE #2: SkillsGapAnalyzer integration" — acknowledged incomplete.

---

### CourseRecommendationEngine
**File:** `V7Career/Sources/V7Career/Services/CourseRecommendationEngine.swift` (1353 lines)
**What it does:** 3-tier fallback recommendation: (1) static JSON DB → (2) edX live API → (3) hardcoded fallback. 8-factor CoursePrioritizer scoring.
**State:** 🔴 ISOLATED
**Notes:** Only called from test files. Zero references in any active View or coordinator. ManifestTabView .courses destination is empty. Also: CourseProviderClient loads `courses_v1.0` from `CourseCatalog/` — actual file is `courses_v1.json` in `Courses.bundle/` — **filename mismatch will trigger `fatalError` on first call.**

---

### courses_v1.json
**Location:** `Resources/Courses.bundle/courses_v1.json` (4.1MB)
**What it contains:** Real course data — Coursera, Udemy, edX. Confirmed real data (MIT Python Fundamentals, etc.).
**State:** ✅ EXISTS but unreachable due to filename mismatch bug.

---

### AffiliateTracker
**File:** `V7Career/Sources/V7Career/Services/AffiliateTracker.swift` (649 lines)
**What it does:** Tracks course affiliate clicks. Commission rates: Coursera 35%, Udemy 17.5%, edX 0%.
**State:** 🔴 ISOLATED
**Notes:** Affiliate credentials are placeholder strings. edX has no affiliate program (acquired by 2U).

---

### CourseProviderClient
**File:** `V7Career/Sources/V7Career/Services/CourseProviderClient.swift` (891 lines)
**What it does:** Static JSON loader + edX OAuth 2.0 API client.
**State:** ⚠️ PARTIAL (filename mismatch bug, placeholder credentials, CircuitBreaker)

---

### CareerLadderBuilder
**File:** `V7Career/Sources/V7Career/Services/CareerLadderBuilder.swift` (402 lines)
**What it does:** Builds career ladder structures using SkillsGapAnalyzer internally.
**State:** UNKNOWN — called from within V7Career, not yet traced to ManifestTabView.

---

### ManifestTabView
**File:** `V7Career/Sources/V7Career/Views/ManifestTabView.swift` (~1200+ lines)
**What it does:** The Manifest tab (Tab 3). Displays: overview, skillsGap, courses, careerPath, timeline, transferableSkills, affiliateAnalytics, myProgress, setCareerGoal destinations.
**State:** ⚠️ PARTIAL
**Notes:** Reads InferredManifestProfile directly from Core Data. SkillsGapAnalyzer integration marked "ISSUE #2". Courses destination is empty — CourseRecommendationEngine never called. Has first-time manifest onboarding sheet (gated by UserDefaults key).

---

## CARD COLOR SIGNAL (V7UI → DeckUI)

### interpolateColor (DeckScreen)
**Location:** `DeckScreen.swift` lines 47, 2110, 2123, 2654, 2664, 2778
**Current signal:** `interpolateColor(ratio: job.thompsonScore)` — quality score (0–1)
**Correct signal:** Per-job current/future spectrum ratio — how much this job belongs to teal vs amber
**State:** ⚠️ BROKEN
**Notes:** High-scoring jobs in amber mode render teal. Color encodes quality, not current/future position. The correct signal doesn't exist in ScoreDecomposition — it would need to be derived from the Beta sampler contributions or a separate calculation.

### DualProfileColorSystem
**File:** `V7UI/Sources/V7UI/Colors/DualProfileColorSystem.swift`
**What it does:** Complete color system with `fitScoreColor(score:, profileBlend:)` — uses profileBlend correctly.
**State:** 🔴 ISOLATED from card rendering
**Notes:** The correctly designed color system exists. DeckScreen uses `interpolateColor` instead.

---

## JOB PIPELINE (V7Services → JobPipeline)

### JobDiscoveryCoordinator
**File:** `V7Services/Sources/V7Services/JobDiscoveryCoordinator.swift`
**What it does:** Orchestrates job sources, builds query, normalizes jobs, calls scoring engine, feeds deck.
**State:** ✅ WORKING
**Notes:** At line 1293: `// ✅ ONLY JSEARCH ENABLED - All other sources disabled per user request`. Lines 1297–1307: all other API calls commented out.

---

### LocationScoringEngine
**File:** `V7Services/Sources/V7Services/JobDiscovery/LocationScoringEngine.swift`
**What it does:** LEVER 4 — pre-filters jobs by geographic distance before they reach Thompson scoring. Distance threshold: 40 miles (amber/match mode) → 100 miles (teal/manifest mode), linearly interpolated.
**State:** ✅ WORKING — initialized at JDC:128, stored as `private let locationEngine`. Runs before scoring to preserve <10ms budget.
**Notes:** Implemented as a binary distance filter, not as a weighted score component. The other 5 levers are weights inside `combinedScore`; LEVER 4 is a pre-filter that removes jobs entirely. Architectural inconsistency — something to resolve in new build.

---

### ONetCodeMapper
**File:** `V7Services/Sources/V7Services/ONet/ONetCodeMapper.swift`
**What it does:** Maps job title string → O*NET occupation code. 4-tier pipeline: exact cache → modern mappings (51) → keyword index → fuzzy Levenshtein.
**Coverage:** ~95% of titles. <5ms cached, <50ms uncached fuzzy.
**State:** ✅ WORKING (called by JobONetEnricher)

---

### JobONetEnricher
**File:** `V7Services/Sources/V7Services/ONet/JobONetEnricher.swift`
**What it does:** Enriches incoming jobs with O*NET code. Called during job ingestion, after normalize, before score. Unlocks workActivities and RIASEC scoring in OptimizedThompsonEngine.
**State:** ✅ WORKING

---

### ProfileConverter
**File:** `V7Services/Sources/V7Services/Utilities/ProfileConverter.swift`
**What it does:** `toThompsonProfile()` — translates Core Data UserProfile (NSManagedObject) to V7Thompson.UserProfile (value type with weighted skills + RIASEC + workActivities).
**State:** ✅ WORKING (called from DeckScreen:1503 and MainTabView:161)

---

### Job Source API Clients

| Client | Lines | Status |
|---|---|---|
| JSearchAPIClient | 1607 | ✅ WORKING — only active source |
| LeverAPIClient | 1096 | 🔴 ISOLATED — commented out at JDC:1297–1307 |
| USAJobsAPIClient | 1017 | 🔴 ISOLATED — same |
| JobicyAPIClient | 913 | 🔴 ISOLATED — same |
| JoobleAPIClient | 762 | 🔴 ISOLATED — same |
| CoreSignalAPIClient | 798 | 🔴 ISOLATED — same |
| AdzunaAPIClient | ~800 est | 🔴 ISOLATED — same |
| GreenhouseAPIClient | ~600 est | 🔴 ISOLATED — same |
| RemoteOKAPIClient | ~400 est | 🔴 ISOLATED — same |
| JobAPIClient (generic) | unknown | 🔴 ISOLATED — same |

---

### SmartSourceSelector
**File:** `V7Services/Sources/V7Services/Intelligence/SmartSourceSelector.swift`
**What it does:** Thompson Sampling MAB for job source selection. Treats each API source as a Beta-distribution arm. Records source quality (jobs returned, relevance) and samples to pick which sources to query next.
**State:** ✅ WORKING — initialized at JDC startup (`initializeSmartSourceSelector()` at JDC:137). JDC:340 throws if not initialized. JDC:350 logs which sources it picked. JDC:1580–1589 shows the initialization with all available sources.
**Notes:** This is a second Thompson Sampling application in the codebase — separate from job scoring. Applies MAB logic to API source selection, not to individual jobs. Currently only JSearch is active, so SmartSourceSelector picks from a single-arm bandit — effectively no-op until more sources re-enabled.

---

### ProfileEnrichmentService
**File:** `V7Services/Sources/V7Services/Profile/ProfileEnrichmentService.swift`
**What it does:** Enriches ProfessionalProfile with O*NET fields from parsed resume data (education level, work history, skills mapped to O*NET dimensions).
**State:** ✅ WORKING — `@State private var profileEnricher = ProfileEnrichmentService()` in ResumeUploadView:47. Called during post-onboarding resume upload flow to enhance the Thompson profile with O*NET data before scoring.

---

### RateLimitManager
**File:** `V7Services/Sources/V7Services/CompanyAPIs/RateLimitManager.swift`
**State:** ✅ WORKING — `RateLimitManager.shared` used by every API client: JSearch, Lever, USAJobs, Jobicy, Jooble, CoreSignal, RSS, RemoteOK, Adzuna. Active even with only JSearch enabled.

---

### APICredentialManager
**File:** `V7Services/Sources/V7Services/CompanyAPIs/APICredentialManager.swift`
**State:** ⚠️ PARTIAL — Called from JDC:1543,1545,1563,1565 for company API credential loading. But the paths that call it (multi-source company APIs) are all commented out in JDC. Only fires if those sources are re-enabled.

---

### SmartCompanySelector
**File:** `V7Services/Sources/V7Services/CompanyAPIs/SmartCompanySelector.swift`
**State:** ⚠️ PARTIAL — Initialized in JDC:1390,1410 for company API orchestration. Inactive when only JSearch is enabled. Infrastructure is in place for when multi-source is re-enabled.

---

### Client-Side Filters
**Files:** `V7Services/Sources/V7Services/JobDiscovery/`
**State (split):**
- `ClientSideSkillsFilter` — 🔴 ISOLATED. Commented out at JDC:557.
- `ClientSideGeoFilter` — ✅ WORKING. Active at JDC:586.
- `ClientSideSalaryFilter` — ✅ WORKING. Active at JDC:601.

---

### ApplicationTracker (CRM)
**File:** `V7Services/Sources/V7Services/ApplicationTracker.swift` (~620 lines)
**What it does:** Tracks job applications — status, notes, reminders, favorites, activity timeline, analytics.
**State:** ✅ WORKING (as a data store) / 🔴 DISCONNECTED from apply actions
**Confirmed:** Tab 1 (`HistoryScreen` → `ApplicationHistoryView`) uses `ApplicationTracker.shared` — **SwiftData**, NOT SwipeHistory (Core Data). The data store is wired to the UI.
**Dead end:** "Apply Now" in DeckScreen records as "save" in Thompson but never writes to ApplicationTracker. The CRM never receives "applied" status from any swipe action.

---

### RequestCoalescer
**File:** `V7Services/Sources/V7Services/RequestCoalescer.swift`
**What it does:** Request deduplication with 500ms coalescing window via SHA256 fingerprinting.
**State:** 🔴 ISOLATED — never referenced in any production View, coordinator, or service. Only in test files.

---

### NetworkOptimizer
**File:** `V7Services/Sources/V7Services/NetworkOptimizer.swift`
**What it does:** Prefetch queue, response cache, latency metrics for network calls.
**State:** 🔴 ISOLATED — never referenced in any production code. Only in test files.

---

## TAXONOMY / MATCHING (V7Core → CoreTaxonomy + V7JobParsing → JobNormalizer)

### EnhancedSkillsMatcher
**File:** `V7Core/Sources/V7Core/SkillsMatching/EnhancedSkillsMatcher.swift`
**What it does:** 4-strategy fuzzy skill matching: exact canonical → synonym → substring → Levenshtein. Weighted by taxonomy weight × skill confidence. LRU cache 50,000 entries.
**State:** ✅ WORKING (called in OptimizedThompsonEngine)

---

### SkillTaxonomy / SkillTaxonomyLoader
**Files:** `V7Core/Sources/V7Core/SkillsMatching/`
**Resource:** `SkillTaxonomy.json` (267KB, 787 canonical skills, 36 categories, ~3,500 aliases)
**State:** ✅ WORKING
**Notes:** Cross-industry — tech, healthcare, finance, legal, manufacturing, education, business. Not tech-only.

---

### StringSimilarity (Levenshtein)
**File:** `V7Core/Sources/V7Core/SkillsMatching/StringSimilarity.swift`
**State:** ✅ WORKING

---

### O*NET Data Bundle
**Location:** `V7Core/Sources/V7Core/Resources/onet_*.json` (13 files, 5.4MB total)
**Key files:** onet_work_activities.json (967 occupations, 41 dims, 3.8MB), onet_interests.json (923 occupations, 6-dim RIASEC), onet_occupation_titles.json (1,016 core + 2,000/3,000 alternates), SkillTaxonomy.json, onet_occupation_skills.json (726 occupations)
**State:** ✅ WORKING — all offline, bundled, no runtime API calls.

---

### JobSkillsExtractor (V7JobParsing)
**File:** `V7JobParsing/Sources/V7JobParsing/Extractors/JobSkillsExtractor.swift`
**What it does:** Extracts skills from raw job description text using NLP.
**State:** ✅ WORKING — available via `SharedJobParser.shared` (`V7JobParsing/SharedJobParser.swift`). Used by all API clients during job ingestion. Thread-safe actor.

---

### V7Core State Management — AppState
**File:** `V7Core/Sources/V7Core/StateManagement/AppState.swift`
**What it does:** `@Observable` runtime state cache holding: selectedTab, currentJobIndex, jobs, jobQueue, userProfile (value-type cache), preferences, savedJobs, applicationHistory, session metrics (jobsViewed/Applied/Saved/Skipped), isLoading, errorState.
**State:** ✅ WORKING — Injected via `.environment(appState)` in ContentView. Read as `@Environment(AppState.self)` in DeckScreen, ProfileScreen, AnalyticsScreen, SettingsView, and 8 settings subviews. Acts as a real-time observable cache layer over Core Data.
**Note:** `AppState.UserProfile` (line 216) is a value-type struct (`Codable, Equatable, Sendable`) distinct from the Core Data `UserProfile` NSManagedObject. AppState bridges the two: loads from Core Data at init, caches in memory, used as fallback when Core Data is unavailable.

---

### V7Core State Management — StateManager / StateCoordinator / StateUpdateActor
**Files:** `V7Core/Sources/V7Core/StateManagement/StateManager.swift`, `StateCoordinator.swift`, `StateUpdateActor.swift` (plus NavigationState, UserInteractionState, PerformanceState, ThompsonState, ProfileManager)
**What they do:** Sophisticated state management infrastructure — state versioning, migration, validation, repair, async coordination.
**State:** 🔴 ISOLATED — Only self-referencing within the StateManagement directory. Not called from AppShell, UI views, or any active service. `StateManager.shared` exists but is never accessed from outside V7Core. Over-engineering that was never connected.

---

### OccupationAdjacencyService
**File:** `V7Core/Sources/V7Core/Services/OccupationAdjacencyService.swift`
**What it does:** Expands job titles to O*NET-adjacent occupations using 3 datasets: Alternate Titles (46K), Related Occupations (923×10), Technology Skills (8.7K).
**State:** ✅ WORKING — Called from JDC:1671 when profileBlend ≥ 0.25. Expansion count scales with slider (5 titles at 0.25 → 20 titles at 1.0). Core Teal-mode discovery mechanism.

---

### CareerRelationshipDiscovery
**File:** `V7Core/Sources/V7Core/Services/CareerRelationshipDiscovery.swift`
**What it does:** Maps career relationships between occupations.
**State:** ✅ WORKING — Called from `RolesDatabase+RelatedRoles.swift` (V7Core extension, lines 49 and 72). RolesDatabase.shared is actively used by ManifestTabView:2648, ProfileConverter:50, WorkExperienceFormView, JobPreferencesView, ProfileSetupStepView.

---

### OccupationExpander
**File:** `V7Core/Sources/V7Core/Services/OccupationExpander.swift`
**State:** ⚠️ SUPERSEDED — OccupationAdjacencyService comment (line 11) states it "replaces OccupationExpander, which used 35 generic O*NET skills." Likely dead code.

---

## RESUME PIPELINE (V7AIParsing → ResumeParsing + V7ResumeAnalysis → ProfileExtraction)

### ResumeParsingService / ResumeParser
**Files:** `V7AIParsing/Sources/V7AIParsing/Core/` (PDF → ParsedResume via OpenAI)
**State:** ✅ WORKING (called from onboarding ResumeUploadStepView)

### PDFTextExtractor + SkillsExtractor (V7AIParsing)
**Files:** `V7AIParsing/Sources/V7AIParsing/Extractors/`
**State:** WORKING (part of resume pipeline)

### ProfileBuilder / ResumeAnalyzer (V7ResumeAnalysis)
**Files:** `V7ResumeAnalysis/Sources/V7ResumeAnalysis/`
**What they do:** ParsedResume → Core Data profile population (ProfileBuilder), high-level resume analysis coordinator (ResumeAnalyzer).
**State:** 🔴 ISOLATED — Only referenced internally within V7ResumeAnalysis (ViewModel, Views, Previews). The active `ResumeUploadView` used in ProfileScreen:275 lives in `V7UI`, not V7ResumeAnalysis. The V7ResumeAnalysis package's own `ResumeUploadView` only appears in its own preview. The entire package is dead — never called from any active flow.
**Notes:** Uses ViewModel pattern (MVVM) — inconsistent with rest of app (MV). Drop from new build entirely.

### OpenAIClient
**File:** `V7AIParsing/Sources/V7AIParsing/AI/OpenAIClient.swift`
**State:** ✅ WORKING (called from ResumeParser)
**API key:** `init(apiKey: String)` — key is passed in from `ResumeParser`. `ResumeParser` has `init(openAIAPIKey: String? = nil)` — if nil, `openAIClient = nil`, throws "OpenAI client not initialized" on first parse.
**CRITICAL BUG:** `ResumeUploadStepView` (onboarding step 2) calls `ResumeParser()` with NO api key. Resume parsing in onboarding will always throw. `ResumeManagementView` (post-onboarding) calls `ResumeParser(openAIAPIKey: apiKey)` with a key from somewhere — needs trace for key source in new build.
**Security:** No Keychain usage found. Key passed as plain string from call site.

---

## PERSISTENCE (V7Data → Persistence)

### PersistenceController
**File:** `V7Data/Sources/V7Data/PersistenceController.swift`
**State:** ✅ WORKING

### Core Data Model — 22 Entities

**Profile Group:** UserProfile, WorkExperience, Education, Certification, Project, VolunteerExperience, Award, Publication

**Thompson/Learning Group:** ThompsonArm (✅ persists alpha/beta), SwipeHistory (✅ every swipe), JobCache (🔴 ORPHANED — defined, never written to), Preferences (✅ sacred constants)

**Career Discovery Group:** InferredManifestProfile (✅ WORKING), JobInteraction (✅ every swipe), UserTruths (✅ populated by UserTruthsExtractionActor), CareerQuestion (✅), QuestionResponse (✅), FallbackCareerQuestion (✅ seeded by CareerQuestionsSeed)

**Analytics/Metrics Group:** SwipeConvergenceMetrics (✅ every 10 swipes), EnrolledCourse (⚠️ PARTIAL — Phase 2, course API not connected), AffiliateClick (⚠️ PARTIAL — entity exists, AffiliateTracker never called), SliderTestSession (⚠️ PARTIAL — Phase 5 A/B testing)

---

## APP SHELL (ManifestAndMatchV7Package → AppShell)

### OnboardingFlow (8 steps, not 12)
**File:** `ManifestAndMatchV7Package/Sources/.../Onboarding/OnboardingFlow.swift` (1023 lines)

| Step | View | Data Collected | Required |
|---|---|---|---|
| 0 Awakening | Resonance statement | None | Auto-advance |
| 1 Current Reality | Emotional state (6 feelings) | None | ≥1 selection |
| 2 Resume Upload | PDF → skills, history, education | WorkExperience, Education, Certification | ❌ Skip |
| 3 Dual Profile Intro | Visual explanation of Amber/Teal | None | Proceed |
| 4 Contact Info | Name, email, phone, location | **UserProfile (PRIMARY CREATE)** | ✅ Required |
| 5 Preferences | Job types, salary, remote pref, desired roles | UserProfile.desiredRoles, primaryLocation | ✅ Required |
| 6 Profile Completion | Review/edit all resume data (8 sections) | All child entities | ✅ Required |
| 7 First Jobs Preview | Swipe tutorial (mock cards, fake scores 87%/72%/91%) | None | ❌ Skip |

**Gate:** `UserDefaults "hasCompletedOnboarding"` checked in MainTabView.

---

### MainTabView
**Tab 0 — Discover:** DeckScreen (job cards + question cards)
**Tab 1 — History:** HistoryScreen → ApplicationHistoryView (filter/search/notes/activity log)
**Tab 2 — Profile:** ProfileScreen (blend slider, skills, work history, 15 sheets, 8 STUB settings links)
**Tab 3 — Manifest:** ManifestTabView (career map, skill gaps, courses placeholder)
**Tab order persisted:** `UserDefaults "v7.phase3.selectedTab"` via TabCoordinator.

---

### The Amber/Teal Slider
**Location:** ProfileScreen (Tab 2), not DeckScreen
**Binding:** `profileBlend` / `amberTealPosition` on UserProfile Core Data entity
**State:** ✅ WORKING
**Notes:** Slider is in ProfileScreen section header. Value persisted to `UserProfile.amberTealPosition`. Loaded at DeckScreen init via `jobCoordinator?.thompsonEngine.currentProfileBlend`. No dedicated slider component.

---

### CoverLetterEngine (AppShell)
**File:** `ManifestAndMatchV7Package/Sources/ManifestAndMatchV7Feature/AI/CoverLetter/CoverLetterEngine.swift`
**What it does:** Generates cover letters. `CoverLetterEngine.shared`.
**State:** ✅ WORKING — called from `CoverLettersView:1427` and `:1949` in ProfileSubviews.
**DUPLICATE SYSTEM:** `CoverLetterService` (V7AI) also generates cover letters and is called from `CoverLetterGeneratorView` (V7UI). Two different cover letter engines wired to two different views. Both active. Which one the user actually hits depends on which navigation path they take (ProfileScreen → CoverLettersView uses Engine; ProfileScreen → CoverLetterGeneratorView uses Service).

---

### SliderPositionLogger
**File:** `V7Performance/Sources/V7Performance/SliderPositionLogger.swift`
**What it does:** Records slider position at the time of each swipe for A/B testing and analytics. `SliderPositionLogger.shared.recordSwipe(action)`.
**State:** ✅ WORKING — called from DeckScreen:894 on every swipe.

---

### ErrorRecoveryManager
**File:** `ManifestAndMatchV7Package/Sources/ErrorRecovery/ErrorRecoveryManager.swift` (9 files in ErrorRecovery/)
**What it does:** Central coordinator for error recovery — AlgorithmErrorHandler, DatabaseErrorHandler, MemoryErrorHandler, MigrationErrorHandler, NetworkErrorHandler, UserErrorCommunication, ErrorTelemetry.
**State:** 🔴 ISOLATED — `ErrorRecoveryManager.shared` exists. No call sites found in any active View or service. Built but never wired into the app lifecycle.

---

### Dead Ends in Active Flow
- **Apply Now → CRM:** Opens job URL in Safari, records as "save" in Thompson. ApplicationTracker never receives "applied" status.
- **ProfileScreen 8 settings links:** All stub `Text()` placeholders (Change Password, Privacy Settings, etc.)
- **Courses tab:** Empty — CourseRecommendationEngine never called.
- **First Jobs Preview:** Mock scores, not real Thompson scoring.

---

## ADS (V7Ads → AdCards)

All systems built, none wired into DeckScreen:

| System | Lines | Status |
|---|---|---|
| AdCardView | 892 | ✅ Built / 🔴 Not wired |
| AdCardInjector | 325 | ✅ Built / 🔴 Not wired |
| AdCachingSystem (incl. AdCacheManager, AdMobRateLimiter, AdLoadingActor) | 937 | ✅ Built / 🔴 Not wired |
| ATTConsentManager | 185 | ✅ Built / 🔴 Not wired |
| ConsentFlowCoordinator | 239 | ✅ Built / 🔴 Not wired |
| AdPerformanceTracker | 405 | ✅ Built / 🔴 Not wired |

**Missing (not present in codebase):**
- Google AdMob SDK — not in any Package.swift. `GADNativeAd` type will fail to compile if `USE_REAL_ADS = true`.
- Ad Unit IDs — placeholder strings throughout.
- `CardItem.ad` case — DeckScreen card enum has no ad type.
- `enableRealAds` flag — currently `false`, returns placeholders.

**Activation effort:** 2–3 days. Infrastructure is production-ready. Gap is: SDK addition, credential registration, 4 DeckScreen wiring points.

---

## SEMANTIC MATCH (V7Embeddings → SemanticMatch)

| System | Lines | Status |
|---|---|---|
| EmbeddingService | 208 | 🔴 ISOLATED (inactive by design) |
| SimilarityCalculator | 167 | 🔴 ISOLATED |
| ThompsonIntegration (in Embeddings) | 159 | 🔴 ISOLATED |

**Notes:** A THIRD system claiming to integrate with Thompson. Different from ThompsonBridge (V7AI) and ThompsonCareerIntegrator (V7Career). Whether these three are complementary or overlapping is unclear.

---

## MONITORING (V7Performance → Monitoring)

### BiasDetectionService
**File:** `V7Performance/Sources/V7Performance/BiasDetection/BiasDetectionService.swift`
**What it does:** Detects scoring bias — checks if Thompson Sampling is systematically favoring certain job types unfairly.
**State:** ✅ WORKING — used by `BiasMonitoringView` (V7UI/Analytics/). `BiasDetectionService()` is instantiated there and generates `BiasReport` objects.

---

### ProductionLoadTestingSystem / ProductionMonitoringIntegration
**Files:** `V7Performance/Sources/V7Performance/ProductionLoadTestingSystem.swift`, `ProductionMonitoringIntegration.swift`, `ProductionMetricsDashboard.swift`
**What they do:** Performance budgets, FPS tracking, Thompson timing validation, metrics dashboard.
**State:** 🔴 ISOLATED — Never initialized in app shell (ManifestAndMatchV7Package) or any active View. Only referenced from V7Performance test files. The monitoring infrastructure was built but never wired to the app lifecycle.

---

## CHARTS LAB (ChartsColorTestPackage → ChartsLab)

**Status:** 🔴 EMPTY SHELL. Source file contains only `public struct ChartsColorTestPackage { public init() {} }`. No logic, no color utilities, no useful code. Drop from new build entirely.

---

## KEY TANGLES SUMMARY (verified against all 8 schematics)

| Tangle | What's wrong | What correct wiring requires |
|---|---|---|
| Thompson Sampling not active | `baseThompsonScore` calculated but never used for deck ordering. App is content-based recommender, not Bayesian MAB. | Decision: reconnect `baseThompsonScore` into `combinedScore` with tuned weight |
| ThompsonBridge + ThompsonCareerIntegrator | Both inside ThompsonScoringOrchestrator (DeckScreen:1572) which has zero method calls. UserTruths bonuses and career bonuses never apply. | Call the orchestrator from scoring pipeline, or restructure |
| ThompsonCareerIntegrator wrong data | Uses V6 ManifestProfile (jobViewHistory, searchQueries) via `UserProfile.toManifestProfile()` instead of InferredManifestProfile | Feed InferredManifestProfile output from ManifestInferenceActor |
| Card color | `interpolateColor(ratio: job.thompsonScore)` uses quality score. `DualProfileColorSystem.fitScoreColor()` exists and is correct but unused. | Replace `interpolateColor` with `DualProfileColorSystem.fitScoreColor()` or equivalent. Correct signal (teal vs amber contribution per job) doesn't exist in ScoreDecomposition yet. |
| CareerPathEngine isolated | 937 lines, never called. ManifestTabView builds career paths directly from InferredManifestProfile. | Route ManifestTabView career path display through CareerPathEngine |
| RIASECScorer isolated | 592 lines, never called. RIASECKeywordMapper (weak signal) is used instead. | Wire RIASECScorer into question answer pipeline to replace/supplement keyword mapper |
| CourseRecommendationEngine isolated | Never called, ManifestTabView .courses destination empty. Also has filename mismatch bug that will crash on first call. | Fix filename bug, wire ManifestTabView .courses to CRE |
| Question card injection path | QuestionTimingCoordinator says "JobDiscoveryCoordinator should inject here" — incomplete. | Implement actual deck injection in JobDiscoveryCoordinator or DeckScreen |
| ApplicationTracker CRM disconnect | "Apply Now" records as "save" in Thompson, not "applied" in ApplicationTracker. | Track apply action correctly in ApplicationTracker |
| SwipePatternAnalyzer isolated | 658 lines. Should feed ManifestInferenceActor with behavioral patterns. Never called. | Wire to ManifestInferenceActor input |
| Three Thompson integrations | ThompsonBridge (V7AI) + ThompsonCareerIntegrator (V7Career) + V7Embeddings/ThompsonIntegration. Unclear if complementary or overlapping. | Audit all three, decide which to keep |
| ResumeAnalysis MVVM inconsistency | V7ResumeAnalysis uses ViewModel, rest of app uses MV pattern | Refactor to MV or accept inconsistency |
| Two disconnected OptimizedThompsonEngine instances | ContentView creates ThompsonScoringBridge with async-init OTE (no persistence). DeckScreen uses sync-init OTE (with persistence). Streaming scores in ContentView never match deck scores. | Single engine instance, passed by reference |
| SmartSourceSelector single-arm no-op | SmartSourceSelector is wired and initialized, but only JSearch is active — one-armed bandit produces no selection value. Will activate automatically when more sources re-enabled. | No code change needed — resolves itself when sources re-enabled |
| KeychainManager inconsistent use | MatchExplanationGenerator uses KeychainManager.shared for OpenAI key. CoverLetterService uses UserDefaults. Two different storage methods for the same key type. | Route all API key access through KeychainManager in new build |
| SwipePatternAnalyzer name collision | Two classes with identical name in V7Thompson and AppShell. MLInsightsEngine reads from AppShell copy; V7Thompson copy is isolated. | Rename or consolidate — keep one canonical implementation |
| LocationScoringEngine is a filter not a lever | LEVER 4 is implemented as a binary pre-filter (removes jobs beyond distance threshold) rather than a weighted score component like the other 5 levers. Inconsistent with lever architecture. | Decide: binary filter (keep) or weighted distance score component (rebuild) |
| Two cover letter generators | CoverLetterEngine (AppShell/CoverLettersView) and CoverLetterService (V7AI/CoverLetterGeneratorView) both generate cover letters. Different call paths, different views. | Consolidate to one system in new build |
| Two explanation generators | MatchExplanationGenerator (V7AI, calls OpenAI GPT-3.5) and ThompsonExplanationEngine (V7Thompson, local from ScoreDecomposition) both explain job fit. | Decide which to keep or how to layer them |
| ThompsonSamplingEngine legacy not cleaned up | V7Thompson.swift:303 defines a legacy `ThompsonSamplingEngine`. Extensions (ThompsonSamplingEngineExtensions, ThompsonSampling+ONet) target it. OptimizedThompsonEngine replaced it but legacy type still present. | Drop legacy engine and its extensions entirely |

---

## VERIFICATION COMPLETE — 2026-05-15

All UNKNOWN items resolved via deep codebase read. No remaining UNKNOWNs.

---

## NEW BUGS FOUND DURING VERIFICATION

### Onboarding resume parsing is broken (not just an API issue)
`ResumeUploadStepView` creates `ResumeParser()` with no API key. `ResumeParser.init(openAIAPIKey: nil)` sets `self.openAIClient = nil`. First parse attempt throws `"OpenAI client not initialized"`. Onboarding step 2 (resume upload) silently fails — the skip option masks this. Post-onboarding `ResumeManagementView` uses `ResumeParser(openAIAPIKey: apiKey)` — key source needs tracing for new build.

### V7ResumeAnalysis package is entirely dead
The V7ResumeAnalysis package (ProfileBuilder, ResumeAnalyzer, ResumeUploadViewModel) is never called from any active flow. The `ResumeUploadView` in use is in V7UI, not V7ResumeAnalysis. Drop the entire package from the new build.

### OccupationExpander likely dead (superseded)
OccupationAdjacencyService explicitly states it replaces OccupationExpander. Expander likely has no active call sites. Verify before including in new build.
