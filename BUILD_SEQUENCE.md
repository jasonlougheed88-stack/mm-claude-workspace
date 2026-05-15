# Build Sequence — Manifest & Match
**This is the authoritative "what are we building" document.**
**Read this at the start of every session. Update this at the end of every session.**

Last updated: 2026-05-14

---

## Current Phase

**PHASE 0 — Workspace Setup**
Status: IN PROGRESS
Goal: Get the build environment right before writing a single line of app code.

---

## What's Done

- [x] 8 schematics written (honest audit of V8 codebase)
- [x] 8 build plans written (what to fix and in what order)
- [x] Folder structure reorganized with correct phase sequence
- [x] Git repository exists in this folder
- [x] BUILD_SEQUENCE.md created (this file)
- [x] DECISIONS.md created
- [x] Backend plan created
- [ ] CLAUDE.md updated to point here
- [ ] CLAUDE_CAPABILITIES.md paths updated
- [ ] Hook updated to point to ios-app/
- [ ] Xcode project scaffolded in ios-app/
- [ ] GitHub remote connected to this folder's git repo
- [ ] Backend (Cloudflare Workers) scaffolded

---

## Build Phases — Ordered

### Phase 0 — Workspace Setup (current)
Get all tooling pointing at this folder. No app code yet.
- Update CLAUDE.md, CLAUDE_CAPABILITIES.md, hook paths
- Scaffold Xcode project in ios-app/
- Connect git to GitHub
- Scaffold backend skeleton in backend/
**Completion gate:** Clean build from ios-app/, hook fires correctly, git push works

---

### Phase 1 — Foundation
*Matches: PACKAGE_BUILD_PLAN.md*
Build the package DAG from scratch, clean. No dead code, no orphaned packages from V7.

Key decisions already made:
- 15-package structure (same DAG shape as V7, no circular deps)
- V7 prefix kept (renaming cost > benefit)
- V7Ads NOT in Feature package dependency at start — add later
- Foundation Models: `#if canImport(FoundationModels)` + `@available(iOS 26.0, *)` guards
- iOS 17+ minimum, iOS 26 optimized

Deliverables:
- All Package.swift files created
- Core Data schema: 21 entities (JobCache removed per DATA_FLOW_BUILD_PLAN)
- SacredUIConstants.swift with all constraint values
- Empty but compiling package DAG

**Completion gate:** `swift build` on all packages passes, 0 circular dependencies

---

### Phase 2 — Data Flow
*Matches: DATA_FLOW_BUILD_PLAN.md*
Wire persistence correctly from day one. Don't rebuild V7's broken ThompsonArm pattern.

Key items:
- ThompsonArm: write `recordSuccess()`/`recordFailure()` on every swipe from the start
- Load persisted state on engine init (not a patch — the correct design)
- ManifestInferenceActor threshold: 3 (not 10)
- No BehavioralEventLog (removed before it's added)
- No JobCache entity (removed before it's added)

**Completion gate:** Swipe 3 times, kill app, relaunch, confirm ThompsonArm alpha = 4

---

### Phase 3 — Scoring Algorithm
*Matches: SCORING_BUILD_PLAN.md*
Build the scoring formula correctly. Don't recreate V7's disconnect.

Key items:
- 6-component combinedScore from day one (Thompson gets 8% weight, not bolted on later)
- 3-tier title match (not binary) from day one
- ThompsonBridge per-job bonus in OptimizedThompsonEngine (not a dead orchestrator)
- ThompsonCareerIntegrator per-job bonus in same place

**Completion gate:** Score 50 jobs, confirm all 6 components contribute, confirm <10ms per score

---

### Phase 4 — User Flow
*Matches: USER_FLOW_BUILD_PLAN.md*
Build the CRM and settings correctly. Don't ship the broken "Apply Now" pattern.

Key items:
- Apply Now: write `action = "applied"` JobInteraction on tap from day one
- ProfileScreen: Privacy Policy, Terms of Service, Data Management — real views, not Text() stubs
- Amber/Teal score label color lerp
- Onboarding Step 7: async JSearch fetch with 2s fallback to mocks
- Courses tab: skill-gap search suggestion cards (Phase 1 of course revenue)

**Completion gate:** Full user flow test — onboarding → deck → apply → appears in History

---

### Phase 5 — Revenue
*Matches: ADS_BUILD_PLAN.md + COURSES_REVENUE_BUILD_PLAN.md*
Wire the revenue systems that are already built.

Key items (Ads):
- AdMob SDK added (after AdMob account created — external)
- AdCardInjector wired into DeckScreen
- ATTConsentManager called after onboarding
- USE_REAL_ADS = true in Release builds

Key items (Courses):
- Fix CourseProviderClient filename bug first
- Affiliate credentials added (Coursera + Udemy — external, apply now)
- CourseCardView + CoursesView created
- ManifestTabView .courses destination wired to CourseRecommendationEngine
- AffiliateTracker writes to Core Data on tap

**Completion gate:** Ad appears in deck at position ~10. Course card appears in Manifest tab. Tap a course → AffiliateClick written to Core Data.

---

### Phase 6 — Connection
*Matches: CONNECTION_BUILD_PLAN.md + TAXONOMY_BUILD_PLAN.md*
Close the remaining disconnected components.

Key items:
- JobRelevanceScorer: delete before it's ever added
- RealTimeScoring: confirm if ContentView.swift is in active path, remove if not
- FoundationModelsRIASECExtractor: new file with canImport guard
- EnhancedSkillsMatcher synonym improvements

**Completion gate:** 17 of 18 components wired (94%)

---

## What's Blocked

Nothing currently blocked. Phase 0 is proceeding.

**External items that require waiting (start these now, they have lead times):**
- AdMob account registration (same day)
- Coursera affiliate (Rakuten LinkShare) — 3-7 day approval
- Udemy affiliate — 1-2 day approval
- edX OAuth credentials — optional for Phase 5

---

## Session End Checklist

Before closing a session, update:
1. Move completed items from "What's in progress" to "What's Done"
2. Update "Current Phase" if phase changed
3. Update "What's Blocked" if anything is blocked
4. Note any decisions made in DECISIONS.md
5. Commit and push
