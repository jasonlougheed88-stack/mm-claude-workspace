---
name: swift-concurrency-enforcer
description: Enforces Swift 6 strict concurrency patterns and prevents data races in async/actor code
category: quality
allowed-tools:
  - Read
  - Grep
  - Edit
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



# Swift Concurrency Enforcer

## Triggers
- Writing or modifying actor definitions
- Implementing @MainActor views, view models, or UI-related classes
- Using async/await, Task, TaskGroup in any Swift code
- Working with mutable shared state across threads
- Core Data persistence operations with background contexts
- Thompson Sampling engine or any background processing code
- Compiler errors related to Sendable, actor isolation, or data races
- Swift 6 strict concurrency migration tasks

## Behavioral Mindset

Think thread-safety first, always. Swift 6 strict concurrency exists to eliminate an entire class of bugs - data races - at compile time. When the compiler complains about concurrency, it's protecting users from crashes, not being pedantic. @MainActor is not optional for UI code, it's mandatory. Actors are your friend for shared mutable state. Global mutable state is the enemy. Structured concurrency (async/await, TaskGroups) beats callbacks and DispatchQueue every time.

## Purpose

Ensures ManifestAndMatchV7 follows Swift 6 strict concurrency patterns to eliminate data races. Swift 6 compiler catches concurrency bugs at compile-time - this skill ensures code compiles with strict concurrency enabled.

## Sacred Concurrency Principles

1. **@MainActor for UI** - All SwiftUI views and UI updates on main thread
2. **Actor for State** - Mutable shared state protected by actors
3. **Sendable Conformance** - Types crossing actor boundaries must be Sendable
4. **No Global Mutable State** - All globals must be immutable or actor-isolated
5. **Structured Concurrency** - Use async/await, not callbacks

## Swift 6 Strict Concurrency Status

ManifestAndMatchV7 has **Swift 6 strict concurrency ENABLED** in all packages:

```swift
// Package.swift
swiftSettings: [
    .enableUpcomingFeature("StrictConcurrency")
]
```

This means the compiler WILL ERROR on concurrency violations. This skill prevents those errors.

## Activation Triggers

This skill activates when you're working on:
- Any `actor` definitions
- Any `@MainActor` views or view models
- Background processing code
- Thompson Sampling engine (high-performance async)
- API networking code
- Core Data persistence

## Critical Enforcement Areas

### 1. @MainActor for All UI

**Every SwiftUI view must be @MainActor:**

```swift
// ❌ WRONG: No @MainActor (will error in Swift 6)
struct JobCardView: View {
    @State private var isLiked = false

    var body: some View {
        Button("Like") {
            isLiked.toggle()  // ERROR: State mutation from non-isolated context
        }
    }
}

// ✅ CORRECT: @MainActor on view
@MainActor
struct JobCardView: View {
    @State private var isLiked = false

    var body: some View {
        Button("Like") {
            isLiked.toggle()  // ✅ Main actor isolated
        }
    }
}

// ✅ CORRECT: @MainActor on ViewModel
@MainActor
final class JobViewModel: ObservableObject {
    @Published var jobs: [Job] = []
    @Published var isLoading = false

    func loadJobs() async {
        isLoading = true  // ✅ Main actor isolated

        let jobs = await jobService.fetchJobs()

        self.jobs = jobs  // ✅ Main actor isolated
        isLoading = false
    }
}
```

### 2. Actor for Mutable State

**Protect mutable state with actors:**

```swift
// ❌ WRONG: Unprotected mutable state
class ThompsonCache {
    var cache: [String: Double] = [:]  // DATA RACE: Multiple threads can access

    func getScore(_ jobId: String) -> Double? {
        cache[jobId]  // RACE CONDITION
    }

    func setScore(_ jobId: String, score: Double) {
        cache[jobId] = score  // RACE CONDITION
    }
}

// ✅ CORRECT: Actor-protected state
actor ThompsonCache {
    private var cache: [String: Double] = [:]

    func getScore(_ jobId: String) -> Double? {
        cache[jobId]  // ✅ Actor-isolated, thread-safe
    }

    func setScore(_ jobId: String, score: Double) {
        cache[jobId] = score  // ✅ Actor-isolated, thread-safe
    }
}

// Usage (note 'await'):
let cache = ThompsonCache()
let score = await cache.getScore("job123")  // ✅ Safe
```

### 3. Sendable Conformance

**Types crossing actor boundaries must be Sendable:**

```swift
// ❌ WRONG: Non-Sendable class crossing actors
class Job {  // ERROR: Class not Sendable
    var id: String
    var title: String
    // ...
}

actor JobProcessor {
    func processJob(_ job: Job) async {  // ERROR: Job is not Sendable
        // ...
    }
}

// ✅ CORRECT: Sendable struct
struct Job: Sendable {  // ✅ Structs are implicitly Sendable if all properties are
    let id: String
    let title: String
    let company: String
    let location: String
}

actor JobProcessor {
    func processJob(_ job: Job) async {  // ✅ Job is Sendable
        // ...
    }
}

// ✅ CORRECT: Sendable class (immutable or actor)
final class JobViewModel: ObservableObject, @unchecked Sendable {
    // Must be @MainActor or thread-safe
}

// ✅ CORRECT: Non-Sendable but nonisolated
actor JobCache {
    nonisolated func getCachedJob(_ id: String) -> Job? {
        // Synchronous, doesn't require await
    }
}
```

### 4. No Global Mutable State

**Global state must be immutable or actor-isolated:**

```swift
// ❌ WRONG: Global mutable state
var currentUser: User?  // DATA RACE: Accessible from any thread

func updateUser(_ user: User) {
    currentUser = user  // RACE CONDITION
}

// ✅ CORRECT: Actor-isolated global
actor UserSession {
    static let shared = UserSession()

    private var currentUser: User?

    func setUser(_ user: User) {
        currentUser = user  // ✅ Actor-isolated
    }

    func getUser() -> User? {
        currentUser  // ✅ Actor-isolated
    }
}

// Usage:
await UserSession.shared.setUser(user)
let user = await UserSession.shared.getUser()

// ✅ CORRECT: Immutable global
let defaultConfiguration = Configuration(
    apiKey: "...",
    baseURL: "..."
)  // ✅ let = immutable, safe
```

### 5. Structured Concurrency

**Use async/await, not completion handlers:**

```swift
// ❌ WRONG: Completion handler (old concurrency)
func fetchJobs(completion: @escaping ([Job]) -> Void) {
    URLSession.shared.dataTask(with: url) { data, response, error in
        // Manual thread switching, error-prone
        DispatchQueue.main.async {
            completion(jobs)
        }
    }.resume()
}

// ✅ CORRECT: Async/await (Swift 6)
func fetchJobs() async throws -> [Job] {
    let (data, _) = try await URLSession.shared.data(from: url)
    let jobs = try JSONDecoder().decode([Job].self, from: data)
    return jobs  // ✅ Automatic thread management
}

// Usage:
Task {
    let jobs = try await fetchJobs()
    await MainActor.run {
        self.jobs = jobs  // ✅ Explicit main actor
    }
}
```

### 6. Task Groups for Parallelism

**Process multiple items concurrently:**

```swift
// ❌ WRONG: Sequential processing
func scoreJobs(_ jobs: [Job]) async -> [ScoredJob] {
    var scored: [ScoredJob] = []

    for job in jobs {
        let score = await calculateScore(job)  // Sequential, slow
        scored.append(ScoredJob(job: job, score: score))
    }

    return scored
}

// ✅ CORRECT: Parallel processing with task group
func scoreJobs(_ jobs: [Job]) async -> [ScoredJob] {
    await withTaskGroup(of: ScoredJob.self) { group in
        for job in jobs {
            group.addTask {
                let score = await calculateScore(job)
                return ScoredJob(job: job, score: score)
            }
        }

        var scored: [ScoredJob] = []
        for await result in group {
            scored.append(result)
        }
        return scored
    }
}

// ✅ CORRECT: Parallel with results array
func scoreJobs(_ jobs: [Job]) async -> [ScoredJob] {
    await withTaskGroup(of: (Int, ScoredJob).self) { group in
        for (index, job) in jobs.enumerated() {
            group.addTask {
                let score = await calculateScore(job)
                return (index, ScoredJob(job: job, score: score))
            }
        }

        var results = [ScoredJob?](repeating: nil, count: jobs.count)
        for await (index, scored) in group {
            results[index] = scored
        }
        return results.compactMap { $0 }
    }
}
```

### 7. Actor Isolation in Classes

**Classes require explicit isolation:**

```swift
// ❌ WRONG: Class with mutable properties (not Sendable)
class JobViewModel {
    var jobs: [Job] = []  // ERROR: Not thread-safe

    func updateJobs(_ newJobs: [Job]) {
        jobs = newJobs  // DATA RACE
    }
}

// ✅ CORRECT: @MainActor class
@MainActor
final class JobViewModel: ObservableObject {
    @Published var jobs: [Job] = []

    func updateJobs(_ newJobs: [Job]) {
        jobs = newJobs  // ✅ Main actor isolated
    }
}

// ✅ CORRECT: Actor (if not UI-related)
actor JobCache {
    private var jobs: [Job] = []

    func updateJobs(_ newJobs: [Job]) {
        jobs = newJobs  // ✅ Actor isolated
    }

    func getJobs() -> [Job] {
        jobs  // ✅ Actor isolated
    }
}
```

### 8. Nonisolated Functions

**Synchronous access when safe:**

```swift
actor ThompsonEngine {
    private var alpha: Double = 1.0
    private var beta: Double = 1.0

    // ✅ CORRECT: Nonisolated for pure computation
    nonisolated func sampleBeta() -> Double {
        // Pure function, no state access
        let u = Double.random(in: 0...1)
        return pow(1 - pow(u, 1/beta), 1/alpha)  // ERROR: Can't access actor properties
    }

    // ✅ CORRECT: Actor-isolated access to state
    func sampleBetaWithState() -> Double {
        let u = Double.random(in: 0...1)
        return pow(1 - pow(u, 1/beta), 1/alpha)  // ✅ Can access alpha, beta
    }

    // ✅ CORRECT: Nonisolated computed property (no state)
    nonisolated var description: String {
        "Thompson Sampling Engine"  // ✅ No state access
    }
}
```

### 9. Core Data with Swift Concurrency

**Use actor for Core Data contexts:**

```swift
// ✅ CORRECT: Actor-isolated Core Data
actor PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "ManifestAndMatch")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error)")
            }
        }
    }

    func saveJob(_ job: Job) throws {
        let context = container.viewContext
        let entity = JobEntity(context: context)
        entity.id = job.id
        entity.title = job.title
        // ...

        try context.save()
    }

    func fetchJobs() throws -> [Job] {
        let context = container.viewContext
        let request = JobEntity.fetchRequest()
        let entities = try context.fetch(request)
        return entities.map { Job(from: $0) }
    }
}

// Usage:
let jobs = try await PersistenceController.shared.fetchJobs()
```

### 10. Task Cancellation

**Check for cancellation in long-running tasks:**

```swift
// ✅ CORRECT: Cancellation-aware task
func processLargeDataset(_ jobs: [Job]) async throws -> [ScoredJob] {
    var results: [ScoredJob] = []

    for (index, job) in jobs.enumerated() {
        // Check for cancellation every 100 jobs
        if index % 100 == 0 {
            try Task.checkCancellation()
        }

        let score = await calculateScore(job)
        results.append(ScoredJob(job: job, score: score))
    }

    return results
}

// Usage:
let task = Task {
    try await processLargeDataset(allJobs)
}

// Cancel if user navigates away
task.cancel()
```

## Swift 6 Concurrency Checklist

Before merging async code:

- [ ] All SwiftUI views are @MainActor
- [ ] All ViewModels are @MainActor
- [ ] Mutable state protected by actors
- [ ] Sendable conformance on shared types
- [ ] No global mutable state (use actors)
- [ ] Async/await instead of completion handlers
- [ ] Task groups for parallel processing
- [ ] Nonisolated for pure functions
- [ ] Core Data access actor-isolated
- [ ] Long tasks check for cancellation
- [ ] No DispatchQueue.main.async (use MainActor.run)
- [ ] Compiles with -strict-concurrency=complete

## When This Skill Flags Issues

I will automatically warn you if:

1. **Missing @MainActor** - SwiftUI view without @MainActor
2. **Unprotected mutable state** - Class with var properties
3. **Non-Sendable crossing actors** - Class passed to actor
4. **Global mutable state** - var at global scope
5. **Completion handlers** - Using callbacks instead of async/await
6. **DispatchQueue.main.async** - Use MainActor.run instead
7. **No cancellation check** - Long-running task without cancellation
8. **Actor property access** - Synchronous access to actor state

## Reference: Swift 6 Concurrency Migration

```swift
// OLD (Swift 5.5):
class ViewModel: ObservableObject {
    @Published var data: [Item] = []

    func load() {
        Task {
            let items = await service.fetch()
            DispatchQueue.main.async {
                self.data = items
            }
        }
    }
}

// NEW (Swift 6):
@MainActor
final class ViewModel: ObservableObject {
    @Published var data: [Item] = []

    func load() async {
        let items = await service.fetch()
        self.data = items  // Already on MainActor
    }
}
```

## Compiler Flags to Enable

Ensure Package.swift has:

```swift
swiftSettings: [
    .enableUpcomingFeature("StrictConcurrency"),
    .enableUpcomingFeature("ExistentialAny")
]
```

---

## Boundaries

**Will:**
- Enforce Swift 6 strict concurrency compliance for all ManifestAndMatchV7 code
- Ensure @MainActor isolation for all SwiftUI views, view models, and UI state
- Protect mutable shared state with actors and proper isolation
- Validate Sendable conformance for types crossing actor boundaries
- Eliminate global mutable state through actor-isolated patterns
- Guide structured concurrency with async/await and TaskGroups instead of callbacks

**Will Not:**
- Allow data races or concurrency bugs that Swift 6 can catch at compile time
- Accept DispatchQueue patterns when async/await provides safer alternatives
- Permit global mutable state without proper actor isolation
- Compromise thread safety for code convenience or migration shortcuts
- Recommend @unchecked Sendable without clear justification and safety analysis

---

# Swift Concurrency Enforcer

**Based On:**
- Swift 6 Concurrency documentation
- ManifestAndMatchV7 Package.swift configurations
- `/Packages/V7Core/` - Swift 6 patterns
- `/Packages/V7Thompson/` - Actor-based Thompson Sampling
