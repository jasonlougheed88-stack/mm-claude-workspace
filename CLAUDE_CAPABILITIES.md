# Claude's Complete Capabilities — Manifest & Match
**Self-Knowledge Reference — Read at Every Session Start**
**Last updated: 2026-05-14**

---

## 1. Native Claude Code Tools (Always Available)

| Tool | What it does |
|------|-------------|
| `Read` | Read any file on the filesystem |
| `Edit` | Make precise edits to existing files |
| `Write` | Create new files |
| `Bash` | Run shell commands, scripts, build tools |
| `Agent` | Spawn a specialized sub-agent for parallel or isolated work |
| `WebFetch` | Fetch a URL |
| `WebSearch` | Search the web |
| `TodoWrite/Read/Update` | Track tasks within the current session |

Rule: Read before Edit. Edit before Write (prefer editing to creating).

---

## 2. MCP Servers

MCP servers load at session start. Verify with `claude mcp list` at session start.

### 2a. GitHub MCP
**Account:** `jasonlougheed88-stack`
**Repo:** `jasonlougheed88-stack/manifest_and_match_V8` (verify this is still the active repo — may be updated)
**Token:** stored in `~/.claude/config.json` — do not commit

**Tools:**
- Create/read/update issues and PRs
- Push commits directly
- Read repo state, branches
- Search code across repo

**Fallback:** `gh` CLI via Bash if MCP isn't responding.

### 2b. Business System MCP
**Server:** `/Users/jasonl/Desktop/Manifest-Match-Business-System/mcp-server.js`
**Database:** SQLite at `Manifest-Match-Business-System/data/business-system.db`

**Tools:** `get_system_overview`, `list_tasks`, `complete_task`, `uncomplete_task`, `list_files`, `move_file`, `list_reminders`, `create_reminder`

If it drops: `node /Users/jasonl/Desktop/Manifest-Match-Business-System/mcp-server.js`

### 2c. XcodeBuildMCP
**Plugin:** Also `swift-lsp@claude-plugins-official` for Swift code intelligence.

**What it does:**
- `build_sim` / `build_run_sim` — build and launch in simulator
- `screenshot` — capture simulator screen
- `describe_ui` — read accessibility tree
- `tap`, `swipe`, `type_text`, `long_press`, `key_press` — full UI interaction
- `start_sim_log_cap` / `stop_sim_log_cap` — log capture
- `test_sim` — run XCTest suite
- `list_sims` / `boot_sim` — manage simulators
- `discover_projs` / `list_schemes` / `show_build_settings` — inspect Xcode project

**This closes the feedback loop.** Build → run → interact → read logs → iterate. No Xcode required.

**Verify active:** `session_show_defaults` before first build call each session.

---

## 3. Skills System (37 Active Skills)

Skills are invoked via `/skill-name`. They are instruction sets that change how I behave.
Active skills live at `~/.claude/skills/`. The `skills/` folder in this repo is a local copy for reference.

### Meta-skill (invoke for complex cross-domain V8 work)
- `/v8-omniscient-guardian` — master skill, knows entire codebase, delegates to domain experts

### Domain Expert Sub-skills
| Skill | When to use |
|-------|-------------|
| `/v8-data-models-expert` | Core Data entities, persistence, relationships |
| `/v8-thompson-mathematician` | Thompson Sampling math, FastBetaSampler, <10ms performance |
| `/v8-job-sources-expert` | API integrations, rate limiting, job fetching |
| `/v8-coresignal-integration-expert` | CoreSignal API |
| `/v8-ai-systems-expert` | iOS 26 Foundation Models, AI features |
| `/v8-data-flows-expert` | End-to-end flows, swipe handling, pipelines |
| `/v8-ui-components-expert` | SwiftUI views, accessibility, DeckScreen |
| `/v8-package-architect` | Package structure, dependencies, circular dep detection |
| `/v8-ios26-design-expert` | iOS 26 Liquid Glass, design system |

### Architecture + Process Skills (pattern knowledge — don't go stale)
| Skill | Purpose |
|-------|---------|
| `/v7-architecture-guardian` | MV pattern, no ViewModels, package rules, sacred constraints |
| `/swift-concurrency-enforcer` | Swift 6 strict concurrency, @MainActor, Sendable |
| `/swiftui-specialist` | SwiftUI patterns, @State, @Binding, ForEach |
| `/core-data-specialist` | Core Data patterns, FetchRequest optimization |
| `/thompson-performance-guardian` | <10ms Thompson requirement enforcement |
| `/thompson-sampling-mathematician` | Mathematical correctness (Beta distribution, Bayesian theory) |
| `/accessibility-compliance-enforcer` | VoiceOver, Dynamic Type, WCAG 2.1 AA |
| `/performance-regression-detector` | Performance regression detection |
| `/privacy-security-guardian` | Privacy manifest, data handling |
| `/ai-error-handling-enforcer` | Defensive AI patterns |
| `/manifestandmatch-v7-coding-standards` | Deep Swift code patterns for this codebase |
| `/manifestandmatch-skills-guardian` | SkillTaxonomy, EnhancedSkillsMatcher architecture |

### Integration + Coordination Skills
| Skill | Purpose |
|-------|---------|
| `/ios26-specialist` | iOS 26 APIs, Liquid Glass, Foundation Models |
| `/ios26-development-guide` | Daily iOS 26 dev workflow |
| `/job-source-integration-validator` | Validates new job source implementations |
| `/job-card-validator` | Job card data structure validation |
| `/api-integration-builder` | Scaffolds new API integrations |
| `/onet-career-integration` | O*NET API, career data enrichment |
| `/skill-builder` | Building/updating Claude skills (meta) |
| `/xcode-project-specialist` | SPM, build settings, signing, schemes |
| `/ios-app-architect` | Generic iOS/Swift/SwiftUI baseline |

### Roadmap + Business Skills
| Skill | Purpose |
|-------|---------|
| `/v7-expansion-architect` | Feature expansion planning |
| `/app-narrative-guide` | Mission alignment |
| `/business-planning-manager` | Business planning, connects to Business System MCP |
| `/professional-user-profile` | Profile data model |
| `/cost-optimization-watchdog` | AI API cost control |

### Note on Staleness
Pattern-based skills (guardians, enforcers, specialists) don't go stale — they encode rules.
V8-prefixed skills know the V7 codebase — useful as reference for the fresh build.
Always verify specific file/line references against actual code.

---

## 4. Installed Plugins

| Plugin | What it does |
|--------|-------------|
| `code-review` | Multi-agent automated code review |
| `feature-dev` | Structured feature development workflow |
| `commit-commands` | Streamlined git: commit, push, PR |
| `pr-review-toolkit` | PR review agents (comments, tests, error handling, types) |
| `security-guidance` | Security review for user data, auth, privacy |
| `hookify` | Build custom hooks to enforce constraints automatically |
| `session-report` | Auto-generates session report at end |

---

## 5. Hooks (Automatic)

**File:** `~/.claude/hooks/validate-sacred-constraints.sh`
**Trigger:** Every user prompt submission

**What it checks:**
1. Swipe thresholds (right: 100, left: -100, up: -80)
2. Thompson <10ms budget
3. Memory <200MB baseline
4. Amber hue = 45/360
5. Teal hue = 174/360
6. V7Core zero dependencies

**Important:** Hook currently points to old V8 path. Update when ios-app/ Xcode project exists:
```bash
V8_PATH="/Users/jasonl/Desktop/Claudes-Man&Man-build/ios-app/Packages"
```

---

## 6. Memory System

**Location:** `~/.claude/projects/-Users-jasonl/memory/`
**Index:** `~/.claude/projects/-Users-jasonl/memory/MEMORY.md`

Types: `user`, `feedback`, `project`, `reference`
Rule: Update memory when something significant changes — decisions, preferences, project state.

---

## 7. Agent Types Available

| Agent | Best for |
|-------|---------|
| `ios-app-architect` | iOS architecture, Swift, Xcode issues |
| `backend-ios-expert` | Backend for iOS apps |
| `xcode-ai-integration-specialist` | Core ML, Vision, Foundation Models |
| `xcode-ux-designer` | SwiftUI UI/UX design |
| `database-migration-specialist` | Core Data schema design and migrations |
| `ml-engineering-specialist` | Thompson Sampling optimization |
| `performance-engineer` | Memory, speed, profiling |
| `algorithm-math-expert` | Beta distribution, scoring math |
| `api-integration-architect` | API design, rate limiting, error handling |
| `testing-qa-strategist` | Test strategy, automation |
| `Explore` | Fast codebase search (read-only) |
| `Plan` | Architecture planning, implementation strategy |
| `general-purpose` | Everything else |

---

## 8. GitHub Setup

**Account:** `jasonlougheed88-stack`
**CLI:** `gh` is authenticated and working
**MCP:** GitHub MCP configured with personal access token

**Git root for this project:** `/Users/jasonl/Desktop/Claudes-Man&Man-build/`
(The planning folder IS the git repo — ios-app/ and backend/ are subdirectories within it)

---

## 9. Project Paths Reference

| What | Where |
|------|-------|
| Git root / build home | `/Users/jasonl/Desktop/Claudes-Man&Man-build/` |
| iOS app (Xcode project) | `/Users/jasonl/Desktop/Claudes-Man&Man-build/ios-app/` |
| Backend (Cloudflare Workers) | `/Users/jasonl/Desktop/Claudes-Man&Man-build/backend/` |
| Build sequence | `/Users/jasonl/Desktop/Claudes-Man&Man-build/BUILD_SEQUENCE.md` |
| Architectural decisions | `/Users/jasonl/Desktop/Claudes-Man&Man-build/DECISIONS.md` |
| Schematics | `/Users/jasonl/Desktop/Claudes-Man&Man-build/schematics/` |
| Build plans | `/Users/jasonl/Desktop/Claudes-Man&Man-build/new_build_requirements/` |
| Skills (active) | `~/.claude/skills/` |
| Skills (local copies) | `/Users/jasonl/Desktop/Claudes-Man&Man-build/skills/` |
| Memory | `~/.claude/projects/-Users-jasonl/memory/` |
| Hooks | `~/.claude/hooks/` |
| Business system | `/Users/jasonl/Desktop/Manifest-Match-Business-System/` |
| V7 reference codebase | `/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8/` |

---

## 10. Session Workflow

### Session Start
1. Read `BUILD_SEQUENCE.md`
2. `claude mcp list` — verify MCPs connected
3. `git status` + `git log --oneline -5`
4. `session_show_defaults` if touching ios-app/ Xcode project

### Build Loop (once Xcode project exists)
1. Edit code in `ios-app/`
2. `build_run_sim` → `screenshot` → verify
3. `test_sim` for unit tests
4. Iterate

### Session End
1. Update `BUILD_SEQUENCE.md`
2. Note decisions in `DECISIONS.md`
3. `git add -p && git commit`
4. Push

### Skill Invocation by Phase
| Phase | Skills |
|-------|--------|
| Phase 1 — Foundation | `/v8-package-architect` + `/v7-architecture-guardian` |
| Phase 2 — Data Flow | `/v8-data-models-expert` + `/v8-thompson-mathematician` |
| Phase 3 — Scoring | `/v8-thompson-mathematician` + `/thompson-performance-guardian` |
| Phase 4 — User Flow | `/v8-ui-components-expert` + `/swiftui-specialist` |
| Phase 5 — Revenue | `/v7-expansion-architect` + `/privacy-security-guardian` |
| Before any commit | `/swift-concurrency-enforcer` + `/v7-architecture-guardian` |
