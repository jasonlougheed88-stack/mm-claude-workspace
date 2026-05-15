# V8 Master Issue List
**Created:** 2026-05-09  
**Status:** In progress — working through one area at a time

---

## ARCHITECTURAL NORTH STAR (2026-05-09)

### The Slider Is the Candidate Generation Control

The Amber/Teal slider has been used to control scoring weights and deck composition ratios. This is backwards. The slider should control **what gets fetched**, not just how fetched jobs are ranked.

**Correct model:**

| Slider Position | Candidate Generation | Scoring |
|---|---|---|
| Amber (0.0) — Match | 80% stated desired roles, 20% skill-cluster outliers | Same math |
| Balanced (0.5) | 50/50 split | Same math |
| Teal (1.0) — Manifest | 20% stated desired roles, 80% skill-cluster expansion | Same math |

The scoring math (Thompson + RIASEC + Work Activities + Skills) stays constant. What changes is the **diversity of the pool** it scores against.

### The Two-Stage Pipeline (Candidate Generation → Ranking)

**Stage 1 — Candidate Generation (invisible to user):**
- Pull a broad stock of jobs (~300-500) based on skill-space coverage
- Amber queries: stated desired roles from onboarding
- Teal queries: occupation titles derived from user's O*NET skill fingerprint via `OccupationExpander`
- Multiple sources run in parallel (JSearch + Greenhouse + Lever + others)
- User never sees this pool directly

**Stage 2 — Ranking (the math):**
- Full Thompson + RIASEC + Work Activities + Skills scoring runs on entire stock
- User sees only the top 10 on the deck
- Every swipe refines Thompson arms AND the skill fingerprint
- Manifest profile builds from the pattern of what surfaces to the top

### Why This Matters for Discovery

A right-swipe on a job the user asked for = preference confirmation.  
A right-swipe on a job the system surfaced from skill-cluster expansion = high-information signal (unexpected preference). This is what drives manifest profile convergence — the user discovering roles they didn't know they wanted.

You cannot score your way to discovery if the candidate pool was never diverse enough. The scoring math is only as good as the variety of what it has to work with.

### Thompson Arm Semantics (Corrected)

- **Amber arm** learns: "from the jobs matching what you said you want, which do you prefer?"
- **Teal arm** learns: "from the jobs the system thinks you'd want based on your skills, which surprise you?"

Both arms need a pool that actually represents their purpose. Currently both draw from the same narrow title-based pool.

### The OccupationExpander (Key Missing Piece)

The inbound taxonomy (Tier 1 → Tier 2) is done: `skill_tier1_to_onet.json` + `SkillNormalizer`.

The **outbound taxonomy** is what generates the Teal pool:
```
User skill fingerprint (O*NET skill names)
  → onet_occupation_skills.json (726 occupations × 35 skills with importance scores)
  → Find all occupations where those skills score ≥ threshold
  → Return ranked occupation titles
  → Those titles become Teal query vocabulary
```

This is `OccupationExpander.swift` — the next piece to build.

**Example for an Account Executive with skills [Persuasion, Negotiation, Service Orientation, Speaking, Active Listening]:**
- Direct matches: Sales Manager, Business Development Rep, Account Manager
- Skill-cluster outliers: Training & Development Manager, Fundraising Manager, Real Estate Agent, Insurance Sales, Partnerships Manager, Revenue Operations
- User never searched for those — but the math says their skill profile matches

---

## A. The Language Problem (Root Cause of Most Scoring Issues)

**A1. ✅ DONE** Resume skills saved as raw free text, never normalized to O*NET canonical names.
- Fix: `SkillNormalizer.swift` + `ProfileConverter.swift`. Resume skills translated to O*NET formal names before scoring.

**A2. ✅ DONE** No translation layer between the three skill vocabularies.
- Fix: `skill_tier1_to_onet.json` (~230 mappings). Bridges Tier 1 (market) → Tier 2 (O*NET formal).

**A3.** Skills gap calculation is case-insensitive string subtraction only. No semantic matching.

**A4.** Course recommendation queries pass skill names directly to APIs with no taxonomy translation.

**A5.** Location saved with full name embedded — messy raw data downstream.

---

## B. Thompson Scoring (The Math Is Mostly Defaults)

**B1. ✅ DONE** Work Activities returns `0.5` default on every job.
- Fix: `ProfileConverter.swift` maps `currentJobTitle` → O*NET code → work activity scores.

**B2.** RIASEC (5–25% weight) returns `0.5` default on every job — `job.riasecProfile` never populated.
- Partial: User RIASEC now wired (E1). Job-side RIASEC still needs O*NET enrichment on fetched jobs.

**B3.** Title Match is pure substring. No synonym expansion.

**B4.** Location Match contributes 0 — JSearch jobs return no coordinates.

**B5.** Thompson only has 2 arms covering the entire job universe. Cannot learn role-specific or sector-specific preferences. (Partially addressed by correct slider → pool architecture above.)

**B6.** Thompson Engine reloads completely on every swipe. >10ms budget violations.

**B7.** Sprint 4 bonus scoring calls `scoreJobs` individually per job instead of batch.

---

## C. Deck Composition

**C1. ✅ DONE** LEVER 10 Jaccard threshold 0.7 — too high. 10 fetched → 4 shown.
- Fix: Threshold lowered to 0.3 in `JobDiscoveryCoordinator.swift`.

**C2.** ManifestInferenceActor stores raw job listing titles as inferred career goals ("Project Manager, GEMS, NA Startup") — sends literal string to API.
- Fix known: normalize `jobRole` before writing to Core Data. Strip commas/parentheticals, snap to RolesDatabase canonical title. Not yet implemented — deprioritized until OccupationExpander changes the query architecture.

**C3. ✅ DONE** Adaptive query adds `job_requirements=under_3_years_experience` after 10 swipes regardless of actual experience level.
- Fix: Removed `job_requirements` param from `buildSearchURL` in `JSearchAPIClient.swift`. Experience level scoring happens post-fetch, not server-side. Commit 2f7b75c.

---

## D. Memory & Performance

**D1.** Memory baseline — PerformanceBudget.swift now shows 1GB max / 800MB baseline. May already be resolved. Needs device verification.

**D2.** Job parsing takes 3–5 seconds per job. Budget is 2s.

**D3.** Total initial load pipeline is 13–14 seconds. Budget is 5 seconds.

**D4.** O*NET enrichment: 44–350ms per job. Budget is 150ms. Inconsistent.

---

## E. Profile → AI Learning Disconnection

**E1. ✅ DONE** RIASEC not wired into `UserFeatures.interests`.
- Fix: `ProfileConverter.swift` reads `onetRIASEC*` Core Data fields → builds `RIASECProfile` → `professionalProfile.interests`.

**E2.** ManifestTab shows 0 skill gaps and 0 courses. Blocked by C2 and the pool architecture.

**E3.** Career Discovery returns `role not found` for common titles ("Product Manager", "Account Executive").

**E4.** RIASEC scores display as 0.00 on ManifestTab even after inference computed values.

---

## F. API & Query Quality

**F1. ✅ DONE** `country=ca` correct. Query titles relevant.

**F2.** Second adaptive fetch returns 1 job — over-filtering (C2 + experience level filter).

**F3.** Career Discovery can't expand cross-domain because role lookup fails at first step (E3).

---

## Revised Priority Order

### Phase 1 — Complete the Taxonomy (Foundation for Everything)
1. **✅ DONE** `OccupationExpander.swift` — outbound taxonomy: skill fingerprint → occupation title list (Teal pool generator).
2. **✅ DONE** Slider-driven candidate generation — `profileBlend` wired into `buildSearchQuery`. OccupationExpander drives Teal pool.
3. ~~Enable Greenhouse + Lever~~ — **REJECTED by user**: data never ported correctly into cards, output was junk. Replaced by broadening JSearch.
4. **✅ DONE** JSearch volume — `num_pages` 1 → 10 (~10 jobs → ~100 per call). Commit 2f7b75c.

### Phase 2 — Fix the Remaining Bugs
5. **C2** — Normalize `jobRole` in swipe recording (unblocks E2, F2, F3)
6. ~~**C3**~~ **✅ DONE** — Experience filter removed from JSearch URL. Commit 2f7b75c.
7. **E3** — Fix O*NET role lookup for conventional titles
8. **B3** — Synonym expansion for title matching
9. **E4** — Wire RIASEC display to ManifestTab
10. **B2** — Populate job-side `riasecProfile` from O*NET enrichment

### Phase 3 — Performance
10. **A3/A4** — Semantic skills gap + course taxonomy translation
11. **D2/D3** — Job parsing performance investigation
12. **B6** — Thompson reload on every swipe

---

## Session Log

- **2026-05-08:** JSearch API 429 fixed. New key active. API returning 10 jobs.
- **2026-05-08:** Removed 30-minute throttle blocking all startup calls.
- **2026-05-08:** Thompson persistence fixed — alpha/beta saved to Core Data, survive app restart (commit 9487265).
- **2026-05-09:** Full architecture audit. 24 issues identified across 6 areas.
- **2026-05-09:** Profile saving correctly (25 skills, location, work experience).
- **2026-05-09:** `skill_tier1_to_onet.json` created (~230 market → O*NET mappings).
- **2026-05-09:** `SkillNormalizer.swift` created. Fixes A1/A2.
- **2026-05-09:** `ProfileConverter.swift` updated — SkillNormalizer (A1/A2), RIASEC wired (E1), WorkActivities wired (B1).
- **2026-05-09:** LEVER 10 threshold 0.7 → 0.3 (C1). Full 10-card deck now possible. Commit 90d255e.
- **2026-05-09:** Architectural realization — slider should control candidate generation pool composition, not just scoring weights. OccupationExpander identified as the key missing piece. Two-stage pipeline (candidate generation → ranking) defined as north star architecture.
- **2026-05-09:** `OccupationExpander.swift` built. Inverted index: O*NET skills → occupation titles. Wired into `buildSearchQuery` replacing RolesDatabase title-graph expansion. Slider blend now controls Amber (stated roles) vs Teal (skill-cluster expansion) pool ratio.
- **2026-05-09:** JSearch `num_pages` 1 → 10. Experience level filter (C3) removed from `buildSearchURL`. Greenhouse/Lever rejected by user — data quality issues. Commit 2f7b75c.
