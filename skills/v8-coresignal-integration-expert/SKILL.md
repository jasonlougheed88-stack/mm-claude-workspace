---
description: Expert guide for integrating CoreSignal Jobs API into Manifest & Match V8 with MCP server (preferred) and REST API fallback, complete UserProfile mapping
version: 2.0.0
author: V8 Development Team
tags: [v8, coresignal, api-integration, job-sources, elasticsearch, user-profile, mcp-server]
created: 2025-11-10
updated: 2025-11-10
---

# v8-coresignal-integration-expert

**Complete CoreSignal Jobs API Integration Expert for Manifest & Match V8**

## Core Mission

Master CoreSignal Jobs API integration for V8, providing:
- **🆕 MCP Server Integration** (PREFERRED): Direct access via Model Context Protocol
- **REST API Fallback**: Full HTTP client implementation when MCP unavailable
- **Complete API knowledge**: All endpoints, parameters, and schemas
- **UserProfile mapping**: How every onboarding field maps to API queries
- **Production-ready patterns**: Following V8's JobSourceProtocol architecture
- **Elasticsearch DSL expertise**: Building optimized queries from user data
- **Error handling**: Rate limits, circuit breakers, authentication

---

## 🚀 Quick Start: MCP Server (RECOMMENDED)

### What is CoreSignal MCP?

**Model Context Protocol (MCP)** provides direct tool-based access to CoreSignal API without writing HTTP clients. This is the FASTEST way to integrate.

### Step 1: Add MCP Server Configuration

**Your MCP Config** (already configured):
```json
{
  "mcpServers": {
    "coresignal_data_api": {
      "command": "npx",
      "args": [
        "mcp-remote",
        "https://mcp.coresignal.com/mcp",
        "--header",
        "apikey:${AUTH_HEADER}"
      ],
      "env": {
        "AUTH_HEADER": "9S5q3ZSpmUM8gnUm65gCvboj1SfVSFEn"
      }
    }
  }
}
```

**Location**: Add to Claude Desktop settings or `~/.claude/mcp.json`

### Step 2: Verify MCP Server Availability

```bash
# Check if server is loaded
# In Claude Code, MCP tools will appear as mcp__coresignal_data_api__*
```

### Step 3: Use MCP Tools (When Available)

MCP provides these tools automatically:
- `mcp__coresignal_data_api__search_jobs` - Search jobs with query
- `mcp__coresignal_data_api__get_job` - Get full job details
- `mcp__coresignal_data_api__preview_search` - Test query without credits

**Example Usage**:
```swift
// In your V8 code, call MCP tools via Claude Code API
// (Implementation depends on how Claude Code exposes MCP to Swift)
```

---

## Traditional REST API (Fallback)

### CoreSignal API Essentials

**Base URL**: `https://api.coresignal.com`

**Authentication**:
```http
-H "apikey: 9S5q3ZSpmUM8gnUm65gCvboj1SfVSFEn"
```

**Primary Endpoints**:
- `POST /v2/job_multi_source/search/es_dsl` - Multi-source job search
- `POST /v2/job_base/search/es_dsl` - Base jobs search
- `GET /v2/job_multi_source/collect/{job_id}` - Fetch full job details

**Rate Limits**:
- Search: 18 requests/second
- Collect: 54 requests/second
- Credits: 2 credits per search, 2 per collection

---

## Part 1: User Profile → CoreSignal API Mapping

### UserProfile Fields (From Onboarding)

**Location**: `V7Data/Sources/V7Data/Entities/UserProfile+CoreData.swift`

```swift
public class UserProfile: NSManagedObject {
    // Basic Info
    @NSManaged public var name: String
    @NSManaged public var email: String
    @NSManaged public var phone: String?

    // Job Preferences
    @NSManaged public var desiredRoles: [String]?         // → title filter
    @NSManaged public var currentDomain: String           // → title/description filter
    @NSManaged public var experienceLevel: String         // → seniority filter

    // Location
    @NSManaged public var primaryLocationCity: String?    // → city filter
    @NSManaged public var primaryLocationCountry: String? // → country filter
    @NSManaged public var primaryLocationLatitude: Double // → geo filter
    @NSManaged public var primaryLocationLongitude: Double

    // Skills
    @NSManaged public var resumeSkills: [String]?        // → description/benefits filter
    @NSManaged public var onetSkills: [String]?          // → skills matching

    // Salary
    @NSManaged public var salaryMin: NSNumber?           // → salary.min_value filter
    @NSManaged public var salaryMax: NSNumber?           // → salary.max_value filter

    // Remote
    @NSManaged public var remotePreference: String       // → accepts_remote filter

    // O*NET Profile
    @NSManaged public var onetEducationLevel: Int16      // → not directly used
    @NSManaged public var onetRIASECRealistic: Double    // → for ranking
    @NSManaged public var onetRIASECInvestigative: Double
    @NSManaged public var onetRIASECArtistic: Double
    @NSManaged public var onetRIASECSocial: Double
    @NSManaged public var onetRIASECEnterprising: Double
    @NSManaged public var onetRIASECConventional: Double
}
```

### CoreSignal API Fields (Response Schema)

**From Multi-source Jobs API Data Dictionary**:

```json
{
  "job_id": "string",
  "title": "string",
  "description": "string",
  "seniority": "string",
  "employment_type": "string",
  "accepts_remote": boolean,
  "location": "string",
  "city": "string",
  "country": "string",
  "latitude": float,
  "longitude": float,
  "company_name": "string",
  "company_domain": "string",
  "company_size_range": "string",
  "company_industry": "string",
  "salary": [
    {
      "min_value": float,
      "max_value": float,
      "currency": "string",
      "type": "string"
    }
  ],
  "benefits": ["string"],
  "skills": ["string"],
  "functions": ["string"],
  "external_url": "string",
  "date_posted": "timestamp",
  "valid_through": "timestamp"
}
```

### Complete UserProfile → Elasticsearch DSL Mapping

| UserProfile Field | CoreSignal API Field | Query Type | Example |
|------------------|---------------------|------------|---------|
| `desiredRoles` | `title` | `bool.should` (multi-match) | `["Software Engineer", "iOS Developer"]` → `title: (Software Engineer OR iOS Developer)` |
| `currentDomain` | `title`, `description` | `match` | `"iOS Development"` → search in title/description |
| `experienceLevel` | `seniority` | `term` | `"mid"` → `seniority: "Mid-Senior level"` |
| `primaryLocationCity` | `city` | `term` | `"San Francisco"` → `city: "San Francisco"` |
| `primaryLocationCountry` | `country` | `term` | `"USA"` → `country: "USA"` |
| `primaryLocationLat/Long` | `latitude`, `longitude` | `geo_distance` | Distance-based filtering |
| `resumeSkills` + `onetSkills` | `description`, `benefits` | `bool.should` (multi-match) | `["Swift", "iOS"]` → search in description |
| `salaryMin` | `salary.min_value` | `range` (gte) | `50000` → `salary.min_value >= 50000` |
| `salaryMax` | `salary.max_value` | `range` (lte) | `150000` → `salary.max_value <= 150000` |
| `remotePreference` | `accepts_remote` | `term` or skip | `"remote"` → `accepts_remote: true` |
| Job type (from V7) | `employment_type` | `term` | `"full_time"` → `employment_type: "Full-time"` |

---

## Part 2: Elasticsearch DSL Query Building

### Basic Query Structure

```json
{
  "query": {
    "bool": {
      "must": [
        { /* required filters */ }
      ],
      "should": [
        { /* optional filters (OR logic) */ }
      ],
      "filter": [
        { /* exact matches */ }
      ]
    }
  },
  "from": 0,
  "size": 50,
  "sort": [
    { "date_posted": "desc" }
  ]
}
```

### Example 1: Basic Job Search (Title + Location)

**User Profile**:
```swift
desiredRoles = ["Software Engineer", "iOS Developer"]
primaryLocationCity = "San Francisco"
primaryLocationCountry = "USA"
```

**Elasticsearch DSL Query**:
```json
{
  "query": {
    "bool": {
      "must": [
        {
          "multi_match": {
            "query": "Software Engineer iOS Developer",
            "fields": ["title^3", "description"],
            "type": "best_fields",
            "operator": "or"
          }
        }
      ],
      "filter": [
        { "term": { "city": "San Francisco" } },
        { "term": { "country": "USA" } }
      ]
    }
  },
  "from": 0,
  "size": 50
}
```

### Example 2: Advanced Search (Skills + Salary + Remote)

**User Profile**:
```swift
desiredRoles = ["Software Engineer"]
primaryLocationCity = "San Francisco"
resumeSkills = ["Swift", "SwiftUI", "iOS"]
onetSkills = ["Mobile Development", "API Integration"]
salaryMin = 120000
salaryMax = 180000
remotePreference = "remote"
```

**Elasticsearch DSL Query**:
```json
{
  "query": {
    "bool": {
      "must": [
        {
          "multi_match": {
            "query": "Software Engineer",
            "fields": ["title^3", "description"],
            "type": "best_fields"
          }
        },
        {
          "term": { "accepts_remote": true }
        }
      ],
      "should": [
        {
          "terms": {
            "description": ["Swift", "SwiftUI", "iOS", "Mobile Development", "API Integration"],
            "boost": 2.0
          }
        }
      ],
      "filter": [
        { "term": { "city": "San Francisco" } },
        {
          "nested": {
            "path": "salary",
            "query": {
              "bool": {
                "must": [
                  { "range": { "salary.min_value": { "gte": 120000 } } },
                  { "range": { "salary.max_value": { "lte": 180000 } } }
                ]
              }
            }
          }
        }
      ]
    }
  },
  "from": 0,
  "size": 50,
  "sort": [
    { "date_posted": "desc" },
    { "_score": "desc" }
  ]
}
```

### Example 3: Geo-Distance Search

**User Profile**:
```swift
primaryLocationCity = "San Francisco"
primaryLocationLatitude = 37.7749
primaryLocationLongitude = -122.4194
```

**Elasticsearch DSL Query**:
```json
{
  "query": {
    "bool": {
      "must": [
        {
          "multi_match": {
            "query": "Software Engineer",
            "fields": ["title"]
          }
        }
      ],
      "filter": [
        {
          "geo_distance": {
            "distance": "50mi",
            "location": {
              "lat": 37.7749,
              "lon": -122.4194
            }
          }
        }
      ]
    }
  }
}
```

---

## Part 3: Production-Ready Implementation

### CoreSignalAPIClient Template

**Location**: `V7Services/Sources/V7Services/CompanyAPIs/CoreSignalAPIClient.swift`

```swift
// CoreSignalAPIClient.swift - CoreSignal Jobs API integration
// Production-ready integration following V8 JobSourceProtocol

import Foundation
import V7Core
import V7Thompson
import V7JobParsing

// MARK: - CoreSignal API Client

actor CoreSignalAPIClient: JobSourceProtocol {

    // MARK: - JobSourceProtocol Requirements

    let sourceIdentifier = "coresignal"

    var rateLimitStatus: RateLimitStatus {
        get async {
            if let extendedStatus = await rateLimitManager.getStatus(for: sourceIdentifier) {
                return extendedStatus.baseStatus
            }
            return RateLimitStatus(remaining: 0, limit: 18, resetsAt: Date().addingTimeInterval(3600))
        }
    }

    // MARK: - Internal Properties

    private var _apiCredentials: APICredential?
    private let rateLimitManager = RateLimitManager.shared
    private let circuitBreaker: CircuitBreaker

    // MARK: - Configuration

    private let session: URLSession
    private let decoder: JSONDecoder
    private let baseURL = "https://api.coresignal.com"

    // API credentials (loaded from environment)
    private var apiKey: String?

    // MARK: - Job Parsing Integration

    private let jobParser: JobSkillsExtractor?

    // MARK: - Initialization

    init() {
        // Configure URLSession for API calls
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = ProductionConfiguration.networkTimeout
        config.requestCachePolicy = .reloadIgnoringCacheData
        self.session = URLSession(configuration: config)

        // Configure JSON decoder
        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        // Initialize circuit breaker
        self.circuitBreaker = CircuitBreaker(
            identifier: sourceIdentifier,
            failureThreshold: 3,
            timeout: 60.0
        )

        // Initialize job parser
        if #available(iOS 18.0, macOS 14.0, *) {
            self.jobParser = JobSkillsExtractor()
        } else {
            self.jobParser = nil
        }

        // Register with rate limit manager
        Task {
            await rateLimitManager.registerSource(
                sourceId: sourceIdentifier,
                requestsPerMinute: 1080, // 18 req/sec × 60 sec = 1080 req/min
                burstCapacity: 20
            )

            await self.loadAPICredentials()
        }
    }

    // MARK: - Credential Management

    private func loadAPICredentials() async {
        if let envApiKey = ProcessInfo.processInfo.environment["CORESIGNAL_API_KEY"] {
            self.apiKey = envApiKey
            if ProductionConfiguration.debugJobSources {
                print("✅ CoreSignal: Loaded API key from environment")
            }
        } else {
            if ProductionConfiguration.debugJobSources {
                print("⚠️ CoreSignal: No API key found (set CORESIGNAL_API_KEY)")
            }
        }
    }

    // MARK: - JobSourceProtocol Implementation

    func fetchJobs(query: JobSearchQuery, limit: Int) async throws -> [RawJobData] {
        guard let apiKey = apiKey else {
            throw JobSourceError.authenticationFailed("CoreSignal API key not configured")
        }

        // Check rate limit
        guard await rateLimitManager.acquireToken(for: sourceIdentifier) else {
            throw JobSourceError.rateLimitExceeded(resetsAt: Date().addingTimeInterval(60))
        }

        // Check circuit breaker
        guard await circuitBreaker.canAttempt() else {
            throw JobSourceError.circuitBreakerOpen("Circuit breaker open for \(sourceIdentifier)")
        }

        let startTime = CFAbsoluteTimeGetCurrent()

        do {
            let jobs = try await fetchJobsInternal(
                query: query,
                limit: limit,
                apiKey: apiKey,
                startTime: startTime
            )

            await circuitBreaker.recordSuccess()

            let fetchTime = (CFAbsoluteTimeGetCurrent() - startTime) * 1000

            if ProductionConfiguration.debugJobSources {
                print("✅ CoreSignal: \(jobs.count) jobs in \(String(format: "%.2f", fetchTime))ms")
            }

            return jobs

        } catch {
            await circuitBreaker.recordFailure()
            throw error
        }
    }

    // MARK: - Private Methods

    private func fetchJobsInternal(
        query: JobSearchQuery,
        limit: Int,
        apiKey: String,
        startTime: CFAbsoluteTime
    ) async throws -> [RawJobData] {

        // Build Elasticsearch DSL query from JobSearchQuery
        let elasticsearchQuery = buildElasticsearchQuery(from: query, limit: limit)

        // Create request
        let url = URL(string: "\(baseURL)/v2/job_multi_source/search/es_dsl")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("V7JobDiscovery/1.0", forHTTPHeaderField: "User-Agent")

        // Encode query body
        let jsonData = try JSONSerialization.data(withJSONObject: elasticsearchQuery)
        request.httpBody = jsonData

        // Execute request
        let (data, response) = try await session.data(for: request)

        // Check response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw JobSourceError.invalidResponse("No HTTP response")
        }

        guard httpResponse.statusCode == 200 else {
            throw JobSourceError.apiError("HTTP \(httpResponse.statusCode)")
        }

        // Parse response
        let coreSignalResponse = try decoder.decode(CoreSignalResponse.self, from: data)

        // Convert to RawJobData
        return coreSignalResponse.hits.hits.map { hit in
            normalizeJob(hit._source)
        }.compactMap { $0 }
    }

    private func buildElasticsearchQuery(from query: JobSearchQuery, limit: Int) -> [String: Any] {
        var mustClauses: [[String: Any]] = []
        var shouldClauses: [[String: Any]] = []
        var filterClauses: [[String: Any]] = []

        // 1. Title search (from keywords)
        if !query.keywords.isEmpty {
            mustClauses.append([
                "multi_match": [
                    "query": query.keywords,
                    "fields": ["title^3", "description"],
                    "type": "best_fields",
                    "operator": "or"
                ]
            ])
        }

        // 2. Location filters
        if let location = query.location {
            filterClauses.append([
                "bool": [
                    "should": [
                        ["term": ["city": location]],
                        ["term": ["country": location]]
                    ]
                ]
            ])
        }

        // 3. Remote preference
        if let remote = query.remote, remote {
            mustClauses.append([
                "term": ["accepts_remote": true]
            ])
        }

        // 4. Salary range
        if query.minSalary != nil || query.maxSalary != nil {
            var salaryQuery: [String: Any] = [:]

            if let min = query.minSalary {
                salaryQuery["gte"] = min
            }
            if let max = query.maxSalary {
                salaryQuery["lte"] = max
            }

            filterClauses.append([
                "nested": [
                    "path": "salary",
                    "query": [
                        "range": ["salary.min_value": salaryQuery]
                    ]
                ]
            ])
        }

        // 5. Experience level (map V7's ExperienceLevel to CoreSignal's seniority)
        if let experienceLevel = query.experienceLevel {
            let coreSignalSeniority = mapExperienceLevel(experienceLevel)
            filterClauses.append([
                "term": ["seniority": coreSignalSeniority]
            ])
        }

        // 6. Job type
        if let jobType = query.jobType {
            let coreSignalEmploymentType = mapJobType(jobType)
            filterClauses.append([
                "term": ["employment_type": coreSignalEmploymentType]
            ])
        }

        // Build final query
        var boolQuery: [String: Any] = [:]
        if !mustClauses.isEmpty { boolQuery["must"] = mustClauses }
        if !shouldClauses.isEmpty { boolQuery["should"] = shouldClauses }
        if !filterClauses.isEmpty { boolQuery["filter"] = filterClauses }

        return [
            "query": ["bool": boolQuery],
            "from": 0,
            "size": limit,
            "sort": [
                ["date_posted": "desc"],
                ["_score": "desc"]
            ]
        ]
    }

    private func mapExperienceLevel(_ level: ExperienceLevel) -> String {
        switch level {
        case .entryLevel: return "Entry level"
        case .midLevel: return "Mid-Senior level"
        case .seniorLevel: return "Mid-Senior level"
        case .executive: return "Executive"
        case .internship: return "Internship"
        }
    }

    private func mapJobType(_ type: JobType) -> String {
        switch type {
        case .fullTime: return "Full-time"
        case .partTime: return "Part-time"
        case .contract: return "Contract"
        case .temporary: return "Temporary"
        case .internship: return "Internship"
        }
    }

    func normalizeJob(_ source: CoreSignalJob) -> RawJobData? {
        guard let url = URL(string: source.external_url ?? "") else {
            return nil
        }

        return RawJobData(
            sourceId: sourceIdentifier,
            externalId: "coresignal-\(source.job_id)",
            title: source.title,
            company: source.company_name,
            location: source.location ?? "\(source.city ?? ""), \(source.country ?? "")",
            description: source.description,
            url: url,
            postedDate: source.date_posted,
            salary: source.salary?.first.flatMap { sal in
                if let min = sal.min_value, let max = sal.max_value {
                    return "\(sal.currency ?? "USD") \(Int(min))-\(Int(max))"
                }
                return nil
            },
            requirements: source.benefits ?? [],
            benefits: source.benefits ?? [],
            jobType: source.employment_type,
            experienceLevel: source.seniority,
            sector: nil, // Will be classified by SectorValidator
            matchScore: 0.0, // Will be calculated by Thompson engine
            metadata: [
                "coresignal_id": source.job_id,
                "company_domain": source.company_domain ?? "",
                "company_size": source.company_size_range ?? "",
                "company_industry": source.company_industry ?? "",
                "accepts_remote": source.accepts_remote ? "true" : "false"
            ]
        )
    }

    func healthCheck() async -> SourceHealth {
        guard let apiKey = apiKey else {
            return SourceHealth(
                isHealthy: false,
                latency: 0.0,
                errorRate: 1.0,
                lastSuccessfulFetch: nil,
                message: "API key not configured"
            )
        }

        // Test with minimal query
        let testQuery: [String: Any] = [
            "query": ["match_all": [:]],
            "size": 1
        ]

        do {
            let url = URL(string: "\(baseURL)/v2/job_multi_source/search/es_dsl")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue(apiKey, forHTTPHeaderField: "apikey")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let jsonData = try JSONSerialization.data(withJSONObject: testQuery)
            request.httpBody = jsonData

            let startTime = CFAbsoluteTimeGetCurrent()
            let (_, response) = try await session.data(for: request)
            let latency = CFAbsoluteTimeGetCurrent() - startTime

            if let httpResponse = response as? HTTPURLResponse {
                let isHealthy = httpResponse.statusCode == 200

                return SourceHealth(
                    isHealthy: isHealthy,
                    latency: latency,
                    errorRate: isHealthy ? 0.05 : 1.0,
                    lastSuccessfulFetch: isHealthy ? Date() : nil,
                    message: isHealthy ? "API accessible" : "HTTP \(httpResponse.statusCode)"
                )
            }

            return SourceHealth(
                isHealthy: false,
                latency: latency,
                errorRate: 1.0,
                lastSuccessfulFetch: nil,
                message: "Invalid response"
            )

        } catch {
            return SourceHealth(
                isHealthy: false,
                latency: 5.0,
                errorRate: 1.0,
                lastSuccessfulFetch: nil,
                message: "Health check failed: \(error.localizedDescription)"
            )
        }
    }
}

// MARK: - Response Models

struct CoreSignalResponse: Codable {
    let hits: CoreSignalHits
}

struct CoreSignalHits: Codable {
    let hits: [CoreSignalHit]
}

struct CoreSignalHit: Codable {
    let _source: CoreSignalJob
}

struct CoreSignalJob: Codable {
    let job_id: String
    let title: String
    let description: String
    let seniority: String?
    let employment_type: String?
    let accepts_remote: Bool
    let location: String?
    let city: String?
    let country: String?
    let latitude: Double?
    let longitude: Double?
    let company_name: String
    let company_domain: String?
    let company_size_range: String?
    let company_industry: String?
    let salary: [CoreSignalSalary]?
    let benefits: [String]?
    let external_url: String?
    let date_posted: Date?
    let valid_through: Date?
}

struct CoreSignalSalary: Codable {
    let min_value: Double?
    let max_value: Double?
    let currency: String?
    let type: String?
}
```

---

## Part 4: Integration Checklist

### Step 1: Add CoreSignal Client to V8
- [ ] Create `CoreSignalAPIClient.swift` in `V7Services/Sources/V7Services/CompanyAPIs/`
- [ ] Add API key environment variable: `CORESIGNAL_API_KEY`
- [ ] Register in `JobDiscoveryCoordinator`

### Step 2: Environment Setup
```bash
# Add to your environment
export CORESIGNAL_API_KEY="your_api_key_here"
```

### Step 3: Test Integration
```swift
// Test query
let client = CoreSignalAPIClient()
let query = JobSearchQuery(
    keywords: "Software Engineer",
    location: "San Francisco",
    minSalary: 100000,
    remote: true
)
let jobs = try await client.fetchJobs(query: query, limit: 20)
print("✅ Found \(jobs.count) jobs from CoreSignal")
```

### Step 4: Verify Rate Limiting
- 18 requests/second (1080/minute)
- Circuit breaker after 3 failures
- Exponential backoff

---

## Part 5: Common Patterns & Best Practices

### Pattern 1: Building Query from UserProfile

```swift
func buildQueryFromUserProfile(_ profile: UserProfile) -> JobSearchQuery {
    // Combine desiredRoles into keywords
    let keywords = profile.desiredRoles?.joined(separator: " ") ?? profile.currentDomain

    // Location from geocoded coordinates
    let location = profile.primaryLocationCity

    // Salary range
    let minSalary = profile.salaryMin?.intValue
    let maxSalary = profile.salaryMax?.intValue

    // Remote preference
    let remote: Bool? = {
        switch profile.remotePreference {
        case "remote": return true
        case "onsite": return false
        default: return nil
        }
    }()

    return JobSearchQuery(
        keywords: keywords,
        location: location,
        minSalary: minSalary,
        maxSalary: maxSalary,
        remote: remote
    )
}
```

### Pattern 2: Skills-Based Boosting

```swift
// Add user skills to query for better matching
let userSkills = (profile.resumeSkills ?? []) + (profile.onetSkills ?? [])

shouldClauses.append([
    "terms": [
        "description": userSkills,
        "boost": 2.0
    ]
])
```

### Pattern 3: Distance-Based Filtering

```swift
if profile.hasGeocodedLocation {
    filterClauses.append([
        "geo_distance": [
            "distance": "50mi",
            "location": [
                "lat": profile.primaryLocationLatitude,
                "lon": profile.primaryLocationLongitude
            ]
        ]
    ])
}
```

---

## Part 6: Troubleshooting

### Authentication Errors
**Problem**: `401 Unauthorized`
**Solution**: Check `CORESIGNAL_API_KEY` environment variable

### Rate Limit Exceeded
**Problem**: `429 Too Many Requests`
**Solution**: Wait for rate limit reset, check RateLimitManager status

### Empty Results
**Problem**: Query returns 0 jobs
**Solution**:
1. Simplify query (remove optional filters)
2. Check Elasticsearch syntax
3. Verify location/salary ranges are reasonable

### Slow Queries
**Problem**: Queries taking >2s
**Solution**:
1. Reduce `size` parameter
2. Remove complex nested queries
3. Use simpler filters

---

## Success Metrics

v8-coresignal-integration-expert is successful when:

✅ Can build complete Elasticsearch DSL queries from UserProfile
✅ Knows all CoreSignal API fields and how they map to V8 data
✅ Follows V8's JobSourceProtocol pattern exactly
✅ Handles authentication, rate limits, circuit breakers correctly
✅ Provides production-ready implementation code
✅ Can troubleshoot common API integration issues

---

**Last Updated**: 2025-11-10
**Version**: 1.0.0
**Status**: Production-ready for V8 integration
