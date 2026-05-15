# Architectural Decisions — Manifest & Match
**Running log of every significant decision. Never delete — mark superseded if changed.**

---

## Product

### Privacy-First Model
**Date:** 2026-05-14
**Decision:** No user data leaves the device for revenue generation. All ML, scoring, and behavioral learning runs on-device. Ads are contextual (no IDFA required as baseline). Course recommendations are on-device using NLEmbedding.
**Why:** User trust + competitive differentiation. On-device Foundation Models (iOS 26, 3B param, zero API cost) makes this technically viable.
**What this rules out:** Behavioral ad targeting (unless user consents to ATT), server-side personalization, selling behavioral data.

### Revenue Model
**Date:** 2026-05-14
**Decision:** Two revenue streams — contextual ads (Google AdMob) + course affiliate commissions (Coursera 35%, Udemy 17.5%).
**Why:** Both are compatible with privacy-first (no user data required). Both are already built in V7Ads and V7Career — activation not rebuild.
**Commission rates:** Coursera 35% via Rakuten LinkShare, Udemy 17.5% direct referral. edX: 0% (no affiliate program post-2U acquisition).

### Mission Statement
**Date:** 2026-05-14
**Decision:** "Most job searches are a search for a title. Manifest & Match is a search for fit." Course recommendations extend this naturally: "Surface the fastest path to close the gap between where you are and where you want to be." Revenue is a product feature, not hidden monetization.

---

## Architecture

### Backend Strategy
**Date:** 2026-05-14
**Decision:** Lightweight API proxy first (Cloudflare Workers, free tier). 2-3 endpoints: JSearch key proxy, affiliate URL builder, anonymous aggregate analytics. Grows into full backend when needed — same codebase, add endpoints.
**Why:** JSearch API key must not be in the app binary (extractable). Affiliate credentials must not be in the app binary. Everything else stays on-device.
**Phase 1 endpoints:**
1. `GET /api/jobs` — proxies JSearch, hides API key
2. `POST /api/affiliate/url` — builds Rakuten/Udemy affiliate URL server-side
**Phase 2 (when needed):** user auth, cross-device sync, aggregate analytics

### iOS Platform Target
**Date:** 2026-05-14
**Decision:** iOS 17+ minimum deployment, iOS 26 optimized.
**Why:** Foundation Models (iOS 26 on-device LLM) is a key differentiator. `#if canImport(FoundationModels)` + `@available(iOS 26.0, *)` guards ensure pre-26 devices fall back cleanly to RIASECKeywordMapper.

### Package Naming
**Date:** 2026-05-14
**Decision:** Keep V7 prefix on all packages (V7Core, V7Data, V7Thompson, etc.). Do not rename to V8.
**Why:** Internal naming only — not user-visible. Renaming cost (every import statement) > benefit (accurate version number in package name).

### Package DAG Shape
**Date:** 2026-05-14
**Decision:** Maintain the 15-package DAG structure from V7. Zero circular dependencies. V7Core has zero dependencies and must never have any added.
**DAG:** V7Core → V7Data/V7JobParsing/V7Embeddings → V7Thompson → V7Performance → V7AIParsing → V7Services → V7AI → V7Career → V7ResumeAnalysis → V7UI → ManifestAndMatchV7Feature → App Target

### V7Ads Package
**Date:** 2026-05-14
**Decision:** V7Ads is NOT a dependency of ManifestAndMatchV7Feature at project start. Add it back when actually activating ads in Phase 5.
**Why:** Removing it from the dependency array during Phase 1-4 prevents dead code compilation. The package code stays on disk.

### No External SPM Dependencies
**Date:** 2026-05-14
**Decision:** No external Swift packages. All frameworks are system: Charts, NaturalLanguage, CoreML, FoundationModels, Foundation, UIKit, SwiftUI.
**Exception:** Google AdMob SDK added in Phase 5 only (required for real ads). This is the only external dependency.

---

## Data

### Core Data Schema Entity Count
**Date:** 2026-05-14
**Decision:** 21 entities (not 22). JobCache entity removed — it was defined but never written to in V7. No migration needed since it had zero data.
**Removed:** JobCache
**Why:** Entity consumed schema space and migration complexity for zero benefit.

### ThompsonArm Persistence
**Date:** 2026-05-14
**Decision:** ThompsonArm `recordSuccess()`/`recordFailure()` called on every swipe from day one. Load persisted state on engine init. Arm IDs: `"amber_primary"`, `"teal_primary"`.
**Why:** V7 never persisted ThompsonArm — every cold launch reset to Beta(1,1). This is the single most impactful fix and must be correct from the start.

### BehavioralEventLog
**Date:** 2026-05-14
**Decision:** Not included in new build. V7 wrote to it on every swipe, nothing ever read it. JobInteraction already captures the same data. Re-add when temporal/velocity analytics are designed.

### ManifestInferenceActor Threshold
**Date:** 2026-05-14
**Decision:** `minimumSwipesRequired = 3` (not 10 as in V7).
**Why:** New users who swipe 9 jobs got zero RIASEC inference benefit in V7. 3 swipes gives an initial (low confidence) guess. convergenceError field lets consumers gate on confidence if needed.

---

## Scoring

### combinedScore Formula
**Date:** 2026-05-14
**Decision:** 6-component formula from day one. Thompson exploration weight = 8%, constant across all profileBlend positions. Existing 5 components scaled by 0.92 to make room.
**Formula:** `combinedScore = (titleScore × w_title + skillsScore × w_skills + locationScore × w_location + workActivitiesScore × w_workActivities + riasecScore × w_riasec) × 0.92 + baseThompsonScore × 0.08`
**Rationale for 8%:** Tunable. At 8%, a historically-liked category gets +7% boost. Reduce to 5% if deck feels too noisy, raise to 12% if no diversity improvement visible.

### Title Match
**Date:** 2026-05-14
**Decision:** 3-tier scoring from day one (not binary 0/1 as in V7).
- Tier 1: Exact substring match → 1.0
- Tier 2: Shared significant word (>3 chars) → 0.6 + 0.1 per shared word
- Tier 3: No match → 0.0
**Why:** Binary match at 61% weight (Amber) creates a cliff. Any non-substring job is penalized 61% of its potential score regardless of how related it is.

### ThompsonBridge + ThompsonCareerIntegrator
**Date:** 2026-05-14
**Decision:** Both wired directly into OptimizedThompsonEngine.fastProfessionalScore() as per-job bonus multipliers. No ThompsonScoringOrchestrator. No `applyUserTruthsBonusToUpcomingJobs()`.
**Formula:** `adjustedScore = min(0.99, combinedScore × (1.0 + userTruthsBonus + careerBonus))`
**Why:** The orchestrator pattern in V7 (initialized in DeckScreen, never called) was an architectural mistake. Bonuses belong inside the scoring engine, not as a post-processing step on a UI coordinator.

---

## Revenue Systems

### Course Provider Priority
**Date:** 2026-05-14
**Decision:** CourseProviderClient loads from `courses_v1.json` in `Courses.bundle`. File path constants: `catalogFileName = "courses_v1"`, `resourceSubdirectory = "Courses.bundle"`.
**Note:** V7 had a filename mismatch (`courses_v1.0` / `CourseCatalog`) that would cause fatalError on first call.

### edX API
**Date:** 2026-05-14
**Decision:** edX live API (Tier 2 in CourseRecommendationEngine) deferred to Phase 5+. Static JSON database (4.1MB, courses_v1.json) is sufficient for launch. edX has no affiliate program (0% commission) — less urgency.

---

## UI / Design

### App Structure — Use Existing as Guide
**Date:** 2026-05-15
**Decision:** The existing V7/V8 app structure is the visual and UX reference for the fresh build. Keep the working skeleton, rebuild everything fresh from it. New buttons and user flows are allowed within the structure. Names can change.
**What stays:** 4-tab bottom navigation, DeckScreen swipe mechanics, job card layout, question card injection, tab structure order (Discover=0, History=1, Profile=2, Manifest=3).
**What can change:** Tab names, screen names, any broken flows (ProfileScreen stubs → real views), new flows added within existing tabs.
**Why:** The working parts of V7 are genuinely good UX. Starting fresh doesn't mean ignoring what works — it means building the good parts correctly the first time and fixing the broken parts.

### Tab Structure
**Date:** 2026-05-15
**Decision:** 4 tabs in this order — Discover (0), History (1), Profile (2), Manifest (3). Order is SACRED (validated by hook).
**Tab 0 — Discover:** DeckScreen. Swipeable job cards. Question card injection every ~5 jobs. Amber/Teal slider. "Why?" button on each card.
**Tab 1 — History:** CRM — shows all interactions (saved, applied, passed). The Apply Now → "applied" status fix must work correctly here.
**Tab 2 — Profile:** User settings, data management. Privacy Policy, Terms of Service, Data Management — real views (not Text() stubs).
**Tab 3 — Manifest:** Career building hub. Sub-tabs: Overview, Skills Gap, Career Path. Courses destination lives here (not a 5th tab).

### Amber/Teal Hue Constants
**Date:** 2026-05-14
**Decision:** Amber hue = 45/360 (0.125). Teal hue = 174/360 (0.483). These are SACRED — they encode the dual-track product concept visually.
**Source:** SacredUI.Preferences entity, SacredUIConstants.swift

### Amber/Teal Score Label
**Date:** 2026-05-14
**Decision:** Score label on job cards interpolates color from amber to teal based on profileBlend at scoring time. Option B (label color only) over Option A (edge bar).
**Why:** Lower visual weight, no layout impact, directly connects the score number to the mode that produced it.

### DeckScreen Decomposition
**Date:** 2026-05-14
**Decision:** DeckScreen.swift starts as a coordinator (~300 lines). Job card rendering extracted to JobDeckView.swift. Buffer management to DeckBufferManager.swift. Sheet state to DeckSheetCoordinator.swift. All in V7UI package.
**Why:** V7's DeckScreen at 3,353 lines was unmaintainable. Start decomposed.
