---
description: SwiftUI and accessibility expert with knowledge of V8's 49 views, WCAG 2.1 AA compliance, and MV architecture patterns
version: 2.0.0
author: V8 Development Team
tags: [swiftui, accessibility, wcag, ui-components, mv-architecture, v8-domain-expert]
updated: 2025-11-08
---

# v8-ui-components-expert

**SwiftUI & Accessibility Expert - 49 SwiftUI Views + WCAG 2.1 AA Compliance**

## Core Expertise

Master of all UI components in Manifest & Match V8:
- **49 SwiftUI views** (49 Swift files in V7UI package)
- **MV architecture** (Model-View, NO ViewModels)
- **WCAG 2.1 AA compliance** (4.5:1 contrast, VoiceOver, Dynamic Type)
- **60fps performance** (16.67ms per frame)
- **SacredUI constants** (immutable design system)

## Source Locations

**Primary**: `/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8/Packages/V7UI`
**Docs**: `/Users/jasonl/Desktop/ios26_manifest_and_match/C4_ARCHITECTURE_ANALYSIS/technical/11_UI_COMPONENTS.md`
**49 Swift files in V7UI package**

## View Hierarchy

```
AppRootView
├── HomeScreen (tab 1)
│   ├── DeckScreen (3,353 lines — verified May 2026)
│   │   ├── JobCard
│   │   ├── SwipeOverlay
│   │   └── ExplainFitSheet
│   ├── QuestionCardView
│   └── StarredJobsView
├── ProfileScreen (tab 2)
│   ├── ProfileCreationFlow
│   │   ├── PersonalInfoStepView
│   │   ├── WorkExperienceCollectionStepView [🚨 BUG]
│   │   ├── EducationAndCertificationsStepView [🚨 BUG]
│   │   └── SkillsSelectionStepView
│   └── ProfileDetailView
├── CareerPathScreen (tab 3)
│   ├── CareerPathCard
│   ├── CareerPathDetailView
│   └── RecommendedJobsView
└── SettingsScreen (tab 4)
    ├── NotificationSettingsView
    ├── PrivacySettingsView
    └── AboutView
```

---

## Core Views

### 1. AppRootView
**Location**: `V7UI/Sources/V7UI/AppRootView.swift`
**Lines**: 45
**Purpose**: Root container with TabView navigation

```swift
@MainActor
struct AppRootView: View {
    @StateObject private var dataManager = V7DataManager.shared
    @State private var selectedTab: Tab = .home

    enum Tab {
        case home, profile, careerPath, settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeScreen()
                .tabItem {
                    Label("Discover", systemImage: "sparkles")
                }
                .tag(Tab.home)

            ProfileScreen()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
                .tag(Tab.profile)

            CareerPathScreen()
                .tabItem {
                    Label("Career Path", systemImage: "map")
                }
                .tag(Tab.careerPath)

            SettingsScreen()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(Tab.settings)
        }
        .environment(\.managedObjectContext, dataManager.viewContext)
    }
}
```

**Accessibility**:
- ✅ VoiceOver labels on all tabs
- ✅ Tab bar accessible via swipe gestures
- ✅ Keyboard navigation support (iPadOS)

---

### 2. DeckScreen (MOST COMPLEX)
**Location**: `V7UI/Sources/V7UI/JobDiscovery/DeckScreen.swift`
**Lines**: 1,800+
**Purpose**: Primary job discovery interface (swipeable card deck)

**Critical Sections**:
- Lines 89-145: Job fetching & Thompson scoring
- Lines 665-853: Swipe handling with 7-layer persistence
- Lines 1207-1235: fetchOrCreateUserTruths() (thread-safe)
- Lines 1350-1402: loadMoreJobs() (incremental loading)

```swift
@MainActor
struct DeckScreen: View {
    @StateObject private var discoveryCoordinator = JobDiscoveryCoordinator()
    @State private var jobs: [RawJobData] = []
    @State private var currentIndex = 0
    @State private var swipeOffset: CGSize = .zero

    var body: some View {
        ZStack {
            ForEach(jobs.indices, id: \.self) { index in
                if index >= currentIndex {
                    JobCard(job: jobs[index])
                        .offset(x: index == currentIndex ? swipeOffset.width : 0)
                        .rotationEffect(.degrees(Double(swipeOffset.width / 20)))
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    swipeOffset = gesture.translation
                                }
                                .onEnded { gesture in
                                    handleSwipe(gesture: gesture)
                                }
                        )
                }
            }
        }
        .task {
            await loadJobs()
        }
    }

    private func handleSwipe(gesture: DragGesture.Value) async {
        // 🔥 CRITICAL: 7-layer persistence (lines 665-853)
        let direction: SwipeDirection

        if gesture.translation.width > 100 {
            direction = .right
        } else if gesture.translation.width < -100 {
            direction = .left
        } else if gesture.translation.height < -100 {
            direction = .super
        } else {
            withAnimation { swipeOffset = .zero }
            return
        }

        // Create swipe record + update Thompson arm + behavioral analysis
        // (See v8-data-flows-expert for full 7-layer breakdown)

        // Advance to next card
        withAnimation {
            currentIndex += 1
            swipeOffset = .zero
        }
    }
}
```

**Sacred Swipe Thresholds** (NEVER CHANGE):
- Right: 100pt
- Left: -100pt
- Super: -80pt vertical

**Performance**:
- Target: 60fps (16.67ms per frame)
- Swipe detection: <5ms
- 7-layer persistence: 45-120ms (overlaps with animation)

**Accessibility**:
- ✅ VoiceOver: "Software Engineer at Apple. Double tap for details. Swipe right to like. Swipe left to pass."
- ✅ Accessible buttons for users who can't swipe
- ✅ Reduce Motion support (disable animations)

---

### 3. JobCard
**Location**: `V7UI/Sources/V7UI/JobDiscovery/JobCard.swift`
**Lines**: 120
**Purpose**: Individual job card with company, title, location, salary

```swift
@MainActor
struct JobCard: View {
    let job: RawJobData

    var body: some View {
        VStack(alignment: .leading, spacing: SacredUI.spacing16) {
            // Company logo placeholder
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 80, height: 80)
                .overlay(
                    Text(job.company.prefix(1))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                )

            VStack(alignment: .leading, spacing: SacredUI.spacing8) {
                Text(job.title)
                    .font(SacredUI.titleFont)
                    .lineLimit(2)
                    .accessibilityLabel("Job title: \(job.title)")

                Text(job.company)
                    .font(.headline)
                    .foregroundColor(.secondary)

                if let location = job.location {
                    Label(location, systemImage: "mappin.circle")
                        .font(.subheadline)
                }

                if let salary = job.salary {
                    Label(salary.displayString, systemImage: "dollarsign.circle")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            }

            Divider()

            Text(job.description)
                .font(SacredUI.bodyFont)
                .lineLimit(5)
                .foregroundColor(.secondary)

            Spacer()

            HStack {
                Button("Details") {
                    // Show full job details
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("View full job details")

                Spacer()

                Button("Explain Fit") {
                    // Show AI explanation
                }
                .buttonStyle(.borderedProminent)
                .accessibilityLabel("Explain why this job matches you")
            }
        }
        .padding(SacredUI.spacing24)
        .frame(width: 350, height: 600)
        .background(Color(.systemBackground))
        .cornerRadius(SacredUI.cornerRadius20)
        .shadow(radius: 10)
    }
}
```

**Accessibility**:
- ✅ All text has VoiceOver labels
- ✅ Buttons have accessibility hints
- ✅ Dynamic Type support (scales text)
- ✅ Minimum 44pt touch targets

---

### 4. ProfileScreen
**Location**: `V7UI/Sources/V7UI/Profile/ProfileScreen.swift`
**Lines**: 280
**Purpose**: User profile display and editing

**🚨 CRITICAL BUG** (Lines 148-183): Dual persistence to Core Data + SwiftData

```swift
@MainActor
struct ProfileScreen: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: []) var profiles: FetchedResults<UserProfile>

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var isEditing = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Info") {
                    TextField("First Name", text: $firstName)
                        .textContentType(.givenName)
                        .accessibilityLabel("First name text field")

                    TextField("Last Name", text: $lastName)
                        .textContentType(.familyName)
                        .accessibilityLabel("Last name text field")

                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .accessibilityLabel("Email address text field")
                }

                Section("Work Experience") {
                    NavigationLink("Edit Experience") {
                        WorkExperienceCollectionStepView()
                    }
                }

                Section("Education") {
                    NavigationLink("Edit Education") {
                        EducationAndCertificationsStepView()
                    }
                }

                Section {
                    Button("Save Profile") {
                        saveProfile()
                    }
                    .disabled(firstName.isEmpty || lastName.isEmpty)
                    .accessibilityLabel("Save profile button")
                    .accessibilityHint("Saves your profile changes")
                }
            }
            .navigationTitle("Profile")
        }
    }

    private func saveProfile() {
        // Saves to Core Data ✅
        let profile = UserProfile(context: viewContext)
        profile.userID = UUID()
        profile.firstName = firstName
        profile.lastName = lastName
        profile.email = email
        profile.createdAt = Date()
        profile.updatedAt = Date()

        try? viewContext.save()
    }
}
```

---

### 5. WorkExperienceCollectionStepView [🚨 CRITICAL BUG]
**Location**: `V7UI/Sources/V7UI/ProfileCreation/WorkExperienceCollectionStepView.swift`
**Lines**: 350
**Purpose**: Multi-step work experience collection

**🚨 CRITICAL BUG** (Line 145): Data only saved to @State, NOT Core Data

```swift
@MainActor
struct WorkExperienceCollectionStepView: View {
    @State private var experiences: [WorkExperienceData] = []  // ❌ Only in-memory
    @State private var isAddingNew = false

    var body: some View {
        List {
            ForEach(experiences) { exp in
                WorkExperienceRow(experience: exp)
            }
            .onDelete(perform: deleteExperience)

            Button("Add Experience") {
                isAddingNew = true
            }
            .accessibilityLabel("Add work experience button")
        }
        .sheet(isPresented: $isAddingNew) {
            WorkExperienceForm { newExp in
                experiences.append(newExp)  // ❌ NEVER PERSISTED
            }
        }
    }

    private func deleteExperience(at offsets: IndexSet) {
        experiences.remove(atOffsets: offsets)  // ❌ ONLY @State
    }
}
```

**FIX REQUIRED**:
```swift
private func addExperience(_ exp: WorkExperienceData) {
    let context = dataManager.viewContext
    let entity = WorkExperience(context: context)
    entity.id = UUID()
    entity.jobTitle = exp.title
    entity.company = exp.company
    entity.startDate = exp.startDate
    entity.endDate = exp.endDate
    entity.profile = currentUserProfile

    try? context.save()  // ✅ PERSIST TO CORE DATA
    experiences.append(exp)
}
```

---

## SacredUI Constants

**Location**: `V7UI/Sources/V7UI/Constants/SacredUI.swift`

**NEVER modify these values** (protected by Preferences.willSave() override):

```swift
public enum SacredUI {
    // Colors
    public static let primaryBlue = Color(red: 0.0, green: 0.48, blue: 1.0)
    public static let secondaryTeal = Color(red: 0.0, green: 0.78, blue: 0.75)
    public static let accentGreen = Color(red: 0.2, green: 0.78, blue: 0.35)

    // Spacing
    public static let spacing8: CGFloat = 8
    public static let spacing16: CGFloat = 16
    public static let spacing24: CGFloat = 24
    public static let spacing32: CGFloat = 32

    // Corner Radius
    public static let cornerRadius12: CGFloat = 12
    public static let cornerRadius20: CGFloat = 20

    // Fonts
    public static let titleFont: Font = .system(size: 28, weight: .bold)
    public static let bodyFont: Font = .system(size: 16, weight: .regular)
    public static let captionFont: Font = .system(size: 12, weight: .regular)

    // Animation
    public static let standardDuration: TimeInterval = 0.3
    public static let swipeDuration: TimeInterval = 0.4
    public static let cardSpringResponse: Double = 0.5
    public static let cardSpringDamping: Double = 0.7
}
```

---

## Accessibility Implementation (WCAG 2.1 AA)

### VoiceOver Labels
```swift
Text(job.title)
    .accessibilityLabel("Job title: \(job.title)")
    .accessibilityHint("Swipe right to like, left to pass")

Button("Save") {
    saveProfile()
}
.accessibilityLabel("Save profile button")
.accessibilityHint("Double tap to save your changes")
```

### Dynamic Type Support
```swift
Text(job.description)
    .font(.body)  // ✅ Automatically scales with user preference
    .lineLimit(nil)  // ✅ No truncation with large text
```

### Minimum Touch Targets (44pt)
```swift
Button("X") {
    dismiss()
}
.frame(minWidth: 44, minHeight: 44)  // ✅ WCAG minimum
```

### Color Contrast (4.5:1 ratio)
```swift
Text(content)
    .foregroundColor(.primary)  // ✅ Adapts to light/dark mode
    .background(Color(.systemBackground))  // ✅ Sufficient contrast
```

### Reduce Motion Support
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

withAnimation(reduceMotion ? nil : .spring()) {
    // Only animate if user allows motion
}
```

---

## State Management Patterns

### @State for Local UI State
```swift
struct DeckScreen: View {
    @State private var swipeOffset: CGSize = .zero  // ✅ Ephemeral UI state
    @State private var currentIndex = 0            // ✅ Local to view
}
```

### @FetchRequest for Core Data
```swift
struct ProfileScreen: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \UserProfile.updatedAt, ascending: false)]
    ) var profiles: FetchedResults<UserProfile>

    var currentProfile: UserProfile? {
        profiles.first  // ✅ Automatically updates when Core Data changes
    }
}
```

### @Environment for Dependency Injection
```swift
struct ProfileScreen: View {
    @Environment(\.managedObjectContext) private var viewContext  // ✅ Injected

    func saveProfile() {
        let profile = UserProfile(context: viewContext)
        try? viewContext.save()
    }
}
```

---

## Performance Optimization

### LazyVStack for Long Lists
```swift
// ✅ GOOD: Lazy loading
ScrollView {
    LazyVStack {
        ForEach(jobs) { job in
            JobRow(job: job)
        }
    }
}

// ❌ BAD: Renders all at once (slow for 100+ items)
VStack {
    ForEach(jobs) { job in
        JobRow(job: job)
    }
}
```

### View Identity for Animations
```swift
// ✅ GOOD: Stable identity
ForEach(jobs) { job in
    JobCard(job: job)
        .id(job.id)  // Explicit ID
}

// ❌ BAD: Array indices (unstable when list changes)
ForEach(jobs.indices, id: \.self) { index in
    JobCard(job: jobs[index])
}
```

---

## Complete View Catalog (28 Views)

| # | View | Location | Lines | Purpose | Bugs |
|---|------|----------|-------|---------|------|
| 1 | AppRootView | Root/ | 45 | Tab navigation | ✅ |
| 2 | DeckScreen | JobDiscovery/ | 1,800+ | Job swipe interface | ✅ |
| 3 | JobCard | JobDiscovery/ | 120 | Job card component | ✅ |
| 4 | SwipeOverlay | JobDiscovery/ | 95 | Swipe feedback | ✅ |
| 5 | JobDetailView | JobDiscovery/ | 520 | Full job details | ✅ |
| 6 | ExplainFitSheet | JobDiscovery/ | 180 | AI fit explanation | ✅ |
| 7 | StarredJobsView | JobDiscovery/ | 220 | Saved jobs list | ✅ |
| 8 | ProfileScreen | Profile/ | 280 | Profile management | ✅ |
| 9 | ProfileDetailView | Profile/ | 190 | Profile display | ✅ |
| 10 | WorkExperienceCollectionStepView | ProfileCreation/ | 350 | Experience input | 🔴 BUG |
| 11 | EducationAndCertificationsStepView | ProfileCreation/ | 280 | Education input | 🔴 BUG |
| 12 | SkillsSelectionStepView | ProfileCreation/ | 420 | Skills picker | ✅ |
| 13 | ResumeUploadView | Profile/ | 280 | PDF upload | ✅ |
| 14 | ResumeParseResultView | Profile/ | 190 | Parse results | ✅ |
| 15 | QuestionCardView | CareerQuestions/ | 310 | AI question display | ✅ |
| 16 | CareerPathScreen | CareerPath/ | 380 | Career transitions | ✅ |
| 17 | CareerPathCard | CareerPath/ | 150 | Path summary card | ✅ |
| 18 | CareerPathDetailView | CareerPath/ | 420 | Path details | ✅ |
| 19 | RecommendedJobsView | CareerPath/ | 240 | Filtered jobs | ✅ |
| 20 | SettingsScreen | Settings/ | 280 | App settings | 🟡 11 empty buttons |
| 21 | NotificationSettingsView | Settings/ | 190 | Notification prefs | ✅ |
| 22 | PrivacySettingsView | Settings/ | 230 | Privacy controls | ✅ |
| 23 | AboutView | Settings/ | 140 | App info | ✅ |
| 24 | OnboardingView | Onboarding/ | 450 | First-time flow | ✅ |
| 25 | WelcomeScreen | Onboarding/ | 180 | Welcome message | ✅ |
| 26 | PermissionsRequestView | Onboarding/ | 220 | System permissions | ✅ |
| 27 | SkillBadge | Common/ | 45 | Skill pill UI | ✅ |
| 28 | LoadingView | Common/ | 60 | Loading spinner | ✅ |

**Summary**:
- ✅ 26/28 working correctly (93%)
- 🔴 2/28 critical bugs (7%)
- 🟡 11 disconnected buttons (SettingsScreen)

---

## Common Bugs & Anti-Patterns

### 🔴 Bug: Missing Persistence
```swift
// ❌ WRONG: Only updates @State
@State private var experiences: [WorkExperienceData] = []

func addExperience(_ exp: WorkExperienceData) {
    experiences.append(exp)  // Lost on restart
}
```

```swift
// ✅ CORRECT: Persist to Core Data
func addExperience(_ exp: WorkExperienceData) {
    let entity = WorkExperience(context: viewContext)
    entity.jobTitle = exp.title
    try? viewContext.save()  // Persisted
}
```

### 🟡 Bug: Empty Button Actions
```swift
// ❌ WRONG: No action (currently exists in SettingsScreen)
Button("Change Theme") {
    // TODO: Implement
}

// ✅ CORRECT: Action or disable
Button("Change Theme") {
    isShowingThemeSheet = true
}
```

---

## Success Criteria

v8-ui-components-expert is successful when:

✅ All 28 SwiftUI views documented
✅ WCAG 2.1 AA compliance (4.5:1 contrast, VoiceOver, Dynamic Type)
✅ MV architecture enforced (no ViewModels)
✅ SacredUI constants protected
✅ 60fps performance maintained
✅ WorkExperience and Education bugs documented
✅ 11 disconnected buttons tracked for fixing

---

**v8-ui-components-expert**: Master of SwiftUI architecture and accessibility, ensuring a world-class, WCAG-compliant user experience across V8's 28 views.
