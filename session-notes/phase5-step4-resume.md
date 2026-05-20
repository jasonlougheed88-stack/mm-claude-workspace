# Phase 5 Step 4 — Resume Notes
**Written: 2026-05-20. Read this before touching any code next session.**

---

## What Was Built This Session

All 12 files from the blueprint were created and built clean (commit `33e41ea`):
- `Persistence/Sources/Persistence/AffiliateClick.swift`
- `CareerGrowth/Sources/CareerGrowth/Models/CourseModels.swift`
- `CareerGrowth/Sources/CareerGrowth/Services/CourseDatabase.swift`
- `CareerGrowth/Sources/CareerGrowth/Services/CourseRecommendationEngine.swift`
- `CareerGrowth/Sources/CareerGrowth/Services/AffiliateTracker.swift`
- `CareerGrowth/Package.swift` (resource rule added)
- `AppShell/Sources/AppShell/Extensions/Color+Hex.swift`
- `AppShell/Sources/AppShell/CourseCardView.swift`
- `AppShell/Sources/AppShell/CoursesView.swift`
- `AppShell/Sources/AppShell/TabViews.swift` (ManifestTab wired)
- `courses_v1.json` copied to CareerGrowth Resources/Courses.bundle/

Visual gates confirmed in simulator:
- Empty state: "Keep Swiping" with teal sparkles ✅
- Course list loads after 3 swipes: shows 14-20 courses with match %, provider icon, price ✅

---

## Bug Found During Gate Testing

**Bug:** `AffiliateTracker.recordClickInCoreData` was passing `viewContext` and calling
`context.save()` on it. The save fails because `viewContext` has pending `JobInteraction`
objects with `sessionID = nil` — a required field that the deck swipe code never sets.
The entire save fails with `NSCocoaErrorDomain Code=1560 "Multiple validation errors"`.

**Fix written (NOT YET BUILT):** Changed `recordClickInCoreData` to create its own
`PersistenceController.shared.container.newBackgroundContext()` instead of accepting
a context parameter. The background context is isolated — it never sees the dirty
JobInteraction objects on viewContext.

**Secondary bug discovered:** `JobInteraction.sessionID` is nil on every swipe — those
records are never saved to Core Data. This is a pre-existing issue (the deck swipe
code doesn't set sessionID). NOT blocking for Step 4, note for Phase 6.

---

## Current File State (what's modified but NOT committed)

### `CareerGrowth/Sources/CareerGrowth/Services/AffiliateTracker.swift`
- **GOOD change (keep):** `recordClickInCoreData` now uses `newBackgroundContext()`, no longer takes `context:` parameter
- **GOOD change (keep):** OSLog `logger` added, `logger.debug("AffiliateClick saved...")` in the save block

### `AppShell/Sources/AppShell/CoursesView.swift`
- **REVERT this:** `@FetchRequest` predicate removed (`hasConverged == YES` predicate was removed for gate testing) — **MUST restore**
- **GOOD change (keep):** OSLog `coursesLogger` added
- **GOOD change (keep):** `openCourse` logs `openCourse called:` and `affiliateURL:`
- **GOOD change (keep):** `do/catch` with `coursesLogger.error(...)` instead of `try?`
- **GOOD change (keep):** `context:` parameter removed from the `recordClickInCoreData` call

---

## Exact Steps to Complete This Session

### Step 1 — Restore the FetchRequest predicate in CoursesView.swift

Change this (current — gate test state):
```swift
// GATE TEST: predicate removed temporarily to verify affiliate click path. Restore after test.
@FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \InferredManifestProfile.lastUpdated, ascending: false)],
    animation: .default
)
```

Back to this (production):
```swift
@FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \InferredManifestProfile.lastUpdated, ascending: false)],
    predicate: NSPredicate(format: "hasConverged == YES"),
    animation: .default
)
```

### Step 2 — Build
`mcp__XcodeBuildMCP__build_sim` — must be zero errors, zero warnings.

### Step 3 — Run and gate test the affiliate click
1. `mcp__XcodeBuildMCP__build_run_sim`
2. Swipe 3+ cards (Interested button at logical 308,817 → screen 848,836, 1.5s apart)
3. Wait for `ManifestInferenceActor: Manifest inference complete` in oslog
4. Ask Jason to tap Manifest tab, then tap a course
5. Check oslog for `[AffiliateTracker] AffiliateClick saved — course: ...`
6. Verify with: `sqlite3 ~/Library/Developer/CoreSimulator/Devices/BC4DBB38-C93E-4ADA-B9F3-E3067699E820/data/Containers/Data/Application/*/Library/Application\ Support/ManifestAndMatch.sqlite "SELECT ZCOURSETITLE, ZPROVIDER FROM ZAFFILIATECLICK;"`

**Note:** The glob `*` in the sqlite path may need to be the actual UUID. Find it with:
`find ~/Library/Developer/CoreSimulator/Devices/BC4DBB38-C93E-4ADA-B9F3-E3067699E820/data/Containers/Data/Application -name "ManifestAndMatch.sqlite" 2>/dev/null`

### Step 4 — If gate passes: commit and push
```
git add ios-app/Packages/CareerGrowth/Sources/CareerGrowth/Services/AffiliateTracker.swift
git add ios-app/Packages/AppShell/Sources/AppShell/CoursesView.swift
git commit -m "Phase 5 Step 4 gate fix — AffiliateTracker uses background context"
git push
```

### Step 5 — Update BUILD_SEQUENCE.md
- Mark Step 4 COMPLETE ✅
- Mark gate as PASSED with oslog timestamp
- Note the secondary JobInteraction.sessionID bug for Phase 6

---

## Oslog Path for This Build (current running process)
The oslog file path changes on each build_run_sim. Always check:
`ls -t ~/Library/Developer/XcodeBuildMCP/workspaces/jasonl-58591b2065c4/logs/ | grep oslog | head -1`

---

## Known: `hasConverged` Never Triggers With Current Test Data
The `hasConverged == YES` predicate means courses won't show until the Thompson engine
converges (~100 swipes). For development testing, either:
- Temporarily remove the predicate (what we did this session — remember to restore)
- OR use the Manifest tab empty state as the normal development view

This is correct production behavior. The gate test required the predicate removed to exercise the course tap path.
