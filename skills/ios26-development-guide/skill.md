---
name: ios26-development-guide
description: Practical iOS 26 development workflows, migration strategies, quick-start commands, and daily development cycle optimizations
category: workflow
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - WebFetch
---

# iOS 26 Development Guide

## Triggers
- "How do I start with iOS 26?"
- "iOS 26 migration steps"
- "iOS 26 quick reference"
- "Test my app on iOS 26"
- "iOS 26 workflow setup"
- "Check iOS 26 compatibility"
- "iOS 26 best practices"
- Starting new iOS 26 projects
- Daily iOS 26 development cycles

## Behavioral Mindset

Think workflow-first, not theory-first. Developers need actionable steps, not documentation summaries. Every recommendation must include "do this now" commands. iOS 26 is mandatory by April 2026 - treat migration as urgent. Liquid Glass isn't optional when building with Xcode 26 - help developers embrace it, not fight it. Foundation Models is the killer feature - always suggest it as the first option for AI needs. When users are stuck, provide the exact command or code snippet to run immediately.

---

## Quick Start: iOS 26 in 5 Minutes

### 1. Check Your Current State

```bash
# Check Xcode version
xcodebuild -version
# Need: Xcode 26.0 or later

# Check iOS simulator versions
xcrun simctl list runtimes | grep iOS
# Need: iOS 26.0 or later

# Check macOS version (for Xcode 26)
sw_vers
# Need: macOS 15.0 (Sequoia) or later
```

**If you don't have Xcode 26:**
1. Download from https://developer.apple.com/download/
2. Install Xcode 26.0+
3. Run: `sudo xcode-select --switch /Applications/Xcode.app`

### 2. Create Your First iOS 26 App

```bash
# Open Xcode
open -a Xcode

# File → New → Project
# iOS → App
# Interface: SwiftUI
# Language: Swift
# Minimum Deployment: iOS 26.0
```

**Automatic Liquid Glass:**
```swift
// ContentView.swift - Liquid Glass is automatic!
import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            // Background
            Color.blue.opacity(0.3)

            // Liquid Glass card
            VStack(spacing: 20) {
                Text("iOS 26")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Liquid Glass is automatic!")
                    .foregroundStyle(.secondary)
            }
            .padding(40)
            .background(.liquidGlass)  // ✨ New material
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }
}
```

### 3. Run on iOS 26 Simulator

```bash
# List available simulators
xcrun simctl list devices | grep "iOS 26"

# Boot a simulator (replace UUID)
xcrun simctl boot <SIMULATOR-UUID>

# Or just: Cmd+R in Xcode
```

**Test Liquid Glass Modes:**
1. Settings → Display & Brightness → Liquid Glass
2. Toggle between "Clear" and "Tinted"
3. See your app adapt automatically

---

## Daily iOS 26 Development Workflow

### Morning Routine (Start of Session)

**Step 1: Environment Check**
```bash
# Quick status
xcodebuild -version && xcrun simctl list devices | grep iOS | head -5
```

**Step 2: Update Check**
```
You: "Check for iOS 26 updates"
Me: *Fetches latest iOS 26.x release notes*
Me: *Summarizes breaking changes*
Me: *Recommends action items*
```

**Step 3: Simulator Boot**
```bash
# Boot your preferred iOS 26 simulator
xcrun simctl boot "iPhone 16 Pro"
open -a Simulator
```

### Active Development Cycle

**Build → Test → Screenshot Loop**

```
You: "Build ManifestAndMatchV7 on iOS 26 simulator"
Me: *Uses mcp__XcodeBuildMCP__build_sim*
Me: *Runs on simulator*
Me: *Captures screenshot*
Me: "Build succeeded. Here's the result [screenshot]"

You: "The button looks off in Tinted mode"
Me: *Adjusts contrast for Tinted mode*
Me: *Rebuilds*
Me: *Shows new screenshot*
Me: "Better? The text weight is now .semibold for readability"
```

**Foundation Models Integration**

```
You: "Add job description summarization"
Me:
1. *Checks device compatibility (iPhone 15 Pro+ required)*
2. *Implements Foundation Models summarization*
3. *Shows before/after comparison*
4. *Calculates cost savings vs OpenAI*

// Example implementation
import Foundation

func summarizeJobDescription(_ text: String) async throws -> String {
    // iOS 26: On-device AI, free, private, offline
    let summary = try await FoundationModels.summarize(
        text: text,
        style: .concise,
        maxLength: 100
    )
    return summary
}
```

### Evening Routine (End of Session)

**Summary & Planning**

```
Me:
📊 Today's Progress:
- Built 8 times (7 successful, 1 error fixed)
- Added Liquid Glass to 3 views
- Integrated Foundation Models for job matching
- Fixed view hierarchy issue in DeckScreen
- Tested on iOS 26.0.1 simulator

⚠️ Known Issues:
- TabView animation glitch (filed FB123456)
- Foundation Models requires iPhone 15 Pro+ (documented)

📋 Tomorrow:
- Test Clear vs Tinted modes on all screens
- Profile Foundation Models performance
- Update third-party analytics SDK
```

---

## iOS 26 Migration Checklist

### Phase 1: Preparation (Week 1)

**Day 1-2: Environment Setup**
- [ ] Install Xcode 26.0+
- [ ] Download iOS 26 simulators
- [ ] Update macOS to 15.0+ (Sequoia)
- [ ] Backup current project (Time Machine or git)
- [ ] Create ios26-migration branch

**Day 3-5: Assessment**
```bash
# Discover your Xcode projects
xcrun swift package init

# Build with Xcode 26 (expect errors)
xcodebuild -workspace ManifestAndMatchV7.xcworkspace \
           -scheme ManifestAndMatchV7 \
           -sdk iphonesimulator \
           -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=26.0'
```

- [ ] Document all build errors
- [ ] List third-party dependencies
- [ ] Check SDK version compatibility
- [ ] Test on iOS 26 simulator

### Phase 2: Migration (Week 2-3)

**SwiftUI View Hierarchy Issues**
```swift
// Common issue: UI tests break
// Old selector (iOS 18)
app.buttons["submitButton"].tap()

// New selector (iOS 26 - accounts for UIDropShadowView)
app.descendants(matching: .button)
   .matching(identifier: "submitButton")
   .firstMatch
   .tap()
```

- [ ] Update UI test selectors
- [ ] Fix privacy/tracking SDK issues
- [ ] Regenerate selector-based rules
- [ ] Test all automated tests

**Liquid Glass Adoption**
```swift
// Option 1: Embrace (recommended)
// Build with Xcode 26, get automatic Liquid Glass
// Test Clear and Tinted modes

// Option 2: Delay (temporary)
// Add to Info.plist:
<key>UIDesignRequiresCompatibility</key>
<true/>
// ⚠️ Only works until Xcode 27!
```

- [ ] Decide: Embrace or Delay?
- [ ] If Embracing: Test all views in both modes
- [ ] If Delaying: Plan migration before Xcode 27
- [ ] Update color scheme for readability

**Third-Party Dependencies**
```bash
# Update CocoaPods
pod update

# Update SPM packages
# File → Packages → Update to Latest Package Versions

# Check compatibility
# Visit each vendor's iOS 26 support page
```

- [ ] Update all dependencies to iOS 26-compatible versions
- [ ] Test analytics, crash reporting, payment SDKs
- [ ] File issues with vendors if not updated

**Foundation Models Integration**
```swift
// Replace cloud AI (optional but recommended)

// Old: OpenAI (costs $$$, requires internet)
let summary = try await openAI.complete(prompt: "Summarize: \(text)")

// New: Foundation Models (free, offline, private)
let summary = try await FoundationModels.summarize(text: text)

// Cost savings: $0.02 per 1K tokens → $0.00
// Privacy: Data sent to cloud → 100% on-device
// Speed: Network latency → Hardware-accelerated
```

- [ ] Identify AI API usage (OpenAI, Anthropic, etc.)
- [ ] Check device compatibility requirements
- [ ] Implement Foundation Models alternatives
- [ ] Measure performance and cost savings

### Phase 3: Testing (Week 4)

**Comprehensive Testing**
```bash
# Run all tests on iOS 26
xcodebuild test \
  -workspace ManifestAndMatchV7.xcworkspace \
  -scheme ManifestAndMatchV7 \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=26.0'

# Test on physical device
xcodebuild test \
  -workspace ManifestAndMatchV7.xcworkspace \
  -scheme ManifestAndMatchV7 \
  -destination 'platform=iOS,id=YOUR_DEVICE_UDID'
```

**Testing Matrix**
- [ ] iPhone 16 Pro (iOS 26.0.1) - Liquid Glass Clear mode
- [ ] iPhone 16 Pro (iOS 26.0.1) - Liquid Glass Tinted mode
- [ ] iPhone 15 Pro (iOS 26.0.1) - Foundation Models device
- [ ] iPhone 13 (iOS 26.0.1) - Non-Foundation Models device
- [ ] iPad Pro (iOS 26.0.1) - Tablet layout
- [ ] Dark Mode + Liquid Glass combinations

**Performance Profiling**
```bash
# Profile with Instruments
# Xcode → Product → Profile (Cmd+I)
# Choose: Time Profiler, Allocations, GPU Frame Capture

# Key metrics:
# - Liquid Glass rendering: <16ms (60 FPS)
# - Foundation Models inference: <500ms
# - Memory: No regressions from iOS 18
```

- [ ] Profile Liquid Glass GPU impact
- [ ] Measure Foundation Models latency
- [ ] Check memory usage (no leaks)
- [ ] Verify 60 FPS scrolling

### Phase 4: Deployment (Week 5)

**Prepare for TestFlight**
```bash
# Archive for distribution
xcodebuild archive \
  -workspace ManifestAndMatchV7.xcworkspace \
  -scheme ManifestAndMatchV7 \
  -sdk iphoneos \
  -configuration Release \
  -archivePath build/ManifestAndMatchV7.xcarchive

# Export for App Store
xcodebuild -exportArchive \
  -archivePath build/ManifestAndMatchV7.xcarchive \
  -exportPath build/ManifestAndMatchV7.ipa \
  -exportOptionsPlist ExportOptions.plist
```

- [ ] Create release build
- [ ] Upload to TestFlight
- [ ] Test with internal testers (iOS 26 devices)
- [ ] Gather feedback on Liquid Glass design
- [ ] Monitor crash reports (iOS 26 specific)

**App Store Submission**
```
⚠️ April 2026 Deadline
After April 2026:
- New apps: MUST use Xcode 26 + iOS 26 SDK
- App updates: MUST use Xcode 26 + iOS 26 SDK
- No extensions or opt-outs

Your Timeline:
- Now - Dec 2025: Testing and refinement
- Jan 2026: TestFlight beta (iOS 26)
- Feb 2026: Final QA
- March 2026: Submit to App Store
- April 2026: Deadline passes, you're ready ✅
```

- [ ] Plan App Store release date
- [ ] Update app screenshots (show Liquid Glass)
- [ ] Update App Store description (mention iOS 26 features)
- [ ] Submit before April 2026 deadline

---

## iOS 26 Quick Reference Commands

### Documentation Fetching

```
"Fetch latest iOS 26 release notes"
"What changed in iOS 26.0.1?"
"Show me WWDC 2025 Liquid Glass session"
"Check for iOS 26.1 beta features"
"Get Foundation Models API docs"
```

### Development Commands

```
"Build ManifestAndMatchV7 on iOS 26 simulator"
"Run tests on iPhone 16 Pro simulator"
"Screenshot the current simulator state"
"Profile Liquid Glass performance"
"Check view hierarchy in iOS 26"
```

### Troubleshooting

```
"My UI tests are failing on iOS 26"
"Why is my app slow with Liquid Glass?"
"How do I fix view hierarchy issues?"
"My analytics stopped working after updating"
"Should I use UIDesignRequiresCompatibility?"
```

### Migration Help

```
"Help me migrate from iOS 18 to iOS 26"
"What breaks when updating to Xcode 26?"
"Show me Foundation Models integration examples"
"Compare OpenAI vs Foundation Models costs"
"When is the App Store iOS 26 deadline?"
```

---

## Foundation Models Use Cases

### Text Operations

**Summarization:**
```swift
// Job descriptions, articles, emails
let summary = try await FoundationModels.summarize(
    text: longJobDescription,
    style: .concise,  // or .detailed, .bullet
    maxLength: 150
)
```

**Translation:**
```swift
// Multi-language support (9 languages in iOS 26.0)
let translated = try await FoundationModels.translate(
    text: "Software Engineer position",
    from: .english,
    to: .spanish
)
```

**Entity Extraction:**
```swift
// Extract skills, companies, locations from text
let entities = try await FoundationModels.extract(
    entities: [.skills, .companies, .locations],
    from: jobDescription
)

// Returns: ["Swift", "iOS", "Apple Inc.", "Cupertino, CA"]
```

### Visual Intelligence

**Image Description:**
```swift
// Company logos, office photos
let description = try await FoundationModels.describe(
    image: companyLogoImage,
    detail: .high
)
```

**Object Detection:**
```swift
// Identify objects in images
let objects = try await FoundationModels.detect(
    objects: .all,
    in: officePhoto
)
```

### ManifestAndMatch V7 Integration Ideas

**Job Matching:**
```swift
// Replace OpenAI with Foundation Models
// Old cost: $0.02/1K tokens
// New cost: $0.00 (on-device)

func matchJobToProfile(job: Job, profile: UserProfile) async -> Double {
    // Summarize job requirements
    let requirements = try await FoundationModels.extract(
        entities: [.skills, .experience],
        from: job.description
    )

    // Calculate match score
    let matchScore = calculateOverlap(
        userSkills: profile.skills,
        jobRequirements: requirements
    )

    return matchScore
}
```

**Career Discovery:**
```swift
// Generate career insights
func generateCareerInsights(jobs: [Job]) async -> String {
    let allDescriptions = jobs.map(\.description).joined(separator: "\n\n")

    let insights = try await FoundationModels.summarize(
        text: allDescriptions,
        style: .detailed
    )

    return insights
}
```

---

## Liquid Glass Design Patterns

### Standard Views

```swift
// Card with Liquid Glass background
VStack {
    Text("Job Title")
        .font(.headline)
    Text("Company Name")
        .font(.subheadline)
}
.padding()
.background(.liquidGlass)
.clipShape(RoundedRectangle(cornerRadius: 16))
```

### Lists with Liquid Glass

```swift
List {
    ForEach(jobs) { job in
        JobRowView(job: job)
            .listRowBackground(Color.liquidGlass)
    }
}
.scrollContentBackground(.hidden)  // Remove default background
```

### Sheets and Modals

```swift
// Automatically Liquid Glass in iOS 26
.sheet(isPresented: $showDetail) {
    JobDetailView(job: selectedJob)
        .presentationDetents([.medium, .large])
    // ✨ Liquid Glass automatic!
}
```

### Custom Intensity

```swift
// Control translucency
Rectangle()
    .fill(.liquidGlass)
    .glassIntensity(0.5)  // 0.0 (transparent) to 1.0 (opaque)
    .glassReflection(true)  // Enable dynamic reflection
```

---

## Performance Optimization

### Liquid Glass GPU Impact

**Issue:** Translucent rendering is GPU-intensive

**Solutions:**
```swift
// 1. Limit Liquid Glass usage
// Only use on visible views, not off-screen

// 2. Check GPU capabilities
if MTLCreateSystemDefaultDevice()?.supportsFamily(.apple5) == true {
    // Use Liquid Glass
} else {
    // Fallback to solid colors
}

// 3. Reduce complexity
// Don't stack multiple Liquid Glass layers
// Avoid Liquid Glass + complex animations
```

### Foundation Models Performance

**Expectations:**
- Text summarization: 200-500ms
- Entity extraction: 100-300ms
- Translation: 150-400ms
- Image description: 500ms-1s

**Optimization:**
```swift
// Cache results
actor FoundationModelsCache {
    private var cache: [String: String] = [:]

    func getSummary(_ text: String) async throws -> String {
        if let cached = cache[text] {
            return cached
        }

        let summary = try await FoundationModels.summarize(text: text)
        cache[text] = summary
        return summary
    }
}
```

---

## Common iOS 26 Issues & Fixes

### Issue 1: UI Tests Failing

**Symptom:** Tests pass on iOS 18, fail on iOS 26

**Cause:** UIDropShadowView added to hierarchy

**Fix:**
```swift
// Old (iOS 18)
app.buttons["login"].tap()

// New (iOS 26)
app.descendants(matching: .button)
   .matching(identifier: "login")
   .firstMatch
   .tap()
```

### Issue 2: Analytics Stopped Working

**Symptom:** Page tracking not recording

**Cause:** View hierarchy changes break selectors

**Fix:**
1. Update SDK to iOS 26-compatible version
2. Regenerate privacy rules with Xcode 26
3. Test on iOS 26 simulator before deployment

### Issue 3: Text Hard to Read

**Symptom:** Text not readable in Tinted mode

**Fix:**
```swift
Text("Important")
    .foregroundStyle(.primary)  // Adapts to mode
    .fontWeight(.semibold)      // Increase weight
    .shadow(radius: 1)          // Subtle shadow for depth
```

### Issue 4: App Slow After Update

**Symptom:** Scrolling lags, animations jank

**Cause:** Liquid Glass GPU overhead

**Fix:**
```swift
// Profile with Instruments
// Reduce Liquid Glass usage
// Simplify view hierarchy
// Use .drawingGroup() for complex views

ComplexView()
    .drawingGroup()  // Render off-screen, improves performance
```

### Issue 5: Foundation Models Not Available

**Symptom:** API fails on device

**Cause:** Device doesn't support Apple Intelligence

**Fix:**
```swift
// Check availability first
if FoundationModels.isAvailable {
    let summary = try await FoundationModels.summarize(text: text)
} else {
    // Fallback to cloud API or simpler algorithm
    let summary = simpleSummarize(text)
}

// Device requirements:
// - iPhone 16 (all models)
// - iPhone 15 Pro, 15 Pro Max
// - iPad mini (A17 Pro)
// - iPad/Mac with M1+
```

---

## iOS 26 Timeline & Deadlines

### Key Dates

**Past:**
- June 9, 2025: iOS 26 announced (WWDC 2025)
- Sept 15, 2025: iOS 26.0 released
- Sept 29, 2025: iOS 26.0.1 released
- Oct 2025: iOS 26.1 beta

**Present (October 2025):**
- Current: iOS 26.0.1
- Beta: iOS 26.1
- **5 months until App Store deadline**

**Future:**
- Nov 2025: iOS 26.1 expected release
- Dec 2025: iOS 26.2 (possibly)
- Jan-March 2026: Final testing window
- **April 2026: App Store requires Xcode 26 + iOS 26 SDK** ⚠️
- June 2026: WWDC 2026, iOS 27 announced
- Sept 2026: iOS 27 released

### Your Migration Timeline

**Now - December 2025 (2 months):**
- Install Xcode 26
- Test existing apps
- Identify breaking changes
- Update dependencies

**January 2026 (1 month):**
- Fix all build errors
- Adopt Liquid Glass
- Integrate Foundation Models
- TestFlight beta testing

**February 2026 (1 month):**
- Final QA
- Performance profiling
- Fix critical bugs
- Prepare App Store assets

**March 2026 (1 month):**
- Buffer for unexpected issues
- App Store review
- Marketing prep

**April 1, 2026:**
- ✅ Deadline passes, you're ready!

---

## Resources & Documentation

### Official Apple

**Developer Portal:**
- https://developer.apple.com/ios/
- https://developer.apple.com/xcode/
- https://developer.apple.com/documentation/foundationmodels

**WWDC 2025 Sessions:**
- "Introducing Liquid Glass design"
- "Build with Foundation Models"
- "What's new in SwiftUI"
- "Migrating to iOS 26"
- "Optimize for iOS 26"

### Community Resources

**Best Guides:**
- Hacking with Swift: "What's new in SwiftUI for iOS 26"
- Fullstory: "iOS 26 Migration Guide"
- Index.dev: "iOS 26 Developer Guide"
- Apple Developer Forums: iOS 26 discussion

### Tools & Downloads

**Xcode:**
- https://developer.apple.com/download/
- Xcode 26.0 (current)
- Xcode 26.1 beta

**Simulators:**
- iOS 26.0.1 (included with Xcode 26)
- Download additional runtimes: Xcode → Settings → Platforms

---

## Boundaries

**Will:**
- Provide step-by-step iOS 26 migration workflows
- Give exact commands and code snippets to run immediately
- Build, test, and screenshot iOS 26 apps using MCP tools
- Fetch latest iOS 26 documentation and release notes
- Help integrate Foundation Models and Liquid Glass
- Track April 2026 App Store deadline progress
- Profile and optimize iOS 26 performance

**Will Not:**
- Recommend delaying iOS 26 migration (April 2026 is mandatory)
- Suggest UIDesignRequiresCompatibility as permanent solution
- Provide iOS 18 workflows without iOS 26 context
- Ignore view hierarchy changes that break apps
- Recommend cloud AI when Foundation Models is available on-device

---

**Last Updated**: October 27, 2025
**iOS Version**: iOS 26.0.1 (current), iOS 26.1 (beta)
**Xcode Version**: Xcode 26.0 (current)
**App Store Deadline**: April 2026 (5 months away)
**Status**: Active development, migration urgent
