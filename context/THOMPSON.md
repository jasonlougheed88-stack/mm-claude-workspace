# Thompson Sampling — Reference
**Source:** `Packages/V7Thompson/Sources/V7Thompson/OptimizedThompsonEngine.swift`

---

## What It Does
Bayesian multi-armed bandit. Two arms (amber=current self, teal=future self) each maintain a Beta distribution (alpha, beta). Each swipe updates the distribution. Over time, the engine shows more of what the user likes.

## The Two Arms
```
amber_primary  — jobs matching current self (profile blend = 0.0)
teal_primary   — jobs matching future self  (profile blend = 1.0)
```
Profile blend slider (0.0–1.0) blends between the two samplers in real time.

## Persistence Pattern (wired as of commit 9487265)
**On init (sync):**
```swift
if let arm = ThompsonArm.fetch(armId: "amber_primary", in: ctx) {
    amberSampler = FastBetaSampler(alpha: arm.alpha, beta: arm.beta)
} else {
    amberSampler = FastBetaSampler(alpha: 1.0, beta: 1.0)  // flat prior
}
// same for teal_primary
```

**On swipe (processInteraction):**
Updates alpha/beta → saves to `ThompsonArm` Core Data entity.

**Starting state:** alpha=1.0, beta=1.0 (uniform — no preference yet)
**After 20 right swipes on tech roles:** alpha grows, beta stays low → tech jobs score higher

## Key Types
| Type | File | Purpose |
|------|------|---------|
| `OptimizedThompsonEngine` | V7Thompson | Production engine, @MainActor |
| `FastBetaSampler` | V7Thompson | Beta distribution math, SIMD |
| `ThompsonArm` | V7Data | Core Data entity — persists alpha/beta |
| `ThompsonCache` | V7Thompson | In-memory score cache |
| `SwipePatternAnalyzer` | V7Thompson | Detects patterns in swipe history |

## Performance Budget
Target: **< 10ms** per `scoreJobs()` call.
Current state: was 12.9ms P95, optimization work done (see Thompson guide in V8 docs).
`PerformanceBudget.thompsonSamplingTarget = 0.010` — runtime assertion.

## Async vs Sync Init
- Async init (`init(initialProfileBlend:...)`) — does NOT wire persistence (`context = nil`)
- Sync init (`init(profileBlend:exploration:confidence:context:)`) — DOES wire persistence
- `JobDiscoveryCoordinator` must use the sync init with a real context for persistence to work

## Debug: Verify Learning Persisted
```bash
bash "/Users/jasonl/Desktop/Claudes-Man&Man-build/tools/check_thompson_state.sh"
```
After swipes, arms should show alpha > 1.0 or beta > 1.0 (not the flat prior).
