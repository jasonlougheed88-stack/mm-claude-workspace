---
name: api-integration-builder
description: Scaffolds production-ready job board API integrations with rate limiting, circuit breakers, exponential backoff, error handling, and caching patterns that follow V7 architectural standards
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
---

# API Integration Builder

## Purpose

Rapidly scaffolds production-ready API integrations for job boards (Remotive, AngelList, LinkedIn, Greenhouse, Lever, etc.) with all necessary patterns: rate limiting, circuit breakers, retry logic, error handling, and caching. Follows V7 architecture standards and Swift 6 strict concurrency.

## When This Skill Activates

**New integration requests:**
- User says "Add [JobBoard] API integration"
- User mentions "Connect to [API name]"
- User asks "How do I integrate with [service]?"

**During development:**
- Working in `Packages/V7JobSources/` or `Packages/V7Services/`
- Creating new job source adapters
- Implementing API clients

**Troubleshooting:**
- "Fix rate limiting for [source]"
- "Add circuit breaker to [API]"
- "Why is [source] timing out?"

## Integration Architecture Pattern

Every job board API integration follows this structure:

```
Packages/V7JobSources/Sources/V7JobSources/
├── [SourceName]JobSource.swift          # Main job source (actor)
├── [SourceName]APIClient.swift          # API client (actor)
├── [SourceName]Models.swift             # API response models
├── [SourceName]Adapter.swift            # API → Job adapter
└── Supporting/
    ├── RateLimiter.swift                # Shared rate limiter
    ├── CircuitBreaker.swift             # Shared circuit breaker
    └── NetworkMonitor.swift             # Connectivity checker
```

## Core Components Template

### 1. Job Source (Main Entry Point)

```swift
// Packages/V7JobSources/Sources/V7JobSources/RemotiveJobSource.swift

import Foundation
import V7Thompson
import V7Core

/// Remotive job board integration
/// Documentation: https://remotive.com/api/remote-jobs
/// Rate Limit: 100 requests/hour
/// Authentication: None required
@MainActor
public final class RemotiveJobSource: JobSourceProtocol {
    // MARK: - Properties

    private let apiClient: RemotiveAPIClient
    private let adapter: RemotiveAdapter
    private let cache: JobCache

    public let sourceIdentifier: String = "remotive"
    public let displayName: String = "Remotive"

    // MARK: - Initialization

    public init(
        apiClient: RemotiveAPIClient = RemotiveAPIClient(),
        adapter: RemotiveAdapter = RemotiveAdapter(),
        cache: JobCache = JobCache(ttl: 300)
    ) {
        self.apiClient = apiClient
        self.adapter = adapter
        self.cache = cache
    }

    // MARK: - Public Methods

    public func fetchJobs() async throws -> [V7Thompson.Job] {
        // Check cache first
        if let cached = await cache.getJobs(for: sourceIdentifier) {
            print("💾 \(displayName): Using cached jobs (\(cached.count) jobs)")
            return cached
        }

        // Fetch from API
        print("📡 \(displayName): Fetching from API...")
        let apiJobs = try await apiClient.fetchJobs()

        // Adapt to Job model
        let jobs = apiJobs.compactMap { adapter.adapt($0) }

        // Cache results
        await cache.setJobs(jobs, for: sourceIdentifier)

        print("✅ \(displayName): Fetched \(jobs.count) jobs")
        return jobs
    }

    public func fetchJob(id: String) async throws -> V7Thompson.Job? {
        // Try cache first
        if let jobs = await cache.getJobs(for: sourceIdentifier),
           let job = jobs.first(where: { $0.id.uuidString == id }) {
            return job
        }

        // Fetch specific job from API
        guard let apiJob = try await apiClient.fetchJob(id: id) else {
            return nil
        }

        return adapter.adapt(apiJob)
    }

    public func clearCache() async {
        await cache.clear(for: sourceIdentifier)
    }
}
```

### 2. API Client (Network Layer)

```swift
// Packages/V7JobSources/Sources/V7JobSources/RemotiveAPIClient.swift

import Foundation

/// API client for Remotive job board
/// Handles all network communication with proper error handling
actor RemotiveAPIClient {
    // MARK: - Configuration

    private let baseURL = "https://remotive.com/api/remote-jobs"
    private let rateLimiter = RateLimiter(
        maxRequests: 100,
        perTimeInterval: 3600  // 1 hour
    )
    private let circuitBreaker = CircuitBreaker(
        failureThreshold: 3,
        recoveryTimeout: 60  // 1 minute
    )
    private let session: URLSession

    // MARK: - Initialization

    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - Public Methods

    func fetchJobs(
        category: String? = nil,
        limit: Int = 50
    ) async throws -> [RemotiveJob] {
        // Check circuit breaker
        try await circuitBreaker.checkState()

        // Check rate limit
        try await rateLimiter.checkLimit()

        // Build request
        var components = URLComponents(string: baseURL)!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        if let category = category {
            queryItems.append(URLQueryItem(name: "category", value: category))
        }
        components.queryItems = queryItems

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10  // 10 second timeout
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("ManifestAndMatchV7/1.0", forHTTPHeaderField: "User-Agent")

        // Perform request with retry logic
        let response = try await performRequestWithRetry(request, maxRetries: 3)

        // Record success
        await rateLimiter.recordRequest()
        await circuitBreaker.recordSuccess()

        return response.jobs
    }

    func fetchJob(id: String) async throws -> RemotiveJob? {
        try await circuitBreaker.checkState()
        try await rateLimiter.checkLimit()

        let url = URL(string: "\(baseURL)/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10

        do {
            let (data, urlResponse) = try await session.data(for: request)

            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            guard httpResponse.statusCode == 200 else {
                if httpResponse.statusCode == 404 {
                    return nil  // Job not found
                }
                throw APIError.httpError(httpResponse.statusCode)
            }

            await rateLimiter.recordRequest()
            await circuitBreaker.recordSuccess()

            let job = try JSONDecoder().decode(RemotiveJob.self, from: data)
            return job

        } catch {
            await circuitBreaker.recordFailure()
            throw error
        }
    }

    // MARK: - Private Methods

    private func performRequestWithRetry(
        _ request: URLRequest,
        maxRetries: Int = 3
    ) async throws -> RemotiveAPIResponse {
        var lastError: Error?
        var retryDelay: TimeInterval = 1.0  // Start with 1 second

        for attempt in 0..<maxRetries {
            do {
                let (data, urlResponse) = try await session.data(for: request)

                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }

                // Handle rate limiting
                if httpResponse.statusCode == 429 {
                    let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After")
                    let waitTime = TimeInterval(retryAfter ?? "60") ?? 60
                    print("⏸️  Rate limited, waiting \(waitTime)s...")
                    try await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
                    continue
                }

                // Handle server errors with retry
                if httpResponse.statusCode >= 500 {
                    throw APIError.serverError(httpResponse.statusCode)
                }

                // Handle client errors (don't retry)
                guard httpResponse.statusCode == 200 else {
                    throw APIError.httpError(httpResponse.statusCode)
                }

                // Parse response
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let response = try decoder.decode(RemotiveAPIResponse.self, from: data)

                return response

            } catch let error as APIError {
                lastError = error

                // Don't retry client errors
                if case .httpError(let code) = error, code >= 400 && code < 500 {
                    throw error
                }

                // Retry with exponential backoff
                if attempt < maxRetries - 1 {
                    print("⚠️  Request failed (attempt \(attempt + 1)/\(maxRetries)), retrying in \(retryDelay)s...")
                    try await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
                    retryDelay *= 2.0  // Exponential backoff
                    // Add jitter (0-25% of delay)
                    retryDelay += Double.random(in: 0...(retryDelay * 0.25))
                }

            } catch {
                lastError = error

                // Network errors - retry
                if attempt < maxRetries - 1 {
                    print("⚠️  Network error (attempt \(attempt + 1)/\(maxRetries)), retrying in \(retryDelay)s...")
                    try await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
                    retryDelay *= 2.0
                }
            }
        }

        // All retries failed
        await circuitBreaker.recordFailure()
        throw lastError ?? APIError.maxRetriesExceeded
    }
}

// MARK: - API Models

struct RemotiveAPIResponse: Codable {
    let jobs: [RemotiveJob]
    let jobCount: Int?

    enum CodingKeys: String, CodingKey {
        case jobs
        case jobCount = "job-count"
    }
}

struct RemotiveJob: Codable, Identifiable {
    let id: Int
    let title: String
    let companyName: String?
    let candidateRequiredLocation: String?
    let jobDescription: String?
    let salary: String?
    let url: String?
    let publicationDate: String?
    let tags: [String]?
    let companyLogoUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, title, salary, url, tags
        case companyName = "company_name"
        case candidateRequiredLocation = "candidate_required_location"
        case jobDescription = "description"
        case publicationDate = "publication_date"
        case companyLogoUrl = "company_logo_url"
    }
}

// MARK: - Error Types

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case serverError(Int)
    case rateLimitExceeded
    case circuitBreakerOpen
    case maxRetriesExceeded
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .serverError(let code):
            return "Server error: \(code)"
        case .rateLimitExceeded:
            return "Rate limit exceeded"
        case .circuitBreakerOpen:
            return "Circuit breaker is open - service temporarily unavailable"
        case .maxRetriesExceeded:
            return "Maximum retries exceeded"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
```

### 3. Rate Limiter (Shared Component)

```swift
// Packages/V7JobSources/Sources/V7JobSources/Supporting/RateLimiter.swift

import Foundation

/// Rate limiter to prevent exceeding API quotas
/// Thread-safe actor implementation
actor RateLimiter {
    // MARK: - Properties

    private let maxRequests: Int
    private let timeInterval: TimeInterval
    private var requestTimestamps: [Date] = []

    // MARK: - Initialization

    init(maxRequests: Int, perTimeInterval: TimeInterval) {
        self.maxRequests = maxRequests
        self.timeInterval = perTimeInterval
    }

    // MARK: - Public Methods

    /// Check if request can be made within rate limit
    func checkLimit() async throws {
        await cleanOldRequests()

        if requestTimestamps.count >= maxRequests {
            let oldestRequest = requestTimestamps.first!
            let timeUntilAvailable = timeInterval - Date().timeIntervalSince(oldestRequest)

            if timeUntilAvailable > 0 {
                throw APIError.rateLimitExceeded
            }
        }
    }

    /// Record a successful request
    func recordRequest() {
        requestTimestamps.append(Date())
    }

    /// Get current usage statistics
    func getUsage() -> (used: Int, available: Int, resetsIn: TimeInterval?) {
        cleanOldRequestsSync()

        let used = requestTimestamps.count
        let available = max(0, maxRequests - used)

        var resetsIn: TimeInterval? = nil
        if let oldestRequest = requestTimestamps.first {
            let elapsed = Date().timeIntervalSince(oldestRequest)
            resetsIn = max(0, timeInterval - elapsed)
        }

        return (used, available, resetsIn)
    }

    /// Reset rate limiter (for testing)
    func reset() {
        requestTimestamps.removeAll()
    }

    // MARK: - Private Methods

    private func cleanOldRequests() async {
        let cutoffDate = Date().addingTimeInterval(-timeInterval)
        requestTimestamps = requestTimestamps.filter { $0 > cutoffDate }
    }

    private func cleanOldRequestsSync() {
        let cutoffDate = Date().addingTimeInterval(-timeInterval)
        requestTimestamps = requestTimestamps.filter { $0 > cutoffDate }
    }
}
```

### 4. Circuit Breaker (Fault Tolerance)

```swift
// Packages/V7JobSources/Sources/V7JobSources/Supporting/CircuitBreaker.swift

import Foundation

/// Circuit breaker pattern for fault tolerance
/// Prevents cascading failures by temporarily disabling failing services
actor CircuitBreaker {
    // MARK: - State

    enum State {
        case closed      // Normal operation
        case open        // Service unavailable, rejecting requests
        case halfOpen    // Testing if service recovered
    }

    // MARK: - Properties

    private var state: State = .closed
    private let failureThreshold: Int
    private let recoveryTimeout: TimeInterval
    private var failureCount: Int = 0
    private var lastFailureTime: Date?
    private var nextRetryTime: Date?

    // MARK: - Initialization

    init(failureThreshold: Int = 3, recoveryTimeout: TimeInterval = 60) {
        self.failureThreshold = failureThreshold
        self.recoveryTimeout = recoveryTimeout
    }

    // MARK: - Public Methods

    /// Check if requests are allowed
    func checkState() async throws {
        switch state {
        case .closed:
            return  // Normal operation

        case .open:
            // Check if recovery timeout has passed
            if let nextRetry = nextRetryTime, Date() >= nextRetry {
                print("🔄 Circuit breaker: Attempting recovery (half-open)")
                state = .halfOpen
                return
            }

            let remaining = nextRetryTime.map { $0.timeIntervalSinceNow } ?? 0
            print("🚫 Circuit breaker: OPEN (retry in \(Int(remaining))s)")
            throw APIError.circuitBreakerOpen

        case .halfOpen:
            return  // Allow test request
        }
    }

    /// Record successful request
    func recordSuccess() {
        switch state {
        case .closed:
            // Reset failure count on success
            if failureCount > 0 {
                failureCount = 0
                lastFailureTime = nil
            }

        case .halfOpen:
            // Recovery successful, close circuit
            print("✅ Circuit breaker: Service recovered (closing)")
            state = .closed
            failureCount = 0
            lastFailureTime = nil
            nextRetryTime = nil

        case .open:
            break  // Shouldn't reach here
        }
    }

    /// Record failed request
    func recordFailure() {
        failureCount += 1
        lastFailureTime = Date()

        switch state {
        case .closed:
            if failureCount >= failureThreshold {
                // Trip circuit breaker
                state = .open
                nextRetryTime = Date().addingTimeInterval(recoveryTimeout)
                print("🚨 Circuit breaker: OPENED (failures: \(failureCount), retry in \(Int(recoveryTimeout))s)")
            }

        case .halfOpen:
            // Recovery failed, reopen circuit
            state = .open
            nextRetryTime = Date().addingTimeInterval(recoveryTimeout)
            print("⚠️  Circuit breaker: Recovery failed, reopening")

        case .open:
            // Extend recovery time
            nextRetryTime = Date().addingTimeInterval(recoveryTimeout)
        }
    }

    /// Get current state
    func getState() -> (state: State, failures: Int, nextRetry: Date?) {
        return (state, failureCount, nextRetryTime)
    }

    /// Reset circuit breaker (for testing)
    func reset() {
        state = .closed
        failureCount = 0
        lastFailureTime = nil
        nextRetryTime = nil
    }
}
```

### 5. Job Adapter (Data Transformation)

```swift
// Packages/V7JobSources/Sources/V7JobSources/RemotiveAdapter.swift

import Foundation
import V7Thompson

/// Adapts Remotive API responses to V7Thompson.Job model
struct RemotiveAdapter {
    private let skillsExtractor = SkillsExtractor()

    func adapt(_ apiJob: RemotiveJob) -> V7Thompson.Job? {
        // Validate required fields
        guard !apiJob.title.isEmpty else {
            print("⚠️  Skipping job with empty title")
            return nil
        }

        guard let companyName = apiJob.companyName, !companyName.isEmpty else {
            print("⚠️  Skipping job with missing company name")
            return nil
        }

        // Build Job
        return V7Thompson.Job(
            id: UUID(),  // Generate fresh UUID
            title: apiJob.title,
            company: companyName,
            location: apiJob.candidateRequiredLocation ?? "Remote",
            description: apiJob.jobDescription,
            salary: apiJob.salary,
            skills: extractSkills(from: apiJob),
            url: parseURL(apiJob.url),
            remote: true,  // Remotive is all remote
            postedDate: parseDate(apiJob.publicationDate),
            source: "Remotive",
            applicationUrl: parseURL(apiJob.url),
            fetchedAt: Date(),
            sourceIdentifier: "remotive"
        )
    }

    // MARK: - Helper Methods

    private func extractSkills(from apiJob: RemotiveJob) -> [String] {
        var skills: [String] = []

        // Use tags from API
        if let tags = apiJob.tags {
            skills.append(contentsOf: tags)
        }

        // Extract from description
        if let description = apiJob.jobDescription {
            let extractedSkills = skillsExtractor.extract(from: description)
            skills.append(contentsOf: extractedSkills)
        }

        // Deduplicate and normalize
        let uniqueSkills = Set(skills.map { $0.trimmingCharacters(in: .whitespaces).capitalized })

        // Filter out generic skills
        let filtered = uniqueSkills.filter { !isGenericSkill($0) }

        return Array(filtered.prefix(10))
    }

    private func isGenericSkill(_ skill: String) -> Bool {
        let generic = ["Teamwork", "Communication", "Leadership", "Problem Solving"]
        return generic.contains(skill)
    }

    private func parseURL(_ urlString: String?) -> URL? {
        guard let urlString = urlString, !urlString.isEmpty else {
            return nil
        }
        return URL(string: urlString)
    }

    private func parseDate(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        return formatter.date(from: dateString)
    }
}
```

## Scaffolding Script

Create complete integration from template:

```bash
#!/bin/bash
# scripts/scaffold_api_integration.sh SOURCE_NAME BASE_URL

SOURCE_NAME=$1
BASE_URL=$2

if [ -z "$SOURCE_NAME" ] || [ -z "$BASE_URL" ]; then
    echo "Usage: $0 SOURCE_NAME BASE_URL"
    echo "Example: $0 AngelList https://api.angel.co/1"
    exit 1
fi

PROJECT_ROOT="/path/to/v_7_uppgrade"
SOURCES_DIR="$PROJECT_ROOT/Packages/V7JobSources/Sources/V7JobSources"

# Convert to PascalCase
PASCAL_NAME="$(echo "$SOURCE_NAME" | sed 's/.*/\u&/')"

echo "🏗️  Scaffolding $PASCAL_NAME API integration..."
echo ""

# Create job source file
cat > "$SOURCES_DIR/${PASCAL_NAME}JobSource.swift" <<EOF
// Auto-generated by api-integration-builder
import Foundation
import V7Thompson

@MainActor
public final class ${PASCAL_NAME}JobSource: JobSourceProtocol {
    private let apiClient: ${PASCAL_NAME}APIClient
    private let adapter: ${PASCAL_NAME}Adapter
    private let cache: JobCache

    public let sourceIdentifier: String = "${SOURCE_NAME,,}"
    public let displayName: String = "$SOURCE_NAME"

    public init() {
        self.apiClient = ${PASCAL_NAME}APIClient()
        self.adapter = ${PASCAL_NAME}Adapter()
        self.cache = JobCache(ttl: 300)
    }

    public func fetchJobs() async throws -> [V7Thompson.Job] {
        if let cached = await cache.getJobs(for: sourceIdentifier) {
            return cached
        }

        let apiJobs = try await apiClient.fetchJobs()
        let jobs = apiJobs.compactMap { adapter.adapt(\$0) }

        await cache.setJobs(jobs, for: sourceIdentifier)
        return jobs
    }
}
EOF

echo "✅ Created ${PASCAL_NAME}JobSource.swift"

# Create API client
cat > "$SOURCES_DIR/${PASCAL_NAME}APIClient.swift" <<EOF
// Auto-generated by api-integration-builder
import Foundation

actor ${PASCAL_NAME}APIClient {
    private let baseURL = "$BASE_URL"
    private let rateLimiter = RateLimiter(maxRequests: 100, perTimeInterval: 3600)
    private let circuitBreaker = CircuitBreaker(failureThreshold: 3, recoveryTimeout: 60)

    func fetchJobs() async throws -> [${PASCAL_NAME}Job] {
        try await circuitBreaker.checkState()
        try await rateLimiter.checkLimit()

        // TODO: Implement API request
        fatalError("Implement API request for $SOURCE_NAME")
    }
}

struct ${PASCAL_NAME}Job: Codable {
    // TODO: Define API response model
}
EOF

echo "✅ Created ${PASCAL_NAME}APIClient.swift"

# Create adapter
cat > "$SOURCES_DIR/${PASCAL_NAME}Adapter.swift" <<EOF
// Auto-generated by api-integration-builder
import Foundation
import V7Thompson

struct ${PASCAL_NAME}Adapter {
    func adapt(_ apiJob: ${PASCAL_NAME}Job) -> V7Thompson.Job? {
        // TODO: Implement adaptation logic
        return nil
    }
}
EOF

echo "✅ Created ${PASCAL_NAME}Adapter.swift"

echo ""
echo "🎉 Integration scaffolded successfully!"
echo ""
echo "📝 Next steps:"
echo "  1. Implement API request in ${PASCAL_NAME}APIClient.swift"
echo "  2. Define API response model in ${PASCAL_NAME}APIClient.swift"
echo "  3. Implement adaptation logic in ${PASCAL_NAME}Adapter.swift"
echo "  4. Test with: swift test --filter ${PASCAL_NAME}Tests"
echo "  5. Validate with: ./scripts/validate_job_structure.sh ${SOURCE_NAME,,}"
```

## Common API Patterns

### Pattern 1: Paginated Results

```swift
func fetchAllJobs() async throws -> [RemotiveJob] {
    var allJobs: [RemotiveJob] = []
    var page = 1
    let pageSize = 50

    while true {
        let batch = try await fetchJobs(page: page, limit: pageSize)

        if batch.isEmpty {
            break  // No more results
        }

        allJobs.append(contentsOf: batch)

        if batch.count < pageSize {
            break  // Last page
        }

        page += 1
    }

    return allJobs
}
```

### Pattern 2: Authentication (Bearer Token)

```swift
actor AuthenticatedAPIClient {
    private let apiKey: String

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    private func authenticatedRequest(_ url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        return request
    }
}
```

### Pattern 3: Webhook/Realtime Updates

```swift
actor RealtimeJobSource {
    private var subscribers: [UUID: AsyncStream<V7Thompson.Job>.Continuation] = [:]

    func subscribe() -> AsyncStream<V7Thompson.Job> {
        AsyncStream { continuation in
            let id = UUID()
            subscribers[id] = continuation

            continuation.onTermination = { [weak self] _ in
                Task { await self?.unsubscribe(id) }
            }
        }
    }

    private func unsubscribe(_ id: UUID) {
        subscribers.removeValue(forKey: id)
    }

    func notifyNewJob(_ job: V7Thompson.Job) {
        for continuation in subscribers.values {
            continuation.yield(job)
        }
    }
}
```

## Quick Commands

**Scaffolding:**
- "Create [SourceName] API integration"
- "Scaffold job source for [API]"
- "Generate boilerplate for [service]"

**Implementation:**
- "Add authentication to [source]"
- "Implement pagination for [API]"
- "Add webhook support to [source]"

**Debugging:**
- "Why is [source] rate limited?"
- "Fix circuit breaker for [API]"
- "Test [source] connectivity"

## Integration Checklist

Before shipping an API integration:

### Configuration
- [ ] Base URL configured
- [ ] Rate limits set correctly
- [ ] Authentication implemented
- [ ] Timeout values appropriate (10s default)

### Error Handling
- [ ] Circuit breaker enabled
- [ ] Retry logic with exponential backoff
- [ ] Rate limiting respected
- [ ] Network errors handled

### Data Quality
- [ ] All required fields validated
- [ ] Skills extraction working
- [ ] URLs validated
- [ ] Dates parsed correctly

### Performance
- [ ] Caching implemented (5-10 min TTL)
- [ ] No blocking on main thread
- [ ] Thompson scoring <10ms maintained

### Testing
- [ ] Unit tests for adapter
- [ ] Integration tests for API client
- [ ] Manual testing with real API
- [ ] Validation script passes

## Integration with Other Skills

Works alongside:
- **job-source-integration-validator**: Validates integration quality
- **v7-architecture-guardian**: Ensures proper Swift 6 patterns
- **performance-regression-detector**: Checks performance impact

## Usage

This skill activates when you:
- Request new API integration
- Scaffold job source code
- Implement network layer
- Debug API connectivity
- Use keywords: "API", "integration", "scaffold", "job source"

The skill provides templates, scaffolding scripts, and best practices for production-ready API integrations.

---

**Last Updated**: Created per user request
**Supported Patterns**: REST, GraphQL, Webhooks, RSS
**Maintenance**: Update templates as patterns evolve
