---
name: manifest-match-guide
description: Master guide for the Manifest & Match build — mission, verified system map, critical tangles, confirmed dead systems, full toolbox, and routing logic. Invoke at the start of every session.
category: project-guide
version: 2.0.0
updated: 2026-05-15
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
---

# Manifest & Match — Project Guide

**Invoke this at the start of every session.**

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

The reference is read-only. We study it. We do not build on top of it.

**What the reference codebase got wrong:**
The app is called a Thompson Sampling system. It is not. `baseThompsonScore` (the Beta sampler output) is calculated on every scoring cycle but stored in `ThompsonScore.personalScore` and never reaches the deck sort key. `combinedScore` — a 5-component weighted professional score — is the only sort key. The Beta arms persist and update correctly on every swipe, but their output is discarded before ordering. The app is a weighted content-based recommender that maintains Bayesian state it never uses. The Untangling Guide will decide whether and how to reconnect this.

**The full verified picture of what works and what doesn't is at:**
`schematics/SYSTEM_INVENTORY.md` — read this before touching any system that existed in the reference codebase.

---

## Current Build Status

**We are pre-Phase 1. Do not write code in `ios-app/` yet.**

| Pre-build task | Status |
|---|---|
| Package naming audit | ✅ COMPLETE |
| System inventory (initial) | ✅ COMPLETE |
| Inventory verified against 8 schematics | ✅ COMPLETE |
| Inventory verified by full codebase read | ✅ COMPLETE |
| **Untangling Guide** | ⬜ NOT STARTED ← **NEXT TASK** |
| Scaffold design | ⬜ NOT STARTED |

**Next task:** Produce `schematics/UNTANGLING_GUIDE.md` — for each tangle in the inventory, specify: correct wiring for the new build, what to lift vs rebuild, which phase it belongs to, what to leave out entirely.

See `BUILD_SEQUENCE.md` for the full task description.

---

## The Mission

> *Most job searches are a search for a title. Manifest & Match is a search for fit — between who you are, what you're capable of, and what you haven't yet imagined for yourself.*

The app runs two engines simultaneously:

**Track 1 — Match:** Finds the best available job given exactly who you are today. Real jobs, real sources, scored by an engine that learns from every swipe.

**Track 2 — Manifest:** Watches what you respond to. Builds a picture of who you could become. Identifies adjacent career paths, transferable skills, and the gaps between where you are and where you could go. Surfaces in the Manifest tab — not as a dashboard, but as a map.

The user doesn't manage tracks. They swipe. The slider tells the system how much of each they want right now.

---

## Guiding Truths

When a design or code decision is in question, run it through these.

### 1. The deck is the input, not the product.
Job cards are how the system learns. The real product is what accumulates over time — the learned model, the career picture, the improving fit. Design that serves the swipe experience serves the product.

### 2. The color means something. Earn it.
Amber = who you are now. Teal = where you could go. The color is supposed to encode per-job current/future spectrum position — not quality. In the reference codebase, `interpolateColor(ratio: job.thompsonScore)` uses the quality score as the color ratio, which is backwards. Fix it in the new build. `DualProfileColorSystem.fitScoreColor(score:, profileBlend:)` is the correct system — it exists and is unused.

### 3. Value compounds, or the app is worthless.
The Beta arms persist and update on every swipe. Their output must reach the deck sort key for the app's core promise to be true. Right now it doesn't. This is the single highest-priority tangle to resolve.

### 4. The user doesn't see the machinery.
Thompson scores, Beta distributions, RIASEC profiles, O*NET codes — none of this is user-facing. The user experiences it as "the app knows what I like." Keep the math invisible.

### 5. Both tracks run always.
The slider adjusts the ratio, not which track is active. Any system that touches scoring or the Manifest tab must respect the full slider range.

### 6. Questions are earned, not scheduled.
A question card appears when the system has a specific data need. The question machinery is built and wired. Audit the trigger conditions before touching it.

### 7. The Manifest tab is a map, not a report card.
Directional, forward-looking, purposeful. Not a performance review.

### 8. Read the inventory before touching any reference system.
The reference codebase has comments claiming systems work that never fire. `schematics/SYSTEM_INVENTORY.md` contains the verified state of every system. A build session that skips this will rebuild broken patterns.

---

## Sacred Technical Constraints

| Constraint | Value | Why |
|---|---|---|
| Thompson scoring budget | **< 10ms** per `scoreJobs()` call | User feels delay above 10ms |
| Tab order | **Discover=0, Tracker=1, Profile=2, Manifest=3** | Navigation state depends on index |
| Amber hue | **45/360 (0.125)** | Data signal + brand consistency |
| Teal hue | **174/360 (0.483)** | Data signal + brand consistency |
| Memory baseline | **< 200MB sustained** | Emergency threshold 250MB |
| CoreTaxonomy dependencies | **Zero** | Foundation package; any dep creates cascade risk |
| Circular dependencies | **Zero** | Full DAG enforced |
| Thompson persistence | **Load on init, save on every swipe** | Without this, the core promise is false |

---

## Verified System Map

This is what the codebase actually does. Verified by direct file reads. Not what comments claim.

### What fires on every swipe (confirmed)

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

### Job discovery pipeline (confirmed)

```
JDC startup
    ├── SmartSourceSelector.init()   ✅ Thompson MAB for source selection
    └── LocationScoringEngine.init() ✅ LEVER 4 — pre-filter by distance before scoring

Per fetch cycle:
    ├── SmartSourceSelector picks sources (currently only JSearch active)
    ├── LocationScoringEngine filters by distance (40mi amber → 100mi teal)
    ├── JobONetEnricher maps job titles → O*NET codes
    └── OptimizedThompsonEngine.scoreJobs()
             │
             ├── baseThompsonScore = amberSample×(1-t) + tealSample×t
             │   ← CALCULATED, stored in ThompsonScore.personalScore
             │   ← NEVER USED FOR DECK ORDERING
             │
             └── combinedScore = titleScore×w_title + skillsScore×w_skills
                                + locationScore×w_location
                                + workActivitiesScore×w_workActivities
                                + riasecScore×w_riasec
                 ← THIS IS THE ACTUAL DECK SORT KEY
```

### What is initialized but never called

```
ThompsonScoringOrchestrator (DeckScreen:1572)
    ├── ThompsonBridge          ⚠️ initialized, ZERO method calls
    │   UserTruths bonuses never reach any job score
    └── ThompsonCareerIntegrator ⚠️ initialized, ZERO method calls
        AND uses V6 ManifestProfile (wrong data), not InferredManifestProfile
```

### Manifest tab pipeline (confirmed)

```
ManifestInferenceActor → InferredManifestProfile (Core Data)
    └── ManifestTabView reads InferredManifestProfile directly
         ├── TealPathGenerator             ✅ wired (ManifestTabView:155)
         ├── SkillsGapAnalyzer             ⚠️ partial (marked "ISSUE #2")
         ├── CourseRecommendationEngine    🔴 isolated + filename bug
         └── CareerPathEngine              🔴 isolated (bypassed entirely)
```

### Card color (confirmed broken)

```
Current:  interpolateColor(ratio: job.thompsonScore)  ← quality score, backwards
Correct:  DualProfileColorSystem.fitScoreColor(score:, profileBlend:)  ← exists, unused
```

---

## Critical Tangles

These are the most build-impactful broken connections. The Untangling Guide will resolve each one. Do not wire any of these without reading that guide first.

| Tangle | What's wrong | Where to look |
|---|---|---|
| baseThompsonScore discarded | Beta samplers update but output never reaches sort key. App is content-based, not MAB. | `OptimizedThompsonEngine.swift:496` |
| ThompsonScoringOrchestrator zero calls | UserTruths bonuses and career bonuses never apply to any score. | `DeckScreen.swift:1572`, `ThompsonBridge.swift`, `ThompsonCareerIntegrator.swift` |
| ThompsonCareerIntegrator wrong data | Consumes V6 ManifestProfile (jobViewHistory, searchQueries) via `toManifestProfile()` — not InferredManifestProfile. | `V6AnalyticsModels.swift`, `ThompsonCareerIntegrator.swift` |
| Card color signal backwards | `interpolateColor` uses quality score. DualProfileColorSystem is correct but unused. | `DeckScreen.swift:2110,2654,2778`, `DualProfileColorSystem.swift` |
| Two disconnected scoring engines | ContentView creates ThompsonScoringBridge with async-init OTE (no persistence). DeckScreen has separate sync-init OTE (with persistence). | `ContentView.swift:124`, `ThompsonScoringBridge.swift` |
| LEVER 4 is a filter not a weight | LocationScoringEngine removes jobs beyond distance threshold. Other 5 levers are score weights. Architecturally inconsistent. | `LocationScoringEngine.swift`, `ThompsonWeights` struct |
| Two cover letter generators | CoverLetterEngine (AppShell/CoverLettersView) and CoverLetterService (V7AI/CoverLetterGeneratorView) both generate cover letters. Different paths, same function. | `CoverLetterEngine.swift`, `CoverLetterService.swift` |
| Three Thompson integrations (plus two more) | ThompsonBridge (V7AI) + ThompsonCareerIntegrator (V7Career) + ThompsonIntegration (V7Embeddings) + ThompsonScoringBridge (AppShell) + legacy ThompsonSamplingEngine. Most never fire. | `schematics/SYSTEM_INVENTORY.md` |

---

## Confirmed Dead — Do Not Rebuild

These systems exist in the reference codebase but are either empty, isolated, or superseded. Leave them out of the new build entirely.

| System | Why |
|---|---|
| `ThompsonSamplingEngine` (legacy) | Superseded by `OptimizedThompsonEngine`. Only in benchmarks. |
| `ThompsonSamplingEngineExtensions` | Extends the legacy engine. Dead by association. |
| `ThompsonSampling+ONet.swift` | Same — extends the legacy engine. |
| `StateManager` / `StateCoordinator` / `StateUpdateActor` | Built but never called. `AppState` (`@Observable`) is the working state layer. |
| `V7ResumeAnalysis` package | Entire package dead. Active `ResumeUploadView` lives in V7UI, not this package. |
| `ChartsColorTestPackage` | Empty shell — `public struct ChartsColorTestPackage { public init() {} }`. |
| `RequestCoalescer` | Built but never called in production. Only in test files. |
| `NetworkOptimizer` | Same. |
| `ErrorRecoveryManager` | Built but never wired into the app lifecycle. |
| `ConfidenceReconciler` | Only self-references. Never called. |
| `CareerPathEngine` | 937 lines, never called. ManifestTabView bypasses it. (Untangling Guide will decide whether to include.) |
| `JobCache` Core Data entity | Defined, never written to. |
| `ClientSideSkillsFilter` | Commented out in JDC. Dead. |
| `OccupationExpander` | Superseded by `OccupationAdjacencyService`. |

---

## The Build — 6 Phases

| Phase | What Gets Built |
|---|---|
| **1 — Foundation** | 15 packages, Core Data schema, SacredUIConstants |
| **2 — Data Flow** | ThompsonArm persistence, ManifestInferenceActor, slider → profileBlend |
| **3 — Scoring** | combinedScore formula, title match, tangles resolved per Untangling Guide |
| **4 — User Flow** | DeckScreen, onboarding, Tracker CRM tab |
| **5 — Revenue** | AdCards, course affiliates, affiliate URL builder |
| **6 — Connection** | Remaining orphans connected, dead code removed, App Store prep |

**Phase details pending:** Phase 3 wiring decisions (ThompsonBridge, ThompsonCareerIntegrator, baseThompsonScore reconnection) come from the Untangling Guide, not from this skill.

**Build plans per phase:** `new_build_requirements/`
**Package names:** `context/PACKAGE_NAMES.md`

---

## The Full Toolbox

### Native Tools

| Tool | Use it for |
|---|---|
| `Read` | Reading any file — always read before editing |
| `Edit` | Precise changes to existing files |
| `Write` | Creating new files only |
| `Bash` | Shell commands, grep, git |
| `Agent` | Spawning sub-agents for parallel or isolated work |
| `WebFetch` / `WebSearch` | Documentation, API research |

---

### MCP Servers

Verify all three at session start: `claude mcp list`

#### XcodeBuildMCP
| Tool | When |
|---|---|
| `session_show_defaults` | **Always first** before any build/run in a session |
| `build_run_sim` | Build and launch |
| `screenshot` / `snapshot_ui` | Capture state / read accessibility tree |
| `tap` / `swipe` / `type_text` | Drive UI |
| `start_sim_log_cap` / `stop_sim_log_cap` | Capture logs |
| `test_sim` | Run tests |
| `list_schemes` / `discover_projs` | Inspect workspace |

#### GitHub MCP
Account: `jasonlougheed88-stack`
Fallback: `gh` CLI

| Tool | When |
|---|---|
| `create_issue` / `get_issue` | Track bugs, decisions |
| `push_files` | Direct push without local git |
| `search_code` | Find patterns across repo |

#### Business System MCP
Restart: `node /Users/jasonl/Desktop/Manifest-Match-Business-System/mcp-server.js`

| Tool | When |
|---|---|
| `get_system_overview` | Full project status |
| `list_tasks` / `complete_task` | Task tracking |
| `create_reminder` | Flag blockers |
| `get_phase_progress` | Phase completion |

---

### Skills — Routing Guide

#### This skill
`/manifest-match-guide` — orientation, verified system map, tangles, routing. Invoke first each session.

#### Master
`/v8-omniscient-guardian` — full codebase knowledge, delegates to domain experts

#### Domain Experts
| Skill | Invoke when |
|---|---|
| `/v8-package-architect` | Package deps, build order |
| `/v8-data-models-expert` | Core Data entities, relationships |
| `/v8-thompson-mathematician` | Thompson math, Beta distributions, lever weights |
| `/v8-job-sources-expert` | API clients, rate limiting |
| `/v8-ai-systems-expert` | Foundation Models, iOS 26 on-device AI |
| `/v8-data-flows-expert` | End-to-end pipelines |
| `/v8-ui-components-expert` | SwiftUI views, DeckScreen |
| `/v8-ios26-design-expert` | iOS 26 Liquid Glass, design system |
| `/v8-coresignal-integration-expert` | CoreSignal API |

#### Guardians — invoke before committing any code
| Skill | Invoke when |
|---|---|
| `/v7-architecture-guardian` | Any Swift code |
| `/swift-concurrency-enforcer` | Any async/await, actor, @MainActor |
| `/thompson-performance-guardian` | Any scoring pipeline change |
| `/accessibility-compliance-enforcer` | Any new UI component |
| `/core-data-specialist` | Any Core Data fetch, save, migration |
| `/privacy-security-guardian` | Any data handling, API keys |

#### Specialists
| Skill | Invoke when |
|---|---|
| `/swiftui-specialist` | Complex SwiftUI patterns |
| `/thompson-sampling-mathematician` | Verifying Beta math |
| `/manifestandmatch-v7-coding-standards` | Matching reference patterns exactly |
| `/manifestandmatch-skills-guardian` | SkillTaxonomy, EnhancedSkillsMatcher |
| `/onet-career-integration` | O*NET data, occupation codes |
| `/performance-regression-detector` | Benchmarks before/after scoring changes |
| `/privacy-security-guardian` | API keys, user data |

---

## Session Protocol

### Every Session Start
```
1. Read BUILD_SEQUENCE.md — current task, blockers
2. claude mcp list — verify 3 MCPs connected
3. git status + git log --oneline -5
4. session_show_defaults — if touching ios-app/
```

### Before Building Any System That Existed in the Reference
```
1. Read schematics/SYSTEM_INVENTORY.md entry for that system
2. Check if it appears in the Critical Tangles table above
3. Check if it appears in the Confirmed Dead list above
4. Read the build plan for the current phase (new_build_requirements/)
5. Check DECISIONS.md — decision may already be made
```

### Skill Routing by Phase
| Phase | Lead skills | Pre-commit checks |
|---|---|---|
| 1 — Foundation | `/v8-package-architect` | `/v7-architecture-guardian` |
| 2 — Data Flow | `/v8-data-models-expert` + `/v8-thompson-mathematician` | `/swift-concurrency-enforcer` |
| 3 — Scoring | `/v8-thompson-mathematician` + `/v8-data-flows-expert` | `/thompson-performance-guardian` |
| 4 — User Flow | `/v8-ui-components-expert` + `/swiftui-specialist` | `/accessibility-compliance-enforcer` |
| 5 — Revenue | `/v7-expansion-architect` | `/privacy-security-guardian` |

### Every Session End
```
1. Update BUILD_SEQUENCE.md — mark done, note blockers
2. Log decisions in DECISIONS.md
3. git add -p && git commit
4. Push to GitHub
```

---

## Key Files

| What | Path |
|---|---|
| **What we're doing now** | `BUILD_SEQUENCE.md` |
| **Verified system inventory** | `schematics/SYSTEM_INVENTORY.md` |
| **Untangling Guide** (next deliverable) | `schematics/UNTANGLING_GUIDE.md` |
| **Confirmed decisions** | `DECISIONS.md` |
| **Unanswered questions** | `OPEN_QUESTIONS.md` |
| **Package names** | `context/PACKAGE_NAMES.md` |
| **Sacred constraints** | `context/SACRED_CONSTRAINTS.md` |
| **Thompson reference** | `context/THOMPSON.md` |
| **Architecture patterns** | `context/ARCHITECTURE.md` |
| **Build plans (per phase)** | `new_build_requirements/` |
| **What went wrong in V7/V8** | `schematics/` |
| **All tools and paths** | `CLAUDE_CAPABILITIES.md` |
