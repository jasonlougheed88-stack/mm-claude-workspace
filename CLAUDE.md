# Claude — Manifest & Match Build Workspace
**This folder is the home. Everything lives here.**

---

## Session Start — Do This Every Time

1. Read `BUILD_SEQUENCE.md` — what phase are we in, what's next, what's blocked
2. Read `CLAUDE_CAPABILITIES.md` — verify tools, paths, MCPs
3. `git status` + `git log --oneline -5` — know what's committed
4. `claude mcp list` — verify MCPs are connected (GitHub, Business System, XcodeBuildMCP)

Do not skip step 1. This is what prevented things from being missed before.

---

## Folder Map

```
Claudes-Man&Man-build/          ← You are here (git root)
├── BUILD_SEQUENCE.md           ← READ THIS FIRST every session
├── DECISIONS.md                ← Architectural decisions log
├── CLAUDE.md                   ← This file
├── CLAUDE_CAPABILITIES.md      ← Tools, MCPs, skills, paths
│
├── ios-app/                    ← The actual Xcode project (built in Phase 1)
├── backend/                    ← Cloudflare Workers API proxy
│   └── BACKEND_PLAN.md
│
├── schematics/                 ← 8 honest code audits (SCHEMATIC_01 through _08)
├── new_build_requirements/     ← 8 build plans (what to build, in what order)
├── context/                    ← ARCHITECTURE.md, SACRED_CONSTRAINTS.md, THOMPSON.md
├── skills/                     ← Local copies (active skills are at ~/.claude/skills/)
│
├── phases/                     ← Work output organized by phase
│   ├── phase-1-foundation/
│   ├── phase-2-data-flow/
│   ├── phase-3-scoring/
│   ├── phase-4-user-flow/
│   ├── phase-5-revenue/
│   └── phase-6-connection/
│
├── session-notes/              ← Per-session notes and blockers
└── tools/                      ← Build scripts
```

---

## The Relationship

- **Jason:** Product decisions, direction, learning to code. Not a technical expert.
- **Claude:** Technical execution. Reads the code, uses the tools, builds the things.

When Jason says something is wrong, it's wrong. When Claude doesn't know something, Claude reads the actual files — not skills, not memory, not training knowledge.

---

## Communication Rules

- No pleasantries. No summaries of what you just did.
- When you know something — say where it comes from (the code, a build plan, a decision in DECISIONS.md).
- When you don't know — say so immediately and go find out by reading the actual files.
- Never claim a limitation without first checking the tools.
- Short and direct. One sentence updates while working.

---

## Source of Truth Hierarchy

1. The actual code files in `ios-app/` (read them)
2. `BUILD_SEQUENCE.md` (what we're doing)
3. `DECISIONS.md` (why we made key choices)
4. `new_build_requirements/*.md` (how to build each piece)
5. `schematics/*.md` (what was wrong in V7)
6. `CLAUDE_CAPABILITIES.md` (what tools exist)
7. Skills and memory (structural knowledge — verify against code before acting)
8. Training knowledge (last resort — say when using it)

---

## Coding Rules

- V8 is a fresh build. The V7 code at `/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8/` is reference only.
- Read the build plan for the current phase before writing code.
- Read `DECISIONS.md` before making any architectural choice — the decision may already be made.
- The <10ms Thompson scoring budget is SACRED. Never regress it.
- No ViewModels — MV pattern only (see context/ARCHITECTURE.md).
- Swift 6 strict concurrency. @MainActor on all SwiftUI views. NSManagedObjectID for Core Data cross-context.
- No external SPM dependencies except Google AdMob (Phase 5 only).

---

## Session End Checklist

1. Update `BUILD_SEQUENCE.md` — mark done items, update current phase, note blockers
2. Note any new decisions in `DECISIONS.md`
3. Commit: `git add -p && git commit -m "..."`
4. Push to GitHub
