# Build Sequence — Manifest & Match
**Read this first. Every session. Before touching anything.**
Last updated: 2026-05-15

---

## ⚠️ CURRENT SESSION STATUS — READ BEFORE DOING ANYTHING

**We are NOT yet on Phase 1. Do not touch `ios-app/`.**

---

## IMMEDIATE NEXT TASK — Scaffold Design (fresh session picks up here)

**Pre-Phase 1 work is COMPLETE.**
- Inventory: ✅ `schematics/SYSTEM_INVENTORY.md`
- Untangling Guide: ✅ `schematics/UNTANGLING_GUIDE.md`

**Next:** Scaffold design — plan the v1.1 Xcode workspace structure before touching `ios-app/`.

Read the Untangling Guide (especially Layer 2 structural conclusions) before designing the scaffold. The lift/rebuild/drop/defer tables tell you exactly which systems go into Phase 1 vs later.

---

## Where We Are

**Phase 0 — Workspace Setup: COMPLETE**
All planning docs, folder structure, repos, and session tooling are in place.

**Pre-Phase 1 work (session 2026-05-15):**
- Package naming audit: ✅ COMPLETE
- System inventory (initial): ✅ COMPLETE (`schematics/SYSTEM_INVENTORY.md`)
- Inventory verified against 8 schematics: ✅ COMPLETE (significant corrections made)
- Inventory verified by running app / reading UNKNOWN items: ✅ COMPLETE (deep codebase read, 2026-05-15)
- Untangling guide: ✅ COMPLETE (`schematics/UNTANGLING_GUIDE.md`)
- Scaffold design: ⬜ NOT STARTED

**Current task: Phase 1 — Scaffold the new Xcode workspace in `ios-app/`**
**STATUS: BLOCKED — complete pre-Phase 1 work above first.**

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
