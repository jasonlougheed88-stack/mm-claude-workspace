# Phase 1 — Thompson Persistence

## The Problem
`OptimizedThompsonEngine` runs two `FastBetaSampler` instances:
- `amberSampler` — alpha/beta for "current self" arm
- `tealSampler` — alpha/beta for "future self" arm

Each has parameters that drift based on swipes. But they are never saved.
`ThompsonArm` Core Data entity has `alpha`, `beta` fields + `recordSuccess()` / `recordFailure()` — never connected.

**Result:** Every cold launch resets to alpha=1, beta=1. The app learns nothing.

## Files to Touch
- `Packages/V7Thompson/Sources/V7Thompson/OptimizedThompsonEngine.swift` — add load/save
- `Packages/V7Data/Sources/V7Data/Entities/ThompsonArm+CoreData.swift` — use existing methods
- `Packages/V7Data/Sources/V7Data/PersistenceController.swift` — provide context

## Implementation Plan
1. On `OptimizedThompsonEngine.init()`: fetch ThompsonArm records from Core Data, set amberSampler.alpha/beta and tealSampler.alpha/beta from stored values
2. On `processInteraction()`: after updating samplers, save new alpha/beta to Core Data
3. Arm IDs: use "amber_primary" and "teal_primary" as stable identifiers

## Verification
Run `tools/check_thompson_state.sh` after swipe session — confirms Core Data has non-default (≠1.0) alpha/beta values.
