---
description: API integration expert with complete knowledge of V8's 9 job source APIs, rate limiting, circuit breakers, and error handling
version: 2.0.0
author: V8 Development Team
tags: [api-integration, job-sources, rate-limiting, circuit-breaker, v8-domain-expert]
updated: 2025-11-08
---

# v8-job-sources-expert

**Job Source API Integration Expert - 9 External APIs + Resilience Patterns**

## Core Expertise

Master of all job source integrations in Manifest & Match V8:
- **9 API clients** (Adzuna, Greenhouse, Lever, Jobicy, Jooble, USAJobs, RemoteOK, RSS, JobAPIClient)
- **Rate limiting** (token bucket pattern, per-source limits)
- **Circuit breakers** (3-5 failure threshold, automatic recovery)
- **Error handling** (exponential backoff, graceful degradation)
- **Caching strategies** (24-hour TTL, 70%+ hit rate)

## Source Locations

**Primary**: `/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8/Packages/V7Services`
**Docs**: `/Users/jasonl/Desktop/ios26_manifest_and_match/C4_ARCHITECTURE_ANALYSIS/technical/07_JOB_SOURCE_INTEGRATIONS.md`
**57 Swift files in V7Services package**


## ⚠️ Current Active Sources (2026-05-08)
**Only JSearch is active.** All others are disabled.
- ✅ JSearch (OpenWebNinja) — env var `JSEARCH_API_KEY` in Xcode scheme
- ❌ CoreSignal — invalid key ("no Route matched"), disabled
- ❌ Greenhouse — built, free, no key needed, commented out
- ❌ Lever — built, free, no key needed, commented out
- ❌ All others — no keys or disabled per user request

**Phase 4 work:** Enable Greenhouse + Lever (free, no keys), then evaluate Adzuna/Jobicy.


## API Clients (9 Total)

### 1. Adzuna API Client

**Location**: `V7Services/Sources/V7Services/CompanyAPIs/AdzunaAPIClient.swift`

**API Type**: Global job aggregator (REST)
**Authentication**: API Key + Application ID
**Rate Limit**: 100 requests/minute
**Circuit Breaker**: 5 failures threshold

**Endpoints**:
```swift
GET https://api.adzuna.com/v1/api/jobs/{country}/search/{page}

Query Parameters:
- app_id: String (required)
- app_key: String (required)
- results_per_page: Int (default: 50, max: 100)
- what: String (keywords)
- where: String (location)
- salary_min: Int
- salary_max: Int
- full_time: Int (1/0)
- part_time: Int (1/0)
```

**Response Format**:
```json
{
  "results": [
    {
      "id": "123456",
      "title": "Software Engineer",
      "company": {"display_name": "Apple Inc."},
      "location": {"display_name": "Cupertino, CA"},
      "description": "...",
      "salary_min": 120000,
      "salary_max": 180000,
      "created": "2025-01-15T10:30:00Z",
      "redirect_url": "https://..."
    }
  ],
  "count": 15234
}
```

**Implementation**:
```swift
struct AdzunaAPIClient: JobSourceProtocol {
    private let baseURL = "https://api.adzuna.com/v1/api/jobs"
    private let appID: String
    private let appKey: String
    private let rateLimitManager = RateLimitManager.shared

    func fetchJobs(query: JobSearchQuery) async throws -> [RawJobData] {
        // 1. Acquire rate limit token
        guard await rateLimitManager.acquireToken(for: "adzuna") else {
            throw JobSourceError.rateLimitExceeded(resetsAt: nextResetTime())
        }

        // 2. Build URL
        var components = URLComponents(string: "\(baseURL)/us/search/1")!
        components.queryItems = [
            URLQueryItem(name: "app_id", value: appID),
            URLQueryItem(name: "app_key", value: appKey),
            URLQueryItem(name: "results_per_page", value: "50"),
            URLQueryItem(name: "what", value: query.keywords.joined(separator: " ")),
            URLQueryItem(name: "where", value: query.location ?? "")
        ]

        // 3. Make request with retry
        let data = try await fetchWithRetry(url: components.url!, maxRetries: 3)

        // 4. Parse response
        let response = try JSONDecoder().decode(AdzunaResponse.self, from: data)

        // 5. Normalize to RawJobData
        return response.results.map { normalizeJob($0) }
    }

    private func normalizeJob(_ job: AdzunaJob) -> RawJobData {
        RawJobData(
            id: UUID(),
            title: job.title,
            company: job.company.displayName,
            location: job.location.displayName,
            description: job.description,
            salary: SalaryRange(min: job.salaryMin, max: job.salaryMax),
            postedDate: ISO8601DateFormatter().date(from: job.created) ?? Date(),
            sourceAPI: "adzuna",
            externalURL: URL(string: job.redirectURL)
        )
    }
}
```

---

### 2. Greenhouse API Client

**Location**: `V7Services/Sources/V7Services/CompanyAPIs/GreenhouseAPIClient.swift`

**API Type**: Company job boards (REST)
**Authentication**: None (public API)
**Rate Limit**: 60 requests/minute
**Circuit Breaker**: 3 failures threshold

**Endpoints**:
```swift
GET https://boards-api.greenhouse.io/v1/boards/{board_token}/jobs

Query Parameters:
- content: String ("true" to include full description)
```

**Features**:
- Multi-company support (pass different board tokens)
- Full job descriptions included
- Department/office filtering
- No authentication required (public boards)

**Companies Using Greenhouse**:
- Airbnb
- Pinterest
- Snap
- DoorDash
- 100+ other tech companies

**Implementation Pattern**:
```swift
struct GreenhouseAPIClient: JobSourceProtocol {
    private let boardTokens: [String] // Multiple company boards

    func fetchJobs(query: JobSearchQuery) async throws -> [RawJobData] {
        // Fetch from multiple boards in parallel
        return try await withThrowingTaskGroup(of: [RawJobData].self) { group in
            for token in boardTokens {
                group.addTask {
                    try await self.fetchFromBoard(token: token, query: query)
                }
            }

            var allJobs: [RawJobData] = []
            for try await jobs in group {
                allJobs.append(contentsOf: jobs)
            }
            return allJobs
        }
    }
}
```

---

### 3. Lever API Client

**Location**: `V7Services/Sources/V7Services/CompanyAPIs/LeverAPIClient.swift`

**API Type**: Company job boards (REST)
**Authentication**: None (public API)
**Rate Limit**: 120 requests/minute (highest)
**Circuit Breaker**: 5 failures threshold

**Endpoints**:
```swift
GET https://api.lever.co/v0/postings/{company}

Query Parameters:
- mode: String ("json")
- limit: Int (default: 100)
- skip: Int (pagination)
- location: String (filter)
- commitment: String (Full-time, Part-time, Contract)
- team: String (Engineering, Sales, etc.)
```

**Companies Using Lever**:
- Netflix
- Shopify
- Atlassian
- Stripe
- 200+ other companies

**Advanced Features**:
- Department/team filtering
- Commitment type filtering (full-time, part-time, contract, internship)
- Location-based filtering
- Pagination support (100 jobs per page)

---

### 4. Jobicy API Client

**Location**: `V7Services/Sources/V7Services/CompanyAPIs/JobicyAPIClient.swift`

**API Type**: Remote jobs aggregator (REST)
**Authentication**: API Key (header: `X-API-Key`)
**Rate Limit**: 50 requests/minute
**Circuit Breaker**: 3 failures threshold

**Endpoints**:
```swift
GET https://jobicy.com/api/v2/remote-jobs

Query Parameters:
- count: Int (default: 50, max: 50)
- geo: String (country code, e.g., "us")
- industry: String (tech, marketing, design, etc.)
- tag: String (skill filter)
```

**Specialization**: 100% remote jobs only

**Example Response**:
```json
{
  "jobs": [
    {
      "id": 789012,
      "jobTitle": "Senior Backend Engineer",
      "companyName": "GitLab",
      "jobGeo": "Anywhere",
      "jobType": "Full Time",
      "jobLevel": "Senior",
      "pubDate": "2025-01-15",
      "url": "https://..."
    }
  ]
}
```

---

### 5. USAJobs API Client

**Location**: `V7Services/Sources/V7Services/CompanyAPIs/USAJobsAPIClient.swift`

**API Type**: US government jobs (REST)
**Authentication**: API Key (header: `Authorization-Key`)
**Rate Limit**: 30 requests/minute (lowest)
**Circuit Breaker**: 3 failures threshold

**Endpoints**:
```swift
GET https://data.usajobs.gov/api/search

Headers:
- Host: data.usajobs.gov
- User-Agent: your-email@example.com
- Authorization-Key: YOUR_API_KEY

Query Parameters:
- Keyword: String
- LocationName: String
- PostingChannel: String (default: "Public")
- ResultsPerPage: Int (default: 25, max: 500)
```

**Special Requirements**:
- Requires email in User-Agent header
- Strict rate limiting (30/min)
- Government-specific metadata (grade levels, security clearance)

**Job Categories**:
- IT/Cybersecurity
- Engineering
- Science
- Healthcare
- Administrative
- 100+ other federal categories

---

### 6. RSS Feed Job Source

**Location**: `V7Services/Sources/V7Services/CompanyAPIs/RSSFeedJobSource.swift`

**API Type**: RSS/Atom feed parser
**Authentication**: None
**Rate Limit**: 20 requests/minute (per feed)
**Circuit Breaker**: 5 failures threshold

**Supported Feed URLs**:
```swift
let feedURLs: [URL] = [
    URL(string: "https://jobs.apple.com/en-us/rss")!,
    URL(string: "https://careers.google.com/api/v3/search/rss")!,
    URL(string: "https://www.amazon.jobs/en/rss")!,
    URL(string: "https://jobs.netflix.com/rss")!
    // + 20 more company RSS feeds
]
```

**Parser Implementation**:
```swift
import Foundation

struct RSSFeedJobSource: JobSourceProtocol {
    private let parser = XMLParser()

    func fetchJobs(query: JobSearchQuery) async throws -> [RawJobData] {
        var allJobs: [RawJobData] = []

        for feedURL in feedURLs {
            let (data, _) = try await URLSession.shared.data(from: feedURL)

            let parsedJobs = parseRSSFeed(data: data)
            allJobs.append(contentsOf: parsedJobs)
        }

        return allJobs.filter { job in
            matchesQuery(job, query: query)
        }
    }

    private func parseRSSFeed(data: Data) -> [RawJobData] {
        // Parse XML using XMLParser
        // Extract <item> elements
        // Map to RawJobData
    }
}
```

**Advantages**:
- Free (no API keys)
- Real-time updates
- Direct from companies
- No rate limits (within reason)

---

### 7. RemoteOK API Client

**Location**: `V7Services/Sources/V7Services/CompanyAPIs/RemoteOKAPIClient.swift`

**API Type**: Remote jobs aggregator (REST)
**Authentication**: None (public API)
**Rate Limit**: 100 requests/minute
**Circuit Breaker**: 5 failures threshold

**Endpoints**:
```swift
GET https://remoteok.com/api

// Returns all jobs (no query params, client-side filtering)
```

**Response Format**:
```json
[
  {
    "id": "456789",
    "slug": "senior-frontend-engineer-react",
    "company": "Stripe",
    "position": "Senior Frontend Engineer",
    "tags": ["react", "typescript", "frontend"],
    "location": "Remote",
    "salary_min": 150000,
    "salary_max": 220000,
    "date": "2025-01-15T12:00:00Z",
    "url": "https://..."
  }
]
```

**Features**:
- 100% remote jobs
- Tag-based filtering (client-side)
- Salary ranges included
- No authentication needed

---

### 8. Jooble API Client

**Location**: `V7Services/Sources/V7Services/CompanyAPIs/JoobleAPIClient.swift`

**API Type**: Global job aggregator (REST)
**Authentication**: API Key (header)
**Rate Limit**: 60 requests/minute
**Circuit Breaker**: 5 failures threshold

**Features**:
- Multi-country support
- Keyword and location search
- Salary filtering
- Global job aggregation

---

### 9. JobAPIClient (Generic Base)

**Location**: `V7Services/Sources/V7Services/CompanyAPIs/JobAPIClient.swift`

**API Type**: Generic base client for job APIs
**Purpose**: Shared utilities, error handling, response parsing

**Features**:
- Common API patterns
- Shared error handling
- Response normalization
- Base protocol conformance

---

## Rate Limiting (Token Bucket Pattern)

### RateLimitManager.swift

**Location**: `V7Services/Sources/V7Services/RateLimitManager.swift`

**Design**: Actor-based for thread safety

```swift
actor RateLimitManager {
    static let shared = RateLimitManager()

    private var tokenBuckets: [String: TokenBucket] = [:]

    struct TokenBucket {
        var tokens: Int
        var capacity: Int
        var refillRate: Int // tokens per minute
        var lastRefill: Date

        mutating func tryAcquire() -> Bool {
            refillTokens()

            if tokens > 0 {
                tokens -= 1
                return true
            }
            return false
        }

        mutating func refillTokens() {
            let now = Date()
            let elapsed = now.timeIntervalSince(lastRefill)
            let minutesElapsed = elapsed / 60.0

            let tokensToAdd = Int(minutesElapsed * Double(refillRate))
            if tokensToAdd > 0 {
                tokens = min(tokens + tokensToAdd, capacity)
                lastRefill = now
            }
        }
    }

    func registerSource(id: String, capacity: Int, refillRate: Int) {
        tokenBuckets[id] = TokenBucket(
            tokens: capacity,
            capacity: capacity,
            refillRate: refillRate,
            lastRefill: Date()
        )
    }

    func acquireToken(for sourceID: String) async -> Bool {
        guard var bucket = tokenBuckets[sourceID] else {
            return false // Source not registered
        }

        let acquired = bucket.tryAcquire()
        tokenBuckets[sourceID] = bucket

        return acquired
    }
}
```

**Per-Source Limits**:
```swift
RateLimitManager.shared.registerSource(id: "adzuna", capacity: 100, refillRate: 100)
RateLimitManager.shared.registerSource(id: "greenhouse", capacity: 60, refillRate: 60)
RateLimitManager.shared.registerSource(id: "lever", capacity: 120, refillRate: 120)
RateLimitManager.shared.registerSource(id: "jobicy", capacity: 50, refillRate: 50)
RateLimitManager.shared.registerSource(id: "usajobs", capacity: 30, refillRate: 30)
RateLimitManager.shared.registerSource(id: "rss", capacity: 20, refillRate: 20)
RateLimitManager.shared.registerSource(id: "remoteok", capacity: 100, refillRate: 100)
```

---

## Circuit Breakers

### CircuitBreaker Pattern

**States**:
1. **Closed** (normal operation)
2. **Open** (failing, reject requests immediately)
3. **Half-Open** (recovery test, allow 1 request)

**Implementation**:
```swift
actor CircuitBreaker {
    enum State {
        case closed
        case open(resetAt: Date)
        case halfOpen
    }

    private var state: State = .closed
    private var failureCount: Int = 0
    private let threshold: Int // e.g., 5 failures
    private let timeout: TimeInterval // e.g., 60 seconds

    func execute<T>(_ operation: () async throws -> T) async throws -> T {
        // Check state
        switch state {
        case .closed:
            do {
                let result = try await operation()
                failureCount = 0 // Reset on success
                return result
            } catch {
                failureCount += 1
                if failureCount >= threshold {
                    state = .open(resetAt: Date().addingTimeInterval(timeout))
                }
                throw error
            }

        case .open(let resetAt):
            if Date() >= resetAt {
                state = .halfOpen
                return try await execute(operation) // Retry
            } else {
                throw CircuitBreakerError.open(resetsAt: resetAt)
            }

        case .halfOpen:
            do {
                let result = try await operation()
                state = .closed // Success, close circuit
                failureCount = 0
                return result
            } catch {
                state = .open(resetAt: Date().addingTimeInterval(timeout))
                throw error
            }
        }
    }
}
```

**Per-Source Thresholds**:
- Adzuna: 5 failures
- Greenhouse: 3 failures
- Lever: 5 failures
- Jobicy: 3 failures
- USAJobs: 3 failures
- RSS: 5 failures
- RemoteOK: 5 failures

---

## Error Handling

### Exponential Backoff

```swift
func fetchWithRetry<T>(
    operation: () async throws -> T,
    maxRetries: Int = 3
) async throws -> T {
    var lastError: Error?

    for attempt in 0..<maxRetries {
        do {
            return try await operation()
        } catch {
            lastError = error

            if attempt < maxRetries - 1 {
                // Exponential backoff: 1s, 2s, 4s, 8s
                let delay = pow(2.0, Double(attempt))
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
    }

    throw lastError!
}
```

### Graceful Degradation

```swift
func fetchJobsFromAllSources(query: JobSearchQuery) async throws -> [RawJobData] {
    let sources: [JobSourceProtocol] = [
        adzunaClient,
        greenhouseClient,
        leverClient,
        jobicyClient,
        usajobsClient,
        rssFeedClient,
        remoteokClient
    ]

    // Fetch from all sources in parallel (continue on errors)
    return await withTaskGroup(of: [RawJobData]?.self) { group in
        for source in sources {
            group.addTask {
                do {
                    return try await source.fetchJobs(query: query)
                } catch {
                    logger.error("Source \(source) failed: \(error)")
                    return nil // Continue with other sources
                }
            }
        }

        var allJobs: [RawJobData] = []
        for await jobs in group {
            if let jobs = jobs {
                allJobs.append(contentsOf: jobs)
            }
        }
        return allJobs
    }
}
```

**Result**: If 3/7 sources fail, still get jobs from 4/7 ✅

---

## Job Discovery Coordinator

### JobDiscoveryCoordinator.swift

**Location**: `V7Services/Sources/V7Services/JobDiscoveryCoordinator.swift`

**Purpose**: Orchestrates multi-source job fetching

```swift
@MainActor
class JobDiscoveryCoordinator: ObservableObject {
    @Published var jobs: [ThompsonScore] = []
    @Published var isLoading: Bool = false

    private let sources: [JobSourceProtocol]
    private let thompsonEngine: ThompsonSamplingEngine

    func loadInitialJobs(profile: UserProfile) async {
        isLoading = true

        do {
            // 1. Build search query from profile
            let query = buildSearchQuery(from: profile)

            // 2. Fetch from all sources (parallel + graceful degradation)
            let rawJobs = await fetchJobsFromAllSources(query: query)

            // 3. Deduplicate (by title + company)
            let dedupedJobs = deduplicate(rawJobs)

            // 4. Score with Thompson Sampling
            let scoredJobs = dedupedJobs.map { job in
                thompsonEngine.score(job, profile)
            }.sorted { $0.score > $1.score }

            // 5. Cache results (24hr TTL)
            await cacheJobs(scoredJobs)

            // 6. Update UI
            jobs = scoredJobs
        } catch {
            logger.error("Job discovery failed: \(error)")
        }

        isLoading = false
    }

    private func deduplicate(_ jobs: [RawJobData]) -> [RawJobData] {
        var seen: Set<String> = []
        return jobs.filter { job in
            let key = "\(job.title)|\(job.company)".lowercased()
            if seen.contains(key) {
                return false
            }
            seen.insert(key)
            return true
        }
    }
}
```

---

## Caching Strategy

### JobCache (24-Hour TTL)

**Location**: Core Data entity (see v8-data-models-expert)

**Cache Flow**:
```swift
func fetchJobs(query: JobSearchQuery) async throws -> [RawJobData] {
    // 1. Check cache first
    let cached = try await JobCache.fetch(query: query, in: context)
    if let cached = cached, !cached.isExpired {
        logger.info("Cache hit (24hr)")
        return cached.jobs
    }

    // 2. Cache miss - fetch from APIs
    let jobs = await fetchJobsFromAllSources(query: query)

    // 3. Update cache
    let cacheEntry = JobCache(context: context)
    cacheEntry.query = query.toJSON()
    cacheEntry.jobs = jobs.toData()
    cacheEntry.fetchedAt = Date()
    cacheEntry.expiresAt = Date().addingTimeInterval(86400) // 24hr

    try? context.save()

    return jobs
}
```

**Cache Hit Rate Target**: >70%

---

## API Keys Management

### KeychainManager Integration

**Location**: `V7AI/Sources/V7AI/KeychainManager.swift`

**Storage**:
```swift
let keychain = KeychainManager.shared

// Store keys securely
try keychain.store(key: "ADZUNA_API_KEY", value: "abc123")
try keychain.store(key: "ADZUNA_APP_ID", value: "12345")
try keychain.store(key: "USAJOBS_API_KEY", value: "xyz789")
try keychain.store(key: "JOBICY_API_KEY", value: "def456")

// Retrieve keys
let adzunaKey = keychain.retrieve(key: "ADZUNA_API_KEY")
```

**NEVER** hardcode API keys in source code.

---

## Performance Targets

### API Response Times

| Source | Target | P95 | P99 |
|--------|--------|-----|-----|
| Adzuna | <2s | 2.5s | 3s |
| Greenhouse | <1.5s | 2s | 2.5s |
| Lever | <1.5s | 2s | 2.5s |
| Jobicy | <2s | 2.5s | 3s |
| USAJobs | <3s | 4s | 5s |
| RSS | <1s | 1.5s | 2s |
| RemoteOK | <1.5s | 2s | 2.5s |

**Overall Target**: <2s average (all 7 sources in parallel)

---

## Common Questions & Answers

### Q: What if all 7 sources fail?

**A**: Fallback to cached jobs (24hr TTL). If cache is empty, show error message with retry button.

### Q: How to add a new API source (e.g., LinkedIn)?

**A**:
1. Create `LinkedInAPIClient.swift` implementing `JobSourceProtocol`
2. Register rate limit: `RateLimitManager.shared.registerSource(id: "linkedin", capacity: 300, refillRate: 300)`
3. Add circuit breaker with 5 failure threshold
4. Add to `JobDiscoveryCoordinator.sources` array
5. Store API key in Keychain
6. Write unit tests

### Q: How to debug rate limiting issues?

**A**:
1. Check `RateLimitManager` logs for "rate limit exceeded"
2. Verify token bucket capacity and refill rate
3. Monitor API response headers (often include rate limit info)
4. Use `DEBUG_RATE_LIMITS=true` environment variable

### Q: What if a source changes its API?

**A**:
1. Circuit breaker will open after 3-5 failures
2. Other 6 sources continue working (graceful degradation)
3. Monitor logs for parsing errors
4. Update client implementation
5. Deploy fix and circuit breaker auto-recovers

---

## Success Criteria

v8-job-sources-expert is successful when:

✅ All 7 API clients implemented and working
✅ Rate limiting prevents API quota violations
✅ Circuit breakers prevent cascading failures
✅ Exponential backoff implemented on retries
✅ Graceful degradation (6/7 sources working = success)
✅ Cache hit rate >70%
✅ API response time <2s average
✅ All API keys stored in Keychain (never hardcoded)

---

**v8-job-sources-expert**: Master of resilient API integration, ensuring reliable job discovery across 7 external sources with industry-standard reliability patterns.
