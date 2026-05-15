# Connection Status Build Plan
**Manifest & Match V8 | Created: 2026-05-14**
**Based on:** SCHEMATIC_05_connection_status.md

---

## What We're Solving

SCHEMATIC_05 produced the definitive audit of what's wired vs. what's dead. 57% of components are fully wired. 17% are partial (initialized, never called). 13% are orphaned (built, never instantiated).

The partial components represent the biggest opportunity — the infrastructure exists, it just needs to be connected:

1. **ThompsonScoringOrchestrator** — initialized at DeckScreen:1572, zero dot-method calls. Contains ThompsonBridge (UserTruths bonuses) and ThompsonCareerIntegrator (career goal bonuses). Both are wired internally to the orchestrator but the orchestrator is never told to act. The code comment "Sprint 4 COMPLETE" is false — the orchestrator has never affected a single job's score.

2. **baseThompsonScore** — computed every cycle, stored in `personalScore` field, never used for deck ordering. The Beta samplers update on every swipe. The learning happens. The output is silently thrown away before reaching the sort key.

3. **RealTimeScoring.swift** — wired to ContentView.swift, which is legacy V7 code. DeckScreen (the active flow) does not use it. It runs only in the old ContentView path.

The orphaned components need decisive action (remove or plan):

4. **JobRelevanceScorer** — public actor with `shared` singleton, `scoreJob()` and `precomputeScores()` methods. Zero call sites. Never instantiated outside its own file.

5. **JobCache** (Core Data entity) — entity defined, `cache()` method exists, zero write calls. Only referenced in V5→V7 migration.

6. **Inactive API clients** — LinkedIn, Greenhouse, Lever, AngelList, Adzuna, Jooble, RemoteOK, Remotive client files exist in V7Services/CompanyAPIs/. None are registered in JobDiscoveryCoordinator. 8 of 9 additional sources are inactive (only JSearch runs).

---

## What Does NOT Change

- JSearch remains the only active job source (by explicit user decision: coordinator line `// ✅ ONLY JSEARCH ENABLED`)
- The 13 fully-wired components stay unchanged
- `SmartQuestionGenerator` iOS 26+ path stays wired
- `FallbackQuestionCoordinator` stays wired for pre-iOS 26
- `ManifestInferenceActor` wiring stays (see DATA_FLOW_BUILD_PLAN for threshold change)
- `RIASECKeywordMapper` stays as fallback (see TAXONOMY_BUILD_PLAN for Foundation Models addition)

---

## Fix 1: Wire ThompsonBridge into Scoring Path

This is the same fix as SCORING_BUILD_PLAN Fix 2, viewed from the connection status perspective.

### Current Audit State

```
ThompsonScoringOrchestrator: initialized DeckScreen:1572
  └─ ThompsonBridge: instantiated inside orchestrator (DeckScreen:2875)
  └─ ThompsonCareerIntegrator: instantiated inside orchestrator (DeckScreen:2879)
     → zero scoringOrchestrator.* calls in DeckScreen
     → applyUserTruthsBonusToUpcomingJobs() logs "ready" and returns []
```

### Target State

```
OptimizedThompsonEngine.fastProfessionalScore()
  └─ computeBaseScore() → combinedScore (5 components)
  └─ ThompsonBridge.computeBonus(for: job, userFeatures) → bonus multiplier
  └─ adjustedScore = min(0.99, combinedScore × (1.0 + bonus))
     → THIS is the sort key
     
DeckScreen: no scoringOrchestrator, no applyUserTruthsBonusToUpcomingJobs
```

### Connection Steps

1. Read `ThompsonBridge.swift` fully before touching anything — understand what `applyUserTruthsBonusToUpcomingJobs()` was supposed to do and what bonus computation logic is already implemented.

2. Read `ThompsonCareerIntegrator.swift` fully — understand the career goal alignment bonus formula.

3. Extract the per-job bonus computation from each into a single callable method:
   ```swift
   // ThompsonBridge addition
   func computeBonus(for job: JobItem, userTruths: UserTruths?) -> Double
   
   // ThompsonCareerIntegrator addition  
   func computeBonus(for job: JobItem, careerGoal: CareerGoal?) -> Double
   ```

4. Call both in `OptimizedThompsonEngine.fastProfessionalScore()` — after computing `combinedScore`, before returning the `ThompsonScore` struct.

5. Remove `ThompsonScoringOrchestrator` initialization from DeckScreen (line 1572).

6. Remove `applyUserTruthsBonusToUpcomingJobs()` entirely — it was a dead stub, not a design pattern to preserve.

**Critical prerequisite:** Verify `UserTruths` and `CareerGoal` are accessible from the OptimizedThompsonEngine context without introducing a circular dependency. OTE is in V7Thompson, UserTruths is a Core Data entity in V7Data. V7Thompson already depends on V7Data — this is safe.

**Files to modify:**
- `ThompsonBridge.swift` — add per-job `computeBonus()` method
- `ThompsonCareerIntegrator.swift` — add per-job `computeBonus()` method
- `OptimizedThompsonEngine.swift` — call both bonus methods, apply multiplier
- `DeckScreen.swift` — remove `scoringOrchestrator` init and all references

**Estimated effort:** 4–5 days (reading both bridge files is mandatory before writing a line).

---

## Fix 2: Wire baseThompsonScore into combinedScore

See SCORING_BUILD_PLAN Fix 1 for the full formula. From the connection status perspective, this converts `personalScore` from a "stored but ignored" field to a live input.

### Connection status change

| Component | Before | After |
|---|---|---|
| `baseThompsonScore` | PARTIAL — computed, stored in personalScore, not in sort key | WIRED — 8% weight in combinedScore |
| `amberSampler` / `tealSampler` | PARTIAL — update on swipe, not used for ordering | WIRED — output reaches deck sort order |
| `ThompsonArm` (Core Data) | PARTIAL — entity exists, never written (see DATA_FLOW_BUILD_PLAN Fix 1) | WIRED — reads on init, writes on processInteraction |

**Dependency:** DATA_FLOW_BUILD_PLAN Fix 1 (ThompsonArm persistence) must complete before this has meaningful effect.

---

## Decision 3: RealTimeScoring.swift — Archive or Remove

### Audit Findings

`RealTimeScoring.swift` provides an async scoring pipeline. It is called from:
```swift
// ContentView.swift — legacy code
ThompsonScoringBridge.subscribeToRealTimeScoring()
```

ContentView.swift is legacy V7 code — not part of the active V8 flow. DeckScreen is the active flow. DeckScreen does not call RealTimeScoring.

### Decision

**Do not remove RealTimeScoring.swift yet.** First audit ContentView.swift:

1. Is ContentView.swift reachable from the active app entry point? Check `ManifestAndMatchV7App.swift` or `AppDelegate`.
2. If ContentView.swift is unreachable (dead code), remove both ContentView.swift and RealTimeScoring.swift together.
3. If ContentView.swift is somehow still in the navigation path, understand why before removing.

**Expected outcome:** ContentView.swift is legacy V7 code — the active path goes through MainTabView → DeckScreen. If confirmed unreachable, both files are candidates for deletion. Do not remove speculatively without tracing the entry point.

**Files to audit (read, do not modify yet):**
- `ManifestAndMatchV7App.swift` (or entry point file) — trace from `@main` to first view
- `ContentView.swift` — confirm it's not in the active path
- `RealTimeScoring.swift` — understand what it does vs. what DeckScreen's scoring does

---

## Decision 4: JobRelevanceScorer — Remove

### Audit Findings

```
JobRelevanceScorer (V7Thompson):
  - public actor with .shared singleton
  - scoreJob() — never called
  - precomputeScores() — never called
  - Zero call sites found in entire codebase
  - Never instantiated outside its own file
```

### Decision

**Remove.** `OptimizedThompsonEngine` already performs job relevance scoring via `fastProfessionalScore()`. `JobRelevanceScorer` is either a predecessor (replaced by OTE) or an unused alternative design. There are zero callers.

**Before removing:** Read `JobRelevanceScorer.swift` to confirm its methods are not called via protocol or type erasure (would not show up in a literal string search). If no protocol conformance or indirect dispatch pattern exists, delete.

**Files to delete:**
- `V7Thompson/Sources/V7Thompson/JobRelevanceScorer.swift`

**Estimated effort:** 30 minutes (read + delete + verify clean build).

---

## Decision 5: Inactive API Client Files

### Current State

In `V7Services/Sources/V7Services/CompanyAPIs/`:
- LinkedIn client
- Greenhouse client  
- Lever client
- AngelList client
- Adzuna client
- Jooble client
- RemoteOK client
- Remotive client

None are registered in `JobDiscoveryCoordinator`. All are commented out at coordinator lines 1297–1307.

### Decision

**Keep on disk, do not register.** These files represent future expansion surface. Deleting them loses the HTTP client implementations that would need to be re-built when new job sources are added. The cost of keeping them is only compile time (they compile as dead code). The coordinator explicitly guards against activating them.

**Exception:** If any of these files have been broken by Swift version upgrades (compile errors suppressed by the coordinator not calling them), they need to be either fixed or removed. Verify each compiles cleanly.

**No file changes required** — status quo acceptable. Revisit when a second job source is prioritized.

---

## Connection Status Target After All Fixes

| Component | Current Status | Target Status |
|---|---|---|
| ThompsonBridge | ⚠️ PARTIAL (in un-invoked orchestrator) | ✅ WIRED (per-job bonus in OTE) |
| ThompsonCareerIntegrator | ⚠️ PARTIAL (in un-invoked orchestrator) | ✅ WIRED (per-job bonus in OTE) |
| baseThompsonScore | ⚠️ PARTIAL (stored, not in sort key) | ✅ WIRED (8% of combinedScore) |
| ThompsonArm (Core Data) | ⚠️ PARTIAL (entity exists, never written) | ✅ WIRED (read on init, write on swipe) |
| RealTimeScoring | ⚠️ PARTIAL (legacy ContentView only) | TBD (pending ContentView audit) |
| JobRelevanceScorer | ❌ ORPHANED | 🗑️ DELETED |
| JobCache (Core Data) | ❌ ORPHANED | 🗑️ DELETED (see DATA_FLOW_BUILD_PLAN) |
| ThompsonScoringOrchestrator | ❌ Never invoked | 🗑️ REMOVED from DeckScreen |

**Wired components after fixes: 17 of 18 (vs. 13 of 20 today)**

---

## Implementation Sequence

```
Week 1 (Prerequisites from other plans):
  DATA_FLOW_BUILD_PLAN Fix 1 — ThompsonArm persistence (must complete first)
  SCORING_BUILD_PLAN Fix 1 — baseThompsonScore reconnection (depends on above)

Week 2:
  Day 1:    Decision 4 — Remove JobRelevanceScorer
            Read file, confirm no indirect callers, delete, clean build
  
  Day 2:    Decision 3 — Audit ContentView.swift + RealTimeScoring.swift
            Trace app entry point, determine if ContentView is reachable
            If unreachable: remove both files
  
  Day 3–5:  Fix 1 — Wire ThompsonBridge into scoring path
            Read ThompsonBridge.swift (full) before writing anything
            Read ThompsonCareerIntegrator.swift (full) before writing anything
            Extract per-job computeBonus() methods
            Wire into OTE.fastProfessionalScore()
            Remove scoringOrchestrator from DeckScreen
```

---

## Files to Modify

| File | Change |
|---|---|
| `OptimizedThompsonEngine.swift` | Add ThompsonBridge + ThompsonCareerIntegrator bonus calls |
| `ThompsonBridge.swift` | Add `computeBonus(for:userTruths:) -> Double` |
| `ThompsonCareerIntegrator.swift` | Add `computeBonus(for:careerGoal:) -> Double` |
| `DeckScreen.swift` | Remove `scoringOrchestrator` init (line 1572) + `applyUserTruthsBonusToUpcomingJobs()` call |

## Files to Delete

| File | Condition |
|---|---|
| `JobRelevanceScorer.swift` | Confirm zero indirect callers first |
| `ContentView.swift` | Only if confirmed unreachable from app entry point |
| `RealTimeScoring.swift` | Only if ContentView.swift is removed |

---

## Success Criteria

| Metric | Before | After |
|---|---|---|
| Fully wired components | 13 of 20 (65%) | 17 of 18 (94%) |
| UserTruths bonus applies to deck order | Never | On every scored job (when UserTruths populated) |
| ThompsonScoringOrchestrator in DeckScreen | Initialized, never used | Removed |
| JobRelevanceScorer | Orphaned, compiles dead | Deleted |
| combinedScore drives deck order | 5 components | 6 components (+ Thompson 8%) |
| ThompsonArm persistence | Cold launch resets to Beta(1,1) | Persists across sessions |
