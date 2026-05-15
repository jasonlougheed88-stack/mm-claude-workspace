# Data Flow Build Plan
**Manifest & Match V8 | Created: 2026-05-14**
**Based on:** SCHEMATIC_03_data_flow.md

---

## What We're Solving

The data flow schematic documents three distinct persistence and wiring failures:

1. **ThompsonArm Core Data is never written.** `amberSampler` and `tealSampler` update in memory on every swipe. But `ThompsonArm+CoreData.swift` has `recordSuccess()` / `recordFailure()` methods that are **never called**. Cold launch always resets to Beta(1, 1). Every session starts with no user preference memory. The learning loop is broken at the persistence layer.

2. **JobCache Core Data entity is defined but never written.** The entity has a `cache()` static method but zero write call sites. The only reference is in V5→V7 migration code. The entity consumes schema space and migration complexity for zero benefit.

3. **BehavioralEventLog is written but never read.** Events are appended on every swipe (immutable log) but nothing reads them. ManifestInferenceActor computes RIASEC from `JobInteraction` entities directly, not from the behavioral log. The log's potential for pattern detection is unused.

There is also a gap in the RIASEC feedback loop quality — ManifestInferenceActor requires 10+ swipes before it runs (debounced 5s), which means new users see no RIASEC-based job improvements in their first session.

---

## What Does NOT Change

- The Core Data schema (22 entities — no entity additions or field changes in this plan)
- `ManifestInferenceActor` time-decay weighting formula (sound design, keep as-is)
- `ProfileConverter.toThompsonProfile()` — correct V7Data → V7Thompson bridge
- `SwipeConvergenceMetrics` update cadence (every 10 swipes)
- The 5-second debounce on ManifestInferenceActor
- All Core Data relationship rules (No Action / Nullify — do not change)

---

## Fix 1: ThompsonArm Core Data Persistence (Priority 1)

### Current State

**OptimizedThompsonEngine** maintains two in-memory `FastBetaSampler` instances:
- `amberSampler` — tracks Amber preference history
- `tealSampler` — tracks Teal preference history

On `processInteraction(jobId, action)`:
```swift
// Current — updates in memory only
case .interested:
    amberSampler.alpha += 1  // or tealSampler depending on profileBlend
case .pass:
    amberSampler.beta += 1
```

`ThompsonArm+CoreData.swift` has these methods ready and waiting:
```swift
func recordSuccess()  // increments alpha, saves context
func recordFailure()  // increments beta, saves context
```

Arm IDs used: `"amber_primary"` and `"teal_primary"`.

### Fix

**Two changes to `OptimizedThompsonEngine.swift`:**

**A) Load ThompsonArm state on engine init:**

```swift
// In OptimizedThompsonEngine init() or a loadState() called once on init
func loadPersistedState(context: NSManagedObjectContext) {
    let fetchRequest: NSFetchRequest<ThompsonArm> = ThompsonArm.fetchRequest()
    
    guard let arms = try? context.fetch(fetchRequest) else { return }
    
    for arm in arms {
        switch arm.armId {
        case "amber_primary":
            amberSampler.alpha = arm.alpha
            amberSampler.beta  = arm.beta
        case "teal_primary":
            tealSampler.alpha = arm.alpha
            tealSampler.beta  = arm.beta
        default:
            break
        }
    }
}
```

This must run before the first `scoreJobs()` call. Call it in `init()` or in `DeckScreen.onAppear` immediately after engine instantiation.

**B) Save ThompsonArm state in `processInteraction()`:**

```swift
// In processInteraction() — after updating in-memory sampler
func processInteraction(_ jobId: String, _ action: SwipeAction, context: NSManagedObjectContext) {
    switch action {
    case .interested:
        amberSampler.alpha += 1
        ThompsonArm.fetchOrCreate(armId: "amber_primary", context: context)
            .recordSuccess()  // persists to Core Data
    case .pass:
        amberSampler.beta += 1
        ThompsonArm.fetchOrCreate(armId: "amber_primary", context: context)
            .recordFailure()  // persists to Core Data
    case .save:
        if Double.random(in: 0...1) < 0.8 {
            amberSampler.alpha += 1
            ThompsonArm.fetchOrCreate(armId: "amber_primary", context: context)
                .recordSuccess()
        }
    }
}
```

The teal sampler follows the same pattern using `"teal_primary"` arm ID.

**Note:** The `fetchOrCreate` pattern needs to be confirmed against the actual `ThompsonArm+CoreData.swift` implementation before committing. If `fetchOrCreate` doesn't exist, it needs to be added.

**Prerequisite for SCORING_BUILD_PLAN Fix 1:** baseThompsonScore reconnection only becomes meaningful once ThompsonArm persistence works. Fix this first.

**Files to modify:**
- `OptimizedThompsonEngine.swift` — add `loadPersistedState()`, update `processInteraction()`
- `ThompsonArm+CoreData.swift` — confirm/add `fetchOrCreate(armId:context:)` helper

**Estimated effort:** 1 day (implementation + session persistence test).

---

## Fix 2: JobCache Entity — Remove or Implement

### Current State

`JobCache` is a Core Data entity with:
- `jobId` (unique)
- `title`, `company`, `location`, `fitScore`, `cachedDate`, `embedding`, `sourceAPI`
- A `cache()` static method
- Zero write calls anywhere in the codebase
- Only reference: V5→V7 migration code

### Decision

**Remove the entity.** It adds a Core Data entity that must be maintained through all future schema migrations for zero benefit.

**Process:**
1. Check whether the V5→V7 migration still executes on any active upgrade path. If it references `JobCache` and could still run, removing the entity requires updating the migration simultaneously.
2. Remove `JobCache` from `V7DataModel.xcdatamodeld` — delete the entity from the data model editor.
3. Remove `JobCache+CoreData.swift` if it exists as a generated or manual file.
4. Add a Core Data migration version (`V7DataModel_v2.xcdatamodeld`) that removes the entity using a lightweight migration (mapping model not required for entity deletion if no data exists).

**Risk assessment:**
- If no users have `JobCache` data in their stores (no write path exists), lightweight migration safely deletes the entity
- If migration code references the entity, update it before removing

**Files to modify:**
- `V7DataModel.xcdatamodeld` — remove JobCache entity
- `JobCache+CoreData.swift` — delete file
- V5→V7 migration file — remove JobCache references
- Add new Core Data version for lightweight migration

**Estimated effort:** 2–3 hours if migration path is clean. Add 1 day if migration code needs updating.

---

## Fix 3: ManifestInferenceActor — Lower First-Run Threshold

### Current State

```
ManifestInferenceActor requires:
  - Minimum 10 swipes before running
  - 5-second debounce between runs
```

### Problem

A new user who swipes 9 jobs (common first session length) gets zero RIASEC inference benefit. The InferredManifestProfile stays at defaults. The feedback loop (ManifestInferenceActor → UserProfile.desiredRoles → better title matching) never activates.

### Solution

Lower the first-run threshold from 10 to 3 swipes. The convergence error at 3 swipes is 1/√3 = 57.7% — high, but the purpose at this stage is initializing the profile, not converging it. The `convergenceError` field already tracks this — consumers of `InferredManifestProfile` can gate on convergence if they need high confidence.

```swift
// ManifestInferenceActor.swift — change threshold
private let minimumSwipesRequired: Int = 3  // was 10
```

The 5-second debounce stays unchanged — this prevents runaway inference on rapid swipes.

**What this means:** After 3 swipes, the system makes an initial guess at the user's preferred role and RIASEC profile. That guess is low confidence (convergenceError ~58%) but it's better than nothing. By 10 swipes, convergenceError drops to ~31.6%. By 25 swipes, ~20%.

**Files to modify:**
- `ManifestInferenceActor.swift` — change `minimumSwipesRequired` constant

**Estimated effort:** 30 minutes. One constant change + verify ManifestTabView shows convergenceError correctly.

---

## Fix 4: BehavioralEventLog — Define Its Role or Remove It

### Current State

`BehavioralEventLog` is an immutable append-only log that records every swipe. It's written from `DeckScreen:783` on every swipe. Nothing reads it.

### Decision

`BehavioralEventLog` has two possible fates:

**Option A: Remove it.** `JobInteraction` (Core Data entity) already captures every swipe with full context (jobId, action, thompsonScore, amberTealPosition, timestamp). BehavioralEventLog is redundant. Remove the write call and delete the class.

**Option B: Feed it into ManifestInferenceActor.** Use the immutable log as the source for pattern detection — temporal patterns (what time of day does the user engage?), session patterns (do early swipes differ from late swipes?), velocity patterns (dwell time per card). This is Phase 2 behavioral intelligence.

**Recommendation for V8 Phase 1: Option A — remove.** The BehavioralEventLog's potential value is in temporal/velocity analytics that require significant new logic to extract. That is Phase 2 work. Keeping unused write calls for Phase 2 creates confusion. Remove now, re-add when the reading logic is ready.

**Files to modify:**
- `DeckScreen.swift` — remove `BehavioralEventLog.recordSwipe()` call (line 783)
- `BehavioralEventLog.swift` — delete or comment class
- (Verify: `FastBehavioralLearning` at line 801 — confirm it's separate from BehavioralEventLog)

**Estimated effort:** 1 hour. Remove write calls, verify nothing breaks.

---

## Data Flow Correctness Verification

After all fixes, verify the complete data flow works end-to-end:

### Session 1 (new user)
```
1. Onboarding Step 4 → UserProfile created (amberTealPosition = 0.5)
2. Onboarding Step 5 → desiredRoles + location written
3. App launch → OptimizedThompsonEngine.loadPersistedState() — finds no ThompsonArm entities, stays at Beta(1,1)
4. JSearch jobs loaded → scored with combinedScore (Thompson = 0.5 uniform, no preference bias)
5. User swipes right 3 times →
   a. ThompsonArm "amber_primary" created + alpha = 4 (1 initial + 3 successes) saved to Core Data
   b. ManifestInferenceActor runs (threshold: 3 swipes) → InferredManifestProfile written
   c. If confidence ≥ 0.30 → UserProfile.desiredRoles prepended
6. Next job load → combinedScore uses updated ThompsonArm samples
```

### Session 2 (returning user)
```
1. App launch → OptimizedThompsonEngine.loadPersistedState()
   → ThompsonArm "amber_primary" fetched: alpha=15 (example), beta=5
   → amberSampler initialized at Beta(15, 5) instead of Beta(1, 1)
   → Mean = 15/20 = 0.75 → user tends to like this category
2. First job load → combinedScore includes 8% Thompson weight
   → Jobs in liked category get ~8% × 0.75 = ~6% boost
   → Jobs in disliked category get ~8% × 0.14 = ~1.1%
3. Exploration/exploitation is now active across sessions ✅
```

---

## Implementation Sequence

```
Day 1 (Priority 1 — blocks everything else):
  Fix 1: ThompsonArm persistence
  Implement loadPersistedState() + processInteraction() Core Data writes
  Test: Swipe 5 times, kill app, relaunch, confirm amberSampler.alpha = 6 (not 1)

Day 2:
  Fix 3: ManifestInferenceActor threshold → 3 swipes
  Test: Swipe 3 times, confirm InferredManifestProfile written
  Check ManifestTabView shows result correctly

Day 3:
  Fix 4: Remove BehavioralEventLog
  Remove write call, delete/stub class, verify no compile errors

Day 4–5:
  Fix 2: JobCache entity removal
  Check V5→V7 migration reference, update if needed
  Add Core Data version, lightweight migration
  Test: Install on clean sim, confirm Core Data loads without migration error
```

---

## Files to Modify

| File | Change |
|---|---|
| `OptimizedThompsonEngine.swift` | Add `loadPersistedState()`, update `processInteraction()` to save ThompsonArm |
| `ThompsonArm+CoreData.swift` | Confirm/add `fetchOrCreate(armId:context:)` |
| `ManifestInferenceActor.swift` | Lower `minimumSwipesRequired` from 10 to 3 |
| `DeckScreen.swift` | Remove BehavioralEventLog write call (line 783) |
| `V7DataModel.xcdatamodeld` | Remove JobCache entity |
| V5→V7 migration file | Remove JobCache references |

## Files to Delete

| File | Reason |
|---|---|
| `JobCache+CoreData.swift` | Entity removed, file is dead |
| `BehavioralEventLog.swift` | Replaced by direct JobInteraction reads |

---

## Success Criteria

| Metric | Before | After |
|---|---|---|
| ThompsonArm α/β on cold launch | Always Beta(1,1) | Persisted from prior sessions |
| InferredManifestProfile first write | After 10 swipes | After 3 swipes |
| Core Data entities (active) | 22 | 21 (JobCache removed) |
| BehavioralEventLog writes | Every swipe (to /dev/null) | Removed |
| Exploration/exploitation active | No | Yes (requires SCORING_BUILD_PLAN Fix 1 also complete) |
