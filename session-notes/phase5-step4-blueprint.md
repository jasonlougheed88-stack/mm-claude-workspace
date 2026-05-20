# Phase 5 Step 4 — CareerGrowth Package Blueprint
**Produced: 2026-05-20. Read this before writing any code for Step 4.**

---

## Critical Findings (not obvious from build plan)

1. **JSON schema mismatch — CourseDatabase must be written from scratch.**
   V7 `CourseDatabase` expects `{"version":..., "skills":[{"skillId":..., "courses":[...]}]}`.
   Actual `courses_v1.json` is `{"courses":[{"id":..., "provider":..., "skills":[...], ...}]}`.
   Do NOT adapt the V7 loader. Write a new `CourseDatabase` against the real schema.

2. **`Bundle.main` bug in V7 — use `Bundle.module`.**
   V7 `CourseDatabase.init()` uses `Bundle.main` — this silently returns nil in a Swift Package
   (no crash, just empty courses forever). New build must use `Bundle.module` exclusively.

3. **`CourseRecommendationEngine.shared` does not exist in V7.** Add it as `static let shared`.

4. **`getRecommendations(for:targetRole:limit:)` does not exist in V7.** Create as a new adapter:
   takes `InferredManifestProfile` + `targetRole: String` + `limit: Int`,
   synthesizes `SkillsGap` objects from `manifest.targetSkills: [String]`,
   calls `recommendCourses(for:)` per gap, dedupes, returns top N.

5. **`AffiliateClick` NSManagedObject subclass is missing.** Entity exists in `.xcdatamodeld`
   but there is no `.swift` file. Blocking dependency — create it first in Persistence package.

6. **`NSCache` Swift 6 violation.** `CourseCache` uses `NSCache` inside an `actor`.
   Needs `nonisolated(unsafe) private let cache: NSCache<...>` annotation.

7. **`CourseProvider.brandColor` is a hex String, not a SwiftUI Color.**
   `CourseCardView` needs a `Color(hex:)` extension. Create `AppShell/.../Extensions/Color+Hex.swift` first.

8. **`AffiliateCredentials` check.** V7 checks `!id.contains("YOUR_")`. With empty string placeholders
   in the new build, change check to `!id.isEmpty` so URLs fall back correctly with no credentials.

9. **`SkillsGapAnalyzer.swift` — DROP entirely.** Imports V7Data/V7Core, defines a conflicting
   `UserProfile` type. Port only `Skill` and `SkillsGap` structs into `CourseModels.swift`.

10. **`CourseProviderClient.swift` — DROP entirely.** Its `Course` struct diverges from
    `RecommendedCourse`. EdX API types (`EdXAPIClient`, `EdXCourse`, etc.) port into
    `CourseRecommendationEngine.swift` directly (they are referenced there in V7).

---

## Files to Create

| File | Purpose |
|---|---|
| `Persistence/Sources/Persistence/AffiliateClick.swift` | NSManagedObject subclass for AffiliateClick entity |
| `CareerGrowth/Sources/CareerGrowth/Models/CourseModels.swift` | All public value types: RecommendedCourse, CourseProvider, CoursePrice, DifficultyLevel, Skill, SkillsGap |
| `CareerGrowth/Sources/CareerGrowth/Services/CourseDatabase.swift` | New CourseDatabase actor — correct JSON schema, Bundle.module |
| `CareerGrowth/Sources/CareerGrowth/Services/CourseRecommendationEngine.swift` | Main orchestrator + SkillMatcher, CoursePrioritizer, CircuitBreaker, FallbackMatcher, CourseCache, EdX types |
| `CareerGrowth/Sources/CareerGrowth/Services/AffiliateTracker.swift` | Click tracking actor + AffiliateURLBuilder |
| `AppShell/Sources/AppShell/Extensions/Color+Hex.swift` | `Color(hex: String)` SwiftUI extension |
| `AppShell/Sources/AppShell/CourseCardView.swift` | Single course card view |
| `AppShell/Sources/AppShell/CoursesView.swift` | Course list screen, wires to engine |

---

## Files to Modify

| File | Change |
|---|---|
| `CareerGrowth/Package.swift` | Add `resources: [.copy("Resources/Courses.bundle")]` to target. Existing deps (CoreTaxonomy, Persistence, ScoringEngine, Intelligence, Monitoring) stay. |
| `AppShell/Sources/AppShell/TabViews.swift` | Replace `ManifestTab.body` stub with `NavigationStack { CoursesView().navigationTitle("Manifest") }` |
| `CareerGrowth/Sources/CareerGrowth/CareerGrowth.swift` | Delete file or replace with `public enum CareerGrowthModule {}` |

---

## Step 0 (Before any Swift files)

Copy the courses JSON from V7 reference into the new package:
```
SOURCE: /Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8/Resources/Courses.bundle/courses_v1.json
DEST:   /Users/jasonl/Desktop/Claudes-Man&Man-build/ios-app/Packages/CareerGrowth/Sources/CareerGrowth/Resources/Courses.bundle/courses_v1.json
```
4.1MB file. Create the directory structure first.

---

## Build Sequence (order matters)

1. Copy `courses_v1.json` (Step 0 above)
2. Create `Persistence/.../AffiliateClick.swift`
3. Create `CareerGrowth/.../Models/CourseModels.swift`
4. Create `CareerGrowth/.../Services/CourseDatabase.swift`
5. Create `CareerGrowth/.../Services/CourseRecommendationEngine.swift`
6. Create `CareerGrowth/.../Services/AffiliateTracker.swift`
7. Update `CareerGrowth/Package.swift` (add resource rule)
8. Delete/replace `CareerGrowth/.../CareerGrowth.swift`
9. Create `AppShell/.../Extensions/Color+Hex.swift`
10. Create `AppShell/.../CourseCardView.swift`
11. Create `AppShell/.../CoursesView.swift`
12. Modify `AppShell/.../TabViews.swift` — wire ManifestTab

---

## Key Type Details

### AffiliateClick.swift (Persistence package)
```swift
@objc(AffiliateClick)
public final class AffiliateClick: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var timestamp: Date?
    @NSManaged public var courseID: String
    @NSManaged public var courseTitle: String
    @NSManaged public var provider: String
    @NSManaged public var affiliateURL: String
    @NSManaged public var converted: Bool
    @NSManaged public var conversionTimestamp: Date?
    @NSManaged public var estimatedCommission: Double
    @NSManaged public var coursePrice: Double
    @NSManaged public var userProfile: UserProfile?
}
```

### CourseModels.swift types to define
- `RecommendedCourse: Sendable, Identifiable, Codable, Hashable` — id: String
- `CourseProvider: String, Sendable, Codable, CaseIterable` — with displayName, brandColor (hex String), logoSystemImage
- `CoursePrice: Sendable, Codable, Hashable` — .free / .paid(amount:Decimal,currency:String) / .subscription — with displayText computed var
- `DifficultyLevel: Int, Sendable, Codable, CaseIterable` — .beginner=1, .intermediate=2, .advanced=3
- `Skill: Hashable, Codable, Sendable, Identifiable` — id, name, category
- `SkillsGap: Identifiable, Sendable, Hashable` — id, skill, priorityScore, impactScore, frequencyScore, difficultyScore, timeToClose, dependencies: [Skill]

### CourseDatabase JSON schema (actual file)
```json
{
  "courses": [
    {
      "id": "edx-python-fundamentals-0",
      "provider": "edx",
      "title": "Python Fundamentals",
      "instructor": "Prof. Ahmed Hassan",
      "institution": "MIT",
      "duration": 432000,
      "difficulty": "beginner",
      "skills": ["python", "shell scripting"],
      "rating": 4.8,
      "priceUSD": 1.26,
      "affiliateURL": "https://www.edx.org/course/python",
      "thumbnailURL": "https://edx.org/images/0.jpg",
      "enrollmentCount": 12500
    }
  ]
}
```
Private decode struct: `struct CourseCatalogJSON: Codable { let courses: [CourseJSONModel] }`
Translate difficulty String → DifficultyLevel enum. Translate priceUSD: 0.0 → .free, else .paid.
skillMatchPercentage and relevanceScore start at 0 — set by SkillMatcher/CoursePrioritizer at recommendation time.

### CourseRecommendationEngine — new adapter method
```swift
public func getRecommendations(
    for manifest: InferredManifestProfile,
    targetRole: String,
    limit: Int
) async -> [RecommendedCourse]
```
Synthesise SkillsGap per skill in manifest.targetSkills. If empty, fallback to keyword search on targetRole.

### CoursesView — openCourse pattern (use SwiftUI openURL, not UIApplication)
```swift
@Environment(\.openURL) private var openURL
private func openCourse(_ course: RecommendedCourse) {
    let affiliateURL = AffiliateURLBuilder.shared.buildAffiliateURL(for: course)
    Task { try? await AffiliateTracker.shared.recordClickInCoreData(course: course, affiliateURL: affiliateURL, context: viewContext) }
    openURL(affiliateURL)
}
```

### ManifestTab replacement (TabViews.swift)
```swift
public var body: some View {
    NavigationStack {
        CoursesView()
            .navigationTitle("Manifest")
    }
}
```
CoursesView must NOT declare its own NavigationStack.

---

## Affiliate Credentials (placeholder, Phase 6)
```swift
// AffiliateTracker.swift
static let courseraAffiliateID = ""   // Replace when Rakuten LinkShare approved
static let udemyAffiliateID = ""      // Replace when Udemy affiliate approved
// Check: !id.isEmpty (not !id.contains("YOUR_") — credentials are empty strings, not placeholders)
```

---

## AppShell/Package.swift — NO CHANGES NEEDED
CareerGrowth is already listed as a dependency (confirmed).

---

## Gate for Step 4
- ManifestTab shows course list (not stub)
- Course tap writes AffiliateClick to Core Data (verify with debugger or print)
- Empty state shows correctly when no InferredManifestProfile exists
- Build: zero errors, zero warnings
