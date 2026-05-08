---
name: manifestandmatch-v7-coding-standards
description: Deep codebase knowledge ensuring all code perfectly matches ManifestAndMatchV7 patterns, naming conventions, concurrency rules, and sacred constraints
allowed-tools:
  - Read
  - Grep
  - Glob
  - Edit
  - Write
---

# ManifestAndMatchV7 Coding Standards
**AI Assistant Skill for Deep Codebase Understanding**

Ensures all code written perfectly matches ManifestAndMatchV7 architectural patterns, conventions, and constraints.

---

## SKILL PURPOSE

This skill enforces the coding standards, patterns, and architectural rules extracted from the ManifestAndMatchV7 codebase. Use this skill EVERY TIME you write code for this project.

---

## 1. TYPE SYSTEM RULES

### When to Use Each Type

**struct** = Immutable data containers (ALWAYS Sendable)
```swift
// CORRECT - Data model
public struct Job: Identifiable, Sendable {
    public let id: UUID
    public let title: String
    public let company: String
}

public struct ThompsonScore: Codable, Equatable, Sendable {
    public let personalScore: Double
    public let professionalScore: Double
}
```

**class** = Long-lived objects with identity, singletons, @Observable state
```swift
// CORRECT - Observable state on MainActor
@Observable
@MainActor
public final class AppState {
    public var selectedTab: Int = 0
    public var jobs: [Job] = []
}

// CORRECT - Singleton pattern
@MainActor
public final class PerformanceMonitorRegistry: @unchecked Sendable {
    public static let shared = PerformanceMonitorRegistry()
    private init() {}
}
```

**enum** = Fixed set of cases, error types, configuration options
```swift
// CORRECT - Error handling
public enum BudgetViolationType: String, Sendable, CaseIterable {
    case memory = "Memory budget exceeded"
    case cpu = "CPU budget exceeded"
    case thompsonSampling = "Thompson sampling >10ms"
}

// CORRECT - Configuration options
public enum JobType: String, Codable, CaseIterable {
    case fullTime = "Full-time"
    case partTime = "Part-time"
    case contract = "Contract"
}
```

**actor** = Background processing with mutable state (thread-safe)
```swift
// CORRECT - Background state isolation
actor StateUpdateActor {
    func performUpdate<T>(_ operation: @Sendable () async throws -> T) async rethrows -> T {
        try await operation()
    }
}
```

---

## 2. CONCURRENCY RULES (Swift 6 Strict Concurrency)

### @MainActor Usage (UI Thread)

**ALWAYS use @MainActor for:**
- Observable state classes (AppState, StateCoordinator)
- UI-related classes (view models, coordinators)
- Singletons that UI depends on (PerformanceMonitorRegistry)

```swift
// PATTERN: Observable state
@Observable
@MainActor
public final class AppState {
    public var selectedTab: Int = 0
    // All properties automatically thread-safe
}

// PATTERN: Main thread coordinator
@MainActor
public final class OptimizedThompsonEngine: @unchecked Sendable {
    // Thompson algorithm isolated to main thread for consistency
}
```

### actor Usage (Background Thread)

**Use actor for:**
- Background processing with mutable state
- Thread-safe operations that don't need main thread

```swift
// PATTERN: Background actor
actor StateUpdateActor {
    func performUpdate<T>(_ operation: @Sendable () async throws -> T) async rethrows -> T {
        try await operation()
    }
}
```

### Sendable Conformance

**ALWAYS make these types Sendable:**
- All structs (data models)
- All enums
- Protocols that cross actor boundaries

```swift
// PATTERN: Sendable data models
public struct Job: Identifiable, Sendable { }
public struct ThompsonScore: Codable, Equatable, Sendable { }
public enum SwipeAction: String, Codable, Sendable { }

// PATTERN: Sendable protocols
public protocol PerformanceMonitorProtocol: Sendable {
    func getCurrentMemoryUsage() async -> UInt64
}
```

### @unchecked Sendable Pattern

**Use ONLY for:**
- Singletons with internal synchronization
- Types that are thread-safe by design but can't prove it to compiler

```swift
// PATTERN: Singleton with @unchecked Sendable
@MainActor
public final class PerformanceMonitorRegistry: @unchecked Sendable {
    public static let shared = PerformanceMonitorRegistry()
    private var monitors: [String: any PerformanceMonitorProtocol] = [:]
}
```

### nonisolated Pattern

**Use for:**
- Protocol conformance across actor boundaries
- Properties that don't access isolated state

```swift
// PATTERN: nonisolated protocol conformance
@MainActor
public final class OptimizedThompsonEngine: ThompsonMonitorable {
    nonisolated public var systemIdentifier: String {
        "ThompsonEngine-\(ObjectIdentifier(self).hashValue)"
    }

    nonisolated public func getThompsonMetrics() async -> ThompsonPerformanceMetrics {
        return await MainActor.run {
            // Access MainActor state safely
        }
    }
}
```

---

## 3. NAMING CONVENTIONS

### File Names
**Pattern:** `{ComponentName}{Type}.swift`

```
✅ CORRECT:
OptimizedThompsonEngine.swift
FastBetaSampler.swift
ThompsonCache.swift
PerformanceBudget.swift
MemoryBudgetManager.swift
JobDiscoveryCoordinator.swift

❌ WRONG:
optimized_thompson_engine.swift
thompson-cache.swift
PerformanceBudgetFile.swift
```

### Type Names (PascalCase)
```swift
✅ CORRECT:
class OptimizedThompsonEngine
struct ThompsonScore
enum JobType
actor StateUpdateActor
protocol PerformanceMonitorable

❌ WRONG:
class optimizedThompsonEngine
struct thompson_score
enum jobType
```

### Function Names (camelCase)
```swift
✅ CORRECT:
func scoreJobs()
func processInteraction()
func getCurrentMemoryUsage()
func validateStateConsistency()

❌ WRONG:
func ScoreJobs()
func process_interaction()
func GetCurrentMemoryUsage()
```

### Variable Names (camelCase)
```swift
✅ CORRECT:
let currentJobIndex: Int
var selectedTab: Int
private var cachedMemoryUsage: Double

❌ WRONG:
let CurrentJobIndex: Int
var selected_tab: Int
private var CachedMemoryUsage: Double
```

### Protocol Names (Capability + "able")
```swift
✅ CORRECT:
protocol PerformanceMonitorable
protocol ThompsonMonitorable
protocol JobDiscoveryMonitorable
protocol Sendable

❌ WRONG:
protocol PerformanceMonitor
protocol ThompsonMonitoring
protocol IPerformanceMonitor
```

### Constants (camelCase, NOT SCREAMING_CASE)
```swift
✅ CORRECT:
public static let thompsonSampleTarget: TimeInterval = 0.010
public static let memoryBaselineMB: Double = 200.0
public static let maxAppMemory: UInt64 = 300_000_000

❌ WRONG:
public static let THOMPSON_SAMPLE_TARGET: TimeInterval = 0.010
public static let MEMORY_BASELINE_MB: Double = 200.0
```

---

## 4. PACKAGE ARCHITECTURE RULES

### Zero Circular Dependencies (SACRED)

**V7Core = Foundation (ZERO dependencies)**
```swift
// V7Core/Package.swift
dependencies: [], // MUST be empty - foundation layer
```

**All Packages Depend on V7Core**
```swift
// V7Thompson/Package.swift
dependencies: [.package(path: "../V7Core")]

// V7Services/Package.swift
dependencies: [
    .package(path: "../V7Core"),
    .package(path: "../V7Thompson")
    // NO V7Performance - would create circular dependency
]
```

### Protocol-Based Cross-Package Communication

**Define protocols in V7Core:**
```swift
// V7Core/Sources/V7Core/Protocols/PerformanceMonitorProtocol.swift
public protocol PerformanceMonitorProtocol: Sendable {
    var systemIdentifier: String { get }
    func getCurrentMemoryUsage() async -> UInt64
}
```

**Implement in other packages:**
```swift
// V7Performance/Sources/V7Performance/...
extension ProductionPerformanceMonitor: PerformanceMonitorProtocol {
    // Implementation
}
```

### Package Responsibility Boundaries

```
V7Core       → State, protocols, sacred constants (ZERO dependencies)
V7Thompson   → Thompson Sampling algorithm (depends: V7Core)
V7Services   → Job discovery, APIs (depends: V7Core, V7Thompson)
V7Performance→ Monitoring, budgets (depends: V7Core, V7Thompson)
V7Data       → Persistence (depends: V7Core)
V7UI         → SwiftUI views (depends: V7Core, V7Services)
```

---

## 5. STATE MANAGEMENT PATTERNS

### @Observable Pattern (NOT ObservableObject)

```swift
✅ CORRECT - Swift 5.9+ @Observable:
@Observable
@MainActor
public final class AppState {
    public var selectedTab: Int = 0
    public var jobs: [Job] = []
    // NO @Published needed
}

❌ WRONG - Old pattern:
class AppState: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var jobs: [Job] = []
}
```

### State Persistence (UserDefaults)

```swift
// PATTERN: Immediate persistence on change
public var selectedTab: Int = 0 {
    didSet {
        if selectedTab != oldValue {
            UserDefaults.standard.set(selectedTab, forKey: "v7.selectedTab")
        }
    }
}

// PATTERN: Load on initialization
private func restorePersistedState() {
    if let savedTab = UserDefaults.standard.object(forKey: "v7.selectedTab") as? Int {
        selectedTab = savedTab
    }
}

// PATTERN: Batch save for complex objects
public func save() {
    if let data = try? JSONEncoder().encode(self) {
        UserDefaults.standard.set(data, forKey: "v7.preferences")
    }
}
```

### Singleton Pattern (RARE - Only for ProfileManager, PersistenceController)

```swift
// PATTERN: Singleton with @MainActor
@MainActor
public final class PerformanceMonitorRegistry: @unchecked Sendable {
    public static let shared = PerformanceMonitorRegistry()
    private init() {}
}
```

---

## 6. ERROR HANDLING PATTERNS

### Enum-Based Errors (ALWAYS)

```swift
// PATTERN: Error enum with Sendable
public enum BudgetViolationType: String, Sendable, CaseIterable {
    case memory = "Memory budget exceeded"
    case cpu = "CPU budget exceeded"
    case thompsonSampling = "Thompson sampling >10ms"

    public var isThompsonCritical: Bool {
        return self == .thompsonSampling
    }

    public var impactSeverity: Double {
        switch self {
        case .thompsonSampling: return 1.0 // CRITICAL
        case .memory: return 0.8           // HIGH
        case .cpu: return 0.7              // MEDIUM
        }
    }
}
```

### Throwing Functions (async throws)

```swift
// PATTERN: Async throwing functions
func parseResume() async throws -> ParsedResume
func fetchJobs() async throws -> [Job]
func scoreJobs(_ jobs: [Job]) async throws -> [Job]
```

### Error Recovery Pattern

```swift
// PATTERN: Validation errors with recovery
public struct StateValidationError: Sendable {
    let check: String
    let message: String
    let timestamp: Date
}

private func attemptStateRecovery() {
    // Reset to safe defaults if needed
    if appState.currentJobIndex >= appState.jobs.count {
        appState.currentJobIndex = 0
    }

    validateStateConsistency()
}
```

---

## 7. PERFORMANCE PATTERNS

### Timing Measurements (CFAbsoluteTimeGetCurrent)

```swift
// PATTERN: Performance measurement
let startTime = CFAbsoluteTimeGetCurrent()
// ... work ...
let duration = CFAbsoluteTimeGetCurrent() - startTime

guard duration < 0.010 else {
    // Log performance violation
}
```

### Zero-Allocation Loops

```swift
// PATTERN: Pre-allocate capacity
var results = [Score]()
results.reserveCapacity(jobs.count)  // Pre-allocate
for job in jobs {
    results.append(score(job))  // No reallocation
}
```

### Memory Budget Checks

```swift
// PATTERN: Memory budget validation
let memoryMB = getCurrentResidentMemoryMB()
guard memoryMB < 200 else {
    // Trigger optimization
}
```

### Zero-Overhead Incremental Metrics

```swift
// PATTERN: Incremental calculations (no overhead)
private var totalScoringTime: TimeInterval = 0
private var scoringCount = 0

// Update incrementally
totalScoringTime += duration
scoringCount += 1

// Calculate when needed
let avgTime = totalScoringTime / Double(scoringCount)
```

---

## 8. SACRED CONSTRAINTS (NEVER CHANGE)

### Tab Order (V5.7 Muscle Memory)

```swift
// RUNTIME VALIDATION REQUIRED
public enum SacredTabs: Int {
    case discover = 0   // NEVER CHANGE
    case history = 1    // NEVER CHANGE
    case profile = 2    // NEVER CHANGE
    case analytics = 3  // NEVER CHANGE
}

// Validation at app launch
assert(SacredTabs.discover.rawValue == 0, "Sacred tab order violated!")
```

### Performance Budgets

```swift
// SACRED VALUES - NEVER CHANGE
public static let thompsonSampleTarget: TimeInterval = 0.010  // <10ms
public static let baselineMemory: UInt64 = 200_000_000        // 200MB
public static let maxAppMemory: UInt64 = 300_000_000          // 300MB

// Runtime validation
assert(duration < thompsonSampleTarget, "Thompson budget violated!")
```

### UI Constants

```swift
// SACRED VALUES - UI consistency
public enum SacredUI {
    public enum Swipe {
        public static let rightThreshold: CGFloat = 100   // NEVER CHANGE
        public static let leftThreshold: CGFloat = -100   // NEVER CHANGE
        public static let upThreshold: CGFloat = -80      // NEVER CHANGE
    }
}
```

---

## 9. FILE ORGANIZATION RULES

### Package Structure

```
/Packages/V7Thompson/
├── Sources/V7Thompson/
│   ├── OptimizedThompsonEngine.swift  (main algorithm)
│   ├── FastBetaSampler.swift          (support)
│   ├── ThompsonCache.swift            (support)
│   └── Internal/                      (private helpers if needed)
└── Tests/V7ThompsonTests/
    ├── OptimizedThompsonEngineTests.swift
    └── FastBetaSamplerTests.swift
```

### File Organization Rules

1. **ONE PRIMARY TYPE PER FILE** (usually)
2. **FILE NAME = PRIMARY TYPE NAME**
3. **Tests mirror source structure**
4. **Group related files in subdirectories** (StateManagement/, Protocols/, etc.)

---

## 10. TESTING PATTERNS

### Swift Testing Framework (@Test)

```swift
// PATTERN: Swift Testing (NOT XCTest)
import Testing
@testable import V7Thompson

@Test func thompsonScoreCalculation() async throws {
    // ARRANGE
    let engine = OptimizedThompsonEngine()
    let testJob = createTestJob()

    // ACT
    let score = await engine.scoreJob(testJob)

    // ASSERT
    #expect(score.combinedScore > 0)
    #expect(score.combinedScore <= 1.0)
}

// PATTERN: Performance tests
@Test func thompsonPerformance() async throws {
    let start = CFAbsoluteTimeGetCurrent()
    await engine.scoreJobs(testJobs)
    let duration = CFAbsoluteTimeGetCurrent() - start

    #expect(duration < 0.010, "Must be under 10ms")
}
```

### Test File Naming

```
✅ CORRECT:
OptimizedThompsonEngineTests.swift
FastBetaSamplerTests.swift
StateIntegrationTests.swift

❌ WRONG:
test_optimized_thompson_engine.swift
ThompsonEngineTestCase.swift
```

---

## 11. COMMON PATTERNS REFERENCE

### Protocol Registry Pattern

```swift
// PATTERN: Dependency inversion via registry
@MainActor
public final class PerformanceMonitorRegistry: @unchecked Sendable {
    public static let shared = PerformanceMonitorRegistry()
    private var monitors: [String: any PerformanceMonitorProtocol] = [:]

    public func register(monitor: any PerformanceMonitorProtocol, for identifier: String) {
        monitors[identifier] = monitor
    }

    public func getMonitor(for identifier: String) -> (any PerformanceMonitorProtocol)? {
        return monitors[identifier]
    }
}
```

### Memory Monitoring Pattern

```swift
// PATTERN: Real memory measurement
private func getCurrentMemoryUsage() -> Int {
    var info = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
    let result = withUnsafeMutablePointer(to: &info) {
        $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
            task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
        }
    }
    return result == KERN_SUCCESS ? Int(info.resident_size) : 0
}
```

### State Synchronization Pattern

```swift
// PATTERN: Async state sync with weak self
private func performInitialSync() {
    Task { @MainActor [weak self] in
        await self?.synchronizeStates()
        self?.isSynchronized = true
        self?.lastSyncTime = Date()
    }
}
```

---

## 12. SWIFT 6 CONCURRENCY CHECKLIST

Before writing ANY code, verify:

- [ ] Is this UI code? → Use `@MainActor`
- [ ] Is this background processing? → Use `actor`
- [ ] Does this cross actor boundaries? → Make it `Sendable`
- [ ] Is this a data model? → Use `struct` + `Sendable`
- [ ] Is this a protocol? → Add `: Sendable` if cross-actor
- [ ] Does this need `nonisolated`? → Only for protocol conformance
- [ ] Is this a singleton? → Use `@MainActor` + `@unchecked Sendable`
- [ ] Does this use `@Observable`? → NEVER use `ObservableObject`

---

## 13. WHAT TO AVOID

### ❌ NEVER DO THESE:

```swift
// ❌ NEVER use ObservableObject (old pattern)
class AppState: ObservableObject { }

// ❌ NEVER use @Published (use @Observable instead)
@Published var selectedTab: Int

// ❌ NEVER create circular package dependencies
// V7Services → V7Performance → V7Services (FORBIDDEN)

// ❌ NEVER use SCREAMING_CASE for constants
public static let THOMPSON_TARGET = 0.010

// ❌ NEVER add dependencies to V7Core
// V7Core must have ZERO external dependencies

// ❌ NEVER change sacred values without runtime validation
public static let rightThreshold: CGFloat = 150 // FORBIDDEN

// ❌ NEVER use Hungarian notation
let strName: String  // Use: let name: String
let arrJobs: [Job]   // Use: let jobs: [Job]

// ❌ NEVER block async contexts with sync file I/O
let data = try Data(contentsOf: url)  // Use async URLSession instead
```

---

## SKILL USAGE

When writing code for ManifestAndMatchV7:

1. **Check type choice** - struct vs class vs enum vs actor
2. **Verify concurrency** - @MainActor vs actor vs Sendable
3. **Follow naming** - PascalCase types, camelCase functions/vars
4. **Check dependencies** - No circular dependencies
5. **Use @Observable** - Not ObservableObject
6. **Validate performance** - CFAbsoluteTimeGetCurrent measurements
7. **Check sacred values** - Never change tab order, performance budgets
8. **Use Swift Testing** - @Test, not XCTest
9. **Add Sendable** - All data models, enums, cross-actor protocols
10. **Verify patterns** - Match existing codebase patterns

---

**All patterns extracted from actual ManifestAndMatchV7 codebase**
**Last verified:** 2024-10-18
