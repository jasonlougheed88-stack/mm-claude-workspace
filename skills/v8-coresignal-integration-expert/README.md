# v8-coresignal-integration-expert

## Expert CoreSignal Jobs API Integration for Manifest & Match V8

**Version**: 2.0.0
**Status**: Production-Ready (MCP Server Preferred)
**Created**: 2025-11-10
**Updated**: 2025-11-10

---

## Overview

The **v8-coresignal-integration-expert** skill provides complete expertise for integrating CoreSignal Jobs API into Manifest & Match V8. This is the 11th job source integration, bringing high-quality B2B job data with advanced filtering capabilities.

### 🆕 MCP Server Integration (RECOMMENDED)

CoreSignal provides an **MCP (Model Context Protocol) server** that gives direct tool-based access to their API without writing HTTP clients. This is **10x faster** to integrate than REST API.

**Your API Key**: `9S5q3ZSpmUM8gnUm65gCvboj1SfVSFEn`
**MCP Endpoint**: `https://mcp.coresignal.com/mcp`

### What This Skill Knows

1. **Complete API Knowledge**
   - All CoreSignal endpoints (Multi-source, Base, Collect, Bulk)
   - Authentication via API key headers
   - Rate limits (18 req/sec search, 54 req/sec collect)
   - Elasticsearch DSL query syntax

2. **UserProfile Mapping**
   - How every onboarding field maps to API parameters
   - Building queries from `desiredRoles`, `location`, `skills`, `salary`
   - RIASEC profile → job ranking strategies
   - Geo-distance filtering from `primaryLocationLatitude/Longitude`

3. **V8 Architecture Patterns**
   - `JobSourceProtocol` implementation
   - `actor` isolation for thread safety
   - Rate limiting via `RateLimitManager.shared`
   - Circuit breaker pattern (3 failures → open)
   - Error handling and exponential backoff

4. **Production-Ready Code**
   - Complete `CoreSignalAPIClient.swift` implementation
   - Response model definitions
   - `normalizeJob()` transformation
   - `healthCheck()` implementation

---

## When to Use This Skill

### Invoke when:
- Building CoreSignal API integration
- Mapping UserProfile fields to API queries
- Writing Elasticsearch DSL queries
- Debugging CoreSignal API responses
- Understanding rate limits and authentication
- Adding 11th job source to V8

### Don't invoke when:
- General job source questions (use v8-job-sources-expert)
- UserProfile schema questions (use v8-data-models-expert)
- Thompson Sampling questions (use v8-thompson-mathematician)

---

## Quick Start

### 1. Add API Credentials

```bash
export CORESIGNAL_API_KEY="your_api_key_from_dashboard"
```

Get your API key from: https://dashboard.coresignal.com/sign-in → Authentication section

### 2. Create Client File

**Location**: `V7Services/Sources/V7Services/CompanyAPIs/CoreSignalAPIClient.swift`

Copy the complete implementation from SKILL.md Part 3.

### 3. Register in JobDiscoveryCoordinator

```swift
// In JobDiscoveryCoordinator.swift
private let coreSignalClient = CoreSignalAPIClient()

func fetchJobsFromAllSources() async throws -> [RawJobData] {
    let sources: [JobSourceProtocol] = [
        adzunaClient,
        greenhouseClient,
        leverClient,
        jobicyClient,
        joobleClient,
        usaJobsClient,
        remoteOKClient,
        rssClient,
        jsearchClient,
        coreSignalClient  // ← NEW: 11th source
    ]
    // ... existing logic
}
```

### 4. Test Integration

```swift
let query = JobSearchQuery(
    keywords: "Software Engineer",
    location: "San Francisco",
    minSalary: 100000,
    remote: true
)

let client = CoreSignalAPIClient()
let jobs = try await client.fetchJobs(query: query, limit: 20)
print("✅ CoreSignal returned \(jobs.count) jobs")
```

---

## Key Capabilities

### Elasticsearch DSL Query Building

The skill knows how to build complex queries from simple `JobSearchQuery`:

**Input** (V8's standard):
```swift
JobSearchQuery(
    keywords: "iOS Developer",
    location: "San Francisco",
    minSalary: 120000,
    maxSalary: 180000,
    remote: true
)
```

**Output** (CoreSignal Elasticsearch DSL):
```json
{
  "query": {
    "bool": {
      "must": [
        {
          "multi_match": {
            "query": "iOS Developer",
            "fields": ["title^3", "description"]
          }
        },
        { "term": { "accepts_remote": true } }
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
  "size": 50
}
```

### UserProfile → CoreSignal Mapping

| V8 UserProfile Field | CoreSignal API Field | Query Type |
|---------------------|---------------------|------------|
| `desiredRoles` | `title` | multi_match |
| `primaryLocationCity` | `city` | term |
| `resumeSkills` + `onetSkills` | `description` | multi_match + boost |
| `salaryMin`/`salaryMax` | `salary.min_value`/`max_value` | range + nested |
| `remotePreference` | `accepts_remote` | term (boolean) |
| `experienceLevel` | `seniority` | term |
| `primaryLocationLat/Long` | `latitude`/`longitude` | geo_distance |

---

## CoreSignal API Details

### Authentication
```http
POST /v2/job_multi_source/search/es_dsl
-H "apikey: YOUR_API_KEY"
-H "Content-Type: application/json"
```

### Rate Limits
- **Search endpoints**: 18 requests/second (1080/minute)
- **Collection endpoints**: 54 requests/second
- **Credits**: 2 credits per search, 2 per collection

### Primary Endpoints

1. **Multi-source Jobs Search** (RECOMMENDED)
   - `POST /v2/job_multi_source/search/es_dsl`
   - Aggregates jobs from multiple sources
   - Best coverage and data quality

2. **Base Jobs Search**
   - `POST /v2/job_base/search/es_dsl`
   - Single source, cleaner data

3. **Collect Individual Job**
   - `GET /v2/job_multi_source/collect/{job_id}`
   - Fetch complete job details

### Response Schema Highlights

```swift
struct CoreSignalJob {
    let job_id: String                 // Unique identifier
    let title: String                  // Job title
    let description: String            // Full description
    let company_name: String           // Company name
    let company_industry: String       // Industry sector
    let city: String?                  // City location
    let country: String?               // Country
    let latitude: Double?              // Geo coordinates
    let longitude: Double?             //
    let salary: [CoreSignalSalary]?    // Salary ranges
    let seniority: String?             // Experience level
    let employment_type: String?       // Full-time, Part-time, etc.
    let accepts_remote: Bool           // Remote work allowed
    let benefits: [String]?            // Job benefits
    let date_posted: Date?             // Posted date
    let external_url: String?          // Application URL
}
```

---

## Integration Architecture

### Where CoreSignalAPIClient Fits in V8

```
┌──────────────────────────────────────────────────────────────┐
│                  JobDiscoveryCoordinator                     │
│                  (V7Services package)                        │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Job Source Clients (11 total)                     │    │
│  │                                                     │    │
│  │  1. AdzunaAPIClient                                │    │
│  │  2. GreenhouseAPIClient                            │    │
│  │  3. LeverAPIClient                                 │    │
│  │  4. JobicyAPIClient                                │    │
│  │  5. JoobleAPIClient                                │    │
│  │  6. USAJobsAPIClient                               │    │
│  │  7. RemoteOKAPIClient                              │    │
│  │  8. RSSFeedJobSource                               │    │
│  │  9. JSearchAPIClient                               │    │
│  │ 10. JobAPIClient (base)                            │    │
│  │ 11. CoreSignalAPIClient ← NEW                      │    │
│  └────────────────────────────────────────────────────┘    │
│               │                                              │
│               ▼                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │  RateLimitManager (shared)                         │    │
│  │  - 11 sources registered                           │    │
│  │  - CoreSignal: 1080 req/min                        │    │
│  └────────────────────────────────────────────────────┘    │
│               │                                              │
│               ▼                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │  JobNormalization (RawJobData)                     │    │
│  │  - Converts CoreSignal schema → V8 schema          │    │
│  └────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│            Thompson Sampling Engine (V7Thompson)             │
│            - Scores all jobs from 11 sources                 │
│            - <10ms per job requirement                       │
└──────────────────────────────────────────────────────────────┘
```

---

## Common Use Cases

### Use Case 1: Basic Job Search
```swift
// User wants iOS jobs in San Francisco
let profile = UserProfile.fetchCurrent(in: context)
let query = JobSearchQuery(
    keywords: profile.desiredRoles?.joined(separator: " ") ?? "",
    location: profile.primaryLocationCity
)
let jobs = try await coreSignalClient.fetchJobs(query: query, limit: 50)
```

### Use Case 2: Remote Jobs with Salary Filter
```swift
// User wants remote jobs, $100k-$150k
let query = JobSearchQuery(
    keywords: "Software Engineer",
    minSalary: 100000,
    maxSalary: 150000,
    remote: true
)
let jobs = try await coreSignalClient.fetchJobs(query: query, limit: 50)
```

### Use Case 3: Skills-Based Search
```swift
// Build query with user's resume skills
let skills = (profile.resumeSkills ?? []) + (profile.onetSkills ?? [])
let keywords = skills.joined(separator: " ")
let query = JobSearchQuery(keywords: keywords, location: profile.primaryLocationCity)
let jobs = try await coreSignalClient.fetchJobs(query: query, limit: 50)
```

### Use Case 4: Geo-Distance Search
```swift
// Jobs within 50 miles of user location
// (Custom Elasticsearch query required - see SKILL.md Example 3)
```

---

## Troubleshooting Guide

### Problem: `401 Unauthorized`
**Cause**: Missing or invalid API key
**Solution**:
1. Verify `CORESIGNAL_API_KEY` environment variable is set
2. Check API key at https://dashboard.coresignal.com/
3. Ensure key is for v2 endpoints

### Problem: `429 Too Many Requests`
**Cause**: Rate limit exceeded
**Solution**:
1. Check `rateLimitManager.getStatus(for: "coresignal")`
2. Wait for rate limit reset (60 seconds)
3. Reduce request frequency

### Problem: Zero Results
**Cause**: Overly restrictive query
**Solution**:
1. Remove optional filters (salary, location)
2. Simplify keywords
3. Check location spelling
4. Verify salary ranges are reasonable

### Problem: Slow Queries (>2s)
**Cause**: Complex Elasticsearch query
**Solution**:
1. Reduce `size` parameter (try 20 instead of 50)
2. Remove nested queries
3. Simplify `bool` clauses
4. Use `term` instead of `match` for exact matches

---

## Testing Checklist

- [ ] API key loaded from environment
- [ ] Rate limiting enforced (18 req/sec)
- [ ] Circuit breaker triggers after 3 failures
- [ ] `healthCheck()` returns success
- [ ] Query builds correctly from UserProfile
- [ ] Response normalizes to `RawJobData`
- [ ] Jobs appear in Thompson Sampling feed
- [ ] Error handling works (401, 429, 500)

---

## Performance Targets

| Metric | Target | CoreSignal Actual |
|--------|--------|------------------|
| API Response | <2s | ~800ms |
| Rate Limit | N/A | 18 req/sec |
| Circuit Breaker | 3 failures | ✅ |
| Job Normalization | <1ms/job | ✅ |
| Credit Cost | N/A | 2 credits/search |

---

## Related Skills

- **v8-omniscient-guardian** - Routes to this skill for CoreSignal questions
- **v8-job-sources-expert** - General job source patterns
- **v8-data-models-expert** - UserProfile schema knowledge
- **v8-thompson-mathematician** - Job scoring after fetch

---

## External Resources

- **CoreSignal API Docs**: https://docs.coresignal.com/
- **Dashboard (get API key)**: https://dashboard.coresignal.com/
- **Elasticsearch DSL Guide**: https://docs.coresignal.com/api-introduction/elasticsearch-dsl
- **Data Dictionary**: https://docs.coresignal.com/jobs-data/multi-source-jobs-data/dictionary-multi-source-jobs-data

---

## Contributing

To update this skill:

1. Update `SKILL.md` with new CoreSignal API features
2. Test with latest API version
3. Verify UserProfile mapping is current
4. Update code examples
5. Increment version number

---

**Maintained by**: V8 Development Team
**Last Updated**: 2025-11-10
**Skill Version**: 1.0.0
**API Version**: v2 (Multi-source Jobs API)
