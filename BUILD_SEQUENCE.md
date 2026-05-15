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

### Read the AI systems and ad card code from the V7 reference codebase.

No implementation decisions have been made about these two systems yet. The schematics and build plans contain assumptions that may be wrong. The source code is the only truth.

**Reference codebase location:** `/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8/Packages/`

**What to read and understand:**

1. **AI Systems** — understand what is actually built, what it does, how it connects
   - `V7AI/Sources/V7AI/` — all files
   - `V7Thompson/Sources/V7Thompson/` — all files
   - Focus: what does the scoring pipeline actually do end to end. How do the AI components feed into job scoring. What is broken vs working.

2. **Ad Cards** — understand what is actually built and how it injects into the job card space
   - `V7Ads/Sources/V7Ads/` — all files
   - Focus: how ad cards are injected into the deck alongside job cards. What state they carry. How they interact with the scoring/swipe system.

3. **Job Card space** — both ad cards and AI-driven question cards live here alongside job cards
   - `V7UI/Sources/V7UI/Views/DeckScreen.swift` — understand the card space architecture
   - How are different card types (job, question, ad) managed in the same deck

**After reading:** Report what is actually there — correct any wrong assumptions in DECISIONS.md and OPEN_QUESTIONS.md before any code is written.

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
