# Build Sequence — Manifest & Match
**Read this first. Every session. Before touching anything.**
Last updated: 2026-05-16

---

## ⚠️ CURRENT SESSION STATUS — READ BEFORE DOING ANYTHING

**Phase 2 data flow is COMPLETE. Phase 3 (Scoring) is next.**

---

## IMMEDIATE NEXT TASK — Phase 3: Scoring

**Phase 2 is DONE. Clean build confirmed (zero errors, zero warnings).**

### What was built in Phase 2 (2026-05-16)
1. ✅ `PersistenceController.container` — marked `nonisolated` (enables cross-actor access)
2. ✅ `ThompsonArm.swift` — NSManagedObject subclass with `createOrUpdate`/`fetch`/`recordSuccess`/`recordFailure`
3. ✅ `JobInteraction.swift` — NSManagedObject subclass with `fetchAll(in:)` and `jobSkills` computed property
4. ✅ `InferredManifestProfile.swift` — NSManagedObject subclass with `fetchOrCreate(in:)`, JSON-coded arrays
5. ✅ `FastBetaSampler.swift` — Kumaraswamy approximation, SIMD batch sampling, `FastLookupTable` (O(1))
6. ✅ `OptimizedThompsonEngine.swift` — actor, `initialize()` loads persisted arms, `processInteraction()` saves after every swipe
7. ✅ `ManifestInferenceActor.swift` — actor, threshold = 3 (not 10), 5s debounce, skill/role inference
8. ✅ Clean build — zero errors, zero warnings

### Phase 2 persistence gate
- Gate test: Call `await OptimizedThompsonEngine.shared.initialize()` at launch, call `processInteraction(action: .interested, thompsonScore: 0.5)` 5 times, kill app, relaunch, call `initialize()` again — `amberAlpha` should be 6 (not 1).
- NOT YET verified via running simulator (requires Phase 4 DeckUI swipe UI to exist)

### Phase 3 Next Task
Read `new_build_requirements/` for the Phase 3 scoring build plan.
Key Phase 3 work:
- 6-component combinedScore: title + skills + location + workActivities + riasec + baseThompsonScore
- 3-tier title match (exact/synonym/fuzzy)
- ThompsonBridge: wires OptimizedThompsonEngine → DeckUI card scoring
- `ThompsonWeights` slider interpolation (Match mode ↔ Manifest mode)
- Performance gate: <10ms for 100-job batch (sacred budget)

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
8. ⬜ Performance gate: <10ms for 100-job batch (sacred budget — must verify before Phase 4)

**Current task: Phase 3 — Scoring (items 1–8 above)**

---

## Pre-Build Audit: COMPLETE (2026-05-15)

Package naming audit done. All 15 packages audited against live workspace (confirmed via XcodeBuildMCP). Names approved. Authoritative mapping: `context/PACKAGE_NAMES.md`. DECISIONS.md updated.

---

## Immediate Next Task

**Phase 1 — Scaffold new Xcode workspace**

New build location: `/Users/jasonl/Desktop/Claudes-Man&Man-build/ios-app/`
Reference codebase: `/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8/`

Scaffold in this order (per `new_build_requirements/package_architecture/PACKAGE_BUILD_PLAN.md`):
1. Create new Xcode workspace: `ManifestAndMatch.xcworkspace`
2. Create 15 Swift packages with approved names (see `context/PACKAGE_NAMES.md`)
3. Wire Package.swift dependencies per the DAG in PACKAGE_NAMES.md
4. Add CoreTaxonomy/SacredUIConstants.swift — copy sacred values from reference, validate at runtime
5. Add Persistence/PersistenceController.swift + Core Data model (21 entities, minus JobCache)
6. Verify clean build (no errors, no circular dependencies)

Do NOT copy code wholesale from the reference codebase. Build each piece intentionally.

**Note:** OPEN_QUESTIONS.md Q1 (Tab 1 name/CRM schema) must be answered before Phase 4 but does not block Phase 1-3.

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
