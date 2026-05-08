# Claude's Complete Capabilities for Manifest & Match
## Self-Knowledge Reference — Read at Every Session Start

**This document is the ground truth for what I have access to and how to use it.**  
Last updated: 2026-05-08

---

## 1. Native Claude Code Tools (Always Available)

These are built into me. No setup required. Use them freely.

| Tool | What it does |
|------|-------------|
| `Read` | Read any file on the filesystem |
| `Edit` | Make precise edits to existing files |
| `Write` | Create new files |
| `Bash` | Run shell commands, scripts, build tools |
| `Agent` | Spawn a specialized sub-agent to do parallel or isolated work |
| `WebFetch` | Fetch a URL |
| `WebSearch` | Search the web |
| `TodoWrite/Read/Update` | Track tasks within the current session |

**Key rule:** Read before Edit. Edit before Write (prefer editing to creating new files).

---

## 2. MCP Servers (Configured — Verify Active at Session Start)

MCP servers extend what I can do beyond the filesystem. Two are configured:

### 2a. GitHub MCP (`@modelcontextprotocol/server-github`)
**Config:** `~/.claude/config.json`  
**Token:** stored in `~/.claude/config.json` — do not commit  
**Repo:** `jasonlougheed88-stack/manifest_and_match_V8` (public)

**What it lets me do:**
- Create/read/update issues
- Create/merge pull requests
- Push commits directly
- Read repo state, branches, PRs
- Search code across the repo

**How to verify it's active:** Try `gh repo view jasonlougheed88-stack/manifest_and_match_V8` via Bash as a fallback if MCP isn't responding.

**GitHub CLI also available:** `gh` command works in Bash — use as backup when MCP isn't available.

### 2b. Business System MCP (`manifest-match-business-system`)
**Config:** `~/.claude/claude_desktop_config.json`  
**Server:** `/Users/jasonl/Desktop/Manifest-Match-Business-System/mcp-server.js`  
**Database:** SQLite at `Manifest-Match-Business-System/data/business-system.db`

**Tools this provides:**
- `get_system_overview` — full project progress snapshot
- `list_tasks` — all tasks, filterable by phase/status
- `complete_task` — mark task done
- `uncomplete_task` — mark task incomplete
- `list_files` — uploaded files by phase
- `move_file` — recategorize files
- `list_reminders` — pending reminders
- `create_reminder` — new reminder

**⚠️ Status:** May not be running. To start: `node /Users/jasonl/Desktop/Manifest-Match-Business-System/mcp-server.js`  
**Use case:** Track business planning tasks, phase progress, project management.

---

## 3. Skills System (42 Custom Skills)

Skills are invoked via `/skill-name` in conversation. They are instruction sets that change how I behave.

### The Hierarchy

**Meta-skill (invoke first for complex V8 work):**
- `/v8-omniscient-guardian` — master skill, knows entire codebase (393 files, 14 packages), delegates to domain experts. Last updated Nov 12 2025.

**Domain expert sub-skills (invoke for specific areas):**
| Skill | When to use | Last updated |
|-------|-------------|-------------|
| `/v8-data-models-expert` | Core Data entities, persistence, relationships | Nov 08 2025 |
| `/v8-thompson-mathematician` | Thompson Sampling math, FastBetaSampler, <10ms performance | Nov 08 2025 |
| `/v8-job-sources-expert` | API integrations, rate limiting, job fetching | Nov 08 2025 |
| `/v8-coresignal-integration-expert` | CoreSignal API, Elasticsearch DSL | Nov 11 2025 |
| `/v8-ai-systems-expert` | iOS 26 Foundation Models, AI features | Nov 08 2025 |
| `/v8-data-flows-expert` | End-to-end flows, swipe handling, pipelines | Nov 08 2025 |
| `/v8-ui-components-expert` | SwiftUI views, accessibility, DeckScreen | Nov 08 2025 |
| `/v8-package-architect` | Package structure, dependencies, circular dep detection | Nov 08 2025 |
| `/v8-ios26-design-expert` | iOS 26 Liquid Glass, design system | Nov 15 2025 |

**Architecture + process skills:**
| Skill | Purpose | Status |
|-------|---------|--------|
| `/v7-architecture-guardian` | Enforces MV pattern, no ViewModels, package rules | Oct 27 — may be stale |
| `/swift-concurrency-enforcer` | Swift 6 strict concurrency, @MainActor, Sendable | Oct 27 — may be stale |
| `/swiftui-specialist` | SwiftUI patterns, @State, @Binding, ForEach | Oct 27 — may be stale |
| `/core-data-specialist` | Core Data patterns, FetchRequest optimization | Oct 27 — may be stale |
| `/thompson-performance-guardian` | Enforces <10ms Thompson requirement | Oct 27 — may be stale |
| `/accessibility-compliance-enforcer` | VoiceOver, Dynamic Type, WCAG 2.1 AA | Oct 18 — stale |
| `/performance-regression-detector` | Catches performance regressions | Oct 26 — stale |
| `/privacy-security-guardian` | Privacy manifest, data handling | Oct 18 — stale |

**Integration + coordination skills:**
| Skill | Purpose | Status |
|-------|---------|--------|
| `/ios26-specialist` | iOS 26 specific APIs and patterns | Oct 27 — stale |
| `/ios26-migration-orchestrator` | Migration strategy from older iOS | Oct 27 — stale |
| `/onet-implementation-coordinator` | O*NET data integration | Nov 06 — semi-current |
| `/job-source-integration-validator` | Validates job source implementations | Oct 26 — stale |
| `/job-card-validator` | Job card data validation | Oct 22 — stale |
| `/api-integration-builder` | Building new API integrations | Oct 26 — stale |
| `/skill-builder` | Building new skills (meta) | Nov 02 — semi-current |

**Narrative + business skills:**
| Skill | Purpose | Status |
|-------|---------|--------|
| `/app-narrative-guide` | Keeps work aligned with app's story | Oct 18 — stale |
| `/business-planning-manager` | Business planning, connects to MCP | Oct 27 — stale |
| `/professional-user-profile` | User persona knowledge | Oct 26 — stale |
| `/cost-optimization-watchdog` | Tracks cost implications | Oct 18 — stale |

### ⚠️ Important: Skills Are 6 Months Stale
All skills were last updated October–November 2025. The codebase has evolved since then. Skills provide good structural knowledge but **always verify against actual code** before acting on skill knowledge. Skills don't know about: logging conversion done May 2026, icon changes, API key updates, or any post-November work.

---

## 4. Hooks (Automatic — Fires on Every Prompt)

**File:** `~/.claude/hooks/validate-sacred-constraints.sh`  
**Trigger:** Every user prompt submission

**What it does:** Validates 7 sacred constraints:
1. Tab order (Discover=0, History=1, Profile=2, Analytics=3)
2. Swipe thresholds (right: 100, left: -100, up: -80)
3. Thompson <10ms budget
4. Memory <200MB baseline
5. Amber hue = 45/360
6. Teal hue = 174/360
7. V7Core zero dependencies

**⚠️ BROKEN:** Hook points to old V7 path:  
`/Users/jasonl/Desktop/manifest and match  v7/V7 build files/...`  
This path does not exist. The hook runs but finds nothing to validate. **Needs to be fixed to point to V8.**

---

## 5. Commands (Slash Commands)

| Command | What it does | Status |
|---------|-------------|--------|
| `/create-upgrade` | Creates folder structure for a new upgrade (plan, checklist, tasks, performance validation, rollback, testing) | ⚠️ Points to old V7 paths |
| `/run-validation` | Runs full validation pipeline | ⚠️ Points to old V7TestValidation folder |

Both commands need to be updated to point to V8 and the new build folder.

---

## 6. Memory System

**Location:** `~/.claude/projects/-Users-jasonl/memory/`  
**Index:** `~/.claude/projects/-Users-jasonl/memory/MEMORY.md`

**Current memories:**
- `project_manifest_and_match.md` — full project brief, architecture, hurdles, phase plan

**Types I can save:**
- `user` — Jason's preferences, knowledge level, how to communicate
- `feedback` — what worked/didn't, corrections to my behavior
- `project` — current state, decisions, context
- `reference` — where things live in external systems

**Rule:** Always update memory when something significant changes — don't let it go stale like the skills did.

---

## 7. Available Agent Types

When I spawn an Agent, these specialized types are available:

| Agent | Best for |
|-------|---------|
| `ios-app-architect` | iOS architecture, Swift, Xcode issues |
| `backend-ios-expert` | Backend for iOS apps |
| `xcode-ai-integration-specialist` | Core ML, Vision, Foundation Models |
| `xcode-ux-designer` | SwiftUI UI/UX design |
| `database-migration-specialist` | Core Data migrations |
| `ml-engineering-specialist` | ML model optimization, Thompson Sampling |
| `performance-engineer` | Memory, speed, profiling |
| `algorithm-math-expert` | Mathematical algorithms (Beta distribution, etc.) |
| `api-integration-architect` | API design, rate limiting, error handling |
| `testing-qa-strategist` | Test strategy, automation |
| `Explore` | Fast codebase search (read-only) |
| `Plan` | Architecture planning, implementation strategy |
| `general-purpose` | Everything else |

---

## 8. GitHub Setup

**Account:** `jasonlougheed88-stack`  
**Primary repo:** `jasonlougheed88-stack/manifest_and_match_V8` (public)  
**CLI:** `gh` is authenticated and working  
**MCP:** GitHub MCP configured with personal access token

**Repos:**
- `manifest_and_match_V8` — current active codebase (V8)
- `v_7_uppgrade` — private, V7 work
- `Manifest-and-Match-` — private, older work

**⚠️ Git state:** The V8 workspace at `/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8` is NOT a git repository (confirmed). The GitHub repo exists but local code has not been committed. **Setting up git properly is a priority task.**

**Workflow going forward:**
1. `git init` in V8 workspace
2. Connect to `manifest_and_match_V8` remote
3. Initial commit of current state
4. Branch per feature/phase
5. PR → merge → tag releases

---

## 9. What Needs to be Fixed (Priority Order)

1. **Git init** — local V8 code not tracked, GitHub repo exists but disconnected
2. **Fix validation hook** — update path to V8, test it actually fires correctly
3. **Update commands** — point to V8 and new build folder
4. **Audit + refresh skills** — 42 skills, 6 months stale, need to identify which to keep/update/kill
5. **Verify MCP servers active** — GitHub and Business System MCPs configured but not verified active

---

## 10. The Idealized Session Workflow

### At the start of every session:
1. Read `MEMORY.md` — get project context
2. Read `PROJECT_PLAN.md` — know current phase and next task
3. Check which skills are relevant — invoke the right ones
4. Verify GitHub state — `gh repo view` to confirm sync

### During work:
- Build via `tools/build.sh` to catch errors without Xcode
- Use `tools/find_todos.sh` to surface work remaining
- Stream logs via `tools/stream_logs.sh` (Xcode must be in debug session)
- Commit after each meaningful change — small, frequent commits
- Update `PROJECT_PLAN.md` checkboxes as items complete

### At the end of every session:
- Update memory with anything significant learned
- Update `PROJECT_PLAN.md` with current status
- Commit and push all changes to GitHub
- Note any blockers in `session-notes/`

---

## 11. Project Paths Reference

| What | Where |
|------|-------|
| Xcode workspace | `/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8/ManifestAndMatchV7.xcworkspace` |
| All packages | `/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8/Packages/` |
| Build folder (this) | `/Users/jasonl/Desktop/Claudes-Man&Man-build/` |
| Skills | `~/.claude/skills/` |
| Memory | `~/.claude/projects/-Users-jasonl/memory/` |
| Hooks | `~/.claude/hooks/` |
| Business system | `/Users/jasonl/Desktop/Manifest-Match-Business-System/` |
| Historical docs | `/Users/jasonl/Desktop/ios26_manifest_and_match/` |
| C4 Architecture docs | `/Users/jasonl/Desktop/ios26_manifest_and_match/C4_ARCHITECTURE_ANALYSIS/` |
| Master plan (historical) | `/Users/jasonl/Desktop/ios26_manifest_and_match/IOS26_MANIFEST_AND_MATCH_MASTER_PLAN.md` |
