# Untangling Guide — Manifest & Match v1.1
**Created: 2026-05-15**
**Source:** SYSTEM_INVENTORY.md (all tangles verified against code) + DECISIONS.md (pre-made decisions carried forward)
**Purpose:** For every broken or tangled system from the V7/V8 reference codebase, specify exactly how v1.1 handles it. Decisions made here are final for Phase 1–6 implementation. Do not re-litigate during build phases.

---

## How to Read This Document

**Layer 1** (sections below): Per-tangle decisions. Each entry answers four questions:
1. **Correct wiring** — what connects to what in v1.1
2. **Lift vs rebuild** — take code as-is, or rewrite the connection logic
3. **Include vs drop** — does this system belong in v1.1
4. **Phase** — which build phase wires this in

**Layer 2** (end of document): Structural conclusions — the canonical pipelines, single-source-of-truth table, and complete lift/rebuild/drop/defer inventory.

---

## LAYER 1 — PER-TANGLE DECISIONS

---

### TANGLE 1: Thompson Sampling not connected to deck ordering
**What's wrong:** `baseThompsonScore = amberSample × (1−t) + tealSample × t` is calculated every scoring cycle and stored in `ThompsonScore.personalScore`. It is never added to `combinedScore`. The deck is a pure content-based recommender despite being named after Thompson Sampling.

**Correct wiring (v1.1):**
`combinedScore = (titleScore×w_title + skillsScore×w_skills + locationScore×w_location + workActivitiesScore×w_workActivities + riasecScore×w_riasec) × 0.92 + baseThompsonScore × 0.08`

The 8% Thompson weight is the initial value. Reduce to 5% if the deck feels noisy; raise to 12% if behavioral diversity doesn't improve.

**Lift vs rebuild:** The Beta arm math (FastBetaSampler, arm update logic) lifts as-is. The formula change is one line in `OptimizedThompsonEngine.fastProfessionalScore()`. No rebuild — just connect the wire that was always there.

**Include vs drop:** Include. This is the core product premise.

**Phase:** Phase 3 (Scoring).

**Source:** DECISIONS.md — combinedScore Formula.

---

### TANGLE 2: ThompsonBridge and ThompsonCareerIntegrator never called
**What's wrong:** Both live inside `ThompsonScoringOrchestrator`, initialized at DeckScreen:1572. The orchestrator has zero dot-method calls anywhere. UserTruths bonuses (+0.5×–2.0×) and career bonuses (skills match +15%, aspiration +10%) never apply to any job score.

**Correct wiring (v1.1):**
Both bonuses applied inside `OptimizedThompsonEngine.fastProfessionalScore()` as post-formula multipliers:
`adjustedScore = min(0.99, combinedScore × (1.0 + userTruthsBonus + careerBonus))`

- `userTruthsBonus` calculated by ThompsonBridge logic: reads `UserTruths` Core Data entity, applies bonus based on loveTasks/hateTasks match
- `careerBonus` calculated by ThompsonCareerIntegrator logic: reads `InferredManifestProfile` (see Tangle 3), applies skills and aspiration bonuses

No `ThompsonScoringOrchestrator`. No `applyUserTruthsBonusToUpcomingJobs()`. Bonuses are part of the scoring function, not a UI-layer post-processing step.

**Lift vs rebuild:**
- ThompsonBridge bonus calculation logic: **lift** as-is
- ThompsonCareerIntegrator bonus calculation logic: **lift** with data source fix (Tangle 3)
- ThompsonScoringOrchestrator: **drop entirely**
- Wiring: **rebuild** — inline both bonuses into `fastProfessionalScore()`

**Include vs drop:** Include both bonus systems. Drop the orchestrator.

**Phase:** Phase 3 (Scoring).

**Source:** DECISIONS.md — ThompsonBridge + ThompsonCareerIntegrator.

---

### TANGLE 3: ThompsonCareerIntegrator reads wrong data source
**What's wrong:** ThompsonCareerIntegrator calls `UserProfile.toManifestProfile()` which produces a V6-era `ManifestProfile` struct containing `jobViewHistory` and `searchQueries` — not the ML-inferred career profile. `InferredManifestProfile` (built by ManifestInferenceActor from actual swipe behavior) exists in Core Data but is never passed to this system. Double-broken: never called AND wrong input if called.

**Correct wiring (v1.1):**
ThompsonCareerIntegrator receives `InferredManifestProfile` (the Core Data entity produced by ManifestInferenceActor). Input signature changes from `ManifestProfile` (V6 struct) to a value-type projection of `InferredManifestProfile` — specifically: `inferredRoles`, `riasecProfile`, `confidence`, `careerTransitionIntent`.

`UserProfile.toManifestProfile()` is not used in v1.1. The V6 `ManifestProfile` struct is dropped.

**Lift vs rebuild:**
- Bonus calculation logic: **lift** once input type is corrected
- Input parameter: **rebuild** — replace `ManifestProfile` parameter with `InferredCareerContext` (new value type projected from `InferredManifestProfile`)
- `toManifestProfile()` extension: **drop**

**Include vs drop:** Include with corrected input.

**Phase:** Phase 3 (Scoring). Depends on ManifestInferenceActor being wired first (Phase 2).

---

### TANGLE 4: Card color uses wrong signal
**What's wrong:** `interpolateColor(ratio: job.thompsonScore)` colors cards by quality score (0–1). A high-scoring job in amber mode renders teal. Color encodes quality, not current/future fit position. `DualProfileColorSystem.fitScoreColor(score:, profileBlend:)` is the correctly designed system but is unused by DeckScreen.

**Correct wiring (v1.1):**
Each `ThompsonScore` carries two new fields: `amberContribution: Float` and `tealContribution: Float` — the Beta arm sample values that fed into `baseThompsonScore`. The per-job color ratio = `amberContribution / (amberContribution + tealContribution)`.

DeckScreen passes this ratio to `DualProfileColorSystem.fitScoreColor(score: ratio, profileBlend: currentBlend)`.

**What must be added to v1.1 that doesn't exist in V7:**
`OptimizedThompsonEngine` must emit `amberContribution` and `tealContribution` per job in `ThompsonScore`. This is new — `ScoreDecomposition` does not currently contain these fields.

**Lift vs rebuild:**
- `DualProfileColorSystem`: **lift** as-is
- `ThompsonScore` struct: **rebuild** to add amber/teal contribution fields
- `interpolateColor` in DeckScreen: **drop**
- Card rendering: **rebuild** to read contribution fields and call `DualProfileColorSystem`

**Include vs drop:** Include DualProfileColorSystem. Drop interpolateColor.

**Phase:** Phase 3 (scoring engine emits contribution fields) + Phase 4 (card rendering uses them).

---

### TANGLE 5: CareerPathEngine isolated
**What's wrong:** 937 lines, never called. ManifestTabView builds career path models directly from `InferredManifestProfile` in ad-hoc code, bypassing the purpose-built engine. `MarketDemandAPI` (BLS bundled data) is also isolated because nothing calls CareerPathEngine.

**Correct wiring (v1.1):**
ManifestTabView `.careerPath` destination calls `CareerPathEngine.buildPaths(from: InferredManifestProfile)` → `[CareerPath]`. MarketDemandAPI fires inside CareerPathEngine as designed. ManifestTabView displays the result — it does not build career path models itself.

**Lift vs rebuild:**
- CareerPathEngine actor: **lift** as-is. Internal logic is complete.
- MarketDemandAPI: **lift** as-is. Bundled offline data is real and useful.
- ManifestTabView career path display: **rebuild** — remove direct InferredManifestProfile reads for this destination, route through CareerPathEngine.

**Include vs drop:** Include both CareerPathEngine and MarketDemandAPI.

**Phase:** Phase 4 (Manifest tab wiring).

---

### TANGLE 6: RIASECScorer isolated
**What's wrong:** 592-line Foundation Models implementation of RIASEC scoring from question answers — never called. `RIASECKeywordMapper` (90 keywords, weak signal) is used instead. The replacement was built and never wired.

**Correct wiring (v1.1):**
`AnswerParsingActor` calls `RIASECScorer` on iOS 26, falls back to `RIASECKeywordMapper` on earlier versions.

```swift
if #available(iOS 26.0, *), AICareerProfileBuilder.isAvailable {
    scores = await RIASECScorer.score(answer: text)
} else {
    scores = RIASECKeywordMapper.extract(from: text)
}
```

Both feed into ManifestInferenceActor's RIASEC update path.

**Lift vs rebuild:**
- RIASECScorer: **lift** as-is
- RIASECKeywordMapper: **lift** as-is (keep as fallback)
- AnswerParsingActor: **rebuild** to add the conditional dispatch

**Include vs drop:** Include both. They serve different OS versions.

**Phase:** Phase 3 (answer pipeline, feeds scoring RIASEC weight).

---

### TANGLE 7: CourseRecommendationEngine isolated + filename crash bug
**What's wrong:** Never called — ManifestTabView `.courses` destination is empty. `CourseProviderClient` loads `courses_v1.0` from `CourseCatalog/` — actual file is `courses_v1.json` in `Courses.bundle/` — this filename mismatch triggers `fatalError` on first call. 4.1MB of real course data (Coursera, Udemy, edX) is unreachable.

**Correct wiring (v1.1):**
ManifestTabView `.courses` destination calls `CourseRecommendationEngine.recommend(for: InferredManifestProfile)`. `CourseProviderClient` uses: `catalogFileName = "courses_v1"`, `resourceSubdirectory = "Courses.bundle"`. AffiliateTracker called on course tap (Phase 5).

**Lift vs rebuild:**
- `CourseRecommendationEngine`: **lift** with filename fix
- `CourseProviderClient`: **lift** with filename constants corrected (two-line fix)
- `AffiliateTracker`: **lift**, wire in Phase 5 when affiliate credentials are set
- ManifestTabView `.courses`: **rebuild** — implement the empty destination to call CRE

**Include vs drop:** Include. Revenue system and core Manifest tab feature.

**Phase:** Phase 4 (ManifestTabView wiring + filename fix). Phase 5 (affiliate credentials + AffiliateTracker wired).

**Source:** DECISIONS.md — Course Provider Priority.

---

### TANGLE 8: Question card injection path incomplete
**What's wrong:** `QuestionTimingCoordinator` (DeckScreen:1562) evaluates timing and says at line 540: "JobDiscoveryCoordinator should inject question card here" — it's a comment, not code. The actual deck injection is never implemented.

**Correct wiring (v1.1):**
After each job view, DeckScreen asks `QuestionTimingCoordinator.shouldShowQuestion()`. If yes:
1. `ManifestAwareQuestionGenerator` determines which `QuestionPurpose` is needed (11-step decision tree)
2. `SmartQuestionGenerator` generates the `CareerQuestion`
3. DeckScreen inserts a question card at the next deck position

Question answer flow:
- `UserTruthsExtractionActor` parses answer via Foundation Models
- `AnswerParsingActor` → `RIASECScorer` or `RIASECKeywordMapper`
- Result feeds ManifestInferenceActor

**Lift vs rebuild:**
- `QuestionTimingCoordinator`: **lift** — timing logic is complete. Add return value that DeckScreen acts on.
- `SmartQuestionGenerator` + `ManifestAwareQuestionGenerator`: **lift** as-is
- `FallbackQuestionCoordinator`: **lift** as-is
- DeckScreen injection: **rebuild** — implement the deck insertion that V7 left as a comment

**Include vs drop:** Include. Core feature.

**Phase:** Phase 4 (User Flow).

**Source:** DECISIONS.md — Question Card Injection.

---

### TANGLE 9: ApplicationTracker CRM disconnect
**What's wrong:** "Apply Now" in DeckScreen records as "save" in Thompson scoring. `ApplicationTracker.shared` never receives an "applied" write from any swipe action. The Tab 1 CRM has no data from the primary apply flow.

**Correct wiring (v1.1):**
DeckScreen apply action:
1. Opens job URL (existing behavior — keep)
2. Records Thompson swipe as "right" with weight `actionType: .apply` (existing)
3. **NEW:** `ApplicationTracker.shared.addApplication(job, status: .applied, date: .now)`

**Persistence note:** `ApplicationTracker` uses SwiftData. The rest of the app uses Core Data. These coexist — SwiftData and Core Data can run in the same app without conflict. No migration needed. Keep ApplicationTracker as SwiftData; it's self-contained and simpler for its use case.

**Lift vs rebuild:**
- `ApplicationTracker` data model: **lift** as-is (SwiftData, keep)
- `ApplicationHistoryView` (Tab 1): **lift** as-is
- DeckScreen apply handler: **rebuild** — add the missing ApplicationTracker write

**Include vs drop:** Include. Tab 1 CRM is the core post-swipe tracking feature.

**Phase:** Phase 4 (User Flow).

---

### TANGLE 10: SwipePatternAnalyzer not wired to ManifestInferenceActor
**What's wrong:** AppShell's `SwipePatternAnalyzer` (658 lines) detects behavioral patterns — streaks, alternation, hesitation, burnout. These patterns would enrich `ManifestInferenceActor`'s career inference but are never passed to it. V7Thompson has a duplicate isolated copy that MLInsightsEngine was reading from (see Tangle 11).

**Correct wiring (v1.1):**
Single canonical `SwipePatternAnalyzer` in the Intelligence package. Called from DeckScreen on each swipe. Pattern output passed to `ManifestInferenceActor` alongside standard swipe data.

**Lift vs rebuild:**
- AppShell `SwipePatternAnalyzer`: **lift** as-is → becomes the canonical version in Intelligence package
- V7Thompson `SwipePatternAnalyzer`: **drop** (duplicate, isolated)
- ManifestInferenceActor input: **rebuild** to accept `SwipePattern` alongside swipe events
- DeckScreen swipe handler: **rebuild** to call `SwipePatternAnalyzer` and forward result

**Include vs drop:** Include (AppShell version only). Drop V7Thompson version.

**Phase:** Phase 2 (Data Flow — feeds ManifestInferenceActor).

---

### TANGLE 11: Three systems claiming to integrate Thompson Sampling
**Three systems, three different purposes:**

| System | Package | What it claims | Actual state |
|---|---|---|---|
| ThompsonBridge | V7AI | UserTruths bonus multiplier | Built, never called (Tangle 2) |
| ThompsonCareerIntegrator | V7Career | Career bonus multiplier | Built, never called, wrong input (Tangles 2, 3) |
| ThompsonIntegration | V7Embeddings | Semantic similarity as Thompson input | Isolated, inactive by design |

**Decisions:**
- `ThompsonBridge`: **keep** — wire into scoring engine (Tangle 2)
- `ThompsonCareerIntegrator`: **keep** — wire into scoring engine with fixed input (Tangles 2, 3)
- `SemanticMatch/ThompsonIntegration`: **defer** — semantic similarity scoring is architecturally separate. The entire SemanticMatch package defers to Phase 6. Do not wire in Phase 1–5.

These are not overlapping. ThompsonBridge and ThompsonCareerIntegrator are bonus multipliers applied after `combinedScore`. ThompsonIntegration is a completely different approach (vector embeddings). They don't conflict — they were just never connected.

**Phase:** Tangle 2/3 Phase 3. SemanticMatch → Phase 6.

---

### TANGLE 12: Two disconnected OptimizedThompsonEngine instances
**What's wrong:** `ThompsonScoringBridge` in AppShell creates a second `OptimizedThompsonEngine` via the async init path — which does NOT wire Core Data persistence. DeckScreen uses the sync init (with persistence). ContentView's bridge streams scores that never match DeckScreen's actual deck. Two instances, two init paths, neither knows about the other.

**Correct wiring (v1.1):**
Single `OptimizedThompsonEngine` instance. Created once at app startup using the sync init (persistence wired). Passed via environment to all consumers. No second instance anywhere.

`ThompsonScoringBridge` is eliminated. Its AsyncStream streaming is not needed when the engine is passed by environment and SwiftUI's observation system handles reactivity.

**Lift vs rebuild:**
- `OptimizedThompsonEngine` (sync init): **lift** as-is — this is the correct instance
- `ThompsonScoringBridge`: **drop** entirely
- App startup: **rebuild** — single init, environment injection

**Include vs drop:** Include OTE (single instance). Drop ThompsonScoringBridge.

**Phase:** Phase 1 (app startup / engine init). Phase 2 (persistence confirmed).

---

### TANGLE 13: SmartSourceSelector is a single-arm bandit
**What's wrong:** SmartSourceSelector is correctly wired — initialized at JDC startup, samples Beta arms to pick API sources. But only JSearch is active, so it samples from one arm. A single-arm MAB produces no selection value.

**Decision:** No code change needed. SmartSourceSelector is correct. The limitation is operational (one API source active), not architectural. When additional sources are re-enabled (Phase 6), SmartSourceSelector activates automatically. Wire it correctly in v1.1 (it already is), leave it.

**Phase:** Phase 1 (wire as-is). Becomes meaningful in Phase 6.

---

### TANGLE 14: KeychainManager used inconsistently
**What's wrong:** `MatchExplanationGenerator` uses `KeychainManager.shared.load(for: .openAIKey)` correctly. `CoverLetterService` reads the OpenAI key from `ProcessInfo.environment["OPENAI_API_KEY"]` then `UserDefaults "openai_api_key"` — both insecure for production. `ResumeParser` takes the key as a plain string parameter with no Keychain path.

**Correct wiring (v1.1):**
`KeychainManager` is the single access point for ALL API keys. Every service that needs an API key reads it via `KeychainManager.shared`. No UserDefaults key storage. No environment variables in production code. Onboarding stores the key on first setup via `KeychainManager.shared.save()`.

**Lift vs rebuild:**
- `KeychainManager`: **lift** as-is
- `MatchExplanationGenerator`: **lift** as-is (already correct)
- `CoverLetterService`: **rebuild** call site — replace UserDefaults/env var reads with `KeychainManager.shared.load(for: .openAIKey)`
- `ResumeParser`/`ResumeUploadStepView`: **rebuild** — pass key from KeychainManager at call site, not nil

**Include vs drop:** Include. Security-critical.

**Phase:** Phase 1 (establish KeychainManager standard in AppShell) + Phase 4 (update all service call sites).

---

### TANGLE 15: SwipePatternAnalyzer name collision
**What's wrong:** Two classes with identical name `SwipePatternAnalyzer` — one in V7Thompson (isolated), one in AppShell (active, read by MLInsightsEngine). If both packages are imported in the same target, compiler requires full qualification.

**Decision:** Resolved by Tangle 10. V7Thompson copy is dropped. AppShell copy moves to Intelligence package as the canonical implementation. One class, one package. No collision in v1.1.

**Phase:** Phase 1 (resolved by package structure).

---

### TANGLE 16: LocationScoringEngine is a filter not a lever
**What's wrong:** LEVER 4 (geographic) is implemented as a binary pre-filter (removes jobs beyond distance threshold) rather than a weighted score component inside `combinedScore` like the other 5 levers. Architecturally inconsistent with the lever naming convention.

**Decision:** Keep as a pre-filter. A job 200 miles away when the user wants local work should not appear in the deck regardless of other scores — binary filtering is the correct UX behavior here. The inconsistency is in the naming, not the logic.

**In v1.1:** Don't call it LEVER 4. Call it the **geographic eligibility filter**. It runs before scoring (correct), it is not a weighted component of `combinedScore` (correct), and it is not referenced in the lever weight interpolation system (correct). The LEVER naming convention in ThompsonWeights refers only to the 5 `combinedScore` weights.

**Lift vs rebuild:** Lift as-is. Rename in documentation only.

**Phase:** Phase 1 (architecture clarification). Phase 3 (wired same as in V7).

---

### TANGLE 17: Two cover letter generators
**What's wrong:** `CoverLetterEngine` (AppShell/CoverLettersView, GPT-4) and `CoverLetterService` (V7AI/CoverLetterGeneratorView, GPT-4o-mini) both generate cover letters from different call paths. Both active, both wired.

**Decision:** **`CoverLetterService`** (Intelligence package in v1.1) is the canonical cover letter system. It has rate limiting (10/day), uses GPT-4o-mini (more cost-effective), proper structure. `CoverLetterEngine` (AppShell) is a duplicate. Drop it.

All navigation paths that opened `CoverLettersView` in V7 should route to a single cover letter view backed by `CoverLetterService` in v1.1.

**Lift vs rebuild:**
- `CoverLetterService`: **lift** with KeychainManager fix (Tangle 14)
- `CoverLetterGeneratorView`: **lift** as the canonical view
- `CoverLetterEngine` + `CoverLettersView`: **drop**

**Phase:** Phase 4 (User Flow — single navigation path).

---

### TANGLE 18: Two job fit explanation generators
**What's wrong:** `ThompsonExplanationEngine` (local, from ScoreDecomposition) and `MatchExplanationGenerator` (OpenAI GPT-3.5) both explain why a job scored the way it did. Different data sources, different quality levels, both active but used in different contexts.

**Decision:** Keep both — they serve different UX moments.
- **`ThompsonExplanationEngine`**: card-level inline explanation. Local, <5ms, no API cost. Used for the brief "why" tooltip visible without tapping into the sheet.
- **`MatchExplanationGenerator`**: full ExplainFitSheet explanation. OpenAI, richer language. Used when user taps "Why?" button to open the detailed sheet.

These are complementary, not duplicate. No consolidation needed.

**Lift vs rebuild:**
- `ThompsonExplanationEngine`: **lift** as-is
- `MatchExplanationGenerator`: **lift** with KeychainManager fix (Tangle 14)

**Phase:** Phase 3 (card-level explanation with scoring). Phase 4 (sheet wiring).

---

### TANGLE 19: ResumeParser called without API key in onboarding
**What's wrong:** `ResumeUploadStepView` (onboarding step 2) calls `ResumeParser()` with no API key. `openAIClient = nil`. First parse attempt throws "OpenAI client not initialized". Onboarding resume parsing silently fails — the skip option masks this. Post-onboarding `ResumeManagementView` passes a key but the source needs tracing.

**Correct wiring (v1.1):**
`ResumeUploadStepView` reads OpenAI key from `KeychainManager.shared.load(for: .openAIKey)` and passes it to `ResumeParser(openAIAPIKey: key)`. If key is nil (not yet configured), show a message explaining that resume parsing requires an API key, with a path to add one in Settings.

Key provisioning flow: user sets OpenAI key in Settings → `KeychainManager.shared.save(key, for: .openAIKey)` → key available to all services.

**Lift vs rebuild:**
- `ResumeParser`: **lift** as-is
- `ResumeUploadStepView`: **rebuild** call site — read key from Keychain before init
- Key management in Settings: **new** — simple KeychainManager write from a settings field

**Phase:** Phase 4 (Onboarding flow fix).

---

### TANGLE 20: V7ResumeAnalysis package entirely dead
**What's wrong:** The entire `V7ResumeAnalysis` package (`ProfileBuilder`, `ResumeAnalyzer`, `ResumeUploadViewModel`) is never called from any active flow. The active `ResumeUploadView` is in V7UI. `V7ResumeAnalysis` uses MVVM pattern — inconsistent with the rest of the app's MV pattern. The package contributed nothing in production V7.

**Decision:** **Drop the entire package.** Do not create a `ProfileExtraction` package in v1.1. The active resume-to-profile pipeline is: `ResumeParsingService` (ResumeParsing) + `ProfileEnrichmentService` (JobPipeline). That's sufficient.

**Phase:** N/A — never include it.

---

## LAYER 2 — STRUCTURAL CONCLUSIONS

---

## Canonical Pipeline: Scoring (v1.1)

This is the single authorized flow from job ingestion to rendered card. Every component in this pipeline has a tangle decision above that specifies how to build it.

```
JSearch API request
  → Cloudflare Workers proxy (hides API key)
  ↓
JobSkillsExtractor (NLP skills extraction from description text)
  ↓
JobONetEnricher (title string → O*NET occupation code)
  ↓
LocationScoringEngine (geographic eligibility filter — removes out-of-range jobs)
  [NOT a lever — runs before scoring]
  ↓
OptimizedThompsonEngine.fastProfessionalScore()
  │
  ├─ ThompsonWeights: 5 lever weights interpolated from profileBlend (0.0–1.0)
  │
  ├─ combinedScore:
  │   (titleScore × w_title
  │    + skillsScore × w_skills
  │    + locationScore × w_location
  │    + workActivitiesScore × w_workActivities
  │    + riasecScore × w_riasec) × 0.92
  │    + baseThompsonScore × 0.08           ← RECONNECTED (Tangle 1)
  │
  ├─ userTruthsBonus: ThompsonBridge reads UserTruths Core Data entity
  ├─ careerBonus: ThompsonCareerIntegrator reads InferredManifestProfile
  │
  ├─ adjustedScore = min(0.99, combinedScore × (1.0 + userTruthsBonus + careerBonus))
  │
  └─ amberContribution, tealContribution (new fields — per-job color signal)
  ↓
[ThompsonScore] sorted by adjustedScore descending
  ↓
DeckScreen card queue
  ├─ Card color: DualProfileColorSystem.fitScoreColor(amberContribution, tealContribution)
  ├─ Inline explanation: ThompsonExplanationEngine (local, <5ms)
  └─ "Why?" sheet: MatchExplanationGenerator (OpenAI GPT-3.5, on demand)
```

Beta arms update after every swipe: `ThompsonArm.recordSuccess()` or `recordFailure()` → Core Data persistence. Cold launch restores prior arm state.

---

## Canonical Pipeline: Manifest Tab (v1.1)

```
Every swipe
  → ManifestInferenceActor (debounced 5s, threshold = 3 swipes)
  → SwipePatternAnalyzer input (behavioral patterns: streaks, alternation, burnout)
  ↓
InferredManifestProfile (Core Data entity, updated when confidence ≥ 0.30)
  ↓
ManifestTabView
  │
  ├─ Overview: direct read from InferredManifestProfile
  │
  ├─ Skills Gap: SkillsGapAnalyzer(InferredManifestProfile)
  │
  ├─ Career Path: CareerPathEngine(InferredManifestProfile)
  │                 └─ MarketDemandAPI (BLS bundled demand data)
  │
  └─ Courses: CourseRecommendationEngine(InferredManifestProfile)
                └─ CourseProviderClient → courses_v1.json (Courses.bundle)
                └─ AffiliateTracker on course tap (Phase 5)
```

---

## Canonical Pipeline: Question Cards (v1.1)

```
After each job view:
  → FastBehavioralLearning (sync, <10ms — immediate session update)
  → ManifestInferenceActor (debounced 5s — persistent RIASEC update)
  → QuestionTimingCoordinator.shouldShowQuestion()
      evaluates: RIASEC gap severity, slider position, jobs viewed, convergence confidence
      if slider is at full Amber: returns false (matching mode, no questions needed)
      if YES:
        → ManifestAwareQuestionGenerator (11-step purpose selector)
        → SmartQuestionGenerator (iOS 26) or FallbackQuestionCoordinator (pre-iOS 26)
        → DeckScreen injects CareerQuestion card at next deck position

Answer submitted:
  → UserTruthsExtractionActor (Foundation Models, iOS 26) → UserTruths Core Data
  → AnswerParsingActor
      → RIASECScorer (iOS 26) or RIASECKeywordMapper (fallback)
  → ManifestInferenceActor update
  → Next scoring cycle uses updated RIASEC weights
```

---

## Canonical Pipeline: Apply Action (v1.1)

```
User taps "Apply Now":
  → Opens job URL in Safari (keep existing behavior)
  → Thompson: record right-swipe with actionType: .apply
  → ThompsonArm.recordSuccess() → persisted to Core Data
  → ApplicationTracker.shared.addApplication(job, status: .applied, date: .now)
      (SwiftData write — coexists with Core Data, no conflict)
  → Tab 1 CRM updates immediately (SwiftData @Query refreshes)
```

---

## Single Source of Truth (v1.1)

Every contested domain has exactly one canonical system. This table is final.

| Domain | v1.1 Canonical System | Package | V7 System Dropped |
|---|---|---|---|
| Scoring engine | OptimizedThompsonEngine (single sync-init instance) | ScoringEngine | ThompsonScoringBridge (AppShell) |
| Thompson bonuses | Inlined in fastProfessionalScore() | ScoringEngine | ThompsonScoringOrchestrator |
| Card color signal | DualProfileColorSystem.fitScoreColor() | DeckUI | interpolateColor (DeckScreen) |
| Swipe pattern analysis | SwipePatternAnalyzer | Intelligence | V7Thompson copy (duplicate) |
| RIASEC from answers | RIASECScorer (iOS 26) + RIASECKeywordMapper (fallback) | Intelligence | (both kept, different OS versions) |
| Cover letter generation | CoverLetterService (GPT-4o-mini, rate limited) | Intelligence | CoverLetterEngine (AppShell) |
| Card explanation (inline) | ThompsonExplanationEngine | ScoringEngine | (no conflict — different UX moment) |
| Card explanation (sheet) | MatchExplanationGenerator (GPT-3.5) | Intelligence | (no conflict — different UX moment) |
| API key storage | KeychainManager.shared | Intelligence | UserDefaults / env var paths |
| State layer | AppState (@Observable, @Environment) | CoreTaxonomy | StateManager / StateCoordinator |
| Resume upload UI | ResumeUploadView | DeckUI | V7ResumeAnalysis package (entire drop) |
| Question generation | SmartQuestionGenerator + FallbackQuestionCoordinator | Intelligence | (both kept, different OS versions) |
| Geographic filtering | LocationScoringEngine (pre-filter, not a lever) | JobPipeline | (no conflict — naming clarified) |

---

## Systems Inventory: Lift / Rebuild / Drop / Defer

### LIFT AS-IS
These can be taken from the V7/V8 reference codebase with minimal or no changes.

| System | Reference Package | v1.1 Package | Notes |
|---|---|---|---|
| OptimizedThompsonEngine | V7Thompson | ScoringEngine | Sync init only — drop async init path |
| FastBetaSampler | V7Thompson | ScoringEngine | |
| ScoreDecomposition | V7Thompson | ScoringEngine | Add amberContribution + tealContribution fields |
| SmartThompsonCache | V7Thompson | ScoringEngine | |
| ThompsonExplanationEngine | V7Thompson | ScoringEngine | |
| ConfidenceCalibrator | V7Thompson | ScoringEngine | |
| EnhancedSkillsMatcher | V7Core | CoreTaxonomy | |
| SkillTaxonomy + SkillTaxonomyLoader | V7Core | CoreTaxonomy | |
| StringSimilarity | V7Core | CoreTaxonomy | |
| O*NET data bundle (13 JSON files) | V7Core | CoreTaxonomy | Copy resources |
| OccupationAdjacencyService | V7Core | CoreTaxonomy | |
| CareerRelationshipDiscovery | V7Core | CoreTaxonomy | |
| AppState | V7Core | CoreTaxonomy | |
| PersistenceController | V7Data | Persistence | |
| Core Data schema (21 entities) | V7Data | Persistence | JobCache excluded per decision |
| JobDiscoveryCoordinator | V7Services | JobPipeline | |
| LocationScoringEngine | V7Services | JobPipeline | Rename: geographic eligibility filter |
| ONetCodeMapper | V7Services | JobPipeline | |
| JobONetEnricher | V7Services | JobPipeline | |
| ProfileConverter | V7Services | JobPipeline | |
| JSearchAPIClient | V7Services | JobPipeline | Only active API source |
| SmartSourceSelector | V7Services | JobPipeline | |
| RateLimitManager | V7Services | JobPipeline | |
| ClientSideGeoFilter | V7Services | JobPipeline | |
| ClientSideSalaryFilter | V7Services | JobPipeline | |
| ProfileEnrichmentService | V7Services | JobPipeline | |
| ManifestInferenceActor | V7AI | Intelligence | Threshold: 3 swipes (not 10) |
| SmartQuestionGenerator | V7AI | Intelligence | |
| ManifestAwareQuestionGenerator | V7AI | Intelligence | |
| QuestionTimingCoordinator | V7AI | Intelligence | Add concrete return value for DeckScreen |
| QuestionTemplateLibrary | V7AI | Intelligence | |
| UserTruthsExtractionActor | V7AI | Intelligence | |
| AnswerParsingActor | V7AI | Intelligence | Add RIASECScorer dispatch |
| RIASECScorer | V7AI | Intelligence | |
| RIASECKeywordMapper | V7AI | Intelligence | Kept as iOS 26 fallback |
| FastBehavioralLearning | V7AI | Intelligence | |
| DeepBehavioralAnalysis | V7AI | Intelligence | |
| CoverLetterService | V7AI | Intelligence | Rebuild call site: KeychainManager for key |
| MatchExplanationGenerator | V7AI | Intelligence | Rebuild call site: KeychainManager (already uses it) |
| KeychainManager | V7AI | Intelligence | |
| ThompsonBridge (bonus logic) | V7AI | ScoringEngine | Rebuild wiring: inline into fastProfessionalScore() |
| TealPathGenerator | V7AI | Intelligence | |
| AICareerProfileBuilder | V7Services | Intelligence | iOS 26 availability check |
| FallbackQuestionCoordinator | V7UI | Intelligence | |
| CareerQuestionsSeed | V7Data | Persistence | |
| DualProfileColorSystem | V7UI | DeckUI | |
| ResumeParsingService + OpenAIClient | V7AIParsing | ResumeParsing | |
| PDFTextExtractor + SkillsExtractor | V7AIParsing | ResumeParsing | |
| CareerPathEngine | V7Career | CareerGrowth | |
| MarketDemandAPI | V7Services | CareerGrowth | |
| SkillsGapAnalyzer | V7Career | CareerGrowth | |
| CourseRecommendationEngine | V7Career | CareerGrowth | Fix filename constants |
| CourseProviderClient | V7Career | CareerGrowth | Fix: catalogFileName = "courses_v1", resourceSubdirectory = "Courses.bundle" |
| courses_v1.json (4.1MB) | V7Career | CareerGrowth | Copy resource |
| AffiliateTracker | V7Career | CareerGrowth | Wire Phase 5 (placeholder creds until then) |
| ApplicationTracker | V7Services | AppShell | SwiftData — keep as-is |
| ApplicationHistoryView | V7UI | DeckUI | |
| SwipePatternAnalyzer (AppShell copy) | AppShell | Intelligence | Canonical — V7Thompson copy dropped |
| SliderPositionLogger | V7Performance | Monitoring | |
| BiasDetectionService | V7Performance | Monitoring | |
| JobSkillsExtractor / SharedJobParser | V7JobParsing | JobNormalizer | |
| ThompsonCareerIntegrator (bonus logic) | V7Career | ScoringEngine | Rebuild input: InferredManifestProfile not V6 ManifestProfile |
| AdCards system (all 6 components) | V7Ads | AdCards | All lift as-is. Wire Phase 5. |
| Inactive API clients (7 sources) | V7Services | JobPipeline | Keep code, keep disabled. Re-enable Phase 6. |
| SmartCompanySelector | V7Services | JobPipeline | Keep, inactive until Phase 6 |
| APICredentialManager | V7Services | JobPipeline | Keep, inactive until Phase 6 |

---

### REBUILD WIRING (logic lifts, connection logic rewrites)

| System | What changes |
|---|---|
| `fastProfessionalScore()` | Add baseThompsonScore × 0.08 to combinedScore. Add userTruthsBonus + careerBonus multipliers. |
| `ThompsonScore` struct | Add `amberContribution: Float`, `tealContribution: Float` fields |
| DeckScreen apply action | Add `ApplicationTracker.shared.addApplication()` call |
| DeckScreen swipe handler | Add `SwipePatternAnalyzer` call, forward result to ManifestInferenceActor |
| DeckScreen card rendering | Replace `interpolateColor` with `DualProfileColorSystem.fitScoreColor()` |
| DeckScreen question injection | Implement actual card insertion (replace the comment at QuestionTimingCoordinator:540) |
| ManifestTabView `.careerPath` | Route through CareerPathEngine instead of direct InferredManifestProfile reads |
| ManifestTabView `.courses` | Implement empty destination: call CourseRecommendationEngine |
| ManifestInferenceActor input | Add SwipePattern parameter alongside swipe events |
| AnswerParsingActor | Add `if #available(iOS 26) { RIASECScorer } else { RIASECKeywordMapper }` dispatch |
| `ResumeUploadStepView` | Read API key from KeychainManager before calling ResumeParser |
| `CoverLetterService` | Replace UserDefaults/env var key reads with KeychainManager |
| ThompsonCareerIntegrator input | Replace `ManifestProfile` (V6) parameter with InferredCareerContext (projected from InferredManifestProfile) |
| App startup | Single OptimizedThompsonEngine init (sync), environment-injected |

---

### DROP — Do Not Rebuild in v1.1

These systems are never instantiated in any build phase. Do not create packages, files, or references for them.

| System | Reason |
|---|---|
| ThompsonScoringOrchestrator | Replaced by direct wiring in fastProfessionalScore() |
| ThompsonScoringBridge (AppShell) | Replaced by single-instance OTE with environment injection |
| ThompsonSamplingEngine (legacy) | Replaced by OptimizedThompsonEngine |
| ThompsonSamplingEngineExtensions | Extension on legacy type — drops with it |
| ThompsonSampling+ONet | Extension on legacy type — drops with it |
| V7ResumeAnalysis package (entire) | Entirely dead. Active resume upload is in DeckUI. |
| ChartsColorTestPackage / ChartsLab | Empty shell. |
| StateManager | Isolated. AppState is the state layer. |
| StateCoordinator | Isolated. |
| StateUpdateActor | Isolated. |
| ProfileManager (V7Core) | Isolated. |
| NavigationState (V7Core) | Isolated. |
| UserInteractionState (V7Core) | Isolated. |
| PerformanceState (V7Core) | Isolated. |
| ThompsonState (V7Core) | Isolated. |
| RequestCoalescer | Isolated. Never called in production. |
| NetworkOptimizer | Isolated. Never called in production. |
| ConfidenceReconciler | Isolated. Never called. |
| OccupationExpander | Superseded by OccupationAdjacencyService. |
| JobCache entity | Never written to. Removed from schema. |
| ClientSideSkillsFilter | Commented out. Dead. |
| SwipePatternAnalyzer (V7Thompson copy) | Duplicate. AppShell copy is canonical. |
| CoverLetterEngine (AppShell) | Duplicate. CoverLetterService is canonical. |
| interpolateColor (DeckScreen) | Replaced by DualProfileColorSystem. |
| BehavioralEventLog | Decided: not in new build. JobInteraction captures same data. |
| JobRelevanceScorer | Isolated. OTE is the scorer. |
| RealTimeScoring | Legacy. OTE handles this. |
| ErrorRecoveryManager | Isolated overkill. Standard Swift error handling instead. |
| ProductionLoadTestingSystem | Isolated. Not in Phase 1–6 scope. |
| ProductionMonitoringIntegration | Isolated. |
| V6 ManifestProfile / toManifestProfile() | Replaced by InferredManifestProfile. |
| ThompsonScoringOrchestrator | Replaced entirely. |
| applyUserTruthsBonusToUpcomingJobs() | Dead stub. Replaced by inline bonus in fastProfessionalScore(). |

---

### DEFER — Include in v1.1, Not Phase 1–4

| System | Package | Defer to Phase | Reason |
|---|---|---|---|
| SemanticMatch package (EmbeddingService, SimilarityCalculator, ThompsonIntegration) | SemanticMatch | Phase 6 | Architecturally separate approach. Build after core scoring is validated. |
| MLInsightsEngine | AppShell | Phase 6 | Depends on SwipePatternAnalyzer being wired first (Phase 2). Defer display until data is meaningful. |
| AdCards (all 6 components) | AdCards | Phase 5 | Infrastructure ready. Needs AdMob SDK + credentials + DeckScreen wiring. |
| AffiliateTracker (live, with real credentials) | CareerGrowth | Phase 5 | Rakuten LinkShare + Udemy direct credentials needed. Placeholder until then. |
| edX live API (CourseProviderClient Tier 2) | CareerGrowth | Phase 5+ | No affiliate program (0% commission). Lower priority. |
| Inactive API clients (6 sources) | JobPipeline | Phase 6 | Code stays, stays commented out. Re-enable with SmartSourceSelector when ready. |
| SmartCompanySelector + APICredentialManager | JobPipeline | Phase 6 | Inactive until multi-source re-enabled. |
| SliderTestSession entity | Persistence | Phase 5 | A/B testing. Not needed until revenue optimization. |
| CareerLadderBuilder | CareerGrowth | Phase 4 (verify first) | Call sites unclear. Trace before wiring. |
| ProductionMetricsDashboard | Monitoring | Phase 6 | Not needed until post-launch monitoring. |

---

## Open Items Requiring Decision Before Phase 3

These items were not resolved by DECISIONS.md and need an answer before the relevant phase starts. They do not block Phase 1 or 2.

1. **ThompsonBridge bonus calculation:** What are the specific UserTruths signal mappings that produce the bonus multiplier? The logic exists in V7 code but the mapping rules (which truths produce what bonus magnitude) should be confirmed or redesigned before Phase 3.

2. **careerBonus magnitude:** ThompsonCareerIntegrator applies skills match +15% and aspiration +10% — are these the right magnitudes for v1.1? These are tunable but should be a conscious decision, not inherited defaults.

3. **CareerLadderBuilder call site:** Inventory says "UNKNOWN — called from within V7Career, not yet traced to ManifestTabView." Trace before Phase 4 to know whether it belongs in the Manifest tab pipeline.

4. **Tab 1 name:** OPEN_QUESTIONS.md Q1 — the CRM tab name is TBD. Doesn't block Phase 1–3.

---

*Untangling Guide complete. Scaffold design can begin.*
