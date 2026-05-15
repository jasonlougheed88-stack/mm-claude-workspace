---
description: Package architecture expert with knowledge of V8's 6-level dependency hierarchy, coupling analysis, and build order optimization
version: 2.0.0
author: V8 Development Team
tags: [package-architecture, spm, dependencies, build-systems, v8-domain-expert]
updated: 2025-11-08
---

---
**PACKAGE NAMES — approved 2026-05-15. New build uses these names, NOT V7\* prefixes.**
Full mapping + DAG: `context/PACKAGE_NAMES.md` in the build folder.

| New Name | Old Name |
|---|---|
| CoreTaxonomy | V7Core |
| Persistence | V7Data |
| ScoringEngine | V7Thompson |
| JobPipeline | V7Services |
| DeckUI | V7UI |
| Intelligence | V7AI |
| ResumeParsing | V7AIParsing |
| CareerGrowth | V7Career |
| SemanticMatch | V7Embeddings |
| JobNormalizer | V7JobParsing |
| Monitoring | V7Performance |
| ProfileExtraction | V7ResumeAnalysis |
| AdCards | V7Ads |
| AppShell | ManifestAndMatchV7Package |

Reference codebase paths still use V7\* names — only NEW BUILD code uses new names.
---



# v8-package-architect

**Package Architecture Expert - 6-Level Hierarchy + Dependency Analysis**

## Core Expertise

Master of Swift Package Manager (SPM) architecture in Manifest & Match V8:
- **14-package system** (373 Swift files total)
- Zero circular dependencies (validated)
- Coupling analysis (afferent/efferent metrics)
- Build order & parallelization opportunities
- Critical paths & bottleneck analysis
- Package cohesion & refactoring recommendations

**Source of Truth:**
- Live codebase: `/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8/Packages/`
- Documentation: `/Users/jasonl/Desktop/ios26_manifest_and_match/C4_ARCHITECTURE_ANALYSIS/technical/05_PACKAGE_ARCHITECTURE.md`
- Dependency graph: `/Users/jasonl/Desktop/ios26_manifest_and_match/C4_ARCHITECTURE_ANALYSIS/technical/DEPENDENCY_GRAPH.md`

---

## Package Hierarchy (6 Levels: LEVELS 0-6)

### LEVEL 0: FOUNDATION (Zero External Dependencies)

#### **V7Core** (0 deps)
- **Purpose:** Foundation types, protocols, constants
- **Size:** 48 Swift files (verified)
- **Memory:** <5MB
- **Sacred Components:** SacredUI constants, PerformanceBudget
- **Status:** ✅ STABLE FOUNDATION
- **Afferent Coupling (Ca):** 14 (ALL packages depend on it)
- **Efferent Coupling (Ce):** 0 (depends on NOTHING)
- **Instability (I):** 0.00 (maximally stable)
- **Critical:** Changes cascade to ALL 14 packages

**Issues:**
- 🚨 **LOW COHESION** - Kitchen sink with protocols, constants, SacredUI, SkillTaxonomy, O*NET (1,016 roles, 636 skills)
- 📦 **RECOMMENDATION:** Split into 4 focused packages:
  - V7Foundation (protocols, base types)
  - V7Constants (SacredUI, performance budgets)
  - V7SkillTaxonomy (skills database)
  - V7ONet (O*NET data models)

---

#### **V7Embeddings** (deps: V7Core)
- **Purpose:** Vector embeddings for semantic matching
- **Status:** ⚠️ Framework ready, implementation minimal
- **Use:** Resume/job similarity computation
- **Size:** ~5+ Swift files, ~1,000 LOC
- **Memory:** <5MB
- **Dependencies:** V7Core only
- **Issue:** Incomplete implementation

---

#### **V7JobParsing** (deps: V7Core)
- **Purpose:** Job description parsing and metadata extraction
- **NLP:** Skills extraction, seniority detection
- **Performance:** <2ms per job
- **Size:** ~10+ Swift files, ~2,000 LOC
- **Memory:** <5MB

---

#### **V7Migration** (deps: V7Core) [DISABLED]
- **Purpose:** V5/V6 → V7 data migration
- **Status:** 🔴 Commented out in Package.swift
- **Location:** `/Packages/V7Migration/Package.swift`
- **Recommendation:** Complete or remove (dead code)
- **Size:** ~10+ Swift files, ~2,000 LOC (unused)

---

### LEVEL 1: ALGORITHM & DATA

#### **V7Thompson** (deps: V7Core, V7Embeddings)
- **Purpose:** Thompson Sampling algorithm (<10ms)
- **Size:** ~30+ Swift files, ~6,000 LOC
- **Memory:** <10MB
- **Performance:** 0.028ms avg (357x faster than baseline)
- **Sacred Constraint:** <10ms guarantee enforced
- **Afferent Coupling (Ca):** 6 packages depend on it
- **Efferent Coupling (Ce):** 2 (V7Core, V7Embeddings)
- **Instability (I):** 0.25 (stable algorithm)

**Components:**
- FastBetaSampler (SIMD optimization)
- ThompsonCache (lock-free, 50-entry LRU)
- RealTimeScoring (differential updates)
- SwipePatternAnalyzer (ML fatigue detection)

**Critical:** Performance regression affects entire scoring pipeline

---

#### **V7Data** (deps: V7Core)
- **Purpose:** Core Data persistence layer
- **Entities:** 14 (UserProfile, SwipeHistory, JobCache, etc.)
- **Stack:** NSPersistentContainer + SQLite
- **Concurrency:** viewContext (main) + backgroundContext (private)
- **Size:** ~20+ Swift files, ~4,000 LOC
- **Memory:** 20-50MB (dynamic, grows with user data)
- **Afferent Coupling (Ca):** 8 packages depend on it
- **Efferent Coupling (Ce):** 1 (V7Core)
- **Instability (I):** 0.11 (stable persistence)

**Critical:** Core Data schema changes require migrations

---

#### **V7Performance** (deps: V7Core, V7Thompson)
- **Purpose:** Performance monitoring & enforcement
- **Size:** ~15+ Swift files, ~3,000 LOC
- **Memory:** <5MB
- **Afferent Coupling (Ca):** 5 packages depend on it
- **Efferent Coupling (Ce):** 2 (V7Core, V7Thompson)
- **Instability (I):** 0.29 (stable monitoring)

**Components:**
- PerformanceMonitor (<10ms Thompson validation)
- MemoryManager (<200MB baseline enforcement)
- BiasDetectionService (sector neutrality)
- EmergencyRecoveryProtocol (20 stub functions 🔴)

**Issue:** 20 empty stub functions need implementation or removal

---

### LEVEL 2: SERVICES & PARSING

#### **V7Services** (deps: V7Core, V7Thompson, V7JobParsing, V7AIParsing, V7Data)
- **Purpose:** API integrations for 7 job sources
- **Size:** ~40+ Swift files, ~10,000 LOC
- **Memory:** <15MB
- **Performance:** <2s API call
- **Afferent Coupling (Ca):** 4 packages depend on it
- **Efferent Coupling (Ce):** 5 dependencies
- **Instability (I):** 0.56 (balanced gateway)

**API Clients:**
- AdzunaAPIClient (60 req/min)
- GreenhouseAPIClient (60 req/min)
- LeverAPIClient (100 req/min)
- JobicyAPIClient (10 req/min)
- USAJobsAPIClient (10 req/min)
- RSSFeedJobSource (20 req/min)
- RemoteOKAPIClient

**Patterns:**
- RateLimitManager (token bucket pattern)
- Circuit Breakers (3-5 failure threshold)
- Exponential backoff (1s, 2s, 4s, 8s)

**Bottleneck Risk:** External API changes cascade through service layer

---

#### **V7AIParsing** (deps: V7Core, V7Thompson, V7Performance)
- **Purpose:** Resume parsing with AI/NLP
- **Size:** ~15+ Swift files, ~3,000 LOC
- **Memory:** <10MB
- **Performance:** 500ms-5s (depends on method)

**Components:**
- ResumeParsingService (PDF/text extraction)
- OpenAIClient (LLM integration - optional)
- PDFTextExtractor (PDFKit)
- NaturalLanguage framework integration

**Parsing Methods:**
- Basic: Regex patterns (0.7 confidence)
- AI-Enhanced: OpenAI parsing (0.95 confidence)

**Caching:** LRU cache (50 resumes, SHA256 keyed)

---

#### **V7ResumeAnalysis** (deps: V7Core, V7Data, V7Career, V7AI)
- **Purpose:** Resume validation & analysis
- **Size:** ~10+ Swift files, ~2,000 LOC
- **Memory:** <8MB
- **Performance:** <5s per resume

**Components:**
- Resume validation rules
- UserTruths integration
- ResumeUploadViewModel

**Output:** ParsedResume → 7 Core Data entities

---

### LEVEL 3: BUSINESS LOGIC & AI

#### **V7AI** (deps: V7Core, V7Data, V7Services, V7Thompson, V7Performance)
- **Purpose:** Behavioral learning & career questions
- **Size:** ~35+ Swift files, ~8,000 LOC
- **Memory:** <8MB
- **Performance:** <50ms per question
- **Afferent Coupling (Ca):** 3 packages depend on it
- **Efferent Coupling (Ce):** 6 dependencies
- **Instability (I):** 0.67 (flexible logic)

**Components:**
- CareerQuestion (Core Data entity)
- UserTruths (Core Data entity)
- FastBehavioralLearning (real-time swipe analysis)
- DeepBehavioralAnalysis (background batch)
- SmartQuestionGenerator (contextual Q&A)
- KeychainManager (secure credentials)
- QuestionTemplateLibrary (career templates)
- OpenAIContextualService (LLM prompting)
- QuestionTimingCoordinator (adaptive timing)
- ThompsonBridge (AI ↔ Thompson integration)

**AI Integration:** Foundation Models (iOS 26)
**Privacy:** 100% on-device processing

**Cohesion:** ⚠️ Medium - Multiple responsibilities (could split into V7Questions, V7BehavioralLearning, V7UserTruths)

---

#### **V7Ads** (deps: V7Core, V7UI, V7Performance) [UNUSED]
- **Purpose:** Google AdMob native ads
- **Status:** 🔴 PLACEHOLDER MODE (SDK commented out)
- **Size:** ~15+ Swift files, ~3,000 LOC (DEAD CODE)
- **Memory:** <15MB (unused)
- **Issue:** ❌ **ENTIRE PACKAGE NEVER IMPORTED**
- **Dependency Violation:** ⚠️ V7Ads → V7UI (reverse dependency, breaks level hierarchy)
- **Recommendation:** 🗑️ **REMOVE** unless ads planned for release

**Components (All Unused):**
- AdCardView (5-state enum)
- AdPerformanceTracker (CloudKit sync)
- AdCachingSystem
- ATTConsentManager (App Tracking Transparency)
- ConsentFlowCoordinator
- JobFeedIntegration (1 ad per 10 jobs)

---

### LEVEL 4: FEATURE & CAREER BUILDING

#### **V7Career** (deps: V7Core, V7Data, V7Thompson, V7AI, V7Services, V7Performance)
- **Purpose:** Career building & course recommendations
- **Size:** ~20+ Swift files, ~4,000 LOC
- **Memory:** <10MB
- **Performance:** <100ms
- **Afferent Coupling (Ca):** 2 packages depend on it
- **Efferent Coupling (Ce):** 6 dependencies
- **Instability (I):** 0.75 (flexible feature)

**Components:**
- CareerPathEngine (learning path generation)
- EnrollmentTrackerView (progress tracking)
- CourseProvider APIs (integration ready)
- Career trajectory prediction
- Thompson career bonuses

**UI:** ManifestTabView (4th tab)
**Navigation:** ManifestDestination enum (6 destinations)

---

### LEVEL 5: PRESENTATION (Terminal Package)

#### **V7UI** (deps: ALL 14 packages)
- **Purpose:** SwiftUI presentation layer
- **Size:** ~60+ Swift files, ~12,000 LOC
- **Memory:** <30MB
- **Performance:** 60fps
- **Afferent Coupling (Ca):** 0 (terminal package)
- **Efferent Coupling (Ce):** 14 (depends on ALL active packages)
- **Instability (I):** 1.00 (maximally instable, as designed)

**Direct Dependencies:**
- V7Core, V7Data, V7Thompson, V7Services, V7AI, V7AIParsing, V7JobParsing, V7ResumeAnalysis, V7Embeddings, V7Performance, V7Career

**Architecture:** MV (NO ViewModels)
**Concurrency:** @MainActor on all views
**Sacred UI:** Constants protected from modification

**Screens:**
- DeckScreen (1,800+ lines, job swipe interface)
- ProfileScreen (user data management)
- HistoryScreen (application tracker)
- ManifestTabView (career building hub)

**Bottleneck Risk:** Changes in ANY dependency break UI compilation

---

## Package Dependency Rules (SACRED)

### 1. Zero Circular Dependencies
✅ **Validated:** Zero circular dependencies detected
- Acyclic directed graph enforced
- V7Core has 0 external dependencies
- V7UI is terminal (only depends on, never depended on)
- **Exception:** V7Ads → V7UI (ONE-WAY only, but entire package unused)

### 2. Level-Based Dependencies
- Packages can only depend on same level or lower
- Level 0 → Level 1 → Level 2 → Level 3 → Level 4 → Level 5
- No skipping levels (except V7Core, which all can depend on)

### 3. Protocol-Based Boundaries
- Services communicate via protocols (JobSourceProtocol, etc.)
- Dependency inversion for testability
- Mock implementations for unit tests

---

## Coupling Analysis

### Instability Metrics

| Package | Afferent (Ca) | Efferent (Ce) | Instability (I) | Category |
|---------|---------------|---------------|-----------------|----------|
| V7Core | 14 | 0 | 0.00 | Stable Foundation |
| V7Thompson | 6 | 2 | 0.25 | Stable Algorithm |
| V7Data | 8 | 1 | 0.11 | Stable Persistence |
| V7Performance | 5 | 2 | 0.29 | Stable Monitoring |
| V7Services | 4 | 5 | 0.56 | Balanced Gateway |
| V7AI | 3 | 6 | 0.67 | Flexible Logic |
| V7Career | 2 | 6 | 0.75 | Flexible Feature |
| V7UI | 0 | 14 | 1.00 | Terminal (Instable) |

**Instability Interpretation:**
- **I = 0.0** - Maximally stable (V7Core)
- **I = 0.5** - Balanced
- **I = 1.0** - Maximally instable (V7UI, as designed for terminal package)

**Key Insight:** Instability increases with level number, following Stable Dependencies Principle.

---

## Critical Path Analysis

### Bottlenecks (High Fan-In)

#### 1. 🔴 V7Core (Ca = 14, CRITICAL PATH)
**Risk:** Changes cascade to ALL packages
**Impact:** Build time, testing scope, deployment complexity
**Mitigation:**
- Strict API stability guarantees
- Semantic versioning enforcement
- Extensive test coverage (>90%)
- Avoid breaking changes
- **Refactor:** Split into 4 focused packages (V7Foundation, V7Constants, V7SkillTaxonomy, V7ONet)

---

#### 2. ⚠️ V7Thompson (Ca = 6, PERFORMANCE CRITICAL)
**Risk:** Performance regression affects entire scoring pipeline
**Impact:** <10ms sacred constraint violation breaks user experience
**Mitigation:**
- <10ms constraint enforced in CI/CD
- Performance tests run on every PR
- Benchmark suite with 357x baseline tracking
- Guardian skill: thompson-performance-guardian

---

#### 3. ⚠️ V7Data (Ca = 8, DATA INTEGRITY CRITICAL)
**Risk:** Core Data schema changes require migrations
**Impact:** Data loss, migration failures, user churn
**Mitigation:**
- Lightweight migrations preferred
- V7Migration package for complex migrations
- Rollback procedures documented
- Backup before major changes

---

### Bottlenecks (High Fan-Out)

#### 1. 🔴 V7UI (Ce = 14, INTEGRATION COMPLEXITY)
**Risk:** Changes in ANY dependency break UI compilation
**Impact:** Brittle build, long compilation times
**Mitigation:**
- Protocol-based contracts with dependencies
- Snapshot tests for UI stability
- Feature flags for gradual rollout
- Comprehensive integration tests
- **Refactor:** Reduce dependencies (use protocols where possible)

---

#### 2. ⚠️ V7Services (Ce = 5, EXTERNAL API DEPENDENCY)
**Risk:** External API changes cascade through service layer
**Impact:** Job fetching failures, degraded user experience
**Mitigation:**
- Adapter pattern for each API
- Circuit breakers prevent cascading failures
- Fallback to cached data
- Graceful degradation strategies

---

## Build Order & Parallelization

### Critical Path Build Order

```
1. V7Core (0 deps) → Build first [~8-10s]

2. Parallel Build (depends on V7Core only):
   - V7Embeddings        [~3s]
   - V7JobParsing        [~3s]
   - V7Migration (DISABLED)

3. Parallel Build (depends on Level 0-1):
   - V7Thompson          [~8s]  (deps: V7Core, V7Embeddings)
   - V7Data              [~5s]  (deps: V7Core)

4. V7Performance         [~4s]  (deps: V7Core, V7Thompson)

5. Parallel Build (depends on Level 0-2):
   - V7Services          [~12s] (deps: V7Core, V7Thompson, V7JobParsing, V7AIParsing, V7Data)
   - V7AIParsing         [~5s]  (deps: V7Core, V7Thompson, V7Performance)

6. Parallel Build (depends on Level 0-3):
   - V7AI                [~10s] (deps: V7Core, V7Data, V7Services, V7Thompson, V7Performance)
   - V7ResumeAnalysis    [~4s]  (deps: V7Core, V7Data, V7Career, V7AI)

7. V7Career              [~6s]  (deps: V7Core, V7Data, V7Thompson, V7AI, V7Services, V7Performance)

8. V7UI (deps: ALL above) → Build last [~15s]
```

**Total Sequential Build Time:** ~75-80 seconds
**With Parallelization:** ~50-55 seconds (35% faster)

**Longest Critical Path:** V7Core → V7Embeddings → V7Thompson → V7Performance → V7Services → V7AI → V7Career → V7UI

**Parallelization Opportunities:** Steps 2, 3, 5, 6 can build concurrently

---

## Package Cohesion Analysis

### ✅ High Cohesion (Good)

- **V7Thompson** - Single responsibility: Thompson Sampling algorithm
- **V7Data** - Single responsibility: Core Data persistence
- **V7JobParsing** - Single responsibility: Job description parsing
- **V7Embeddings** - Single responsibility: Vector embeddings

---

### ⚠️ Medium Cohesion (Acceptable)

**V7AI** - Multiple responsibilities: Questions, UserTruths, Behavioral Learning
- Could split into: V7Questions, V7BehavioralLearning, V7UserTruths
- Current grouping acceptable for now (semantic cohesion)

**V7Services** - Multiple responsibilities: 7 API clients + coordination
- Could split into: V7JobAPIs, V7ServiceCoordination
- Current grouping acceptable (all job fetching related)

---

### ❌ Low Cohesion (Needs Improvement)

**V7Core** - Kitchen sink: Protocols, Constants, SacredUI, SkillTaxonomy, O*NET
- **Should split into:**
  - V7Foundation (protocols, base types)
  - V7Constants (SacredUI, PerformanceBudget)
  - V7SkillTaxonomy (skills database, 636 skills)
  - V7ONet (O*NET data, 1,016 roles)
- **Risk:** V7Core becoming "god package"
- **Recommendation:** Refactor in Phase 2

---

## Dependency Injection Patterns

### 1. Environment-Based Injection (Core Data)
```swift
// In V7Data
extension EnvironmentValues {
    var managedObjectContext: NSManagedObjectContext { ... }
}

// In V7UI
@Environment(\.managedObjectContext) var context
```

---

### 2. Property-Based Injection (Thompson Engine)
```swift
// In V7UI/DeckScreen
@State var jobCoordinator = JobDiscoveryCoordinator()

init(thompsonEngine: ThompsonSamplingEngine = .default) {
    self.jobCoordinator = JobDiscoveryCoordinator(engine: thompsonEngine)
}
```

---

### 3. Protocol-Based Injection (Job Sources)
```swift
// In V7Services
protocol JobSourceProtocol {
    func fetchJobs(query: JobSearchQuery) async throws -> [RawJobData]
}

// In JobDiscoveryCoordinator
func registerSource(_ source: JobSourceProtocol) { ... }
```

---

## Dependency Violations & Anti-Patterns

### ❌ VIOLATION 1: V7Ads → V7UI (Reverse Dependency)
**Location:** `/Packages/V7Ads/Package.swift:25`
**Issue:** Lower-level package (V7Ads, Level 3) depends on higher-level (V7UI, Level 5)
**Impact:** Breaks level-based architecture
**Current Status:** Entire V7Ads package is UNUSED anyway
**Resolution:** Remove V7Ads package entirely

**Better Design (if ads were needed):**
```swift
// In V7Core (Level 0)
protocol AdPlacementDelegate {
    func placeAd(at index: Int, in deck: [JobCard])
}

// In V7UI (Level 5)
class DeckScreen: AdPlacementDelegate {
    func placeAd(at index: Int, in deck: [JobCard]) { ... }
}

// In V7Ads (Level 3)
class AdManager {
    weak var delegate: AdPlacementDelegate?
}
```

---

### ⚠️ WARNING: V7Core Growing Too Large
**Issue:** 50+ files, 8,000+ LOC in single package
**Risk:** Becomes "god package" with low cohesion
**Recommendation:** Split into:
- V7Foundation (protocols, base types)
- V7Constants (SacredUI, performance budgets)
- V7SkillTaxonomy (skills database, 636 skills)
- V7ONet (O*NET data, 1,016 roles)

---

## Swift Package Manager Configuration

### Shared Configuration (Packages/Shared.xcconfig)
```
SWIFT_VERSION = 6.0
IPHONEOS_DEPLOYMENT_TARGET = 18.0
MACOSX_DEPLOYMENT_TARGET = 15.0
ENABLE_STRICT_CONCURRENCY = YES
SWIFT_UPCOMING_FEATURE_CONCURRENCY = YES
```

### Per-Package Package.swift Structure
```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "V7{PackageName}",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(name: "V7{PackageName}", targets: ["V7{PackageName}"])
    ],
    dependencies: [
        .package(path: "../V7Core"),
        // Other local dependencies
    ],
    targets: [
        .target(
            name: "V7{PackageName}",
            dependencies: ["V7Core"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "V7{PackageName}Tests",
            dependencies: ["V7{PackageName}"]
        )
    ]
)
```

---

## Build Configurations

### Debug
- Optimizations: None (`-Onone`)
- Assertions: Enabled
- Logging: Verbose
- Thompson performance: Warning if >10ms
- Memory tracking: Enabled

### Release
- Optimizations: Whole Module (`-O`)
- Assertions: Disabled (except Thompson <10ms)
- Logging: Errors only
- Dead code stripping: Enabled
- Bitcode: No (iOS 14+ deprecated)

---

## Concurrency Model (Swift 6)

### Actor Isolation
- **Actors:** ResumeParser, BehavioralEventLog, RateLimitManager, SkillTaxonomyLoader
- **@MainActor:** All SwiftUI views, AppState, ProfileManager
- **Sendable:** NSManagedObjectID wrapper, all value types

### Thread Safety Patterns
```swift
// Core Data context access
await context.perform {
    // Thread-safe Core Data operations
}

// Actor message passing
let result = await someActor.processData(input)

// @MainActor isolated functions
@MainActor
func updateUI() {
    // Guaranteed main thread
}
```

---

## Testing Strategy

### Unit Tests (Per Package)
- Target: V7{PackageName}Tests
- Pattern: One test target per package
- Mocks: Protocol-based mocking
- Coverage: Aim for 70%+ on critical paths

### Integration Tests
- Location: `/Tests/IntegrationTests/`
- Scope: Cross-package interactions
- Focus: Thompson scoring, job discovery pipeline

### Performance Tests
- Location: `/Tests/PerformanceTests/`
- Benchmarks: Thompson <10ms, API <2s, UI 60fps
- Profiling: Instruments.app integration

---

## Package Statistics

| Package | Swift Files | Lines of Code | Dependencies | Memory | Performance Target |
|---------|-------------|---------------|--------------|--------|--------------------|
| V7Core | 50+ | ~8,000 | 0 | <5MB | - |
| V7Thompson | 30+ | ~6,000 | 2 | <10MB | <10ms per job |
| V7Data | 20+ | ~4,000 | 1 | 20-50MB | <100ms save |
| V7Services | 40+ | ~10,000 | 5 | <15MB | <2s API call |
| V7AI | 35+ | ~8,000 | 6 | <8MB | <50ms per question |
| V7UI | 60+ | ~12,000 | 14 | <30MB | 60fps |
| V7AIParsing | 15+ | ~3,000 | 3 | <10MB | 500ms-5s |
| V7JobParsing | 10+ | ~2,000 | 1 | <5MB | <2ms per job |
| V7ResumeAnalysis | 10+ | ~2,000 | 4 | <8MB | <5s per resume |
| V7Embeddings | 5+ | ~1,000 | 1 | <5MB | TBD |
| V7Performance | 15+ | ~3,000 | 2 | <5MB | <1ms overhead |
| V7Career | 20+ | ~4,000 | 6 | <10MB | <100ms |
| V7Ads | 15+ | ~3,000 | 3 | <15MB | UNUSED |
| V7Migration | 10+ | ~2,000 | 1 | <5MB | DISABLED |
| **TOTAL** | **335+** | **~68,000** | **-** | **<200MB** | **-** |

---

## Dead Code Detection Results

### 🔴 Unused Packages
- ❌ **V7Ads** - Never imported anywhere (1,850 LOC dead code)
  - **Action:** REMOVE entire package
  - **Impact:** Eliminates 15+ files, simplifies dependency graph

### ⚠️ Disabled Packages
- ⚠️ **V7Migration** - Commented out in Package.swift
  - **Action:** COMPLETE or REMOVE
  - **Status:** Currently in limbo (dead code)

### ⚠️ Incomplete Packages
- ⚠️ **V7Embeddings** - Framework exists but minimal implementation
  - **Action:** Complete vector similarity implementation
- ⚠️ **V7Performance** - 20 empty stub functions in EmergencyRecoveryProtocol
  - **Action:** Implement or remove stubs

---

## Dependency Health Metrics

| Metric | Value | Status | Target |
|--------|-------|--------|--------|
| Total Packages | 15 | ⚠️ | 12-18 (acceptable) |
| Active Packages | 14 | ✅ | 12-18 |
| Max Depth | 5 levels | ✅ | <7 levels |
| Circular Deps | 0 | ✅ | 0 |
| V7Core Fan-Out | 0 | ✅ | 0 (stable foundation) |
| V7Core Fan-In | 14 | ⚠️ | <10 (high coupling) |
| V7UI Fan-Out | 14 | ⚠️ | <12 (high coupling) |
| Unused Packages | 1 (V7Ads) | ❌ | 0 |
| Disabled Packages | 1 (V7Migration) | ⚠️ | 0 |

---

## Recommendations

### 🔴 Immediate (This Sprint)
1. ✅ Remove V7Ads package (never imported, 15+ dead files, 1,850 LOC)
2. ✅ Complete or remove V7Migration (currently disabled)
3. ⚠️ Document V7Ads → V7UI exception pattern (or remove with package)
4. ✅ Implement 20 empty stub functions in V7Performance or remove

### ⚠️ Short-Term (Next Sprint)
5. ⚠️ Split V7Core into 4 focused packages (V7Foundation, V7Constants, V7SkillTaxonomy, V7ONet)
6. ⚠️ Reduce V7UI dependencies (use protocols where possible)
7. ✅ Add dependency visualization tool to CI/CD
8. ⚠️ Complete V7Embeddings vector similarity implementation

### 📦 Long-Term (Before V8)
9. Enforce dependency rules via Swift Package Plugin
10. Add automated circular dependency detection
11. Track coupling metrics in CI/CD dashboard
12. Extract V7Testing - Shared test utilities across packages
13. Add V7Networking - Abstract URLSession for better testability
14. Modularize V7UI - Split into V7UIComponents + V7UIScreens

---

## Critical Inter-Package Contracts

### V7Thompson ← → V7Services
**Contract:** Thompson scores jobs fetched by Services
```swift
// V7Services provides
struct RawJobData { ... }

// V7Thompson consumes
func score(job: RawJobData, profile: UserProfile) -> ThompsonScore
```

---

### V7Data ← → V7UI
**Contract:** UI reads/writes Core Data via shared context
```swift
// V7Data provides
@Environment(\.managedObjectContext) var context

// V7UI uses
@FetchRequest(entity: WorkExperience.entity(), ...)
var experiences: FetchedResults<WorkExperience>
```

---

### V7AI ← → V7Thompson
**Contract:** AI provides bonus multipliers for Thompson scoring
```swift
// V7AI provides
func calculateThompsonBonus(for job: JobDescription) -> Double

// V7Thompson consumes
finalScore = baseScore * aiBonus
```

---

### V7Services ← → V7Performance
**Contract:** Services report metrics, Performance enforces budgets
```swift
// V7Services reports
performanceMonitor.record(responseTime: duration, source: sourceId)

// V7Performance enforces
guard responseTime < budgets.apiTimeout else { circuitBreak() }
```

---

## Tools for Dependency Visualization

### Recommended
1. **Swift Package Graph** - Built-in `swift package show-dependencies`
2. **Graphviz** - Generate visual graphs from Package.swift
3. **XcodeGen** - Manage project structure as code
4. **SwiftLint** - Custom rules for dependency violations

### Example Graphviz Generation
```bash
swift package show-dependencies --format dot > deps.dot
dot -Tpng deps.dot -o dependency_graph.png
```

---

## Summary

**Total Packages:** 15 (14 active + 1 disabled)
**Architecture:** 5-level hierarchy (V7Core → V7UI)
**Dependencies:** Acyclic, protocol-based, testable
**Concurrency:** Swift 6 strict concurrency with actors
**Performance:** <10ms Thompson, <200MB memory, 60fps UI
**Code Quality:** 68,000+ lines, 335+ Swift files

### 🟢 Strengths:
- ✅ Zero circular dependencies (validated)
- ✅ Clean 5-level hierarchy
- ✅ Stable foundation (V7Core, I=0.00)
- ✅ Terminal presentation layer (V7UI, I=1.00)
- ✅ Protocol-based boundaries for testability

### 🔴 Critical Issues:
- ❌ V7Ads package unused (1,850 LOC dead code) → REMOVE
- ❌ V7Migration disabled → COMPLETE or REMOVE
- ⚠️ V7Core too large (low cohesion) → SPLIT into 4 packages
- ⚠️ V7Performance has 20 empty stubs → IMPLEMENT or REMOVE

### ⚠️ Warnings:
- High coupling on V7UI (14 deps) → Use protocols to reduce
- V7Core high fan-in (14 dependents) → Requires API stability
- V7Ads → V7UI reverse dependency → Moot (package unused)

### 🎯 Critical Paths:
1. **V7Core** → (affects all 14 packages)
2. **V7Thompson** → (affects 6 packages, performance critical)
3. **V7Data** → (affects 8 packages, data integrity critical)

### 📊 Build Performance:
- **Sequential:** ~75-80 seconds
- **Parallelized:** ~50-55 seconds (35% faster)
- **Parallelization Stages:** 4 (steps 2, 3, 5, 6)

---

## Usage Examples

### Query: "What packages depend on V7Thompson?"
**Answer:** 6 packages depend on V7Thompson:
1. V7Services (scores jobs from APIs)
2. V7Performance (monitors Thompson <10ms)
3. V7AIParsing (uses Thompson for resume scoring)
4. V7AI (provides bonus multipliers to Thompson)
5. V7Career (uses Thompson for career path scoring)
6. V7UI (displays Thompson scores in DeckScreen)

---

### Query: "Why is V7Core so critical?"
**Answer:** V7Core is the FOUNDATION (Level 0) with:
- **Afferent Coupling (Ca):** 14 (ALL packages depend on it)
- **Efferent Coupling (Ce):** 0 (depends on NOTHING)
- **Instability (I):** 0.00 (maximally stable)
- **Impact:** ANY change cascades to all 14 packages
- **Mitigation:** Strict API stability, semantic versioning, >90% test coverage

---

### Query: "What's the build order for parallelization?"
**Answer:** 8-step build with 4 parallel stages:
1. V7Core (sequential, 0 deps)
2. Parallel: V7Embeddings, V7JobParsing
3. Parallel: V7Thompson, V7Data
4. V7Performance (sequential)
5. Parallel: V7Services, V7AIParsing
6. Parallel: V7AI, V7ResumeAnalysis
7. V7Career (sequential)
8. V7UI (sequential, terminal)

**Speedup:** 35% faster (50s vs 75s)

---

### Query: "Should we remove V7Ads?"
**Answer:** 🔴 **YES, IMMEDIATELY**
- **Usage:** NEVER imported anywhere (0 references)
- **Size:** 15+ files, ~3,000 LOC (1,850 LOC dead code)
- **Violation:** V7Ads → V7UI reverse dependency (breaks architecture)
- **Impact:** Simplifies dependency graph, reduces build time
- **Action:** Delete `/Packages/V7Ads/` directory

---

### Query: "Why is V7UI instability 1.00?"
**Answer:** V7UI is a TERMINAL package (Level 5):
- **Afferent Coupling (Ca):** 0 (nothing depends on it)
- **Efferent Coupling (Ce):** 14 (depends on everything)
- **Instability (I):** Ce/(Ca+Ce) = 14/(0+14) = 1.00
- **By Design:** Terminal packages SHOULD be maximally instable (flexible to change)
- **Stable Dependencies Principle:** High-level packages (UI) depend on low-level (Core)

---

### Query: "What's the critical path for builds?"
**Answer:** Longest dependency chain (8 packages):
```
V7Core → V7Embeddings → V7Thompson → V7Performance →
V7Services → V7AI → V7Career → V7UI
```
**Impact:** Changes to V7Core ripple through entire chain
**Build Time:** ~50s with parallelization (Step 1→8)

---

## When to Use This Skill

Invoke v8-package-architect for:
- 📦 Package dependency questions ("What depends on X?")
- 🏗️ Architecture decisions (adding new package, splitting existing)
- ⚡ Build optimization (parallelization, critical path analysis)
- 🔄 Circular dependency concerns
- 📊 Coupling analysis (afferent/efferent, instability metrics)
- 🧹 Dead code detection (unused packages, disabled packages)
- 🎯 Critical path analysis (bottlenecks, high fan-in/fan-out)
- 📐 Refactoring recommendations (package cohesion, splitting)
- 🔧 Swift Package Manager configuration
- 🧪 Testing strategy (unit tests per package, integration tests)

**Collaboration:** Works with all domain expert skills for cross-package concerns.
