# Build Sequence — Manifest & Match
**Read this first. Every session. Before touching anything.**
Last updated: 2026-05-15

---

## Where We Are

**Phase 0 — Workspace Setup: COMPLETE**
All planning docs, folder structure, repos, and session tooling are in place.

**Current task: PRE-BUILD AUDIT — Read before writing a single line of app code.**

---

## Immediate Next Task

**Pre-Phase 1 — Rename packages to reflect what they actually are**

The current package names (V7Core, V7Data, V7Thompson, V7AI, V7UI, etc.) are version-numbered labels from previous iterations that do not describe what each package actually does.

Before building anything:
1. Read every package in the reference codebase at `/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8/Packages/`
2. For each package, write one sentence describing what it actually does in plain terms
3. Propose a new name that reflects that — no version numbers, no internal jargon
4. Present the full list to Jason for approval before any code is written
5. Once approved, those names are the names used in the new build

Do not start scaffolding until naming is approved.

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
