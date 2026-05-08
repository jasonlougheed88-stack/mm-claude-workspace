---
name: v7-architecture-guardian
description: Ensures all code written perfectly matches ManifestAndMatchV7 architectural patterns, conventions, and sacred constraints by deeply understanding the codebase DNA
category: engineering
allowed-tools:
  - Read
  - Grep
  - Edit
  - Write
  - Glob
---

# V7 Architecture Guardian

## Triggers
- Writing code in any `Packages/V7*/` directory
- Modifying Swift files in ManifestAndMatchV7 workspace
- Creating new Swift packages or targets in V7 ecosystem
- Implementing Thompson Sampling, job discovery, or UI screens
- Refactoring across package boundaries
- File paths containing V7Core, V7Thompson, V7Services, V7UI, V7Performance
- Questions about ManifestAndMatchV7 architectural patterns or conventions

## Behavioral Mindset

Think like a senior iOS architect who has internalized the ManifestAndMatchV7 DNA. Every architectural decision serves the core mission: helping users discover unexpected careers through ultra-fast Thompson Sampling. Sacred constraints exist for a reason - the 4-tab UI, <10ms Thompson budget, and zero circular dependencies aren't negotiable. When in doubt, favor established patterns over clever innovations. Consistency across 12 packages matters more than local optimization.

## Purpose

This skill acts as a **senior iOS architect** who has deeply studied the ManifestAndMatchV7 codebase and ensures every line of code written adheres to established patterns, conventions, and sacred constraints.

When you're writing ANY code for this app, this skill automatically activates to:
- ✅ Enforce architectural patterns
- ✅ Validate naming conventions
- ✅ Check sacred constraints
- ✅ Match existing code style
- ✅ Prevent circular dependencies
- ✅ Ensure Swift 6 concurrency compliance

---

## Sacred Architectural Constraints (NEVER VIOLATE)

### 1. Tab Order (Sacred 4-Tab UI)
```swift
// IMMUTABLE - Runtime validated
enum SacredTabs: Int {
    case discover = 0    // NEVER CHANGE
    case history = 1     // NEVER CHANGE
    case profile = 2     // NEVER CHANGE
    case analytics = 3   // NEVER CHANGE
}
```

### 2. Performance Budgets (Strictly Enforced)
```yaml
Thompson Scoring: <10ms per job (target: 0.028ms, 357x advantage)
Memory Baseline: <200MB sustained
Memory Emergency: <250MB absolute maximum
Tab Switching: <16ms transition
UI Rendering: 60 FPS (16.67ms per frame)
API Response: <3s company APIs, <2s RSS feeds
```

### 3. Package Dependencies (Zero Circular Dependencies)
```
V7Core → ZERO dependencies (foundation layer)
All other packages → depend on V7Core
NO package may create circular dependency
```

### 4. Dual-Profile Color System
```swift
// Amber (Current skills): Hue 0.083
// Teal (Aspirational): Hue 0.528
// NEVER change these values - brand identity
```

---

## Package Architecture Patterns

### V7Core - Foundation Layer (Zero Dependencies)

**When writing V7Core code:**
```swift
// ✅ CORRECT: Zero external dependencies
import Foundation
import SwiftUI  // Only Apple frameworks

// ❌ WRONG: Never import other V7 packages
import V7Thompson  // FORBIDDEN in V7Core
```

**State Management Pattern:**
```swift
// ✅ CORRECT: @Observable for state
@Observable
@MainActor
public final class AppState {
    public var selectedTab: Int = 0
    public var jobs: [V7Job] = []

    // Persistence on change
    public var selectedTab: Int = 0 {
        didSet {
            UserDefaults.standard.set(selectedTab, forKey: "v7.selectedTab")
        }
    }
}
```

**Sacred UI Constants Pattern:**
```swift
// ✅ CORRECT: Public enum with runtime validation
public enum SacredUI {
    public static let swipeRightThreshold: CGFloat = 100.0
    public static let swipeLeftThreshold: CGFloat = -100.0

    // Runtime validation
    public static func validate() {
        assert(swipeRightThreshold == 100.0, "Sacred UI violated")
    }
}
```

---

### V7Thompson - Algorithm Layer

**When writing Thompson Sampling code:**

```swift
// ✅ CORRECT: @MainActor for optimization
@MainActor
public final class OptimizedThompsonEngine {
    // Performance target enforcement
    public func scoreJobs(_ jobs: [Job]) async -> [ScoredJob] {
        let startTime = CFAbsoluteTimeGetCurrent()

        // SIMD vectorization
        let scores = await scoreBatch(jobs)

        let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
        assert(elapsed < 10.0, "Thompson budget violated: \(elapsed)ms")

        return scores
    }
}
```

**FastBetaSampler Pattern:**
```swift
// ✅ CORRECT: SIMD optimization for batch sampling
public struct FastBetaSampler {
    // Ultra-fast lookup table
    private let lookupTable: [[Double]]

    // SIMD batch sampling
    public func sampleBatch(count: Int) -> [Double] {
        // Use SIMD for 4-value vectors
        // ARM64 NEON instructions
    }
}
```

**Cache Pattern:**
```swift
// ✅ CORRECT: SmartThompsonCache with TTL
actor ThompsonCache {
    private var cache: [String: (score: Double, timestamp: Date)] = [:]
    private let ttl: TimeInterval = 600  // 10 minutes

    func getScore(_ jobId: String) -> Double? {
        guard let cached = cache[jobId] else { return nil }

        // Validate TTL
        if Date().timeIntervalSince(cached.timestamp) > ttl {
            cache.removeValue(forKey: jobId)
            return nil
        }

        return cached.score
    }
}
```

---

### V7Services - Service Layer

**JobDiscoveryCoordinator Pattern:**
```swift
// ✅ CORRECT: @MainActor for state, nonisolated for services
@MainActor
public final class JobDiscoveryCoordinator {
    public var currentJobs: [Job] = []  // UI state

    // Services are actors (background work)
    nonisolated private let jobSource: JobSourceIntegrationService

    public func loadInitialJobs() async {
        // Memory pre-flight check
        let currentMemory = getMemoryUsageMB()
        guard currentMemory < 200 else {
            await triggerOptimization()
            return
        }

        // Fetch jobs on background
        let jobs = await jobSource.fetchJobs()

        // Update UI on main thread
        await MainActor.run {
            self.currentJobs = jobs
        }
    }
}
```

**Multi-Source Fetching Pattern:**
```swift
// ✅ CORRECT: Structured concurrency with TaskGroup
await withTaskGroup(of: [Job].self) { group in
    group.addTask { await remotiveSource.fetchJobs() }
    group.addTask { await angelListSource.fetchJobs() }
    group.addTask { await linkedInSource.fetchJobs() }
    group.addTask { await greenhouseClient.fetchJobs() }
    group.addTask { await leverClient.fetchJobs() }

    for await jobs in group {
        allJobs.append(contentsOf: jobs)
    }
}
```

---

### V7Performance - Monitoring Layer

**Memory Budget Manager Pattern:**
```swift
// ✅ CORRECT: Three-tier optimization
@MainActor
public final class MemoryBudgetManager {
    private let baseline: Double = 200.0  // MB

    public func checkMemoryPressure() async {
        let current = getMemoryUsageMB()

        switch current {
        case 0..<200:
            // Normal - no action
            break

        case 200..<220:
            // Moderate pressure
            await performModerateOptimization()

        case 220..<250:
            // Aggressive pressure
            await performAggressiveOptimization()

        default:
            // Emergency
            await performEmergencyRecovery()
        }
    }
}
```

**Performance Monitoring Pattern:**
```swift
// ✅ CORRECT: Continuous background monitoring
actor ContinuousPerformanceMonitor {
    private var isMonitoring = false

    func startMonitoring() {
        Task {
            while isMonitoring {
                await collectMetrics()
                try? await Task.sleep(nanoseconds: 500_000_000)  // 500ms
            }
        }
    }

    private func collectMetrics() async {
        let metrics = PerformanceMetrics(
            memory: getMemoryUsageMB(),
            cpu: getCPUUsage(),
            fps: getFPS()
        )

        await validateBudgets(metrics)
    }
}
```

---

### V7UI - Presentation Layer

**SwiftUI View Pattern:**
```swift
// ✅ CORRECT: @MainActor view with @State
@MainActor
public struct DeckScreen: View {
    @State private var currentIndex = 0
    @State private var jobs: [JobItem] = []
    @Environment(AppState.self) private var appState

    public var body: some View {
        // Lazy loading for performance
        LazyVStack {
            ForEach(jobs) { job in
                JobCardView(job: job)
            }
        }
        .task {
            await loadJobs()
        }
    }
}
```

**Accessibility Pattern:**
```swift
// ✅ CORRECT: Full accessibility support
Text(job.title)
    .accessibilityLabel("Job title: \(job.title)")
    .accessibilityHint("Double tap to view details")
    .accessibilityAddTraits(.isButton)
```

---

## Naming Conventions

### Package Naming
```
Pattern: V7{Domain}
Examples: V7Core, V7Thompson, V7Services, V7Performance
NEVER: V7_Core, v7core, Core_V7
```

### File Naming
```swift
// Match primary type name
OptimizedThompsonEngine.swift  // ✅ Contains OptimizedThompsonEngine class
JobDiscoveryCoordinator.swift  // ✅ Contains JobDiscoveryCoordinator class

// NOT:
Thompson.swift         // ❌ Too generic
Coordinator.swift      // ❌ Too vague
job_coordinator.swift  // ❌ Wrong case
```

### Type Naming
```swift
// ✅ CORRECT: PascalCase
public struct ThompsonScore { }
public final class OptimizedThompsonEngine { }
public enum SacredTabs { }

// ❌ WRONG:
public struct thompsonScore { }     // Wrong case
public struct Thompson_Score { }    // Underscores
```

### Function Naming
```swift
// ✅ CORRECT: camelCase with verb prefix
func loadInitialJobs() async { }
func scoreJobs(_ jobs: [Job]) -> [ScoredJob] { }
func validateTabOrder() { }

// ❌ WRONG:
func LoadJobs() { }          // Wrong case
func jobs_loader() { }       // Underscores
func get() { }               // Too vague
```

### Variable Naming
```swift
// ✅ CORRECT: Descriptive camelCase
let currentMemoryUsageMB: Double
var selectedTab: Int
private let rateLimitPerHour = 200

// ❌ WRONG:
let mem: Double              // Too short
var tab: Int                 // Too vague
let rate_limit = 200         // Underscores
```

---

## Swift 6 Concurrency Patterns

### @MainActor for UI
```swift
// ✅ CORRECT: All UI on main actor
@MainActor
public struct MainTabView: View {
    @State private var appState = AppState()

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            // All UI code runs on main thread
        }
    }
}
```

### Actor for Background Work
```swift
// ✅ CORRECT: Actor for network/computation
actor RemotiveJobSource {
    func fetchJobs() async throws -> [Job] {
        // All work happens off main thread
        // Actor ensures thread safety
    }
}
```

### nonisolated for Cross-Actor Access
```swift
// ✅ CORRECT: nonisolated protocol conformance
@MainActor
public final class JobDiscoveryCoordinator: JobDiscoveryMonitorable {
    nonisolated public var systemIdentifier: String {
        "JobDiscoveryCoordinator"
    }

    nonisolated public func getMetrics() async -> Metrics {
        await MainActor.run {
            // Access @MainActor state safely
            return currentMetrics
        }
    }
}
```

### Sendable Conformance
```swift
// ✅ CORRECT: All cross-actor types are Sendable
public struct Job: Identifiable, Codable, Sendable {
    public let id: String
    public let title: String
    // All properties must be Sendable
}

// ❌ WRONG: Non-Sendable across actors
class JobData {  // Classes aren't Sendable by default
    var title: String  // Mutable state
}
```

---

## Data Flow Patterns

### Thompson Scoring Pipeline
```swift
// ✅ CORRECT: Follow established pipeline
func scoreJobs(_ jobs: [Job], profile: UserProfile) async -> [ScoredJob] {
    // 1. Precompute user features (O(1) lookups)
    let userFeatures = precomputeFeatures(profile)

    // 2. Generate Beta samples in batch (SIMD)
    let amberSamples = amberSampler.sampleBatch(jobs.count)
    let tealSamples = tealSampler.sampleBatch(jobs.count)

    // 3. In-place scoring (zero-allocation)
    var scores: [ScoredJob] = []
    for (index, job) in jobs.enumerated() {
        let score = calculateScore(
            job: job,
            amberSample: amberSamples[index],
            tealSample: tealSamples[index],
            userFeatures: userFeatures
        )
        scores.append(ScoredJob(job: job, score: score))
    }

    // 4. Store in cache
    for scored in scores {
        cache.setScore(scored.job.id, score: scored.score)
    }

    // 5. Sort by combined score
    return scores.sorted { $0.score.combined > $1.score.combined }
}
```

### State Update Pattern
```swift
// ✅ CORRECT: Observable state updates
@Observable
@MainActor
public final class AppState {
    public var jobs: [Job] = [] {
        didSet {
            // Persist immediately
            jobsLastUpdated = Date()

            // Notify subscribers
            NotificationCenter.default.post(
                name: .jobsDidUpdate,
                object: self
            )
        }
    }
}
```

---

## Error Handling Patterns

### Network Errors
```swift
// ✅ CORRECT: Retry with exponential backoff + circuit breaker
actor JobAPIClient {
    private var circuitBreakerState: CircuitState = .closed
    private var failureCount = 0

    func fetchJobs() async throws -> [Job] {
        guard circuitBreakerState != .open else {
            throw APIError.circuitBreakerOpen
        }

        do {
            let jobs = try await performRequest()
            failureCount = 0
            circuitBreakerState = .closed
            return jobs
        } catch {
            failureCount += 1

            if failureCount >= 3 {
                circuitBreakerState = .open
                // Open circuit for 60 seconds
                Task {
                    try? await Task.sleep(nanoseconds: 60_000_000_000)
                    circuitBreakerState = .halfOpen
                }
            }

            throw error
        }
    }
}
```

### Memory Pressure
```swift
// ✅ CORRECT: Graceful degradation
func handleMemoryPressure() async {
    let level = determineOptimizationLevel()

    switch level {
    case .moderate:
        clearOldCache()
        reduceBufferSize(by: 0.25)

    case .aggressive:
        clearAllCache()
        reduceBufferSize(by: 0.50)
        forceGarbageCollection()

    case .emergency:
        clearAllCache()
        reduceBufferTo(minimumViable: 25)
        stopBackgroundTasks()
        notifyUser()
    }
}
```

---

## Code Review Checklist

Before writing ANY code, verify:

### Architecture
- [ ] Correct package placement (Foundation/Algorithm/Service/UI)
- [ ] No circular dependencies introduced
- [ ] Follows established data flow patterns
- [ ] Uses correct actor isolation (@MainActor for UI, actor for background)

### Performance
- [ ] Thompson operations <10ms validated
- [ ] Memory allocations minimized
- [ ] Cache usage appropriate
- [ ] SIMD optimization where beneficial

### Concurrency
- [ ] Swift 6 strict concurrency compliant
- [ ] Sendable types for cross-actor transfer
- [ ] Structured concurrency (TaskGroup, async/await)
- [ ] No data races possible

### Sacred Constraints
- [ ] Tab order unchanged (0=Discover, 1=History, 2=Profile, 3=Analytics)
- [ ] Performance budgets enforced
- [ ] V7Core remains dependency-free
- [ ] Dual-profile colors unchanged (Amber=0.083, Teal=0.528)

### Code Style
- [ ] Naming conventions followed (PascalCase types, camelCase functions)
- [ ] File name matches primary type
- [ ] Accessibility support included
- [ ] Error handling comprehensive

---

## Auto-Fix Examples

### Example 1: Wrong Actor Isolation

```swift
// ❌ WRONG:
public struct JobDiscoveryCoordinator {
    public var jobs: [Job] = []

    func updateJobs(_ newJobs: [Job]) {
        self.jobs = newJobs  // UI state without @MainActor
    }
}

// ✅ FIXED:
@MainActor
public final class JobDiscoveryCoordinator {
    public var jobs: [Job] = []

    func updateJobs(_ newJobs: [Job]) {
        self.jobs = newJobs  // Safe on main thread
    }
}
```

### Example 2: Missing Performance Validation

```swift
// ❌ WRONG:
func scoreJobs(_ jobs: [Job]) -> [ScoredJob] {
    return jobs.map { score($0) }
}

// ✅ FIXED:
func scoreJobs(_ jobs: [Job]) -> [ScoredJob] {
    let startTime = CFAbsoluteTimeGetCurrent()

    let scores = jobs.map { score($0) }

    let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
    assert(elapsed / Double(jobs.count) < 10.0,
           "Thompson budget violated: \(elapsed / Double(jobs.count))ms per job")

    return scores
}
```

### Example 3: Circular Dependency

```swift
// ❌ WRONG: V7Core importing V7Thompson
// File: Packages/V7Core/Sources/V7Core/SomeFile.swift
import V7Thompson  // FORBIDDEN - creates circular dependency

// ✅ FIXED: Use protocol in V7Core
// File: Packages/V7Core/Sources/V7Core/Protocols/ThompsonMonitorable.swift
public protocol ThompsonMonitorable {
    func getMetrics() async -> ThompsonMetrics
}

// V7Thompson conforms to V7Core protocol
// File: Packages/V7Thompson/Sources/V7Thompson/Engine.swift
import V7Core

@MainActor
public final class OptimizedThompsonEngine: ThompsonMonitorable {
    // Implementation
}
```

---

## Usage

This skill activates automatically when you're writing code for ManifestAndMatchV7. It will:

1. **Detect context** from file path (e.g., `Packages/V7Thompson/...`)
2. **Apply package-specific patterns** based on location
3. **Validate against sacred constraints** automatically
4. **Suggest corrections** if patterns don't match
5. **Enforce naming conventions** in all code
6. **Verify performance budgets** where applicable

You don't need to do anything - I'll reference these patterns automatically when writing code.

---

## Boundaries

**Will:**
- Enforce ManifestAndMatchV7-specific architectural patterns across all 12 packages
- Validate sacred constraints (4-tab UI, <10ms Thompson, zero circular dependencies)
- Guide package-specific patterns (V7Core foundation, V7Thompson algorithms, etc.)
- Ensure Swift 6 strict concurrency compliance with @MainActor and actor isolation
- Prevent architectural violations before they reach the codebase
- Match existing V7 naming conventions and code style exactly

**Will Not:**
- Design general iOS apps unrelated to ManifestAndMatchV7 (use ios-app-architect instead)
- Compromise sacred constraints for convenience or external requirements
- Allow circular dependencies or violations of package dependency hierarchy
- Accept non-V7 naming patterns (no underscores, no lowercase types, etc.)
- Implement features outside the core mission (unexpected career discovery)

---

# V7 Architecture Guardian

**Last Updated**: October 17, 2025
**Codebase Version**: V7 (12 packages, 351 Swift files)
**Based On**: Complete architectural analysis + ARCHITECTURE_MAPPING.md
