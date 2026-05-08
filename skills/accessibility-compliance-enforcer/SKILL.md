---
name: accessibility-compliance-enforcer
description: Ensures WCAG 2.1 AA compliance and full VoiceOver/Dynamic Type support for inclusive job discovery
allowed-tools:
  - Read
  - Grep
  - Edit
---

## Purpose

Makes ManifestAndMatchV7 accessible to ALL users including those with visual, motor, or cognitive disabilities. Job seeking should be available to everyone - accessibility is not optional.

## Sacred Accessibility Principles

1. **VoiceOver First** - Every UI element must have meaningful labels
2. **Dynamic Type Support** - All text scales from accessibility sizes to accessibility extra-extra-extra large
3. **High Contrast** - WCAG 2.1 AA contrast ratios (4.5:1 for normal text)
4. **Keyboard Navigation** - Full app navigation without touch
5. **Reduce Motion** - Respect motion preferences
6. **Screen Reader Friendly** - Semantic structure, not visual structure

## Activation Triggers

This skill activates when you're working on:
- `V7UI/` - All SwiftUI views and components
- Any custom UI components or controls
- Job cards, swipe interactions, charts
- Forms, buttons, navigation elements
- Animation or transition code

## Critical Enforcement Areas

### 1. VoiceOver Labels (Required for EVERY element)

**Every interactive element needs an accessibility label:**

```swift
// ❌ WRONG: No accessibility label
Button {
    likeJob()
} label: {
    Image(systemName: "heart.fill")  // VoiceOver reads "heart dot fill" - useless
}

// ✅ CORRECT: Descriptive accessibility label
Button {
    likeJob()
} label: {
    Image(systemName: "heart.fill")
}
.accessibilityLabel("Save job")
.accessibilityHint("Double tap to add this job to your saved list")

// ✅ CORRECT: Job card accessibility
struct JobCardView: View {
    let job: Job

    var body: some View {
        VStack(alignment: .leading) {
            Text(job.title)
            Text(job.company)
            Text(job.location)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(job.title) at \(job.company) in \(job.location)")
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Swipe right to apply, swipe left to skip")
    }
}
```

### 2. Dynamic Type Support

**All text must scale with user preferences:**

```swift
// ❌ WRONG: Fixed font sizes
Text("Software Engineer")
    .font(.system(size: 24))  // Won't scale with Dynamic Type

// ✅ CORRECT: Dynamic Type with TextStyle
Text("Software Engineer")
    .font(.title2)  // Scales from small to XXXL

// ✅ CORRECT: Custom font with scaling
Text("Software Engineer")
    .font(.custom("SFPro-Bold", size: 24, relativeTo: .title2))

// ✅ CORRECT: Handle extreme sizes
struct JobTitleView: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var body: some View {
        VStack {
            if dynamicTypeSize >= .accessibility3 {
                // Extra large: Simplify layout
                Text(job.title)
                    .font(.title)
                Text(job.company)
                    .font(.body)
            } else {
                // Normal: Full layout
                HStack {
                    Text(job.title)
                        .font(.title2)
                    Spacer()
                    Text(job.company)
                        .font(.subheadline)
                }
            }
        }
    }
}
```

### 3. Color Contrast Ratios (WCAG 2.1 AA)

**Minimum 4.5:1 for normal text, 3:1 for large text:**

```swift
// ❌ WRONG: Low contrast (fails WCAG)
Text("Apply Now")
    .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))  // Light gray on white = 1.5:1
    .background(.white)

// ✅ CORRECT: High contrast (passes WCAG AA)
extension Color {
    static let accessibleAmber = Color(red: 0.8, green: 0.4, blue: 0.0)  // 4.8:1 on white
    static let accessibleTeal = Color(red: 0.0, green: 0.5, blue: 0.5)   // 4.6:1 on white

    // Validate contrast ratio
    func contrastRatio(with background: Color) -> Double {
        let fgLuminance = self.relativeLuminance()
        let bgLuminance = background.relativeLuminance()

        let lighter = max(fgLuminance, bgLuminance)
        let darker = min(fgLuminance, bgLuminance)

        return (lighter + 0.05) / (darker + 0.05)
    }

    func meetsWCAG_AA(on background: Color, largeText: Bool = false) -> Bool {
        let ratio = contrastRatio(with: background)
        return largeText ? ratio >= 3.0 : ratio >= 4.5
    }
}

// Usage:
let amber = Color.accessibleAmber
let white = Color.white

assert(amber.meetsWCAG_AA(on: white), "Amber doesn't meet WCAG AA on white")
```

### 4. Semantic Structure (Not Visual)

**Use semantic views, not just visual layouts:**

```swift
// ❌ WRONG: Visual structure only
VStack {
    Text("Job Details")  // Looks like a heading
    Text("Software Engineer at Apple")
    Text("Description...")
}
// VoiceOver reads all as equal text

// ✅ CORRECT: Semantic structure
VStack {
    Text("Job Details")
        .accessibilityAddTraits(.isHeader)  // Semantic heading

    Text("Software Engineer at Apple")
        .accessibilityLabel("Job title: Software Engineer at Apple")

    Text("Description...")
        .accessibilityLabel("Job description")
}

// ✅ CORRECT: Group related content
VStack {
    HStack {
        Image(systemName: "mappin")
        Text("San Francisco, CA")
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Location: San Francisco, California")

    HStack {
        Image(systemName: "dollarsign.circle")
        Text("$150,000 - $200,000")
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Salary range: 150 to 200 thousand dollars")
}
```

### 5. Custom Swipe Actions (Accessible)

**Make swipe gestures keyboard-accessible:**

```swift
// ✅ CORRECT: Accessible swipe interface
struct AccessibleJobCardView: View {
    let job: Job
    @State private var showActions = false

    var body: some View {
        JobCardContent(job: job)
            .accessibilityAction(named: "Apply") {
                applyToJob()
            }
            .accessibilityAction(named: "Skip") {
                skipJob()
            }
            .accessibilityAction(named: "Save for Later") {
                saveJob()
            }
            .accessibilityAction(named: "More Options") {
                showActions = true
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width > 100 {
                            applyToJob()
                        } else if value.translation.width < -100 {
                            skipJob()
                        }
                    }
            )
    }
}

// VoiceOver: "Software Engineer at Apple. Actions available. Double tap to activate."
// User activates → hears "Apply, Skip, Save for Later, More Options"
```

### 6. Charts and Data Visualization

**Provide alternative representations:**

```swift
// ✅ CORRECT: Accessible charts
struct AccessibleChartView: View {
    let dataPoints: [DataPoint]

    var body: some View {
        VStack {
            // Visual chart
            Chart(dataPoints) { point in
                BarMark(
                    x: .value("Date", point.date),
                    y: .value("Applications", point.count)
                )
            }
            .accessibilityLabel(chartDescription)
            .accessibilityValue(chartSummary)

            // Alternative text representation (hidden visually)
            Text(chartDataTable)
                .accessibilityLabel("Detailed data table")
                .frame(height: 0)  // Hidden but available to VoiceOver
        }
    }

    var chartDescription: String {
        "Bar chart showing job application activity over time"
    }

    var chartSummary: String {
        "Total applications: \(dataPoints.reduce(0) { $0 + $1.count }). " +
        "Highest day: \(dataPoints.max(by: { $0.count < $1.count })?.date.formatted() ?? "unknown"). " +
        "Average per day: \(dataPoints.reduce(0) { $0 + $1.count } / dataPoints.count)."
    }

    var chartDataTable: String {
        dataPoints.map { "\($0.date.formatted()): \($0.count) applications" }
            .joined(separator: ". ")
    }
}
```

### 7. Reduce Motion Support

**Respect motion preferences:**

```swift
// ✅ CORRECT: Respect reduce motion
struct AnimatedJobCardView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var isAnimating = false

    var body: some View {
        JobCardView(job: job)
            .scaleEffect(isAnimating && !reduceMotion ? 1.05 : 1.0)
            .animation(
                reduceMotion ? .none : .spring(),
                value: isAnimating
            )
            .onAppear {
                if !reduceMotion {
                    isAnimating = true
                }
            }
    }
}

// ✅ CORRECT: Alternative for swipe animations
struct SwipeIndicatorView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        if reduceMotion {
            // Static arrows
            HStack {
                Image(systemName: "arrow.left")
                Text("Skip")
                Spacer()
                Text("Apply")
                Image(systemName: "arrow.right")
            }
        } else {
            // Animated arrows
            HStack {
                Image(systemName: "arrow.left")
                    .symbolEffect(.wiggle)
                Text("Skip")
                Spacer()
                Text("Apply")
                Image(systemName: "arrow.right")
                    .symbolEffect(.wiggle)
            }
        }
    }
}
```

### 8. Form Accessibility

**Accessible forms with clear labels and errors:**

```swift
// ✅ CORRECT: Accessible form
struct ProfileEditView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var nameError: String?
    @State private var emailError: String?

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                    .accessibilityLabel("Full name")
                    .accessibilityValue(name.isEmpty ? "Empty" : name)
                    .accessibilityHint("Enter your full name")

                if let error = nameError {
                    Text(error)
                        .foregroundColor(.red)
                        .accessibilityLabel("Name error: \(error)")
                }

                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .accessibilityLabel("Email address")
                    .accessibilityValue(email.isEmpty ? "Empty" : email)
                    .accessibilityHint("Enter your email address")

                if let error = emailError {
                    Text(error)
                        .foregroundColor(.red)
                        .accessibilityLabel("Email error: \(error)")
                }
            } header: {
                Text("Personal Information")
                    .accessibilityAddTraits(.isHeader)
            }

            Section {
                Button("Save Changes") {
                    saveProfile()
                }
                .accessibilityLabel("Save profile changes")
                .accessibilityHint("Double tap to save your updated profile information")
            }
        }
        .navigationTitle("Edit Profile")
    }
}
```

### 9. Loading States

**Accessible loading indicators:**

```swift
// ❌ WRONG: Silent loading spinner
ProgressView()  // VoiceOver user doesn't know what's happening

// ✅ CORRECT: Announced loading state
struct AccessibleLoadingView: View {
    let message: String

    var body: some View {
        VStack {
            ProgressView()
            Text(message)
                .accessibilityLabel(message)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Loading. \(message)")
        .accessibilityAddTraits(.updatesFrequently)
    }
}

// Usage:
AccessibleLoadingView(message: "Searching for jobs matching your profile")
```

### 10. Error Messages

**Clear, actionable error messages:**

```swift
// ❌ WRONG: Vague error
Text("Error")
    .foregroundColor(.red)

// ✅ CORRECT: Descriptive, actionable error
struct AccessibleErrorView: View {
    let error: Error

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                    .accessibilityHidden(true)  // Redundant with text

                Text("Unable to Load Jobs")
                    .font(.headline)
            }
            .accessibilityAddTraits(.isHeader)

            Text(errorMessage)
                .font(.body)

            Button("Try Again") {
                retryLoad()
            }
            .accessibilityLabel("Try loading jobs again")
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error. Unable to load jobs. \(errorMessage). Try again button available.")
    }

    var errorMessage: String {
        switch error {
        case NetworkError.noConnection:
            return "Check your internet connection and try again."
        case NetworkError.timeout:
            return "Request timed out. Please try again."
        default:
            return "An unexpected error occurred. Please try again later."
        }
    }
}
```

## Accessibility Testing Checklist

Before merging UI code:

- [ ] VoiceOver labels on ALL interactive elements
- [ ] Dynamic Type tested from small to accessibility XXXL
- [ ] Color contrast ≥4.5:1 for normal text (WCAG AA)
- [ ] Color contrast ≥3:1 for large text
- [ ] Keyboard navigation works without touch
- [ ] Reduce Motion respected (no forced animations)
- [ ] Semantic structure (headers, buttons, etc.)
- [ ] Custom gestures have accessibility actions
- [ ] Charts have text alternatives
- [ ] Forms have clear labels and error messages
- [ ] Loading states announced to VoiceOver
- [ ] Error messages descriptive and actionable

## When This Skill Flags Issues

I will automatically warn you if:

1. **Missing accessibility labels** - Interactive elements without labels
2. **Fixed font sizes** - Using `.system(size:)` instead of TextStyle
3. **Low contrast** - Colors that don't meet WCAG AA
4. **Visual-only structure** - Missing semantic traits
5. **Inaccessible gestures** - Swipes without accessibility actions
6. **Silent loading** - ProgressView without announcement
7. **Vague errors** - Generic error messages
8. **Motion not respected** - Animations without reduce motion check

## Reference: VoiceOver Testing Commands

```bash
# Enable VoiceOver on simulator
xcrun simctl spawn booted launchctl setenv VOICEOVER_ENABLED 1

# Common VoiceOver gestures:
# - Single tap: Focus element
# - Double tap: Activate element
# - Swipe right: Next element
# - Swipe left: Previous element
# - Two-finger swipe down: Read all from cursor
# - Rotor (two-finger twist): Change navigation mode
```

## WCAG 2.1 AA Requirements Summary

- **Contrast**: 4.5:1 normal text, 3:1 large text
- **Resize Text**: Support up to 200% without loss of functionality
- **Keyboard**: All functionality available via keyboard
- **Focus Visible**: Clear focus indicator
- **Labels**: All form inputs have labels
- **Error Messages**: Clear, descriptive errors with suggestions
- **Status Messages**: Announced to screen readers
- **Motion**: Respect prefers-reduced-motion

---

# Accessibility Compliance Enforcer

**Based On:**
- Apple Human Interface Guidelines (Accessibility)
- WCAG 2.1 Level AA requirements
- `/Packages/V7UI/` - SwiftUI views
- Accessibility best practices for job search apps
