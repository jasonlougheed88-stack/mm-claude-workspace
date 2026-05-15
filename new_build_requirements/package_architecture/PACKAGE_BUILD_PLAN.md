# Package Architecture Build Plan
**Manifest & Match V8 | Created: 2026-05-14**
**Based on:** SCHEMATIC_01_package_dependencies.md

---

## What We're Solving

The current 15-package DAG is clean (0 circular dependencies) but has three structural problems heading into V8:

1. **Two inactive packages in the build graph** — `V7Ads` and `V7Embeddings` are in the dependency tree but inactive in production. Every build compiles dead code. V7Ads depends on V7UI which means V7UI changes trigger V7Ads recompilation unnecessarily.

2. **Foundation Models requires conditional availability** — `FoundationModelsRIASECExtractor` (new from TAXONOMY_BUILD_PLAN) must import the `FoundationModels` framework, which only exists on iOS 26+. The current V7AI `Package.swift` has no conditional platform requirements. Without changes, any device running pre-iOS 26 will fail to link.

3. **DeckScreen.swift is 3,353 lines** — V7UI is the terminal presentation package. It has 7 direct dependencies. DeckScreen alone is a monolithic file mixing job scoring coordination, swipe handling, question card logic, sheet management, and Thompson update triggers. V8 scaffold should decompose this.

---

## What Does NOT Change

- The DAG shape: V7Core → V7Data/V7JobParsing/V7Embeddings → V7Thompson → V7Performance → V7AIParsing → V7Services → V7AI → V7Career → V7ResumeAnalysis → V7UI → ManifestAndMatchV7Feature → App Target
- The build order (15 levels)
- All Package.swift dependency declarations that are currently correct
- V7Core's zero-dependency status (foundation package — never add deps here)
- The no-external-SPM-dependencies rule (Charts, NaturalLanguage, CoreML, FoundationModels are all system frameworks)

---

## Change 1: Conditional Foundation Models Platform in V7AI

### Problem

V7AI's `Package.swift` currently declares no platform floor that matches the FoundationModels requirement. When `FoundationModelsRIASECExtractor.swift` is added (per TAXONOMY_BUILD_PLAN), any build targeting pre-iOS 26 devices will fail at link time.

### Solution

Add conditional availability in `Package.swift` for V7AI using `#if canImport(FoundationModels)` guards in the Swift file itself. The package platform declaration stays at iOS 17+ (or whatever the current minimum is) — the framework import is guarded at the call site.

**V7AI Package.swift — no change needed to platforms array.**

**FoundationModelsRIASECExtractor.swift — add availability guard:**

```swift
#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26.0, *)
actor FoundationModelsRIASECExtractor {
    // ... implementation from TAXONOMY_BUILD_PLAN
}
#endif
```

**Call site in answer handler — update to use availability check:**

```swift
#if canImport(FoundationModels)
if #available(iOS 26.0, *), LanguageModelSession.isAvailable {
    riasecScores = (try? await FoundationModelsRIASECExtractor.shared.extractRIASEC(from: answerText))
        ?? RIASECKeywordMapper.shared.extractRIASEC(from: answerText)
} else {
    riasecScores = RIASECKeywordMapper.shared.extractRIASEC(from: answerText)
}
#else
riasecScores = RIASECKeywordMapper.shared.extractRIASEC(from: answerText)
#endif
```

**Files to modify:**
- `V7AI/Sources/V7AI/Parsing/FoundationModelsRIASECExtractor.swift` (new — wrap in `#if canImport(FoundationModels)`)
- Answer handler call site (exact file: wherever `RIASECKeywordMapper.shared.extractRIASEC()` is called)

**Estimated effort:** 30 minutes — availability guards only, no logic change.

---

## Change 2: Deactivate V7Ads from Build Graph

### Problem

V7Ads depends on V7UI (`V7UI → V7Ads` edge in graph). It is confirmed inactive — no ad cards display, no ad network is connected. It sits above V7UI in the dependency chain, meaning any V7UI change triggers a V7Ads recompile. It adds dead build time to every compile cycle.

### Options

| Option | What it does | Risk |
|---|---|---|
| **Remove V7Ads from Feature package dependencies** | ManifestAndMatchV7Feature stops importing V7Ads. V7Ads code remains on disk but never compiles. | ✅ Lowest risk. Reversible. Code not deleted. |
| **Delete V7Ads package entirely** | Remove directory + Package.swift entry. | ⚠️ Harder to restore. Only do if no monetization plans exist. |
| **Keep as-is** | Continue compiling dead code | No risk, no improvement. |

**Recommendation:** Remove from Feature package dependency array only. Do not delete. If monetization becomes a priority, re-add.

**File to modify:**
- `ManifestAndMatchV7Package/Package.swift` — remove `V7Ads` from the Feature target's dependencies array

**Estimated effort:** 5 minutes. Verify build succeeds without it.

---

## Change 3: V7Embeddings Decision

### Problem

V7Embeddings provides semantic vector embeddings and is "disabled by default in prod" per SCHEMATIC_01. It sits at build level 1 (only depends on V7Core) so it adds minimal compile overhead. However, V7Thompson depends on it — V7Thompson includes V7Embeddings in its Package.swift dependencies even though the embedding path is inactive.

### Resolution

**Keep V7Embeddings as-is for now.** The compile cost is minimal (level 1, V7Core only). If Foundation Models-based embeddings replace it in Phase 2 or 3, revisit at that point. No immediate action.

---

## Change 4: DeckScreen.swift Decomposition (V8 Scaffold Priority)

### Problem

DeckScreen.swift is 3,353 lines. It currently owns:
- Job card rendering and gesture handling
- Question card injection logic
- Thompson update triggers (processInteraction calls)
- Sheet presentations (JobDetailsSheet, ExplainFitSheet, MLInsightsDashboard)
- Buffer management (preload when < 3 jobs remain)
- ThompsonScoringOrchestrator (initialized here, lines 1572–1579)
- ManifestInferenceActor trigger (line 1005)
- Cover letter trigger

This is a V7UI problem. The V8 scaffold should break this apart.

### Target Architecture

```
DeckScreen.swift              ← coordinator only (~300 lines)
  ├─ JobDeckView.swift        ← card rendering + gesture handling
  ├─ QuestionCardCoordinator.swift ← question injection logic  
  ├─ DeckBufferManager.swift  ← buffer loading, preload triggers
  └─ DeckSheetCoordinator.swift ← sheet state management
```

**Key constraint:** V7UI is the terminal package. All of these files stay in V7UI/Sources/V7UI/Views/. No new packages are created — this is a within-package file decomposition.

**Files to create** (all in `V7UI/Sources/V7UI/Views/`):
- `JobDeckView.swift` — extract job card gesture handling from DeckScreen lines 477–730
- `DeckBufferManager.swift` — extract buffer preload logic from DeckScreen lines 1800–1900 (approx)
- `DeckSheetCoordinator.swift` — extract sheet state @State vars and sheet presentations

**Files to modify:**
- `DeckScreen.swift` — becomes coordinator that owns the state and delegates to sub-views

**Estimated effort:** 3–4 days. High value for V8 maintainability. No behavior change — pure decomposition.

---

## V8 Package Name Decision

The packages are currently named `V7*`. For V8 scaffolding, two options:

| Option | Implication |
|---|---|
| **Keep V7 prefix** | No rename cost. V8 is additive changes on top of V7 packages. Internal names only — not user-visible. |
| **Rename to V8 prefix** | Clean break, accurate naming. High effort — every import statement changes. Requires updating all 13 Package.swift files and hundreds of import lines. |

**Recommendation: Keep V7 prefix.** The version number in the package name is internal only. The build plan calls this "V8" as a product version, not a package naming convention. Renaming creates risk with zero user benefit.

---

## Implementation Sequence

```
Day 1:
  Change 1 — Availability guards for FoundationModels in V7AI
  Verify simulator build succeeds on iOS 17 target (no link errors)
  Verify FoundationModels path is reachable on iOS 26 sim

Day 2:
  Change 2 — Remove V7Ads from Feature package dependencies
  Full clean build. Verify no V7Ads references remain in active code paths.

Day 3:
  Change 4 kickoff — Begin DeckScreen decomposition
  Extract JobDeckView.swift first (most isolated, swipe gesture logic)
  Confirm DeckScreen still compiles with extracted view

Days 4–6:
  Complete DeckScreen decomposition
  DeckBufferManager.swift, DeckSheetCoordinator.swift
  Full feature test: swipe, question card, sheets, buffer preload
```

---

## Files to Create

| File | Package | Purpose |
|---|---|---|
| `FoundationModelsRIASECExtractor.swift` | V7AI | Wrapped in `#if canImport(FoundationModels)` |
| `JobDeckView.swift` | V7UI | Extracted card + gesture from DeckScreen |
| `DeckBufferManager.swift` | V7UI | Buffer preload logic |
| `DeckSheetCoordinator.swift` | V7UI | Sheet state management |

## Files to Modify

| File | Change |
|---|---|
| `ManifestAndMatchV7Package/Package.swift` | Remove V7Ads from dependencies |
| `DeckScreen.swift` | Reduce to coordinator, delegate to extracted views |
| Answer handler (RIASECKeywordMapper call site) | Add `#if canImport(FoundationModels)` / `#available` guard |

## Files Unchanged

- All 13 Package.swift files except ManifestAndMatchV7Package
- V7Core (never touch)
- All O*NET resource files
- All Core Data model files
- V7Embeddings (no changes until Phase 2)

---

## Success Criteria

| Metric | Before | After |
|---|---|---|
| Dead packages in compile graph | 1 (V7Ads) | 0 |
| DeckScreen.swift line count | 3,353 | ~300 (coordinator) |
| Pre-iOS 26 build: FoundationModels link error | Would fail on first FM import | Compiles cleanly |
| Circular dependencies | 0 | 0 (unchanged) |
| External SPM dependencies | 0 | 0 (unchanged) |
