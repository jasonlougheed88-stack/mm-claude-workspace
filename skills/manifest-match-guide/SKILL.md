---
name: manifest-match-guide
description: Master guide for the Manifest & Match build — mission, verified system map, critical tangles, likely unused systems, full toolbox, and routing logic. Invoke at the start of every session.
category: project-guide
version: 3.0.0
updated: 2026-05-15
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
---

# Manifest & Match — Project Guide

**Invoke this at the start of every session. It is the north star.**

---

## Why This Exists

We are building a new version of Manifest & Match from scratch in:
```
/Users/jasonl/Desktop/Claudes-Man&Man-build/ios-app/
```

The reference codebase lives at:
```
/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8/ManifestAndMatchV7.xcworkspace
```

The reference is read-only. We study it. We do not build on top of it. The new build uses what worked, rebuilds what was broken, and names everything correctly from day one.

**The single most important failure of the reference codebase:** The deck sort key is `combinedScore` — a 5-component weighted professional score. `baseThompsonScore` (the Beta sampler output) is calculated on every scoring cycle but stored in `ThompsonScore.personalScore` and never reaches the sort comparison. The Beta arms persist and update correctly on every swipe, but their output is discarded before ordering. The app is a weighted content-based recommender that maintains Bayesian state it never uses. `schematics/UNTANGLING_GUIDE.md` specifies how to reconnect this in v1.1.

---

## Current Build Status

**Pre-Phase 1 work is complete. Scaffold design is next.**

| Pre-build task | Status |
|---|---|
| Package naming audit | ✅ COMPLETE |
| System inventory (initial) | ✅ COMPLETE |
| Inventory verified against 8 schematics | ✅ COMPLETE |
| Inventory verified by full codebase read | ✅ COMPLETE |
| Untangling Guide | ✅ COMPLETE (`schematics/UNTANGLING_GUIDE.md`) |
| Architecture diagrams | ✅ COMPLETE (`diagrams/`) |
| **Scaffold design** | ⬜ NOT STARTED ← **NEXT TASK** |

**Next task:** Design and build the v1.1 Xcode workspace scaffold in `ios-app/`. Read `BUILD_SEQUENCE.md` for current task detail.

---

## The Mission

> *Most job searches are a search for a title. Manifest & Match is a search for fit — between who you are, what you're capable of, and what you haven't yet imagined for yourself.*

**What this app is**

Most job apps help people find a job. This one helps people find out what they actually want — and then gives them the most direct path to get it.

The core mechanic is a swipe card deck. Users swipe through real job listings — right to save, left to skip, up to apply. That is the only discovery surface. There is no search bar. There is no browse view. The deck is intentional and permanent — it is how the system learns, not just how the user browses. Every swipe is a data point.

**Two tracks run simultaneously, invisibly.**

Track 1 — Match. Finds the best available job for who the user is today. Real jobs from real sources, personalized by a Thompson Sampling engine that learns their taste from every swipe. A user who swipes right on remote senior engineering roles and left on management roles teaches the system something without being asked. The deck adjusts. Over sessions, the recommendations stop feeling random and start feeling like the app knows them.

Track 2 — Manifest. Runs alongside Track 1 without the user doing anything extra. The system watches what they respond to — not just job titles, but work activities, adjacent skills, RIASEC personality patterns. It builds a picture of who they could become. It identifies career paths they haven't considered, adjacent roles outside their current industry that their skills transfer to, and the gaps between where they are and where those paths lead.

The SkillTaxonomy is the cross-industry bridge. It maps 787 canonical skills across 36 categories against O*NET occupation data — identifying not just what a user knows, but how those skills transfer across domains. A background in project management doesn't just match project manager roles — the taxonomy connects it to product management, operations, consulting, and construction management. The courses surfaced in Track 2 are chosen because they close specific gaps identified by this cross-industry mapping, connected to the same taxonomy that scored the job cards that revealed the gap. The math that links skills to jobs to courses must be verified before anything is built on top of it.

This surfaces in the Manifest tab — not as a performance report, but as a map. Career paths the system identified. Skills the user already has toward those paths. Gaps between now and there. Courses that close those gaps.

**The slider is how the user tells the app what they want right now.**

One slider. Amber on one end, Teal on the other. At full Amber, the user is asking for the best job matching exactly who they are today — their current role, their existing skills, their known preferences. At full Teal, they're telling the app they're planning for something different and want the system to surface possibilities they haven't imagined. Most users live somewhere in the middle.

The slider isn't just a filter — it changes the entire scoring formula. In Amber mode, title match dominates (~66% weight). In Teal mode, work activities and RIASEC personality take over (~32% + ~25%), which is how the system surfaces jobs across industries that the user would never have searched for. The slider makes the user's intent mathematically legible to the scoring engine.

**The card color is the score made visible.**

Each job card shows a color on the amber-to-teal spectrum. That color is not decoration. It is the system's assessment of where that specific job falls between "this is who you are now" and "this is who you could become." A card scoring 80% current / 20% future shows closer to amber. A card scoring 20% current / 80% future shows closer to teal. The color is the score ratio, made visible without numbers or explanations. Over time the user learns to read it intuitively.

**Value compounds. This is not a one-session tool.**

A job board is equally useful on day one as day thirty. This app is not. The Thompson arms learn from every swipe and persist across sessions. The Manifest inference builds on accumulated swipe history. Question cards ask exactly the right thing at the right moment — not on a schedule, but when the system has a specific data gap that more information would close. The longer someone uses the app, the more precisely it represents them. This is the core promise. Anything that resets learning, bypasses persistence, or ignores accumulated data breaks it.

**The user never sees the machinery.**

Thompson Sampling, Beta distributions, RIASEC profiles, O*NET occupation codes, InferredManifestProfile — none of this is user-facing language. The user experiences it as "the app seems to know what I like" and "it found something I wouldn't have thought of." Transparency about what the system has learned is welcome. Explaining the math is not.

**Revenue is part of the product, not hidden behind it.**

Ads appear in the card space at a ratio that doesn't break the swipe experience. Course recommendations in the Manifest tab are affiliate-linked (Coursera 35%, Udemy 17.5%) and are earned — they appear because the system identified a real skill gap and found a real course that closes it. Revenue is aligned with user value, not opposed to it. No user behavioral data leaves the device for targeting purposes. Privacy-first is not a constraint — it is a differentiator.

**What this app is not.**

Not a job board. Not a resume database. Not a LinkedIn competitor. Not a career coach that talks too much. Not a one-session utility. Not a search engine with a swipe coat of paint.

**How to evaluate any feature, code decision, or new idea:**

Two questions:
1. Does it help the user find a better job for who they are today? (Track 1)
2. Does it help the user discover who they could become — including outside their current industry — using the taxonomy to connect their existing skills to new domains? (Track 2)

If it serves neither, it doesn't belong.

---

## Guiding Truths

These are not rules. They are orientations. When a design or code decision is in question, run it through these. They protect the mission without constraining how you build toward it.

### 1. The deck is the input, not the product.
Job cards are how the system learns. The real product is what accumulates over time — the learned model, the career picture, the improving fit score. Design that serves the swipe experience serves the product. Design that turns the app into a job board (search bars, browse views, listings) doesn't belong here.

### 2. The color means something. Earn it.
Amber = who you are now. Teal = where you could go. These are not brand choices — they are data derived from the Thompson scoring at the moment a card is shown. Any use of amber or teal that is decorative rather than data-driven dilutes the signal the user is learning to read. Use the colors consistently and they become a language. Use them loosely and they become noise.

### 3. Value compounds, or the app is worthless.
A job board is useful on day one. This app is better than a job board only if it improves with use. Any change that resets learned preferences, bypasses Thompson Sampling, or ignores persistence breaks the core promise. Persistence is not a feature — it is the foundation everything else is built on.

### 4. The user doesn't need to see the machinery.
Thompson Sampling, Beta distributions, RIASEC profiles, O*NET occupation codes — none of this is user-facing language. The user experiences it as "the app seems to know what I like." Transparency about what the app has learned is welcome. Explaining how is not. Keep the math invisible.

### 5. Both tracks run always.
Every session feeds Track 1 (find a job now) and Track 2 (build the career picture). The slider doesn't turn one track off — it adjusts the ratio. Design that serves only one track should be evaluated against whether it harms the other. The goal is a product where both tracks reinforce each other silently.

### 6. Questions are earned, not scheduled.
A question card appears when the system has a specific data need — a gap in the RIASEC profile, a slider position indicating career-building intent, a pattern the ManifestInferenceActor needs more signal on. Questions are not engagement mechanics. Not gamification. Not scheduled interruptions. The system asks when it genuinely needs to know something to do its job better.

### 7. The Manifest tab is a map, not a report card.
It shows the picture the system has built of who the user could become. Career paths identified from swipe patterns. Transferable skills toward those paths. Gaps between now and there. Courses that close those gaps. Design it like a compass — directional, purposeful, forward-looking. Not a performance review. Not a leaderboard.

### 8. Read the inventory before touching any system from the reference codebase.
The reference has comments claiming systems work that never fire in production. `schematics/SYSTEM_INVENTORY.md` has the verified state of every system — confirmed by direct file reads, not by comments. A session that skips this will rebuild broken patterns.

---

## Sacred Technical Constraints

These are immutable. They were validated in prior builds and exist for a reason. Violating them breaks either user experience or architectural integrity.

| Constraint | Value | Why |
|---|---|---|
| Thompson scoring budget | **< 10ms** per `scoreJobs()` call | User feels delay above 10ms; 357x competitive advantage |
| Tab order | **Discover=0, Tracker=1, Profile=2, Manifest=3** | Runtime-validated; changing breaks navigation state |
| Amber hue | **45/360 (0.125)** | Brand identity + data signal consistency |
| Teal hue | **174/360 (0.483)** | Brand identity + data signal consistency |
| Memory baseline | **< 200MB sustained** | Emergency threshold is 250MB |
| CoreTaxonomy dependencies | **Zero** | Foundation package; any dep creates cascade risk |
| Circular dependencies | **Zero** | Full DAG enforced; one cycle breaks the entire build chain |
| Thompson persistence | **Load on init, save on every swipe** | Without this, the core value proposition is false |

**Source of truth for sacred values:**
Reference codebase: `Packages/V7Core/Sources/V7Core/SacredUIConstants.swift`
New build: `CoreTaxonomy/Sources/CoreTaxonomy/SacredUIConstants.swift`

---

## How to Use the Information in This Skill

Everything that follows — the verified system map, the tangles list, the likely unused systems, the canonical pipeline decisions — was produced by direct reads of the reference codebase to the best of our ability as of the audit date. It is pre-work. It is a working hypothesis, not a verified source of truth.

**The reference codebase is the only source of truth.**

Before any claim in this skill — or in `schematics/SYSTEM_INVENTORY.md`, `schematics/UNTANGLING_GUIDE.md`, or `diagrams/` — drives a code decision, verify that specific claim against the actual files using `Read`, `Bash`, or `Grep` on the reference at:
```
/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8/
```

Systems listed as likely unused may play a role we didn't find. Decisions listed as resolved are the likely best approach — not immutable constraints. The math especially must be verified before anything is built on top of it.

When in doubt: read the code. The documents describe what we think we know. The code is what is actually true.

---

## Verified System Map

This is what the reference codebase actually does — confirmed by direct file reads, not comments.

### What fires on every swipe

```
User Swipe
    ├── ThompsonArm.recordSuccess/Failure()       ✅ persists alpha/beta to Core Data
    ├── BehavioralEventLog                         ✅ append-only swipe log
    ├── FastBehavioralLearning                     ✅ sync inference <10ms
    ├── DeepBehavioralAnalysis                     ✅ pattern analysis (DeckScreen:1083)
    ├── ConfidenceCalibrator.recordSwipe()         ✅ O(1/√n) convergence tracking
    ├── SliderPositionLogger.recordSwipe()         ✅ records slider position per swipe
    └── ManifestInferenceActor                     ✅ debounced 5s, fires after 10+ swipes
```

### Job discovery and scoring pipeline

```
JDC startup
    ├── SmartSourceSelector.init()    ✅ Thompson MAB — picks which source API to query
    └── LocationScoringEngine.init()  ✅ geographic pre-filter before scoring

Per fetch:
    ├── LocationScoringEngine filters (40mi amber → 100mi teal)
    ├── JobONetEnricher maps titles → O*NET codes
    └── OptimizedThompsonEngine.scoreJobs()
             │
             ├── baseThompsonScore = amberSample×(1-t) + tealSample×t
             │   ← CALCULATED. Stored in ThompsonScore.personalScore.
             │   ← NEVER USED FOR DECK ORDERING.
             │
             └── combinedScore = titleScore×w + skillsScore×w + locationScore×w
                                + workActivitiesScore×w + riasecScore×w
                 ← THIS IS THE ACTUAL DECK SORT KEY
```

### What is initialized but never called

```
ThompsonScoringOrchestrator (DeckScreen:1572) — ZERO method calls
    ├── ThompsonBridge          ⚠️ UserTruths bonuses never reach any job score
    └── ThompsonCareerIntegrator ⚠️ Never invoked. Also uses V6 ManifestProfile
                                    (wrong data), not InferredManifestProfile.
```

### Manifest tab pipeline

```
ManifestInferenceActor → InferredManifestProfile (Core Data)
    └── ManifestTabView reads InferredManifestProfile directly
         ├── TealPathGenerator             ✅ wired (ManifestTabView:155)
         ├── SkillsGapAnalyzer             ⚠️ partial — marked "ISSUE #2"
         ├── CourseRecommendationEngine    🔴 isolated + filename mismatch bug
         └── CareerPathEngine              🔴 isolated — ManifestTabView bypasses it
```

### Card color (broken)

```
Current:  interpolateColor(ratio: job.thompsonScore)  ← quality score — backwards
Correct:  DualProfileColorSystem.fitScoreColor(score:, profileBlend:)  ← exists, unused
```

---

## Critical Tangles

The Untangling Guide (`schematics/UNTANGLING_GUIDE.md`) has made decisions on each of these. Those decisions are the likely best approach — verify against actual code before implementing.

| Tangle | What's wrong |
|---|---|
| baseThompsonScore discarded | Beta samplers update but output never reaches sort key |
| ThompsonScoringOrchestrator zero calls | UserTruths bonuses and career bonuses never apply |
| ThompsonCareerIntegrator wrong data | Uses V6 ManifestProfile, not InferredManifestProfile |
| Card color signal backwards | `interpolateColor` uses quality score; DualProfileColorSystem unused |
| Two disconnected scoring engines | ContentView/ThompsonScoringBridge creates a separate non-persisting OTE instance; DeckScreen has a different persisting instance |
| LEVER 4 is a filter not a weight | LocationScoringEngine is a binary pre-filter; other 5 levers are score weights |
| Two cover letter generators | CoverLetterEngine (AppShell) and CoverLetterService (V7AI) both generate cover letters from different call paths |
| Five Thompson integrations, two active | ThompsonBridge + ThompsonCareerIntegrator + ThompsonIntegration (Embeddings) + ThompsonScoringBridge (AppShell) + legacy ThompsonSamplingEngine — most never fire |

Full tangle detail and decisions: `schematics/UNTANGLING_GUIDE.md`

---

## Likely Unused — Verify Before Including or Excluding

These systems showed no active call sites during the inventory audit. They are candidates to leave out of v1.1 — but the audit could have missed something, and some may play a role we didn't expect. Verify before deciding. See `schematics/UNTANGLING_GUIDE.md` for the reasoning behind each. We are building a house that was built wrong and do not know exactly what it will look like — treat this list as a starting point, not a final verdict.

| System | Why it appeared unused |
|---|---|
| `ThompsonSamplingEngine` (legacy) | Superseded by `OptimizedThompsonEngine` |
| `ThompsonSamplingEngineExtensions` | Extends the legacy engine |
| `ThompsonSampling+ONet.swift` | Extends the legacy engine |
| `StateManager` / `StateCoordinator` / `StateUpdateActor` | No external call sites found. `AppState` is the working state layer. |
| `V7ResumeAnalysis` package (entire) | Active `ResumeUploadView` is in V7UI, not this package |
| `ChartsColorTestPackage` | Empty shell — `public struct ChartsColorTestPackage { public init() {} }` |
| `RequestCoalescer` | No production call sites found |
| `NetworkOptimizer` | No production call sites found |
| `ErrorRecoveryManager` | No wiring to app lifecycle found |
| `ConfidenceReconciler` | Only self-references found |
| `CareerPathEngine` | ManifestTabView appeared to bypass it — Untangling Guide recommends wiring it |
| `JobCache` Core Data entity | Defined, never written to |
| `ClientSideSkillsFilter` | Commented out in JDC |
| `OccupationExpander` | Superseded by `OccupationAdjacencyService` per its own comments |

---

## Canonical Pipeline Decisions — Likely Best Approach

These decisions come from `schematics/UNTANGLING_GUIDE.md`. They represent the likely correct approach based on the codebase audit. **Verify each one against the reference code before implementing.** They are not immutable — if verification reveals a different reality, the decision should be revisited.

| Decision | Likely best approach | Verify in |
|---|---|---|
| Thompson engine instance | Single `OptimizedThompsonEngine`, sync init, Core Data persistence wired | `OptimizedThompsonEngine.swift` — confirm sync init wires persistence |
| combinedScore formula | `(5 components × 0.92) + baseThompsonScore × 0.08` | `OptimizedThompsonEngine.swift` — confirm current formula and reconnection point |
| UserTruths + career bonuses | Inlined in `fastProfessionalScore()` as post-formula multipliers — no orchestrator | `ThompsonBridge.swift`, `ThompsonCareerIntegrator.swift` |
| ThompsonCareerIntegrator input | `InferredManifestProfile` — not V6 `ManifestProfile` via `toManifestProfile()` | `ThompsonCareerIntegrator.swift` — confirm current input type |
| Card color signal | `DualProfileColorSystem.fitScoreColor()` using per-job amber/teal contribution fields | `DualProfileColorSystem.swift`, `DeckScreen.swift` — interpolateColor to drop |
| Cover letter system | `CoverLetterService` (Intelligence package) — single canonical system | `CoverLetterService.swift`, `CoverLetterEngine.swift` — compare before deciding |
| Swipe pattern analysis | Single `SwipePatternAnalyzer` in Intelligence — AppShell copy appeared canonical | Both `SwipePatternAnalyzer.swift` files — confirm which is more complete |
| API key storage | `KeychainManager.shared` for all API keys — no UserDefaults, no env vars | `KeychainManager.swift`, `CoverLetterService.swift` |
| Geographic filter | `LocationScoringEngine` as pre-filter before scoring — not a lever weight | `LocationScoringEngine.swift` — confirm it runs before scoring pipeline |
| ThompsonScoringOrchestrator | Drop — bonuses inline in scoring engine | `DeckScreen.swift` — confirm orchestrator is initialized but never called |

**For full decision rationale:** `schematics/UNTANGLING_GUIDE.md`
**For canonical pipeline diagrams:** `diagrams/`

---

## The Build

**New build location:** `/Users/jasonl/Desktop/Claudes-Man&Man-build/ios-app/`
**Package names:** See `context/PACKAGE_NAMES.md` — new descriptive names, no V7* prefix
**Current status:** Read `BUILD_SEQUENCE.md` at session start — it is the live status document

### The 6 Phases

| Phase | What Gets Built | Non-Negotiable Gate |
|---|---|---|
| **1 — Foundation** | 15 packages scaffolded, Core Data schema (21 entities), SacredUIConstants | Clean build, zero circular deps, CoreTaxonomy has zero deps |
| **2 — Data Flow** | ThompsonArm persistence wired, ManifestInferenceActor threshold=3, slider drives profileBlend | Swipe → save arms → relaunch → arms match last session |
| **3 — Scoring** | combinedScore formula, title match, tangles resolved per Untangling Guide | Score formula produces verifiable output; no regression from reference codebase |
| **4 — User Flow** | DeckScreen decomposed, onboarding (clean, minimal), Tracker CRM tab | Full swipe → apply → tracker pipeline works end-to-end |
| **5 — Revenue** | AdCards in deck at 1:10 ratio, course affiliates in CareerGrowth tab | Revenue paths are trackable; no user data leaves device without ATT consent |
| **6 — Connection** | Orphaned components connected, dead code resolved, App Store prep | Clean codebase, privacy manifest, TestFlight build |

**Build plans per phase:** `new_build_requirements/` — read the relevant plan before writing phase code.
**Schematics (what went wrong in the reference codebase):** `schematics/` — read before building any component that existed in V7/V8.

---

## The Full Toolbox

### Native Tools (always available)

| Tool | Use it for |
|---|---|
| `Read` | Reading any file — always read before editing |
| `Edit` | Precise changes to existing files |
| `Write` | Creating new files only (prefer Edit) |
| `Bash` | Shell commands, build scripts, grep, git |
| `Agent` | Spawning specialized sub-agents for parallel or complex isolated work |
| `WebFetch` | Fetching documentation or URLs |
| `WebSearch` | Researching APIs, Swift patterns, framework docs |

---

### MCP Servers

Verify all three are connected at session start: `claude mcp list`

#### XcodeBuildMCP
The feedback loop closer. Build → run → interact → read logs — no Xcode required.

| Tool | When to use |
|---|---|
| `session_show_defaults` | **Always first** before any build/run call in a session |
| `build_run_sim` | Build and launch in simulator |
| `build_sim` | Build only (no launch) |
| `screenshot` | Capture simulator state |
| `snapshot_ui` | Read accessibility tree + coordinates |
| `tap` / `swipe` / `type_text` | Drive UI programmatically |
| `start_sim_log_cap` / `stop_sim_log_cap` | Capture simulator logs |
| `test_sim` | Run XCTest suite |
| `list_schemes` | Inspect workspace schemes |
| `discover_projs` | Find project/workspace files |
| `list_sims` / `boot_sim` | Manage simulators |

#### GitHub MCP
Account: `jasonlougheed88-stack`
Repo: `jasonlougheed88-stack/mm-claude-workspace`
Fallback: `gh` CLI via Bash

| Tool | When to use |
|---|---|
| `create_issue` / `get_issue` | Track bugs, questions, decisions |
| `create_pull_request` | PR creation with description |
| `push_files` | Direct file push without local git |
| `search_code` | Find patterns across the repo |
| `list_commits` | Review recent history |

#### Business System MCP
Server: `/Users/jasonl/Desktop/Manifest-Match-Business-System/mcp-server.js`
If it drops: `node /Users/jasonl/Desktop/Manifest-Match-Business-System/mcp-server.js`

| Tool | When to use |
|---|---|
| `get_system_overview` | Full project status at a glance |
| `list_tasks` / `complete_task` | Track and close build tasks |
| `create_reminder` / `list_reminders` | Flag things that need attention later |
| `list_files` / `move_file` | Manage project documents |
| `get_phase_progress` | Phase completion status |

---

### Skills — When to Use Each

Skills are invoked via `/skill-name`. They are instruction sets that change how Claude approaches a task.
Active skills live at `~/.claude/skills/`. Local copies at `skills/` in this repo.
Deploy updates: `bash tools/sync-skills.sh deploy`

#### This skill (invoke first each session)
| Skill | Purpose |
|---|---|
| `/manifest-match-guide` | **This skill.** North star, routing guide, mission context. |

#### Master/Orchestration
| Skill | Purpose |
|---|---|
| `/v8-omniscient-guardian` | Full codebase knowledge, delegates to domain experts for cross-cutting V8 concerns |

#### Domain Experts — invoke for specific technical areas
| Skill | Invoke when... |
|---|---|
| `/v8-package-architect` | Adding packages, resolving deps, build order questions |
| `/v8-data-models-expert` | Core Data entities, relationships, migrations |
| `/v8-thompson-mathematician` | Thompson Sampling math, Beta distributions, FastBetaSampler |
| `/v8-job-sources-expert` | API clients, rate limiting, circuit breakers, job fetching |
| `/v8-ai-systems-expert` | Foundation Models, iOS 26 on-device AI, RIASEC extraction |
| `/v8-data-flows-expert` | End-to-end pipelines, swipe → score → persist flows |
| `/v8-ui-components-expert` | SwiftUI views, DeckScreen, accessibility, color system |
| `/v8-ios26-design-expert` | iOS 26 Liquid Glass design, design system, HIG compliance |
| `/v8-coresignal-integration-expert` | CoreSignal API integration specifically |

#### Architecture Guardians — invoke before committing any code
| Skill | Invoke when... |
|---|---|
| `/v7-architecture-guardian` | Writing any Swift code — enforces MV pattern, naming, package rules |
| `/swift-concurrency-enforcer` | Any async/await, actor, @MainActor code |
| `/thompson-performance-guardian` | Any change that touches scoring pipeline |
| `/accessibility-compliance-enforcer` | Any new UI component |
| `/core-data-specialist` | Any Core Data fetch, relationship, or migration |
| `/privacy-security-guardian` | Any data handling, API keys, user data storage |

#### Specialists — invoke for focused technical work
| Skill | Invoke when... |
|---|---|
| `/swiftui-specialist` | Complex SwiftUI patterns, @State/@Binding design, animations |
| `/thompson-sampling-mathematician` | Verifying Beta distribution math is correct |
| `/manifestandmatch-v7-coding-standards` | Matching existing code style and patterns exactly |
| `/manifestandmatch-skills-guardian` | SkillTaxonomy, EnhancedSkillsMatcher, O*NET integration |
| `/onet-career-integration` | O*NET data, occupation codes, work activities |
| `/job-source-integration-validator` | Validating a new job source is producing correct data |
| `/job-card-validator` | Validating job card data structure |
| `/api-integration-builder` | Scaffolding a new API client |
| `/performance-regression-detector` | Running benchmarks before/after a scoring change |
| `/ai-error-handling-enforcer` | AI feature error paths, fallback logic |
| `/cost-optimization-watchdog` | Any code that calls external AI APIs |

#### Project & Planning
| Skill | Invoke when... |
|---|---|
| `/xcode-project-specialist` | SPM configuration, build settings, signing, scheme setup |
| `/ios-app-architect` | Generic iOS architecture questions not covered by V8-specific skills |
| `/ios26-specialist` | iOS 26-specific APIs, Liquid Glass, Foundation Models availability |
| `/ios26-development-guide` | Day-to-day iOS 26 dev workflow |
| `/v7-expansion-architect` | Planning a new feature that doesn't exist in V7/V8 |
| `/app-narrative-guide` | Checking if a feature aligns with the app's mission |
| `/business-planning-manager` | Business planning, task management via Business System MCP |
| `/skill-builder` | Creating or editing skills themselves |

---

### Agents — When to Spawn One

Agents run in parallel and protect the main context window. Use them when the task is isolated and well-defined.

| Agent | Best for |
|---|---|
| `ios-app-architect` | Complex iOS architecture decisions, Xcode issues |
| `database-migration-specialist` | Core Data schema design, migration planning |
| `ml-engineering-specialist` | Thompson Sampling optimization, algorithm analysis |
| `performance-engineer` | Memory profiling, speed bottlenecks |
| `algorithm-math-expert` | Beta distribution math verification |
| `api-integration-architect` | Designing multi-API integration strategy |
| `testing-qa-strategist` | Test strategy, coverage planning |
| `xcode-ai-integration-specialist` | Core ML, Vision, Foundation Models integration |
| `Explore` | Fast codebase search — reading without touching |
| `Plan` | Architecture planning before writing code |
| `general-purpose` | Everything that doesn't fit the above |

---

## Session Protocol

### Every Session Start
```
1. Read BUILD_SEQUENCE.md — what phase, what task, what's blocked
2. claude mcp list — verify all 3 MCPs connected
3. git status + git log --oneline -5
4. session_show_defaults — if touching ios-app/ Xcode project
```

### Before Writing Any Code
```
1. Read the build plan for the current phase (new_build_requirements/)
2. Read schematics/SYSTEM_INVENTORY.md for any system from the reference codebase
3. Verify the specific system claim against actual reference code via Read/Bash/Grep
4. Check DECISIONS.md — has this decision already been made?
5. Check OPEN_QUESTIONS.md — is this blocked on an unanswered question?
```

### Skill Routing by Phase
| Phase | Lead skills | Guardian checks before commit |
|---|---|---|
| 1 — Foundation | `/v8-package-architect` | `/v7-architecture-guardian` |
| 2 — Data Flow | `/v8-data-models-expert` + `/v8-thompson-mathematician` | `/swift-concurrency-enforcer` |
| 3 — Scoring | `/v8-thompson-mathematician` + `/v8-data-flows-expert` | `/thompson-performance-guardian` |
| 4 — User Flow | `/v8-ui-components-expert` + `/swiftui-specialist` | `/accessibility-compliance-enforcer` |
| 5 — Revenue | `/v7-expansion-architect` | `/privacy-security-guardian` |
| All phases | — | `/v7-architecture-guardian` + `/swift-concurrency-enforcer` |

### Every Session End
```
1. Update BUILD_SEQUENCE.md — mark done items, note blockers
2. Log new decisions in DECISIONS.md
3. git add -p && git commit (meaningful message)
4. Push to GitHub
5. Update Business System MCP tasks if applicable
```

---

## Key Files — Session Quick Reference

| What | Path |
|---|---|
| **What we're doing now** | `BUILD_SEQUENCE.md` |
| **Verified system inventory** | `schematics/SYSTEM_INVENTORY.md` |
| **Untangling Guide** | `schematics/UNTANGLING_GUIDE.md` |
| **Architecture diagrams** | `diagrams/` — overall systems + one per tab |
| **Confirmed decisions** | `DECISIONS.md` |
| **Unanswered questions** | `OPEN_QUESTIONS.md` |
| **Package names map** | `context/PACKAGE_NAMES.md` |
| **Sacred constraints** | `context/SACRED_CONSTRAINTS.md` |
| **Thompson reference** | `context/THOMPSON.md` |
| **Architecture patterns** | `context/ARCHITECTURE.md` |
| **Build plans (per phase)** | `new_build_requirements/` |
| **What went wrong in V7/V8** | `schematics/` |
| **All tools & paths** | `CLAUDE_CAPABILITIES.md` |

---

## What This Skill Does NOT Do

- It does not write code.
- It does not make product decisions — those go in DECISIONS.md after discussion.
- It does not override the sacred technical constraints.
- It does not tell you how to design the UI — the guiding truths orient direction; they do not specify layout, animation, or visual choices.
- It does not treat the pre-work documents as verified truth — they are the best picture we have, not the final word.

**When in doubt about a design choice:** run it through the 7 Guiding Truths and the two-question mission test. If it serves the mission and doesn't break a sacred constraint, it belongs. If it serves neither track, it doesn't.

**When in doubt about a technical claim:** read the actual code.
