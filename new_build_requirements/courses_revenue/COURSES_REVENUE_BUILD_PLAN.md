# Courses & Affiliate Revenue Build Plan
**Manifest & Match V8 | Created: 2026-05-14**
**Based on:** SCHEMATIC_08_courses_and_affiliate.md

---

## What We're Solving

SCHEMATIC_08 confirmed the V7Career course infrastructure is fully built and entirely disconnected. `CourseRecommendationEngine` (1,354 lines), `CourseProviderClient`, `SkillMatcher`, `CoursePrioritizer`, `CircuitBreaker`, and `AffiliateTracker` exist and compile. The `courses_v1.json` dataset (4.1MB, real course data) is bundled.

The course system has never been called from any active app view. Four things block activation:

1. **Filename mismatch** — `CourseProviderClient` looks for `courses_v1.0.json` in subdirectory `CourseCatalog`. Actual file is `courses_v1.json` in `Courses.bundle`. This causes a `fatalError` on first call.

2. **Affiliate credentials missing** — Both Coursera (Rakuten LinkShare) and Udemy (direct referral) credentials are placeholder strings. Zero affiliate revenue will be earned until replaced.

3. **ManifestTabView .courses destination is empty** — The navigation target exists, no CourseRecommendationEngine call is wired.

4. **No CourseCardView** — No view exists to display course recommendations. Must be created.

**Revenue model:** Coursera 35% commission (~$17 per $49 course), Udemy 17.5% (~$2.62 per $14.99 sale). At 1% purchase conversion on 500 course views/day, target $50–90/day affiliate revenue at scale.

---

## What Does NOT Change

- `courses_v1.json` — 4.1MB real data, do not modify or replace
- `CoursePrioritizer` 8-factor scoring formula — sound design, activate as-is
- `SkillMatcher` NLEmbedding approach — NaturalLanguage framework, zero external dependency
- `AffiliateClick` Core Data entity and its validation logic — write-ready
- `CircuitBreaker` edX API protection — keep for Tier 2
- The `InferredManifestProfile` and `UserProfile` Core Data entities (already populated by existing flows)

---

## Fix 1: Resolve Filename Mismatch (Critical — Blocks Everything)

### Current State

```swift
// CourseProviderClient.swift — current constants:
private let catalogFileName = "courses_v1.0"
private let resourceSubdirectory = "CourseCatalog"
// Looks for: Bundle.module/CourseCatalog/courses_v1.0.json → fatalError
```

```
// Actual file on disk:
Resources/Courses.bundle/courses_v1.json
```

Any call to `CourseRecommendationEngine` triggers `CourseDatabase` initialization, which calls `Bundle.module.url(forResource:)` with the wrong name/path → `fatalError("courses_v1.json not found in Courses.bundle")`.

### Fix

**Read `CourseProviderClient.swift` in full before changing anything** — verify the exact constant names and the exact `Bundle.module.url()` call site. Then:

```swift
// CourseProviderClient.swift — change constants to match actual file:
private let catalogFileName = "courses_v1"
private let resourceSubdirectory = "Courses.bundle"
```

Or alternatively — if the Bundle.module resource path structure is different from the `Resources/` folder path — verify the actual bundle path by logging `Bundle.module.url(forResource: "courses_v1", withExtension: "json")` on a real build.

**Verification test:**
```swift
// Add temporary debug in CourseDatabase.init():
let url = Bundle.module.url(forResource: "courses_v1", withExtension: "json",
                             subdirectory: "Courses.bundle")
print("Course bundle URL: \(String(describing: url))")  // must not be nil
```

**Files to modify:**
- `V7Career/Sources/V7Career/Services/CourseProviderClient.swift` — fix `catalogFileName` and `resourceSubdirectory` constants

**Estimated effort:** 30 minutes (read file, fix constants, verify bundle loads).

---

## Fix 2: Register Affiliate Programs (External — No Code)

### Coursera Affiliate (Rakuten LinkShare)

1. Go to `rakutenadvertising.com` or directly `coursera.org/affiliate`
2. Apply to the Coursera affiliate program via Rakuten LinkShare
3. Approval takes 3–7 business days
4. Once approved, get your Rakuten publisher ID (format: numeric)
5. Replace in code:
   ```swift
   // AffiliateTracker.swift / AffiliateURLBuilder:
   static let courseraAffiliateID = "YOUR_COURSERA_AFFILIATE_ID"
   // Replace with: "1234567"  (your Rakuten publisher ID)
   ```

### Udemy Affiliate (Direct)

1. Go to `udemy.com/affiliate`
2. Apply directly — approval typically same-day to 48 hours
3. Get your referral code (format: alphanumeric string)
4. Replace in code:
   ```swift
   static let udemyReferralCode = "YOUR_UDEMY_AFFILIATE_ID"
   // Replace with: "YOURCODE"
   ```

### edX (No Action)

edX affiliate program closed after 2U acquisition. The commission rate is already set to `0.0` in `AffiliateTracker`. edX courses can still be displayed (good content) but will not earn affiliate revenue. LinkedIn Learning affiliate via ShareASale is a future option.

### Code Changes After Credentials

```swift
// AffiliateURLBuilder.AffiliateCredentials — update struct:
static let courseraAffiliateID: String = "<REAL_RAKUTEN_ID>"
static let udemyReferralCode: String = "<REAL_UDEMY_CODE>"
```

**Files to modify:**
- `V7Career/Sources/V7Career/Services/AffiliateTracker.swift` — update credential constants (find exact property names by reading the file)

**Estimated effort:** Credential registration is external (3–7 days for Coursera, 1–2 days for Udemy). Code change after receipt is 15 minutes.

---

## Fix 3: Create CourseCardView

### Current State

No view exists to display course recommendations. The ManifestTabView `.courses` destination needs a card-style view for each recommended course.

### Design Spec

CourseCardView should display:
- Course title
- Provider (Coursera / Udemy / edX) with provider brand color
- Rating (e.g., ★ 4.8)
- Price (.free / .paid(amount:) / .subscription)
- "Skill Match: 87%" badge (from `skillMatchPercentage`)
- CTA button: "View Course" → opens affiliate URL in Safari

**Visual design alignment:**
- Corner radius: 12pt (between job card 24pt and ad card 16pt)
- Provider accent color: use `CourseProvider.brandColor` (already defined in enum)
- Skill Match badge: use same SacredUI teal as job card score badge

```swift
// New file: V7UI/Sources/V7UI/Views/CourseCardView.swift

struct CourseCardView: View {
    let course: RecommendedCourse
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Provider header
            HStack {
                Image(systemName: course.provider.logoSystemImage)
                    .foregroundStyle(Color(course.provider.brandColor))
                Text(course.provider.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(course.skillMatchPercentage))% match")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SacredUI.Colors.teal)
            }
            
            Text(course.title)
                .font(.body.weight(.semibold))
                .lineLimit(2)
            
            HStack {
                // Rating
                Label("\(String(format: "%.1f", course.rating))", systemImage: "star.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
                
                // Price
                Text(course.price.displayString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button("View Course") { onTap() }
                    .buttonStyle(.borderedProminent)
                    .tint(SacredUI.Colors.teal)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
```

**Accessibility requirements (accessibility-compliance-enforcer):**
- VoiceOver: `accessibilityLabel("\(course.title), \(course.provider.rawValue), \(Int(course.skillMatchPercentage)) percent match")`
- CTA button minimum 44pt tap target
- Provider brand colors must meet 4.5:1 contrast on background

**Files to create:**
- `V7UI/Sources/V7UI/Views/CourseCardView.swift`

**Estimated effort:** 3–4 hours. The data model (`RecommendedCourse`) is already defined — this is pure UI.

---

## Fix 4: Wire ManifestTabView .courses Destination

### Current State

```swift
// ManifestTabView.swift — .courses destination renders empty or placeholder
// CourseRecommendationEngine is never called
```

### Target State

```swift
// ManifestTabView.swift — .courses destination:
CoursesView(engine: CourseRecommendationEngine.shared)
```

### CoursesView Implementation

```swift
// New file: V7UI/Sources/V7UI/Views/CoursesView.swift

struct CoursesView: View {
    let engine: CourseRecommendationEngine
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [])
    private var profiles: FetchedResults<UserProfile>
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \InferredManifestProfile.updatedAt, ascending: false)])
    private var inferredProfiles: FetchedResults<InferredManifestProfile>
    
    @State private var courses: [RecommendedCourse] = []
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Finding courses for your skill gaps...")
            } else if courses.isEmpty {
                ContentUnavailableView(
                    "No courses yet",
                    systemImage: "graduationcap",
                    description: Text("Swipe on a few jobs to help us understand your goals.")
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(courses) { course in
                            CourseCardView(course: course) {
                                openCourseWithTracking(course)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Skill-Building")
        .task { await loadCourses() }
    }
    
    private func loadCourses() async {
        guard let profile = profiles.first,
              let inferred = inferredProfiles.first else { return }
        
        isLoading = true
        courses = (try? await engine.getRecommendations(
            for: profile,
            targetRole: inferred.targetRole ?? "",
            limit: 10
        )) ?? []
        isLoading = false
    }
    
    private func openCourseWithTracking(_ course: RecommendedCourse) {
        AffiliateTracker.shared.recordClick(course: course, context: viewContext)
        if let url = URL(string: course.affiliateURL) {
            UIApplication.shared.open(url)
        }
    }
}
```

**Files to create:**
- `V7UI/Sources/V7UI/Views/CoursesView.swift`

**Files to modify:**
- `ManifestTabView.swift` — replace `.courses` destination body with `CoursesView(engine: CourseRecommendationEngine.shared)`

**Estimated effort:** 1 day (view creation + wiring + test with real InferredManifestProfile data).

---

## Fix 5: Wire AffiliateTracker — Core Data Write

### Current State

`AffiliateTracker.recordClick()` exists and writes to `AffiliateClick` Core Data entity — but it's never called. The `AffiliateClick` entity is fully defined with validation, default values, and relationship rules.

### Fix

The `openCourseWithTracking()` method in Fix 4 above already includes this call:

```swift
AffiliateTracker.shared.recordClick(course: course, context: viewContext)
```

**Read `AffiliateTracker.swift` before calling** to confirm the exact method signature. The schematic shows it uses a `context: NSManagedObjectContext` parameter for Core Data writes — verify this matches.

The `estimatedCommission` field should be populated at click time:
```swift
// AffiliateTracker.recordClick — ensure this calculates correctly:
let price = course.price.amountUSD ?? 49.0  // fallback to avg course price
let commission = price × affiliateRate(for: course.provider)
// e.g., Coursera: 49.0 × 0.35 = $17.15
```

**Files to modify:**
- `AffiliateTracker.swift` — verify/confirm `recordClick()` signature matches call site

**Estimated effort:** 1 hour (read + wire + verify Core Data writes).

---

## Fix 6: edX API Credentials (Optional — Phase 2)

The `CourseProviderClient.EdXAPIClient` uses OAuth 2.0 with placeholder `clientID`/`clientSecret`. The static JSON database (Fix 1) provides sufficient courses for launch. edX live API is Tier 2 — adds freshness but not required.

**Defer this to Phase 2.** The `CircuitBreaker` will protect against the dead edX endpoint (5 failures → OPEN state) so it won't crash or slow down the app if left unconfigured.

---

## Implementation Sequence

```
Day 1 (External — no code):
  Apply for Coursera affiliate (Rakuten LinkShare)
  Apply for Udemy affiliate (direct)
  Note: 3–7 day approval wait — start code work in parallel

Day 1 (Code):
  Fix 1 — Filename mismatch
  Read CourseProviderClient.swift fully
  Fix catalogFileName + resourceSubdirectory constants
  Verify courses_v1.json loads: log URL, check entry count
  
Day 2:
  Fix 3 — Create CourseCardView.swift
  Build from RecommendedCourse struct
  Add VoiceOver labels (accessibility-compliance-enforcer)
  Preview in Xcode canvas with sample data
  
Day 3:
  Fix 4 — Create CoursesView.swift
  Wire to ManifestTabView .courses destination
  Test with real InferredManifestProfile from prior swipes
  Verify empty state (no InferredManifestProfile yet)
  
Day 3–4:
  Fix 5 — AffiliateTracker wire
  Read AffiliateTracker.swift for exact method signature
  Wire recordClick() in openCourseWithTracking()
  Test: tap a course → verify AffiliateClick entity written to Core Data
  
Day 5 (After affiliate approval):
  Fix 2 — Replace affiliate credential placeholders with real IDs
  Test affiliate URL format: verify Coursera Rakuten link structure
  Test affiliate URL format: verify Udemy referralCode appended correctly
```

---

## Files to Create

| File | Package | Purpose |
|---|---|---|
| `CourseCardView.swift` | V7UI/Sources/V7UI/Views/ | Individual course recommendation card |
| `CoursesView.swift` | V7UI/Sources/V7UI/Views/ | Course list, lazy load, empty state |

## Files to Modify

| File | Change |
|---|---|
| `CourseProviderClient.swift` | Fix `catalogFileName` and `resourceSubdirectory` constants |
| `AffiliateTracker.swift` | Replace Coursera + Udemy credential placeholders |
| `ManifestTabView.swift` | Replace `.courses` destination body with `CoursesView` |

---

## Success Criteria

| Metric | Before | After |
|---|---|---|
| CourseRecommendationEngine ever called | Never | ✅ On every ManifestTab .courses open |
| courses_v1.json loads | fatalError crash | ✅ Loads 4.1MB dataset |
| Course cards display | Empty screen | ✅ Top 10 skill-matched courses |
| Affiliate URL format | Placeholder | ✅ Real Rakuten/Udemy format |
| AffiliateClick written to Core Data | Never | ✅ On every course tap |
| Estimated commission tracked | $0 | ✅ Calculated at click time |
| edX live API | Placeholder creds | Phase 2 (static JSON sufficient for launch) |
| Affiliate revenue | $0 | Target: $50–90/day at scale (1% conversion) |
