# User Flow Build Plan
**Manifest & Match V8 | Created: 2026-05-14**
**Based on:** SCHEMATIC_04_user_flow.md

---

## What We're Solving

SCHEMATIC_04 identified five categories of user flow failures:

1. **8 stub settings destinations in ProfileScreen** — Every settings navigation link opens a `Text()` placeholder. Change Password, Privacy Settings, Data Management, Help Center, Contact Support, FAQ, Terms of Service, Privacy Policy. Users who tap these hit a blank screen with no way back except the back button.

2. **Apply Now → CRM disconnect** — The "Apply Now" button opens `job.url` in Safari and records the action as `"save"` in Thompson. It does NOT write an `"applied"` status to JobInteraction. ApplicationTracker and HistoryScreen never show this job as applied. The application CRM is permanently broken for every job the user applies to via the in-app button.

3. **Courses API not connected** — ManifestTabView's `.courses` destination renders a list UI but no real courses load. The course provider APIs are not connected. This was acknowledged in the schematic as "Phase 2 — course API not yet connected."

4. **First Jobs Preview — mock scores** — Step 7 of onboarding shows mock Thompson scores (87%, 72%, 91%) on demo cards. These are hardcoded numbers that don't reflect how the user's actual profile would score those jobs.

5. **Amber/Teal visual feedback** — Job cards don't visually distinguish whether a job is being surfaced because of Amber (current role match) or Teal (discovery/growth) weighting. The slider exists but there's no per-card color or signal to reinforce what mode the user is in.

---

## What Does NOT Change

- Onboarding steps 0–7 flow and validation logic (working correctly)
- All three swipe directions and their Thompson update logic
- QuestionCardView answer handling
- MainTabView tab architecture (4 tabs)
- DeckScreen's core job display loop
- Cover letter generator integration
- ExplainFitSheet ("Why?" button)

---

## Fix 1: Apply Now → CRM "Applied" Status

### Priority: Highest. This breaks the core CRM loop.

### Current State

```swift
// DeckScreen.swift — "Apply Now" button handler
// Opens URL in Safari + records "save" action
UIApplication.shared.open(job.url)
// Creates JobInteraction with action = "save"
// Does NOT create JobInteraction with action = "applied"
```

HistoryScreen filters on `action == "applied"` to show applied jobs. Zero jobs ever reach this state via Apply Now.

### Fix

When the user taps "Apply Now":
1. Open `job.url` in Safari (keep this behavior)
2. Write a `JobInteraction` with `action = "applied"` (add this)
3. Also write the Thompson "save" update (80% success) (keep this behavior)

The JobInteraction write already has all required fields available at the call site (jobId, jobTitle, jobCompany, thompsonScore, amberTealPosition). Adding the "applied" write is a one-line addition after the URL open.

```swift
// DeckScreen — after UIApplication.shared.open(job.url)
let appliedInteraction = JobInteraction(context: viewContext)
appliedInteraction.id = UUID()
appliedInteraction.timestamp = Date()
appliedInteraction.jobID = job.id
appliedInteraction.jobTitle = job.title
appliedInteraction.jobCompany = job.company
appliedInteraction.action = "applied"
appliedInteraction.thompsonScore = currentThompsonScore
appliedInteraction.amberTealPosition = profileBlend
appliedInteraction.actionWeight = 2.0  // same as interested
try? viewContext.save()
```

**Consideration:** Should "Apply Now" trigger a Thompson `α += 1` (treated as "interested") in addition to the save 80% update? Currently it only does the 80% save. An applied job is the strongest positive signal — recommend treating as full success (`α += 1`) regardless of the 80% save roll.

**Files to modify:**
- `DeckScreen.swift` — find "Apply Now" handler, add JobInteraction "applied" write + Thompson `α += 1`

**Estimated effort:** 2 hours. Straightforward write addition.

---

## Fix 2: ProfileScreen Settings Stubs

### Current State (ProfileScreen.swift lines 400–450)

```swift
NavigationLink("Change Password") { Text("Change Password") }
NavigationLink("Privacy Settings") { Text("Privacy Settings") }
NavigationLink("Data Management") { Text("Data Management") }
NavigationLink("Help Center") { Text("Help Center") }
NavigationLink("Contact Support") { Text("Contact Support") }
NavigationLink("FAQ") { Text("FAQ") }
NavigationLink("Terms of Service") { Text("Terms of Service") }
NavigationLink("Privacy Policy") { Text("Privacy Policy") }
```

### Fix Priority by Impact

| Setting | V8 Build Priority | Minimum Viable Implementation |
|---|---|---|
| **Change Password** | High — account security | Not applicable yet: no auth system. Replace with "Managed via Apple ID" message. |
| **Data Management** | High — users need data export/delete (regulatory) | Implement: export profile as JSON, delete all local data option |
| **Privacy Policy** | High — legal requirement | Implement: webview or embedded static text |
| **Terms of Service** | High — legal requirement | Implement: webview or embedded static text |
| **Help Center** | Medium | Implement: embedded FAQ content (static) |
| **FAQ** | Medium | Consolidate with Help Center (one destination) |
| **Contact Support** | Low | Implement: `mailto:support@...` link |
| **Privacy Settings** | Low — no tracking yet | Implement: empty state with "no data collected outside this device" message |

### Implementation Approach

**Phase 1 (V8 scaffold — must have):**
- Terms of Service: embed static text or `WKWebView` pointing to a URL
- Privacy Policy: same pattern as ToS
- Data Management: two actions — "Export Profile Data" (encodes UserProfile to JSON) + "Delete All Data" (destructive, confirmation required, clears all Core Data)
- Contact Support: `mailto:` URL open (same pattern as Apply Now's Safari open)

**Phase 2:**
- Help Center / FAQ: embedded scrollable content
- Change Password: defer until authentication system is designed
- Privacy Settings: defer until any analytics/tracking is added

**Data Management — critical flows:**

```
Export Profile Data:
  1. Fetch V7Data.UserProfile + all child entities from Core Data
  2. Encode to JSON using Codable bridge
  3. Present ShareSheet with the JSON file
  
Delete All Data:
  1. Show confirmation alert: "This will delete your profile, swipe history, and all learning data. This cannot be undone."
  2. On confirm: deleteAllObjects() for all 21 Core Data entities
  3. Reset UserDefaults keys (hasCompletedOnboarding, selectedTab, etc.)
  4. Return to onboarding flow
```

**Files to modify:**
- `ProfileScreen.swift` — replace stub NavigationLink destinations with real views
- New files (in V7UI or ManifestAndMatchV7Feature): `PrivacyPolicyView.swift`, `TermsOfServiceView.swift`, `DataManagementView.swift`

**Estimated effort:** 3–4 days for Phase 1 (legal + data management).

---

## Fix 3: Amber/Teal Card Visual Feedback

### Current State

Job cards render identically regardless of the profileBlend slider position. A user at full Teal (exploring new career paths) sees the same card appearance as a user at full Amber (matching their current role). The slider has no visual connection to the deck.

### Fix

Add a subtle visual indicator on each job card that reflects whether the card's appearance in the deck is driven more by Amber (professional match) or Teal (discovery) components.

**Two options:**

**Option A: Accent bar color on card edge**
Each card gets a thin (3px) left-edge accent bar. Color interpolates between Amber hue (`0.125` per SacredUI.Preferences) and Teal hue (`0.483`) based on `amberTealPosition` at the time the card was scored.

```swift
// JobCardView — left edge accent
Rectangle()
    .fill(Color(hue: lerp(0.125, 0.483, profileBlend), saturation: 0.7, brightness: 0.9))
    .frame(width: 3)
    .frame(maxHeight: .infinity)
```

This respects SacredUI constants (uses the stored hue values from Preferences entity).

**Option B: Match percentage label color**
The fit score percentage (`87%`) displayed on the card changes color from amber to teal based on profileBlend. No structural change to the card layout.

**Recommendation: Option B.** Lower visual weight, no layout impact, directly connects the score number to the mode it was produced in.

```swift
// JobCardView — score label
Text("\(Int(score.combinedScore * 100))%")
    .foregroundStyle(
        Color(hue: lerp(SacredUI.Colors.amberHue, SacredUI.Colors.tealHue, profileBlend),
              saturation: 0.8,
              brightness: 0.85)
    )
```

**Files to modify:**
- `JobCardView` (inside `DeckScreen.swift` or extracted file per PACKAGE_BUILD_PLAN) — update score label color

**Estimated effort:** 2 hours. One `.foregroundStyle()` change with lerp.

---

## Fix 4: First Jobs Preview — Use Real Scoring

### Current State

Onboarding Step 7 shows 3 demo cards with hardcoded scores: `87%`, `72%`, `91%`. These are not derived from the user's profile (which was just completed in Steps 4–6).

### Fix

After the user completes Steps 4–6 (profile created), optionally run a live JSearch query for 3 jobs matching their desired role, score them with OptimizedThompsonEngine, and display those cards in the preview step instead of mock data.

**Risk:** JSearch API call adds latency to the onboarding completion moment. If JSearch is slow or unavailable, the user waits before seeing Step 7.

**Mitigation:** Keep mock cards as fallback. If JSearch returns results within 2 seconds, show real cards. If not, show mock cards. The real cards, if shown, use the actual combinedScore.

**Implementation:**

```swift
// FirstJobsPreviewStepView — on appear
Task {
    if let jobs = try? await jobDiscoveryCoordinator.fetchJobsForPreview(limit: 3) {
        previewJobs = jobs  // real JSearch results + Thompson scores
    }
    // else: use existing mock cards
}
```

**Files to modify:**
- `FirstJobsPreviewStepView.swift` — add async JSearch fetch with timeout fallback

**Estimated effort:** 1 day. The JSearch + scoring path already exists — this is wiring it into the preview view with a timeout guard.

---

## Fix 5: Courses Tab — Connect or Replace

### Current State

ManifestTabView's `.courses` destination shows a list UI but no courses load. "Phase 2 — course API not yet connected."

### Decision for V8

**Do not connect a real courses API in V8 Phase 1.** Course APIs (Coursera, LinkedIn Learning, Udemy) require:
- OAuth agreements (Coursera Partner API requires application)
- Revenue share structures (affiliate links need separate integration)
- Content freshness management

**Instead for V8 Phase 1:** Replace the empty courses list with a curated skill-gap driven recommendation:
1. Compute skill gaps from `InferredManifestProfile` (target role) vs `UserProfile` (current skills) — this logic already exists in `ManifestTabView.skillsGap` destination
2. For each top skill gap, display a card: skill name + a "Search [skill] courses" button that opens a pre-formatted Udemy or Google search URL

This gives users actionable guidance without requiring a partner API agreement.

**Files to modify:**
- The courses destination view in ManifestTabView — replace empty list with skill-gap cards

**Estimated effort:** 1 day (use existing skillsGap logic, add search URL launch).

---

## Gaps NOT Fixed in This Plan

| Gap | Reason Deferred |
|---|---|
| Change Password | No authentication system exists — no V8 Phase 1 scope |
| Privacy Settings | No analytics/tracking exists — placeholder acceptable until tracking added |
| setCareerGoal destination implementation depth | Requires reading the actual current implementation before planning |

---

## Implementation Sequence

```
Day 1:   Fix 1 — Apply Now CRM disconnect
         Highest impact, lowest effort. Done in < 2 hours.
         Test: Tap Apply Now → open Safari → kill app → open History tab → job appears as "applied"

Day 2:   Fix 3 — Amber/Teal card color
         Simple SwiftUI change. Verify hue lerp is correct at t=0 and t=1.

Day 3–4: Fix 2 — ProfileScreen legal stubs (Privacy Policy + Terms of Service + Data Management)
         Implement the 4 high-priority destinations first.

Day 5:   Fix 4 — First Jobs Preview real scoring
         Add async JSearch fetch with 2s timeout fallback

Week 2:
Day 1:   Fix 5 — Courses tab placeholder → skill-gap search cards
Day 2:   Fix 2 continued — Help Center, FAQ, Contact Support
Day 3:   End-to-end user flow test (full onboarding → deck → apply → history)
```

---

## Files to Create

| File | Location | Purpose |
|---|---|---|
| `PrivacyPolicyView.swift` | V7UI or Feature package | Privacy policy content/webview |
| `TermsOfServiceView.swift` | V7UI or Feature package | Terms of service content/webview |
| `DataManagementView.swift` | V7UI or Feature package | Export + delete data actions |

## Files to Modify

| File | Change |
|---|---|
| `DeckScreen.swift` | Apply Now handler — add "applied" JobInteraction write |
| `ProfileScreen.swift` | Replace 8 stub NavigationLink destinations |
| `JobCardView` (in DeckScreen or extracted) | Score label color lerp |
| `FirstJobsPreviewStepView.swift` | Add async JSearch fetch with fallback |
| Courses destination view | Replace empty list with skill-gap search cards |

---

## Success Criteria

| User Action | Before | After |
|---|---|---|
| Tap Apply Now | Job appears in History as "save" | Job appears in History as "applied" |
| Tap settings link in Profile | Blank Text() screen | Real content or clear placeholder |
| Look at job card at t=1 (Teal) | Same appearance as t=0 | Score label in teal hue |
| Complete onboarding Step 7 | See 87%, 72%, 91% hardcoded | See real scored jobs (or fallback mocks if API slow) |
| Tap Courses in Manifest tab | Empty list | Skill gap search suggestions |
| Tap "Delete All Data" | No option exists | Confirmation → Core Data cleared → Onboarding restarts |
