# Build Sequence — Manifest & Match
**Read this first. Every session. Before touching anything.**
Last updated: 2026-05-15

---

## ⚠️ CURRENT SESSION STATUS — READ BEFORE DOING ANYTHING

**Phase 1 scaffold is COMPLETE. Phase 2 is next.**

---

## IMMEDIATE NEXT TASK — Phase 2: Data Flow

**Phase 1 scaffold is DONE. Clean build confirmed twice (zero errors, zero warnings).**

### What was built in Phase 1 (2026-05-15)
1. ✅ XcodeBuildMCP — connected
2. ✅ Bundle ID — `com.manifestandmatch.app` (Team ID: 5U9GNHH75M, registered in Apple Developer Portal)
3. ✅ Xcode project — `ios-app/ManifestAndMatch.xcodeproj` (xcodegen 2.45.4)
4. ✅ 15 packages — created in DAG order at `ios-app/Packages/`
5. ✅ Package.swift DAG — wired per `context/PACKAGE_NAMES.md`
6. ✅ SacredUIConstants — `CoreTaxonomy/Sources/CoreTaxonomy/SacredUIConstants.swift`
7. ✅ Clean build — zero errors, zero warnings
8. ✅ Core Data model — 21 entities (JobCache excluded) at `Persistence/Sources/Persistence/ManifestAndMatch.xcdatamodeld/`
9. ✅ PersistenceController — `Persistence/Sources/Persistence/PersistenceController.swift`
10. ✅ Final clean build — zero errors, zero warnings

### Phase 2 Next Task
Read `new_build_requirements/` for the Phase 2 data flow build plan before writing any code.
Key Phase 2 work:
- ThompsonArm persistence — load on init, save on every swipe (arm IDs: `"amber_primary"`, `"teal_primary"`)
- ManifestInferenceActor threshold = 3 (not 10)
- Slider drives profileBlend → ThompsonWeights
- Gate: swipe → save arms → relaunch → arms match last session

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

**Current task: Phase 2 — Data Flow**

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
