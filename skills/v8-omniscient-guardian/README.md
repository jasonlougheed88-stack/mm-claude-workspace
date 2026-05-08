# V8-OMNISCIENT-GUARDIAN
## Complete Codebase Knowledge System for Manifest & Match V8

---

## Overview

**V8-omniscient-guardian** is a meta-skill that orchestrates 7 specialized domain expert sub-skills to provide complete, detailed knowledge of the Manifest & Match V8 iOS codebase. It uses a **two-source truth system** (live codebase + technical documentation) with **self-updating** and **self-diagnostic** capabilities.

**Version:** 1.0.0
**Codebase:** Manifest & Match V8 (iOS 26, Swift 6, SwiftUI)
**Total Coverage:** 14 packages, 506 Swift files, 68,000+ LOC

---

## Architecture

### Two-Source Truth System

1. **Live Codebase (Ground Truth)**
   - Location: `/Users/jasonl/Desktop/ios26_manifest_and_match/manifest and match V8`
   - 14 active Swift packages (V7Core, V7Thompson, V7Data, V7Services, V7AI, V7UI, etc.)
   - 506 Swift files, 68,000+ lines of code
   - Real-time file access via Read tool

2. **Technical Documentation (Context)**
   - Location: `/Users/jasonl/Desktop/ios26_manifest_and_match/C4_ARCHITECTURE_ANALYSIS/technical`
   - 14 comprehensive technical documents
   - Architecture diagrams, dependency graphs, data flows
   - Dead code analysis, connection validation

**Drift Detection:** Automatically detects when docs diverge from code (e.g., docs said 335+ files, actual scan found 506 = 51% drift)

---

## Domain Expert Sub-Skills (7 Specialists)

### 1. **v8-thompson-mathematician** 🧮
**Expert in:** Thompson Sampling algorithm, Bayesian statistics, Beta-Bernoulli distributions

**Knowledge:**
- Mathematical foundations (Beta distribution, conjugate priors)
- <10ms sacred requirement (357x competitive advantage)
- FastBetaSampler (SIMD optimization, Kumaraswamy approximation)
- ThompsonCache (lock-free 50-entry LRU, 5-min TTL)
- Performance monitoring and enforcement

**Use for:**
- Thompson Sampling mathematics
- Performance optimization
- Algorithm correctness validation
- Bayesian inference questions

---

### 2. **v8-data-models-expert** 💾
**Expert in:** Core Data entities, relationships, persistence patterns

**Knowledge:**
- 14 Core Data entities (8 profile, 4 behavioral, 2 performance)
- Entity relationships (WorkExperience, Education, Certification, etc.)
- Swift 6 Sendable patterns (NSManagedObjectID wrapper)
- Critical bugs: WorkExperience persistence bug (Line 145), Education persistence bug (Line 89)

**Use for:**
- Core Data schema questions
- Entity relationship mapping
- Persistence bug diagnosis
- Swift 6 concurrency patterns

---

### 3. **v8-job-sources-expert** 🔌
**Expert in:** API integrations, rate limiting, circuit breakers, error handling

**Knowledge:**
- 7 job source API clients (Adzuna, Greenhouse, Lever, Jobicy, USAJobs, RSS, RemoteOK)
- Rate limiting with token bucket pattern
- Circuit breakers (3-5 failure threshold)
- Exponential backoff (1s, 2s, 4s, 8s)
- Graceful degradation (6/7 sources working = success)

**Use for:**
- API integration questions
- Rate limiting strategies
- Error handling patterns
- Adding new job sources

---

### 4. **v8-ai-systems-expert** 🤖
**Expert in:** iOS 26 Foundation Models, on-device AI, ML integrations

**Knowledge:**
- 7 iOS 26 AI systems (SmartQuestionGenerator, ResumeParser, BehavioralAnalyst, etc.)
- 100% on-device processing (zero API costs, complete privacy)
- Performance targets (180ms, 850ms, 45ms, 120ms, 35ms, 290ms, 25ms)
- LanguageModel, EmbeddingModel, VisionModel APIs

**Use for:**
- iOS 26 Foundation Models integration
- On-device AI implementation
- Performance optimization
- Privacy-first architecture

---

### 5. **v8-data-flows-expert** 🔄
**Expert in:** End-to-end data flows, multi-layer transactions, data synchronization

**Knowledge:**
- 5 major data flows (Profile Creation, Job Discovery, Swipe Interaction, AI Question Answering, Resume Parsing)
- 7-layer atomic persistence (SwipeRecord, ThompsonArm, BehavioralPattern, JobCache, StarredJobs, SwipeSessionMetadata, PerformanceMetrics)
- Flow performance metrics (1.2-3s typical)
- Cross-package data choreography

**Use for:**
- Understanding data flow through the app
- Multi-layer transaction patterns
- Performance bottleneck analysis
- Data synchronization questions

---

### 6. **v8-ui-components-expert** 🎨
**Expert in:** SwiftUI views, WCAG 2.1 AA compliance, MV architecture

**Knowledge:**
- 28 SwiftUI views (DeckScreen 1,800+ lines, ProfileScreen, HistoryScreen, ManifestTabView)
- SacredUI constants (NEVER modify: swipe thresholds)
- WCAG 2.1 AA compliance (4.5:1 contrast, VoiceOver, Dynamic Type)
- MV architecture (Model-View, no ViewModels)
- Critical bugs: 11 disconnected buttons in SettingsScreen

**Use for:**
- SwiftUI view questions
- Accessibility compliance
- UI architecture patterns
- Bug diagnosis in views

---

### 7. **v8-package-architect** 📦
**Expert in:** Swift Package Manager, dependency management, build systems

**Knowledge:**
- 5-level package hierarchy (Level 0: Foundation → Level 5: Presentation)
- 14 active packages + 1 disabled (V7Migration)
- Zero circular dependencies (validated)
- Coupling analysis (afferent/efferent metrics)
- Critical paths (V7Core affects all 14 packages)
- Dead code: V7Ads package unused (1,850 LOC)

**Use for:**
- Package dependency questions
- Architecture decisions
- Build optimization
- Circular dependency detection
- Dead code analysis

---

## Integration with Timeless Skills

V8-omniscient-guardian integrates these existing skills:

### Guardian Skills (Always Active)
- **v7-architecture-guardian** - Enforces V7 architectural patterns (MV, no ViewModels)
- **swift-concurrency-enforcer** - Validates Swift 6 strict concurrency
- **swiftui-specialist** - SwiftUI state management and optimization
- **accessibility-compliance-enforcer** - WCAG 2.1 AA compliance
- **core-data-specialist** - Core Data optimization

### Strategic Skills
- **business-planning-manager** - Business planning system awareness
- **app-narrative-guide** - Ensures features serve core mission

### Specialized Skills
- **thompson-performance-guardian** - Enforces <10ms Thompson requirement
- **ai-error-handling-enforcer** - Prevents AI parsing failures
- **cost-optimization-watchdog** - Prevents excessive AI API costs
- **privacy-security-guardian** - On-device processing, Keychain security

---

## How to Use V8-Omniscient-Guardian

### Basic Usage

Simply invoke the skill when you need deep codebase knowledge:

```
/skill v8-omniscient-guardian
```

The meta-skill will:
1. Analyze your question/request
2. Identify relevant domain(s)
3. Delegate to appropriate domain expert(s)
4. Synthesize comprehensive answer

---

### Example Queries

#### Data Model Questions
```
User: "How do I add a new field to WorkExperience entity?"
Guardian: [Delegates to v8-data-models-expert]
Response: Complete guide including:
- Core Data entity modification
- Swift 6 Sendable patterns
- Migration requirements
- Critical bug warning about WorkExperience persistence
```

---

#### API Integration Questions
```
User: "How do I add a new job source API?"
Guardian: [Delegates to v8-job-sources-expert]
Response: Step-by-step guide including:
- JobSourceProtocol implementation
- Rate limiting configuration
- Circuit breaker setup
- Error handling patterns
- Registration with JobDiscoveryCoordinator
```

---

#### Thompson Performance Questions
```
User: "Why is Thompson Sampling taking 15ms?"
Guardian: [Delegates to v8-thompson-mathematician]
Response: Performance analysis including:
- <10ms sacred requirement violation
- FastBetaSampler optimization techniques
- ThompsonCache configuration
- Profiling recommendations
- 357x competitive advantage at risk
```

---

#### Multi-Domain Questions
```
User: "How does swiping right save data and update Thompson scores?"
Guardian: [Delegates to v8-data-flows-expert + v8-data-models-expert + v8-thompson-mathematician]
Response: Complete flow including:
- 7-layer atomic persistence
- Core Data entities updated
- Thompson Bayesian update (alpha/beta)
- Performance metrics
- Error handling
```

---

#### Package Architecture Questions
```
User: "What packages depend on V7Thompson?"
Guardian: [Delegates to v8-package-architect]
Response:
- 6 packages depend on V7Thompson
- Coupling analysis (Ca=6, Ce=2, I=0.25)
- Critical path analysis
- Impact of changes to V7Thompson
```

---

#### UI/Accessibility Questions
```
User: "Is DeckScreen WCAG 2.1 AA compliant?"
Guardian: [Delegates to v8-ui-components-expert]
Response: Compliance analysis including:
- VoiceOver labels on all interactive elements
- 4.5:1 contrast ratio validation
- Dynamic Type support (small → XXXL)
- Known issues and fixes
```

---

## Self-Update Command

When codebase or documentation changes, update the meta-skill:

```
User: "Update yourself" or "Sync with codebase"
```

**Self-Update Process:**
1. Read all 14 technical docs from `C4_ARCHITECTURE_ANALYSIS/technical`
2. Scan V8 codebase (all 14 packages, 506 Swift files)
3. Compare docs vs code for drift
4. Regenerate domain expert skills from ACTUAL code
5. Report changes to user

**Example Output:**
```
Self-Update Report:
✅ V8 codebase: 506 Swift files (was 335 in docs, +51% drift)
✅ 14 active packages (V7Migration disabled, V7Ads unused)
✅ Updated v8-data-models-expert with 2 new critical bugs
✅ Updated v8-package-architect with new coupling metrics
⚠️ Drift detected: 47 dead code instances found
🔄 All domain experts synchronized with live codebase
```

---

## Self-Diagnostic Command

Detect code issues across the codebase:

```
User: "Diagnose yourself" or "Check for issues"
```

**Self-Diagnostic Process:**
1. Run dead code analysis
2. Validate critical connections
3. Check performance baselines
4. Verify architectural patterns
5. Test data integrity
6. Report findings

**Example Output:**
```
Self-Diagnostic Report:

🔴 CRITICAL BUGS:
1. WorkExperience persistence bug (Line 145) - Data lost on restart
2. Education persistence bug (Line 89) - Only saves to @State
3. 11 disconnected buttons in SettingsScreen

⚠️ WARNINGS:
1. V7Ads package unused (1,850 LOC dead code) - REMOVE
2. V7Migration disabled - COMPLETE or REMOVE
3. 20 empty stub functions in V7Performance - IMPLEMENT

✅ HEALTHY:
- Zero circular dependencies (validated)
- Thompson <10ms requirement met (0.028ms avg)
- All 7 API clients operational
- WCAG 2.1 AA compliance: 95%
```

---

## Sacred Constraints (NEVER VIOLATE)

### 1. Thompson Sampling Performance
- **Requirement:** <10ms per job scoring
- **Current:** 0.028ms avg (357x faster than baseline)
- **Enforcement:** thompson-performance-guardian skill
- **Impact:** 357x competitive advantage at risk if violated

---

### 2. Memory Budget
- **Requirement:** <200MB total app memory
- **Current:** ~150MB typical usage
- **Enforcement:** MemoryManager in V7Performance
- **Impact:** App termination on iOS if exceeded

---

### 3. SacredUI Constants
```swift
public enum SacredUI {
    public static let swipeRightThreshold: Double = 100.0  // SACRED
    public static let swipeLeftThreshold: Double = -100.0  // SACRED
    public static let swipeSuperThreshold: Double = -80.0  // SACRED
}
```
**NEVER modify these values** - Millions of swipes calibrated to these thresholds

---

### 4. UI Performance
- **Requirement:** 60fps for all interactions
- **Current:** 58-60fps (DeckScreen)
- **Enforcement:** LazyVStack, view identity optimization
- **Impact:** Degraded user experience if violated

---

## Known Critical Bugs

### 🚨 1. WorkExperience Persistence Bug
**Location:** `WorkExperienceCollectionStepView.swift:145`
**Issue:** Only saves to `@State`, not Core Data
**Impact:** Work experience data lost on app restart
**Fix:** See v8-data-models-expert for correct implementation

---

### 🚨 2. Education Persistence Bug
**Location:** `EducationAndCertificationsStepView.swift:89`
**Issue:** Only saves to `@State`, not Core Data
**Impact:** Education data lost on app restart
**Fix:** See v8-data-models-expert for correct implementation

---

### ⚠️ 3. SettingsScreen Disconnected Buttons
**Location:** `SettingsScreen.swift` (11 buttons)
**Issue:** Buttons have no action handlers
**Impact:** Non-functional settings UI
**Fix:** See v8-ui-components-expert for implementation

---

## Codebase Statistics (Live)

**Packages:** 15 total (14 active + 1 disabled)
- Level 0: V7Core, V7Embeddings, V7JobParsing, V7Migration (disabled)
- Level 1: V7Thompson, V7Data, V7Performance
- Level 2: V7Services, V7AIParsing, V7ResumeAnalysis
- Level 3: V7AI, V7Ads (unused)
- Level 4: V7Career
- Level 5: V7UI (terminal)

**Files:** 506 Swift files (51% more than docs stated)

**Lines of Code:** ~68,000 LOC
- V7Core: ~8,000
- V7Thompson: ~6,000
- V7UI: ~12,000
- V7Services: ~10,000
- V7AI: ~8,000
- Others: ~24,000

**Core Data:** 14 entities
- 8 profile entities (UserProfile, WorkExperience, Education, Certification, Project, VolunteerExperience, Award, Publication)
- 4 behavioral entities (SwipeRecord, ThompsonArm, CareerQuestion, UserTruths)
- 2 performance entities (JobCache, Preferences)

**API Integrations:** 7 job sources
- Adzuna, Greenhouse, Lever, Jobicy, USAJobs, RSS, RemoteOK

**iOS 26 AI Systems:** 7
- SmartQuestionGenerator, ResumeParser, BehavioralAnalyst, JobFitExplainer, SkillsMatcher, CareerPathRecommender, SalaryEstimator

**SwiftUI Views:** 28 views (DeckScreen is largest at 1,800+ lines)

---

## When to Use Each Domain Expert

### Use v8-thompson-mathematician for:
- Thompson Sampling algorithm questions
- Performance optimization (<10ms requirement)
- Bayesian statistics and Beta distributions
- FastBetaSampler implementation
- ThompsonCache configuration

### Use v8-data-models-expert for:
- Core Data entity questions
- Entity relationships (WorkExperience, Education, etc.)
- Persistence patterns
- Swift 6 Sendable patterns
- Data migration questions

### Use v8-job-sources-expert for:
- API client implementation
- Rate limiting strategies
- Circuit breaker patterns
- Error handling and retry logic
- Adding new job sources

### Use v8-ai-systems-expert for:
- iOS 26 Foundation Models integration
- On-device AI implementation
- ML performance optimization
- Privacy-first architecture
- AI/ML system design

### Use v8-data-flows-expert for:
- Understanding data flow through app
- Multi-layer transaction patterns
- Cross-package data choreography
- Performance bottleneck analysis
- Atomic persistence patterns

### Use v8-ui-components-expert for:
- SwiftUI view questions
- WCAG 2.1 AA accessibility compliance
- MV architecture patterns (no ViewModels)
- SacredUI constants
- UI bug diagnosis

### Use v8-package-architect for:
- Package dependency questions
- Architecture decisions (adding/splitting packages)
- Build optimization and parallelization
- Circular dependency detection
- Coupling analysis (afferent/efferent)
- Dead code detection

---

## Technical Expertise

V8-omniscient-guardian is an expert in:

### Xcode Development
- iOS 26 SDK
- Xcode 16+
- Swift Package Manager (SPM)
- Build configurations (Debug/Release)
- Xcode schemes and targets

### Swift 6
- Strict concurrency mode
- Actor isolation
- Sendable protocol
- @MainActor annotation
- Data race prevention

### SwiftUI
- MV architecture (Model-View, no ViewModels)
- @State, @Binding, @Environment
- @FetchRequest for Core Data
- LazyVStack optimization
- View identity and performance

### Core Data
- NSPersistentContainer
- NSManagedObjectContext (main + background)
- @FetchRequest
- Lightweight migrations
- Thread-safe patterns

### Thompson Sampling
- Beta-Bernoulli conjugate priors
- Bayesian inference
- Multi-armed bandits
- Exploration-exploitation tradeoff
- <10ms performance optimization

### O*NET Taxonomy
- 1,016 occupations
- 636 skills taxonomy
- RIASEC profiles
- Career pathways
- Skills matching

### iOS 26 Foundation Models
- LanguageModel API
- EmbeddingModel API
- VisionModel API
- On-device processing
- Privacy-first design

---

## Collaboration with Other Skills

V8-omniscient-guardian works alongside:

1. **business-planning-manager** - For business strategy and planning
2. **app-narrative-guide** - Ensures features serve core mission
3. **thompson-performance-guardian** - Enforces <10ms requirement
4. **swift-concurrency-enforcer** - Validates Swift 6 patterns
5. **accessibility-compliance-enforcer** - Ensures WCAG 2.1 AA
6. **ai-error-handling-enforcer** - Prevents AI parsing failures
7. **privacy-security-guardian** - Enforces on-device processing

**Delegation Pattern:** V8-omniscient-guardian delegates to domain experts, which may further invoke guardian skills as needed.

---

## Updating This README

When updating V8-omniscient-guardian or domain experts:

1. Run self-update: `Update yourself`
2. Review changes in domain expert skills
3. Update statistics in this README
4. Document new features or capabilities
5. Add new example queries if applicable
6. Update "Known Critical Bugs" section

**Last Updated:** 2025-11-02
**Version:** 1.0.0
**Codebase:** Manifest & Match V8 (iOS 26, Swift 6)

---

## Quick Reference

### Invoke Meta-Skill
```
/skill v8-omniscient-guardian
```

### Self-Update
```
Update yourself
Sync with codebase
```

### Self-Diagnose
```
Diagnose yourself
Check for issues
```

### Query Specific Domain
```
[Ask question] → Guardian auto-delegates to correct domain expert
```

---

## Architecture Summary

```
┌─────────────────────────────────────────────────────────────────┐
│                   V8-OMNISCIENT-GUARDIAN                        │
│                   (Meta-Skill Orchestrator)                     │
│                                                                 │
│  Two-Source Truth:                                             │
│  • Live Codebase (506 files, 68k LOC)                          │
│  • Technical Docs (14 documents)                               │
│  • Drift Detection (51% more files than docs)                  │
└────────────────┬────────────────────────────────────────────────┘
                 │
    ┌────────────┴──────────────┐
    │   Domain Expert Delegation │
    └────────────┬──────────────┘
                 │
    ┌────────────┴───────────────────────────────────────┐
    │                                                     │
    ▼                                                     ▼
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│ v8-thompson-     │  │ v8-data-models-  │  │ v8-job-sources-  │
│ mathematician    │  │ expert           │  │ expert           │
│                  │  │                  │  │                  │
│ Thompson Algo    │  │ Core Data        │  │ API Integrations │
│ <10ms Guarantee  │  │ 14 Entities      │  │ 7 Job Sources    │
│ 357x Advantage   │  │ Persistence Bugs │  │ Rate Limiting    │
└──────────────────┘  └──────────────────┘  └──────────────────┘

    ▼                     ▼                     ▼
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│ v8-ai-systems-   │  │ v8-data-flows-   │  │ v8-ui-components-│
│ expert           │  │ expert           │  │ expert           │
│                  │  │                  │  │                  │
│ iOS 26 AI (7)    │  │ 5 Major Flows    │  │ 28 SwiftUI Views │
│ 100% On-Device   │  │ 7-Layer Atomic   │  │ WCAG 2.1 AA      │
│ Zero API Costs   │  │ 1.2-3s Flows     │  │ SacredUI         │
└──────────────────┘  └──────────────────┘  └──────────────────┘

    ▼
┌──────────────────┐
│ v8-package-      │
│ architect        │
│                  │
│ 5-Level Hierarchy│
│ 14 Packages      │
│ Zero Circular    │
└──────────────────┘
```

---

## Support

For issues, questions, or contributions:
- **Codebase:** `/Users/jasonl/Desktop/ios26_manifest_and_match/manifest and match V8`
- **Documentation:** `/Users/jasonl/Desktop/ios26_manifest_and_match/C4_ARCHITECTURE_ANALYSIS/technical`
- **Skills Directory:** `/Users/jasonl/Desktop/ios26_manifest_and_match/.claude/skills/v8-omniscient-guardian/`

---

## License

This meta-skill system is part of the Manifest & Match V8 project.
