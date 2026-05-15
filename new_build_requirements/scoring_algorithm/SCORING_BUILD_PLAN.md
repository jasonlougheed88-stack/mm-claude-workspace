# Scoring Algorithm Build Plan
**Manifest & Match V8 | Created: 2026-05-14**
**Based on:** SCHEMATIC_02_algorithm_math.md

---

## What We're Solving

The current scoring system has one correctly designed component and two broken ones:

**Working correctly:**
- The 5-component professional formula (titleScore, skillsScore, locationScore, workActivitiesScore, riasecScore)
- The profileBlend weight interpolation (0.0 Amber → 1.0 Teal)
- FastBetaSampler (Kumaraswamy approximation, <0.1ms)
- SmartThompsonCache (LRU 50-entry, 5-min TTL)

**Broken / disconnected:**

1. **baseThompsonScore is calculated but discarded.** `amberSampler` and `tealSampler` update on every swipe and persist (once persistence is fixed — see DATA_FLOW_BUILD_PLAN), but their sampled values never reach `combinedScore`. The app is a content-based recommender, not Thompson Sampling.

2. **ThompsonScoringOrchestrator is initialized but never invoked.** It contains `ThompsonBridge` (UserTruths bonuses) and `ThompsonCareerIntegrator` (career goal bonuses). Both are wired internally but `scoringOrchestrator` has zero dot-method calls in DeckScreen.swift. UserTruths bonuses and career bonuses do NOT affect deck order.

3. **Binary title match.** `calculateTitleMatchScore()` returns exactly 0.0 or 1.0 — substring containment only, no partial credit. "Senior Software Engineer" vs "Software Engineer" is a 1.0. "Platform Engineer" vs "Software Engineer" is a 0.0. At Amber (66.5% title weight), this binary creates a cliff: any job that doesn't substring-match the exact desired role is penalized 66.5% of its potential score.

---

## What Does NOT Change

- The master equation structure (5 components × weights)
- The Kumaraswamy approximation in FastBetaSampler
- The Haversine location formula
- The cosine similarity for workActivities and RIASEC
- The weight interpolation formula (Step 1–4 per SCHEMATIC_02)
- The <10ms performance requirement (all changes must maintain this)
- EnhancedSkillsMatcher (unchanged — see TAXONOMY_BUILD_PLAN for synonym improvements)

---

## Fix 1: Reconnect baseThompsonScore to combinedScore

### Current State

```swift
// OptimizedThompsonEngine.swift line 496
let baseThompsonScore = amberSample * (1.0 - profileBlend) + tealSample * profileBlend
// ... (never used in combinedScore formula)

// line 508–517
combinedScore = min(1.0,
    titleScore × w_title +
    skillsScore × w_skills +
    locationScore × w_location +
    workActivitiesScore × w_workActivities +
    riasecScore × w_riasec
)
```

### Problem

Without baseThompsonScore in the formula, user preference history (encoded in Beta distribution α/β) has zero influence on deck ordering. The app cannot explore — it always serves the best professional match regardless of whether that category of job has historically been liked or disliked by this user.

### Solution

Add `baseThompsonScore` as a sixth component with a fixed, small weight. This weight does NOT interpolate with profileBlend — it applies equally at all slider positions. The exploration signal is constant.

**New formula:**

```swift
// 6-component formula with fixed exploration weight
let w_thompson: Double = 0.08  // 8% — tunable

// Scale existing weights to make room for Thompson exploration
let professionalScaleFactor = 1.0 - w_thompson

// combinedScore now includes exploration
combinedScore = min(1.0,
    titleScore          × (w_title          × professionalScaleFactor) +
    skillsScore         × (w_skills         × professionalScaleFactor) +
    locationScore       × (w_location       × professionalScaleFactor) +
    workActivitiesScore × (w_workActivities × professionalScaleFactor) +
    riasecScore         × (w_riasec         × professionalScaleFactor) +
    baseThompsonScore   × w_thompson
)
```

**What 8% means in practice:**
- At Amber (t=0): title was 66.5%, becomes 66.5% × 0.92 = 61.2%. Thompson gets 8%.
- At Teal (t=1): work activities was 30%, becomes 30% × 0.92 = 27.6%. Thompson gets 8%.
- A job category with α=15, β=2 (historically liked: mean ~0.88) gets +7.0% boost
- A job category with α=2, β=12 (historically disliked: mean ~0.14) gets +1.1%

**Weight table after change:**

| Weight | t=0.0 (Amber) | t=0.5 (Default) | t=1.0 (Teal) |
|---|---|---|---|
| Title Match | 61.2% | 39.3% | 13.8% |
| Skills | 21.9% | 25.1% | 20.7% |
| Location | 4.4% | 6.8% | 6.9% |
| Work Activities | 0% | 15.6% | 27.6% |
| RIASEC | 4.6% | 13.8% | 23.0% |
| **Thompson** | **8.0%** | **8.0%** | **8.0%** |
| **Sum** | **100%** | **100%** | **100%** |

**Tuning:** Start at 8%. If user testing shows exploration too noisy (unfamiliar jobs jumping high), reduce to 5%. If no visible diversity improvement, raise to 12%.

**Prerequisite:** ThompsonArm persistence must be fixed first (DATA_FLOW_BUILD_PLAN Fix 1). Without persistence, Beta always starts at (1,1) and Thompson contribution is uniform 0.5 — functionally neutral but not harmful.

**File to modify:**
- `OptimizedThompsonEngine.swift` lines 508–517 — extend combinedScore formula

**Estimated effort:** 2 hours. One formula change + weight constant + tests.

---

## Fix 2: Wire ThompsonScoringOrchestrator

### Current State

```swift
// DeckScreen.swift line 1572
private let scoringOrchestrator = ThompsonScoringOrchestrator()
// ... zero dot-method calls on scoringOrchestrator anywhere in DeckScreen.swift

// applyUserTruthsBonusToUpcomingJobs() — logs "ready" and returns
```

### ThompsonBridge Logic (what it was designed to do)

ThompsonBridge applies a bonus multiplier to jobs based on UserTruths Core Data entity:
```
finalScore = baseScore × (1.0 + userTruthsBonus + careerBonus)
```

The multiplier caps at 0.99. It uses:
- `UserTruths.loveTasks` — boost jobs matching tasks the user loves
- `UserTruths.hateTasks` — penalize jobs with tasks the user hates
- `UserTruths.workValues` — boost jobs matching stated values
- `CareerGoal` (ThompsonCareerIntegrator) — boost jobs aligned with declared target role

### Solution

**Step 1: Call ThompsonBridge in the scoring path, not as a post-processing step.**

The current design tried to apply bonuses to "upcoming jobs" in bulk (applyUserTruthsBonusToUpcomingJobs). This is fragile. Instead, apply the multiplier per-job inside `fastProfessionalScore()` after computing combinedScore:

```swift
// In OptimizedThompsonEngine.fastProfessionalScore() — after computing combinedScore
let truthsBonus = await ThompsonBridge.shared.computeBonus(for: job, profile: userFeatures)
let adjustedScore = min(0.99, combinedScore * (1.0 + truthsBonus))
```

**Step 2: Ensure UserTruths has data before applying.**

UserTruths is populated by UserTruthsExtractionActor when question cards are answered. Until the user answers at least one question, UserTruths is empty — bonus = 0.0, no effect.

```swift
// ThompsonBridge.computeBonus() guard
guard let truths = UserTruths.current, truths.hasData else {
    return 0.0  // no effect until UserTruths populated
}
```

**Step 3: Remove ThompsonScoringOrchestrator from DeckScreen.**

The orchestrator pattern (initialized but not called) was an architectural mistake. Move ThompsonBridge and ThompsonCareerIntegrator into the OptimizedThompsonEngine directly. DeckScreen should not own scoring infrastructure.

**Files to modify:**
- `OptimizedThompsonEngine.swift` — add ThompsonBridge.computeBonus() call post-scoring
- `DeckScreen.swift` — remove `scoringOrchestrator` initialization (line 1572)
- `ThompsonBridge.swift` — update `computeBonus()` to be callable per-job

**Estimated effort:** 3–4 days. Requires reading ThompsonBridge.swift and ThompsonCareerIntegrator.swift to understand current bonus logic before wiring.

---

## Fix 3: Soften Binary Title Match

### Current State

```swift
// calculateTitleMatchScore() — binary
if jobTitle.lowercased().contains(desiredRole.lowercased()) ||
   desiredRole.lowercased().contains(jobTitle.lowercased()) {
    return 1.0
} else {
    return 0.0
}
```

### Problem

At Amber, title weight is ~61% of the score. A binary match means:
- "Software Engineer" desired → "Senior Software Engineer" = 1.0 ✅
- "Software Engineer" desired → "Platform Engineer" = 0.0 ❌
- "Software Engineer" desired → "Staff Software Engineer" = 1.0 (substring) ✅

But the semantic gap matters. "Engineering Manager" should score higher than "Content Writer" for someone who wants "Software Engineer" — the binary formula gives both 0.0.

### Solution

Replace the binary with a 3-tier scoring:

```swift
func calculateTitleMatchScore(jobTitle: String, desiredRoles: [String]) -> Double {
    let job = jobTitle.lowercased()
    
    for role in desiredRoles {
        let desired = role.lowercased()
        
        // Tier 1: Exact substring — full score
        if job.contains(desired) || desired.contains(job) {
            return 1.0
        }
        
        // Tier 2: Shared significant word overlap — partial score
        let jobWords = Set(job.components(separatedBy: .whitespaces)
            .filter { $0.count > 3 })  // skip "and", "of", etc.
        let desiredWords = Set(desired.components(separatedBy: .whitespaces)
            .filter { $0.count > 3 })
        let overlap = jobWords.intersection(desiredWords).count
        if overlap >= 1 {
            return 0.6 + Double(overlap) * 0.1  // 0.6 base + 0.1 per shared word, max 1.0
        }
    }
    
    // Tier 3: No match — reduced penalty rather than zero
    return 0.0  // could raise to 0.10 if zero-cliff causes too many empty decks
}
```

**Impact:** At Amber (61% title weight), a partial tier-2 match contributes 61% × 0.6 = 36.6% to combinedScore rather than 0%. Jobs that are related but not exact matches become viable rather than invisible.

**Files to modify:**
- `OptimizedThompsonEngine.swift` — replace `calculateTitleMatchScore()` implementation (~line 705)

**Estimated effort:** 1 day (implementation + validation against 50 sample title pairs).

---

## Missing Levers (LEVERS 1,2,4,5,6,7,8,10)

SCHEMATIC_02 notes: LEVERS 1, 2, 4, 5, 6, 7, 8, 10 are referenced in comments but have no implementation found.

**Resolution for V8 build plan:**

Do not implement ghost levers from comments. Define what V8 actually needs:

| Lever # | Proposed V8 Use | Implementation Phase |
|---|---|---|
| UserTruths Bonus | ThompsonBridge multiplier (Fix 2 above) | Phase 1 |
| Career Goal Alignment | ThompsonCareerIntegrator multiplier (Fix 2 above) | Phase 1 |
| Salary Range Match | New component: does job salary band overlap user target? | Phase 2 |
| Company Size Preference | User states preference in onboarding Step 5 — add scoring component | Phase 2 |
| Remote/Hybrid/Onsite Preference | Currently binary in location score — expand to explicit preference match | Phase 2 |
| Tenure Match | User experience level vs job seniority requirements | Phase 3 |

Do not add Phase 2/3 levers until Phase 1 (Fixes 1–3 above) are validated and scoring latency confirmed at <10ms.

---

## Implementation Sequence

```
Week 1:
  Prerequisite: ThompsonArm persistence (DATA_FLOW_BUILD_PLAN) — must complete first
  
  Day 1–2:   Fix 3 — Soften binary title match
             Lowest risk, isolated change, high impact at Amber
             Test: 50 sample title pairs, confirm no regression on exact matches
  
  Day 3:     Fix 1 — Reconnect baseThompsonScore to combinedScore
             Requires ThompsonArm persistence to be meaningful
             Test: Score 50 jobs before/after, confirm Thompson signal visible in ordering
  
  Day 4–5:  Validate both changes together
             Confirm combinedScore still in [0.0, 1.0] range
             Confirm <10ms scoring budget (benchmark via PerformanceTests.swift)

Week 2:
  Day 1–4:  Fix 2 — Wire ThompsonBridge into per-job scoring
             Read ThompsonBridge.swift, ThompsonCareerIntegrator.swift first
             Remove scoringOrchestrator from DeckScreen
             Wire computeBonus() into OptimizedThompsonEngine
             Test: Answer 3 question cards, confirm UserTruths populated, confirm bonus applies
  
  Day 5:    End-to-end scoring validation
             Full scoring run on 100 jobs with all 3 fixes applied
             Compare deck order diversity before/after (expect more varied titles at Amber)
```

---

## Files to Modify

| File | Change |
|---|---|
| `OptimizedThompsonEngine.swift` | Extend combinedScore formula (Fix 1), soften title match (Fix 3), add ThompsonBridge call (Fix 2) |
| `DeckScreen.swift` | Remove `scoringOrchestrator` initialization |
| `ThompsonBridge.swift` | Update `computeBonus()` to per-job callable |

## Files Unchanged

- `FastBetaSampler.swift` — sampling math unchanged
- `SmartThompsonCache.swift` — cache unchanged
- `EnhancedSkillsMatcher.swift` — unchanged (synonym improvements handled in TAXONOMY_BUILD_PLAN)
- `calculateWorkActivitiesScore()` — unchanged
- `calculateRIASECScore()` — unchanged

---

## Success Criteria

| Metric | Before | After |
|---|---|---|
| Thompson Sampling influence on deck order | 0% (discarded) | 8% (active) |
| Title match granularity | Binary (0 or 1) | 3-tier (0, 0.6–0.8, 1.0) |
| UserTruths bonus active in scoring | No | Yes |
| Scoring latency | ~7ms avg | ~7.5ms avg (budget allows 10ms) |
| Deck diversity at Amber slider position | Title-locked | Title-dominant but not title-exclusive |
