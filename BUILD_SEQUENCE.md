# Build Sequence — Manifest & Match
**Read this first. Every session. Before touching anything.**
Last updated: 2026-05-16

---

## ⚠️ CURRENT SESSION STATUS — READ BEFORE DOING ANYTHING

**Phases 1–4 are COMPLETE. Phase 5 (Revenue) is next.**
**Last updated: 2026-05-16. Build: zero errors, zero warnings on all four phases.**

---

## IMMEDIATE NEXT TASK — Phase 5: Revenue

**Step 1: Read `new_build_requirements/` for Phase 5 plan before writing any code.**

Key Phase 5 work:
1. Ad cards — Google AdMob integration, ad card in job card space (every N cards)
2. Course affiliate cards — in Manifest tab, triggered by RIASEC data gaps + slider position
3. Wire `JobPipeline` to real job data source (replaces SyntheticJobs.swift in DeckUI)
4. Gate: ad card renders in deck, affiliate card renders in Manifest tab, revenue events fire

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
