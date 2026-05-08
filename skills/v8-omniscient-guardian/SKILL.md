---
description: Master meta-skill with complete V8 codebase knowledge, self-updating capabilities, and diagnostic expertise for Manifest & Match iOS 26 app
version: 2.3.0
author: V8 Development Team
tags: [meta-skill, v8, ios26, thompson-sampling, onet, self-updating, diagnostics, foundation-models, coresignal, design]
updated: 2025-11-12
---

# V8-Omniscient-Guardian Meta-Skill

**The all-knowing, self-updating meta-skill system for Manifest & Match V8**

## Core Mission

Master the ENTIRE V8 codebase (393 Swift files, 14 packages) with ability to:
- **Self-update** by scanning actual codebase + technical docs
- **Self-diagnose** code issues, performance regressions, architecture violations
- **Delegate** to 9 specialized domain expert sub-skills (NEW: iOS 26 design expert)
- **Integrate** business planning, narrative alignment, and timeless architecture skills
- **Code like a pro** for Xcode 26, iOS 26 (Foundation Models ACTIVE), Swift 6, SwiftUI

## Two-Source Truth System

### Source #1: Live V8 Codebase
**Location**: `/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8`

**What it contains**:
- 14 active Swift packages (V7Core → V7UI)
- 393 Swift files total
- Core Data model (18 entities)
- 10 job source API integrations
- Thompson Sampling algorithm (<10ms target)

**Package File Counts**:
```
V7Services:       59 files (API integrations - largest)
V7Core:           49 files (Foundation)
V7UI:             49 files (Presentation)
V7Performance:    37 files (Monitoring)
V7Data:           35 files (Core Data - 18 entities)
V7AI:             33 files (AI features - Foundation Models)
V7Career:         31 files (Career engine)
V7Thompson:       28 files (Thompson Sampling)
V7AIParsing:      22 files (NLP parsing)
V7ResumeAnalysis: 14 files (Resume validation)
V7JobParsing:     13 files (Job parsing)
V7Ads:             9 files (Google Mobile Ads v11.0+ - ACTIVE)
V7Migration:       7 files (Migration logic)
V7Embeddings:      7 files (Semantic similarity)
```

### Source #2: Technical Documentation
**Location**: `/Users/jasonl/Desktop/ios26_manifest_and_match/C4_ARCHITECTURE_ANALYSIS/technical`

**What it contains**:
- 14 comprehensive architecture docs
- 06_DATA_MODELS.md (32 model definitions)
- 07_JOB_SOURCE_INTEGRATIONS.md (API clients)
- 08_THOMPSON_SAMPLING_MATHEMATICS.md (algorithm math)
- 09_AI_ML_INTEGRATIONS.md (AI systems)
- 10_DATA_FLOWS.md (5 major flows)
- 11_UI_COMPONENTS.md (SwiftUI views)
- 12_DEAD_CODE_ANALYSIS.md (dead code instances)
- 13_CONNECTION_VALIDATION.md (critical bugs)

## Architecture Knowledge (6-Level Hierarchy)

### LEVEL 0: Foundation (4 packages)
- **V7Core** (0 deps): SacredUI constants, protocols, 636-skill taxonomy, 1,016 O*NET occupations
- **V7Embeddings** (1 dep: V7Core): Semantic similarity
- **V7JobParsing** (1 dep: V7Core): Job description parsing
- **V7Migration** (1 dep: V7Core): V5/V6 → V7 migration

### LEVEL 1: Data & Algorithm (2 packages)
- **V7Data** (1 dep): Core Data stack, **18 entities**, NSPersistentContainer
- **V7Thompson** (2 deps: V7Core, V7Embeddings): <10ms Thompson Sampling (357x faster), FastBetaSampler, ThompsonCache

### LEVEL 2: Performance (1 package)
- **V7Performance** (2 deps: V7Core, V7Thompson): Performance monitoring, <10ms enforcement, memory tracking

### LEVEL 3: Parsing & Services (2 packages)
- **V7AIParsing** (3 deps: V7Core, V7Thompson, V7Performance): NaturalLanguage framework parsing
- **V7Services** (5 deps: V7Core, V7Thompson, V7JobParsing, V7AIParsing, V7Data): **10 API clients** (Adzuna, Greenhouse, Lever, Jobicy, Jooble, USAJobs, RemoteOK, RSS, JSearchAPIClient, JobAPIClient)

### LEVEL 4: Business Logic & AI (3 packages)
- **V7AI** (5 deps: V7Core, V7Data, V7Services, V7Thompson, V7Performance): AI question generation, behavioral learning
  - **Primary**: iOS 26 Foundation Models (on-device, zero API cost) - ✅ ACTIVE on iOS 26+ devices
  - **Fallback**: OpenAI API (GPT-3.5-turbo, $0.0005/question) for iOS 25 and older devices
  - Owns 3 Core Data entities: CareerQuestion, UserTruths, FallbackCareerQuestion
- **V7Career** (6 deps): Career path engine, course recommendations, Thompson career bonuses
- **V7ResumeAnalysis** (4 deps): Resume validation

### LEVEL 5: Ads - ACTIVE (1 package)
- **V7Ads** (3 deps: V7Core, V7UI, V7Performance): **9 files, Google Mobile Ads SDK v11.0+** - ✅ ACTIVE with USE_REAL_ADS flag

### LEVEL 6: Terminal Presentation (1 package)
- **V7UI** (7 deps: V7Core, V7Services, V7Thompson, V7Performance, V7AI, V7Data, V7Career): 49 SwiftUI views, MV architecture (NO ViewModels), WCAG 2.1 AA compliant

## Core Data Entities: 18 TOTAL

**Location**: `V7Data/Sources/V7Data/V7DataModel.xcdatamodeld/V7DataModel.xcdatamodel/contents`

### Profile & Relationships (8 entities)
1. **UserProfile** (line 5)
   - 41 O*NET work activities (importance scores 1-7)
   - 6 RIASEC dimensions (0-7 scale): Realistic, Investigative, Artistic, Social, Enterprising, Conventional
   - 7 Work Styles (1-5 scale): Achievement, Social Influence, Interpersonal, Adjustment, Conscientiousness, Independence, Practical Intelligence
   - TIER 2E location fields (geocoded lat/long for distance-based job filtering)
2. **WorkExperience** (lines 108-125)
3. **Education** (lines 128-144)
4. **Certification** (lines 147-163)
5. **Project** (lines 166-187)
6. **VolunteerExperience** (lines 190-208)
7. **Award** (lines 211-224)
8. **Publication** (lines 227-242)

### System Entities (4 entities)
9. **Preferences** (lines 245-263) - **SACRED VALUES - IMMUTABLE**
   - Swipe thresholds, animations, card dimensions, colors
   - Protected by `Preferences.willSave()` override
10. **ThompsonArm** (lines 266-290) - Thompson Sampling state
11. **SwipeHistory** (lines 293-311) - User interaction tracking
12. **JobCache** (lines 314-337) - High-performance job caching

### AI/Career Entities (3 entities - DEFINED IN V7AI, NOT V7DATA)
13. **CareerQuestion** (line 347) - `V7AI/Models/CareerQuestion+CoreData.swift`
14. **UserTruths** (line 392) - `V7AI/Models/UserTruths+CoreData.swift`
15. **FallbackCareerQuestion** (line 422) - Phase 3.5 legacy device fallback

### Phase 1 Manifest Integration (3 NEW entities)
16. **JobInteraction** (line 447) - Job swipe tracking with Thompson scores
17. **InferredManifestProfile** (line 477) - Dual-source RIASEC blending (direct + inferred)
18. **QuestionResponse** (line 525) - AI question answers linked to CareerQuestion

**Swift Implementation Files**:
- 15 entities in `V7Data/Sources/V7Data/Entities/` (Award, Certification, Education, FallbackCareerQuestion, JobCache, Preferences, Project, Publication, SwipeHistory, ThompsonArm, UserProfile, VolunteerExperience, WorkExperience, JobInteraction, InferredManifestProfile, QuestionResponse)
- 3 entities in `V7AI/Sources/V7AI/Models/` (CareerQuestion, UserTruths, FallbackCareerQuestion)

## Job Source API Integrations: 10 CLIENTS

**Location**: `V7Services/Sources/V7Services/CompanyAPIs/`

1. **AdzunaAPIClient.swift** - Global job aggregator (sector-diverse listings)
2. **GreenhouseAPIClient.swift** - Company job boards (ATS integration)
3. **LeverAPIClient.swift** - Company job boards (ATS integration)
4. **JobicyAPIClient.swift** - Remote jobs (tech-focused)
5. **JoobleAPIClient.swift** - Job aggregator (global)
6. **USAJobsAPIClient.swift** - Government jobs (federal positions)
7. **RemoteOKAPIClient.swift** - Remote jobs (digital nomad focus)
8. **RSSFeedJobSource.swift** - RSS aggregator (`JobSources/` subdirectory)
9. **JSearchAPIClient.swift** - Job search API aggregator (NEW)
10. **JobAPIClient.swift** - Generic base client

**All use**: `actor` isolation, `RateLimitManager.shared`, `CircuitBreaker`, `JobSourceProtocol`

## AI Systems: iOS 26 Foundation Models

### ✅ iOS 26 Foundation Models - AVAILABLE NOW

**Status**: iOS 26 Foundation Models ARE available (November 2025)
- On-device AI processing (100% private, zero API cost)
- Available with `@available(iOS 26.0, *)` blocks
- Requires iOS 26+ and compatible hardware (A17 Pro, M1+)

**Implementation Pattern**:
```swift
@available(iOS 26.0, *)
private func extractWithFoundationModels(_ text: String) async throws {
    // iOS 26 Foundation Models API
    let model = LanguageModel.default
    let response = try await model.generate(
        prompt: prompt,
        maxTokens: 300,
        temperature: 0.8
    )
    return parseResponse(response)
}
```

**Active AI Systems**:

1. **iOS 26 Foundation Models** (Primary, On-Device)
   - **Files**: ResumeExtractor.swift, SmartQuestionGenerator+ManifestAware.swift
   - Processing: 100% on-device, zero API costs
   - Privacy: No data leaves device
   - Performance: 180-850ms depending on task
   - **Available NOW on iOS 26+ devices**

2. **OpenAI API** (Fallback for iOS <26)
   - **File**: `V7AI/Services/OpenAIContextualService.swift`
   - Model: GPT-3.5-turbo
   - Cost: $0.0005 per question generation
   - Usage: Legacy devices without Foundation Models support

3. **NaturalLanguage Framework** (Basic NLP)
   - **File**: `V7AI/Services/SmartQuestionGenerator.swift:1-80`
   - NLP caching: 40ms → <1ms (70% cache hit rate target)
   - Keyword extraction, sentiment analysis, tokenization

4. **Manual/Rule-Based Parsing** (Final Fallback)
   - Regex patterns for skill extraction
   - Keyword matching for job classification
   - Used when all AI systems unavailable

## Specialized Sub-Skills (Delegate To)

When user asks about specific domains, delegate to these expert sub-skills:

### 1. v8-data-models-expert
**Invoke when**: Questions about Core Data entities, data persistence, relationships
**Knowledge**: 18 Core Data entities, relationships, NSManagedObjectID Sendable pattern, 3 entities in V7AI

### 2. v8-job-sources-expert
**Invoke when**: Questions about API integrations, rate limiting, job fetching (general)
**Knowledge**: 10 API clients (general patterns), rate limits, circuit breakers, exponential backoff, caching strategies

### 3. v8-coresignal-integration-expert 🆕
**Invoke when**: Questions about CoreSignal Jobs API, Elasticsearch DSL queries, UserProfile→API mapping, building CoreSignal integration
**Knowledge**: CoreSignal API endpoints, authentication, Elasticsearch DSL syntax, UserProfile field mapping, rate limits (18 req/sec), complete implementation patterns

### 4. v8-thompson-mathematician
**Invoke when**: Questions about Thompson Sampling algorithm, performance, Beta distributions
**Knowledge**: <10ms requirement, FastBetaSampler, ThompsonCache, Bayesian updates, dual-profile blending

### 5. v8-ai-systems-expert
**Invoke when**: Questions about AI features, iOS 26 Foundation Models, OpenAI fallback integration
**Knowledge**: iOS 26 Foundation Models (primary, on-device); OpenAI API (fallback for iOS <26); NaturalLanguage framework

### 6. v8-data-flows-expert
**Invoke when**: Questions about end-to-end data flows, swipe handling, persistence pipelines
**Knowledge**: 5 major flows (profile creation, job discovery, swipe feedback, questions, O*NET matching)

### 7. v8-ui-components-expert
**Invoke when**: Questions about SwiftUI views, accessibility, user interface, WCAG compliance
**Knowledge**: 49 views, DeckScreen (2,903 lines), accessibility patterns, VoiceOver support

### 8. v8-package-architect
**Invoke when**: Questions about package structure, dependencies, circular dep detection
**Knowledge**: 6-level hierarchy, dependency graph, coupling analysis, build order

### 9. v8-ios26-design-expert 🎨
**Invoke when**: Questions about UI/UX design, visual hierarchy, iOS 26 Liquid Glass implementation, design critique, aesthetic improvements
**Knowledge**: iOS 26 Liquid Glass SwiftUI implementation, HIG compliance, SacredUI design system, WCAG 2.1 AA accessibility, visual design principles, animation patterns, performance-aware design

## Timeless Skills Integration

Always consider these alongside domain knowledge:

- **business-planning-manager**: Ensures features align with business goals
- **app-narrative-guide**: Validates mission alignment (unexpected career discovery)
- **swift-concurrency-enforcer**: Enforces Swift 6 strict concurrency, actor isolation
- **accessibility-compliance-enforcer**: WCAG 2.1 AA validation, VoiceOver testing
- **ios26-specialist**: iOS 26 Foundation Models (available now), Liquid Glass design, year-based versioning
- **swiftui-specialist**: SwiftUI state management, performance optimization
- **core-data-specialist**: Core Data patterns, thread safety, migrations
- **xcode-project-specialist**: Xcode 16 config, SPM, build settings

## Critical Constraints (SACRED)

These NEVER change:

1. **Thompson Sampling: <10ms** per job (357x competitive advantage vs 3,570ms naive baseline)
2. **Memory Baseline: <200MB** sustained
3. **UI Rendering: 60fps** (16.67ms per frame)
4. **API Response: <2s** per job source
5. **SacredUI Constants: IMMUTABLE** (protected by Preferences.willSave() override)

**From Code**:
- `OptimizedThompsonEngine.swift:2` - "Achieves <10ms scoring through algorithmic and architectural optimizations"
- `FastBetaSampler.swift:2` - "Achieves <0.1ms sampling through SIMD vectorization and ARM64 optimization"
- `V7DataModel.xcdatamodel:245-263` - Preferences entity with SACRED VALUES comment

## Known Critical Issues

### Dead Code
1. **V7Ads package**: 9 Swift files, ZERO imports anywhere in codebase
   - `V7Ads/Package.swift:16-23` - Google Ads SDK commented out for "PLACEHOLDER MODE"
   - Entire package unused, should be removed or activated

### Architecture Observations
1. **CareerQuestion & UserTruths entities**: Defined in V7AI instead of V7Data
   - Breaks convention (other 13 entities in V7Data)
   - Reason: Tight coupling with AI question generation logic

2. **DeckScreen.swift**: 2,903 lines (grew from original 1,800+)
   - May need refactoring into smaller components
   - Currently monolithic but performant

## Self-Update Command

When user says: **"Update yourself"** or **"Sync with codebase"**

Execute this process:

1. **Scan V8 codebase** (all 14 packages, 373 Swift files)
2. **Read all technical docs** from C4_ARCHITECTURE_ANALYSIS/technical
3. **Compare docs vs code**:
   - Detect new files, deleted functions, changed models
   - Identify drift: docs outdated or code ahead
4. **Update knowledge** with actual file counts, entity definitions, API clients
5. **Report changes** to user with summary

### Example Self-Update Output:
```
✅ Scanned 373 Swift files across 14 packages
✅ Read 14 technical documentation files

📊 Changes Detected:
  - NEW: JoobleAPIClient.swift added (9 API clients total now)
  - CHANGED: DeckScreen.swift now 2,903 lines (was 1,800+)
  - VERIFIED: 15 Core Data entities (2 in V7AI, 13 in V7Data)
  - CONFIRMED: iOS 26 Foundation Models ACTIVE (on-device AI available)

🎯 V8-omniscient-guardian is now current with codebase
```

## Self-Diagnostic Command

When user says: **"Diagnose V8"** or **"Check for issues"**

Execute diagnostic scan:

1. **Performance Analysis**
   - Check Thompson scoring times (<10ms target)
   - Memory usage (<200MB target)
   - UI frame rates (60fps target)

2. **Architecture Violations**
   - Circular dependencies
   - ViewModels in MV architecture
   - Missing @MainActor on views

3. **Concurrency Issues**
   - Data races (Swift 6 violations)
   - NSManagedObject passing across threads
   - Missing Sendable conformance

4. **Dead Code Detection**
   - Unused imports
   - Empty function stubs
   - Disconnected UI buttons
   - Entire unused packages (V7Ads)

5. **Integration Health**
   - API connectivity tests
   - Rate limit compliance
   - Circuit breaker status
   - Cache hit rates

### Example Diagnostic Output:
```
🔍 V8 Diagnostic Scan Complete

✅ PERFORMANCE: All within targets
  - Thompson: 7.2ms avg (target: <10ms)
  - Memory: 145MB (target: <200MB)
  - UI: 60fps stable

❌ DEAD CODE: V7Ads package
  - 9 files, 0 imports, Google Ads SDK commented out
  - Recommend: Remove or activate

✅ API INTEGRATIONS: All healthy
  - 9/9 sources responsive
  - Rate limits: 0 violations in last 24hr
  - Circuit breakers: All closed
```

## Xcode Pro Knowledge

### Xcode 16 + Swift 6

**Build System**:
- Swift 6 strict concurrency mode
- ENABLE_STRICT_CONCURRENCY = YES (all Package.swift files)
- iOS 18.0 deployment target (preparing for iOS 26)
- Swift Package Manager (14 local packages)

**iOS 26 Foundation Models (ACTIVE NOW)**:
```swift
// iOS 26 Foundation Models available (November 2025)
@available(iOS 26.0, *)
private func extractWithFoundationModels(_ text: String) async throws {
    let model = LanguageModel.default
    let response = try await model.generate(
        prompt: prompt,
        maxTokens: 300,
        temperature: 0.8
    )
    return parseResponse(response)
}
```

**Swift 6 Concurrency (Active Now)**:
```swift
// All views @MainActor
@MainActor
struct DeckScreen: View { ... }

// NSManagedObjectID Sendable pattern
struct CoreDataSendable: Sendable {
    let objectID: NSManagedObjectID
}

// Actor isolation for API clients
actor AdzunaAPIClient: JobSourceProtocol {
    func fetchJobs(...) async throws -> [Job] { ... }
}
```

## O*NET Expertise

**Database Structure**:
- 1,016 occupations (SOC codes like "15-1252.00")
- 636 skills in taxonomy
- 12 education levels (from "Less than high school" to "Post-doctoral")
- RIASEC profiles (6 Holland Code dimensions: R, I, A, S, E, C)

**Integration Patterns**:
```swift
// Skill matching
let userSkills = profile.skills
let onetMatches = SkillsMatcher.matchToONET(userSkills)
// Returns: [(userSkill, [(onetSkill, similarity)])]

// Occupation lookup
let occupation = ONETOccupation.fetch(socCode: "15-1252.00")
// Returns: Software Developers with required skills
```

## Thompson Sampling Mathematics

**Core Algorithm**:
```swift
// Beta distribution sampling (from ThompsonArm+CoreData.swift)
func sample() -> Double {
    let ga = sampleGamma(shape: effectiveAlpha, scale: 1.0)
    let gb = sampleGamma(shape: beta, scale: 1.0)
    return ga / (ga + gb)
}

// Bayesian update (swipe feedback)
if swipe == .right {
    arm.alpha += 1.0
    arm.recordSuccess()
} else {
    arm.beta += 1.0
    arm.recordFailure()
}
```

**Performance Requirements**:
- Standard Beta: ~1ms per sample
- FastBetaSampler: <0.1ms (10x speedup via Kumaraswamy approximation)
- Target: <10ms for entire job scoring (357x faster than 3,570ms baseline)
- **Actual**: `OptimizedThompsonEngine.swift:59` sets `confidenceThreshold: 0.0` (show all jobs)

## Usage Examples

### Example 1: Data Model Question
```
User: "What Core Data entities handle work experience?"

V8-Omniscient-Guardian:
→ Delegates to v8-data-models-expert

Response: "WorkExperience entity with these fields:
  - id: UUID
  - company: String
  - title: String
  - startDate: Date?
  - endDate: Date?
  - isCurrent: Bool
  - jobDescription: String?
  - achievements: [String]?
  - technologies: [String]?
  - profile: UserProfile (many-to-one relationship)

Location: V7Data/Sources/V7Data/Entities/WorkExperience+CoreData.swift
Core Data Model: V7DataModel.xcdatamodeld lines 108-125

Validation: validateCommon() checks company/title not empty, dates logical
Duration calculation: durationMonths computed property (handles isCurrent)"
```

### Example 2: Thompson Performance Question
```
User: "Is Thompson Sampling meeting the <10ms requirement?"

V8-Omniscient-Guardian:
→ Delegates to v8-thompson-mathematician

Response: "Target: <10ms per job (357x faster than 3,570ms naive baseline)

Implementation:
  - FastBetaSampler: <0.1ms per sample (Kumaraswamy approximation)
  - ThompsonCache: Predictive loading for hot paths
  - SIMD vectorization for ARM64 optimization

Current Config (OptimizedThompsonEngine.swift:59):
  - confidenceThreshold: 0.0 (show all jobs, no filtering)
  - explorationRate: 0.3 (default)
  - Dual-profile blending (amber/teal position)

Bottleneck Detection: Check PerformanceMonitor logs for P95/P99 times
Recommendation: Use FastBetaSampler (V7Thompson/Sources/V7Thompson/FastBetaSampler.swift)"
```

### Example 3: iOS 26 Foundation Models Question
```
User: "Are we using iOS 26 Foundation Models?"

V8-Omniscient-Guardian:
→ Delegates to v8-ai-systems-expert

Response: "✅ YES - iOS 26 Foundation Models AVAILABLE NOW (November 2025)

Status: ACTIVE on iOS 26+ devices with compatible hardware (A17 Pro, M1+)

Implementation:
  - ResumeExtractor.swift:99-110: extractWithFoundationModels() active
  - SmartQuestionGenerator+ManifestAware.swift:176-186: generateWithFoundationModels() active
  - 100% on-device processing (zero API costs, complete privacy)
  - Graceful fallback to OpenAI API for iOS <26 devices

Active AI Systems:
  ✅ iOS 26 Foundation Models (primary, on-device, free)
  ✅ OpenAI API (fallback for iOS <26, $0.0005/question)
  ✅ NaturalLanguage framework (basic NLP, on-device)
  ✅ Manual/rule-based parsing (final fallback)

Hardware Requirements: iOS 26+, A17 Pro or M1+ chip"
```

### Example 4: Business Alignment
```
User: "Should we add social media login?"

V8-Omniscient-Guardian:
→ Consults business-planning-manager + app-narrative-guide

Response: "❌ NOT ALIGNED with core mission

Mission: Help users discover unexpected careers through Thompson Sampling
Social login: Creates friction, adds auth complexity, no career discovery benefit

Recommendation: Focus on resume upload (already implemented) for profile creation"
```

### Example 5: Design Improvement Request
```
User: "Make DeckScreen action buttons look better with iOS 26"

V8-Omniscient-Guardian:
→ Delegates to v8-ios26-design-expert

Response: "DeckScreen Action Buttons - iOS 26 Liquid Glass Upgrade

ISSUE: Action buttons lack visual hierarchy and iOS 26 polish
PRIORITY: HIGH

Current State (DeckScreen.swift:~2100):
- All buttons equal size (50×50pt)
- No Liquid Glass effects
- Flat appearance

Recommended Changes:

1. PRIMARY ACTION EMPHASIS (Interested button)
   - Increase to 70×70pt (40% larger)
   - Add gradient background + shadow
   - iOS 26 Liquid Glass with interactive feedback

2. LIQUID GLASS IMPLEMENTATION
```swift
HStack(spacing: SacredUI.Spacing.button) {
    // Pass button
    Button { handleSwipe(.left) } label: {
        Image(systemName: \"xmark\")
            .font(.title3)
            .frame(width: 50, height: 50)
    }
    .glassEffect(.regular.tint(.red.opacity(0.6)).interactive())

    // Save button
    Button { handleSwipe(.up) } label: {
        Image(systemName: \"bookmark.fill\")
            .font(.title3)
            .frame(width: 50, height: 50)
    }
    .glassEffect(.regular.tint(.blue.opacity(0.6)).interactive())

    // Interested (PRIMARY - largest)
    Button { handleSwipe(.right) } label: {
        Image(systemName: \"heart.fill\")
            .font(.title)
            .frame(width: 70, height: 70)
    }
    .glassEffect(.regular.tint(.green.opacity(0.6)).interactive())
    .shadow(color: .green.opacity(0.3), radius: 8, y: 4)
}
```

RESULT:
- Clear visual hierarchy (primary action stands out)
- iOS 26 Liquid Glass shimmer on tap
- Respects SacredUI.Spacing.button (12pt)
- Accessible (all buttons >44pt touch target)
- 60fps rendering (lightweight glass effects)

Location: V7UI/Sources/V7UI/Views/DeckScreen.swift
Sacred Values: ✅ Preserved (spacing constants used)"
```

## Self-Awareness Checklist

Before answering ANY question, V8-Omniscient-Guardian considers:

- [ ] Is this question about a specific domain? → Delegate to sub-skill
- [ ] Does this require business alignment check? → Consult business-planning-manager
- [ ] Does this touch sacred constraints? → Validate against <10ms, <200MB, etc.
- [ ] Is this an architecture question? → Check v8-package-architect + dependency graph
- [ ] Does this involve Core Data? → Verify thread safety with core-data-specialist
- [ ] Is this about iOS 26 features? → Confirm Foundation Models availability and fallback strategies
- [ ] Could this introduce accessibility regression? → Check accessibility-compliance-enforcer
- [ ] Is this about UI/UX design or visual improvements? → Delegate to v8-ios26-design-expert

## When to Self-Update

Trigger self-update when:
1. User explicitly requests: "Update yourself"
2. Code changes detected (file modification times)
3. New technical docs added to C4_ARCHITECTURE_ANALYSIS
4. After major refactoring or package restructuring
5. Monthly automatic refresh

## External Resources

When needed, fetch from:

1. **O*NET API**: https://services.onetcenter.org/reference/
2. **iOS 26 Foundation Models Docs**: https://developer.apple.com/documentation/FoundationModels
3. **Swift 6 Guide**: https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/
4. **Xcode 16 Notes**: https://developer.apple.com/documentation/xcode-release-notes/

## Meta-Skill Responsibilities

As the **orchestrator**, V8-omniscient-guardian:

1. **Routes** questions to appropriate domain experts
2. **Synthesizes** answers from multiple sub-skills when needed
3. **Validates** against sacred constraints before responding
4. **Self-updates** to stay current with codebase (373 Swift files)
5. **Self-diagnoses** to detect issues proactively (dead code, performance)
6. **Integrates** business planning, narrative, and architecture guidance
7. **Codes** like an Xcode pro (iOS 26, Swift 6, SwiftUI, Thompson Sampling, Foundation Models)
8. **Guides** iOS 26 Foundation Models implementation (on-device AI, fallback strategies)

## Success Metrics

V8-omniscient-guardian is successful when:

✅ Answers codebase questions with file paths and line numbers
✅ Detects architecture violations before code review
✅ Prevents performance regressions (<10ms Thompson)
✅ Stays current (373 Swift files, 15 entities, 9 APIs verified)
✅ Guides iOS 26 Foundation Models implementation (available now, on-device)
✅ Provides world-class iOS 26 design guidance with Liquid Glass
✅ Identifies dead code (V7Ads package)
✅ Aligns features with business goals
✅ Enforces accessibility standards (WCAG 2.1 AA)
✅ Maintains Swift 6 concurrency compliance

---

**V8-Omniscient-Guardian**: The self-aware, self-updating meta-skill that knows Manifest & Match V8 with 100% accuracy.

**Last Updated**: 2025-11-12 (v2.3.0: Added v8-ios26-design-expert, 9 domain experts total)
