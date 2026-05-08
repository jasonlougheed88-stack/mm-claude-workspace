## Common Job Board APIs Reference

Quick reference for integrating popular job boards with ManifestAndMatchV7.

## Remotive

**Base URL:** `https://remotive.com/api/remote-jobs`
**Authentication:** None required
**Rate Limit:** ~100 requests/hour (undocumented)
**Documentation:** https://remotive.com/api-docs

**Endpoints:**
```
GET /remote-jobs                    # List all jobs
GET /remote-jobs?limit=50           # With pagination
GET /remote-jobs?category=software  # Filter by category
```

**Response Format:**
```json
{
  "job-count": 500,
  "jobs": [
    {
      "id": 123456,
      "title": "Senior iOS Engineer",
      "company_name": "Tech Corp",
      "candidate_required_location": "Worldwide",
      "description": "...",
      "salary": "$120k - $180k",
      "url": "https://...",
      "publication_date": "2025-10-20T10:00:00",
      "tags": ["ios", "swift", "mobile"]
    }
  ]
}
```

**Rate Limiting Strategy:** Conservative (100/hour)
**Recommended Cache TTL:** 5 minutes

---

## AngelList (Wellfound)

**Base URL:** `https://api.angel.co/1`
**Authentication:** OAuth 2.0 or API Key
**Rate Limit:** 1000 requests/hour (authenticated)
**Documentation:** https://angel.co/api

**Endpoints:**
```
GET /jobs                          # List jobs
GET /jobs/:id                      # Single job
GET /startups/:id/jobs             # Jobs by company
```

**Authentication:**
```
Authorization: Bearer YOUR_ACCESS_TOKEN
```

**Response Format:**
```json
{
  "total": 1000,
  "page": 1,
  "per_page": 50,
  "jobs": [
    {
      "id": "abc123",
      "title": "iOS Developer",
      "startup": {
        "name": "Startup Inc",
        "logo_url": "https://..."
      },
      "location": "San Francisco",
      "salary_min": 120000,
      "salary_max": 180000,
      "tags": ["iOS", "Swift", "Mobile"],
      "apply_url": "https://..."
    }
  ]
}
```

**Rate Limiting Strategy:** Aggressive (1000/hour with backoff)
**Recommended Cache TTL:** 10 minutes

---

## LinkedIn Job Search API

**Base URL:** `https://api.linkedin.com/v2`
**Authentication:** OAuth 2.0
**Rate Limit:** Application-dependent (typically 500/day)
**Documentation:** https://docs.microsoft.com/linkedin/

**Endpoints:**
```
GET /jobSearch                     # Search jobs
GET /jobs/:id                      # Job details
```

**Authentication:**
```
Authorization: Bearer YOUR_ACCESS_TOKEN
X-RestLi-Protocol-Version: 2.0.0
```

**Response Format:**
```json
{
  "elements": [
    {
      "id": "123456789",
      "title": "Senior iOS Engineer",
      "companyDetails": {
        "company": "urn:li:organization:1234",
        "companyName": "LinkedIn"
      },
      "location": "Sunnyvale, CA",
      "description": {
        "text": "..."
      },
      "listedAt": 1698048000000,
      "applyUrl": "https://..."
    }
  ]
}
```

**Rate Limiting Strategy:** Very conservative (daily limit)
**Recommended Cache TTL:** 30 minutes
**Note:** Requires LinkedIn partnership/application approval

---

## Greenhouse ATS

**Base URL:** `https://boards-api.greenhouse.io/v1/boards/{board_token}`
**Authentication:** Public boards (no auth), or API key
**Rate Limit:** 10 requests/second per IP
**Documentation:** https://developers.greenhouse.io/

**Endpoints:**
```
GET /boards/{board_token}/jobs              # List jobs
GET /boards/{board_token}/jobs/{job_id}     # Job details
GET /boards/{board_token}/departments       # List departments
```

**Response Format:**
```json
{
  "jobs": [
    {
      "id": 123456,
      "title": "iOS Engineer",
      "location": {
        "name": "San Francisco"
      },
      "departments": [
        {"name": "Engineering"}
      ],
      "content": "Full job description...",
      "metadata": [
        {"name": "Salary", "value": "$150k-$200k"}
      ],
      "absolute_url": "https://..."
    }
  ]
}
```

**Rate Limiting Strategy:** Moderate (600/minute)
**Recommended Cache TTL:** 15 minutes
**Note:** Each company has unique board_token

---

## Lever ATS

**Base URL:** `https://api.lever.co/v0/postings/{company}`
**Authentication:** None for public postings
**Rate Limit:** 100 requests/minute
**Documentation:** https://lever.readme.io/

**Endpoints:**
```
GET /postings/{company}               # List jobs for company
GET /postings/{company}/{posting_id}  # Job details
```

**Response Format:**
```json
[
  {
    "id": "abc123-def456",
    "text": "iOS Engineer",
    "categories": {
      "department": "Engineering",
      "location": "San Francisco",
      "team": "Mobile"
    },
    "description": "...",
    "descriptionPlain": "...",
    "lists": [
      {"text": "Swift", "content": "5+ years"}
    ],
    "hostedUrl": "https://...",
    "applyUrl": "https://..."
  }
]
```

**Rate Limiting Strategy:** Moderate (100/minute)
**Recommended Cache TTL:** 10 minutes
**Note:** Company name in URL (e.g., "stripe", "figma")

---

## Indeed Job Search API

**Base URL:** `https://api.indeed.com/ads/apisearch`
**Authentication:** Publisher ID (free registration)
**Rate Limit:** Varies by plan (free: limited)
**Documentation:** https://opensource.indeedeng.io/api-documentation/

**Query Parameters:**
```
?publisher={YOUR_ID}
&q=iOS+Engineer
&l=San+Francisco,+CA
&format=json
&v=2
```

**Response Format:**
```json
{
  "results": [
    {
      "jobtitle": "Senior iOS Engineer",
      "company": "Tech Company",
      "city": "San Francisco",
      "state": "CA",
      "snippet": "We are seeking...",
      "date": "Mon, 20 Oct 2025",
      "url": "https://www.indeed.com/viewjob?jk=abc123",
      "formattedLocation": "San Francisco, CA"
    }
  ],
  "totalResults": 1500
}
```

**Rate Limiting Strategy:** Conservative (depends on plan)
**Recommended Cache TTL:** 30 minutes
**Note:** Requires publisher account, usage tracked

---

## RSS Feeds (Various Boards)

Many job boards offer RSS feeds as a simple integration option.

**Common RSS Sources:**
- Stack Overflow Jobs: `https://stackoverflow.com/jobs/feed`
- RemoteOK: `https://remoteok.com/remote-jobs.rss`
- We Work Remotely: `https://weworkremotely.com/remote-jobs.rss`

**Parsing Strategy:**
```swift
import Foundation

actor RSSJobSource {
    func fetchJobs(from rssURL: URL) async throws -> [Job] {
        let (data, _) = try await URLSession.shared.data(from: rssURL)

        let parser = XMLParser(data: data)
        let delegate = RSSParserDelegate()
        parser.delegate = delegate

        guard parser.parse() else {
            throw RSSError.parseFailed
        }

        return delegate.jobs
    }
}

class RSSParserDelegate: NSObject, XMLParserDelegate {
    var jobs: [Job] = []
    // Implement XML parsing...
}
```

**Rate Limiting Strategy:** Very conservative (1-2 requests/hour)
**Recommended Cache TTL:** 30-60 minutes

---

## GraphQL APIs (Apollo, etc.)

Some modern job boards use GraphQL.

**Example: Hypothetical GraphQL Endpoint**

**Base URL:** `https://api.example.com/graphql`
**Authentication:** Bearer token

**Query:**
```graphql
query GetJobs($limit: Int!) {
  jobs(limit: $limit) {
    id
    title
    company {
      name
      logo
    }
    location
    description
    salary {
      min
      max
      currency
    }
    skills
    postedAt
    applyUrl
  }
}
```

**Swift Client:**
```swift
struct GraphQLRequest: Codable {
    let query: String
    let variables: [String: Any]
}

actor GraphQLJobClient {
    func fetchJobs() async throws -> [Job] {
        let query = """
        query GetJobs($limit: Int!) {
            jobs(limit: $limit) { ... }
        }
        """

        let request = GraphQLRequest(
            query: query,
            variables: ["limit": 50]
        )

        // Send POST request with JSON body
        // ...
    }
}
```

---

## Authentication Patterns

### Pattern 1: API Key (Header)

```swift
request.setValue("YOUR_API_KEY", forHTTPHeaderField: "X-API-Key")
```

### Pattern 2: Bearer Token

```swift
request.setValue("Bearer YOUR_TOKEN", forHTTPHeaderField: "Authorization")
```

### Pattern 3: OAuth 2.0

```swift
actor OAuth2Client {
    private var accessToken: String?
    private var tokenExpiry: Date?

    func getAccessToken() async throws -> String {
        if let token = accessToken,
           let expiry = tokenExpiry,
           Date() < expiry {
            return token
        }

        // Refresh token
        let response = try await refreshAccessToken()
        self.accessToken = response.accessToken
        self.tokenExpiry = Date().addingTimeInterval(response.expiresIn)

        return response.accessToken
    }

    private func refreshAccessToken() async throws -> TokenResponse {
        // OAuth flow...
    }
}
```

### Pattern 4: Basic Auth

```swift
let credentials = "\(username):\(password)"
let encoded = Data(credentials.utf8).base64EncodedString()
request.setValue("Basic \(encoded)", forHTTPHeaderField: "Authorization")
```

---

## Rate Limit Configurations

Recommended configurations for `RateLimiter`:

| Source | Max Requests | Time Window | Notes |
|--------|-------------|-------------|-------|
| Remotive | 100 | 3600s (1h) | Undocumented, be conservative |
| AngelList | 1000 | 3600s (1h) | With authentication |
| LinkedIn | 500 | 86400s (24h) | Daily limit, very conservative |
| Greenhouse | 600 | 60s (1m) | Per-second limit |
| Lever | 100 | 60s (1m) | Per-minute limit |
| Indeed | 100 | 3600s (1h) | Varies by plan |
| RSS Feeds | 2 | 3600s (1h) | Very conservative |

---

## Error Code Handling

Common HTTP status codes and recommended actions:

| Code | Meaning | Action |
|------|---------|--------|
| 200 | Success | Process response |
| 400 | Bad Request | Log error, don't retry |
| 401 | Unauthorized | Refresh credentials, retry once |
| 403 | Forbidden | Check API key, don't retry |
| 404 | Not Found | Return nil/empty |
| 429 | Too Many Requests | Respect Retry-After header, backoff |
| 500 | Server Error | Retry with backoff |
| 502 | Bad Gateway | Retry with backoff |
| 503 | Service Unavailable | Circuit breaker, long backoff |
| 504 | Gateway Timeout | Retry with backoff |

---

## Testing APIs

### Test with curl

```bash
# Test Remotive
curl -s "https://remotive.com/api/remote-jobs?limit=1" | jq

# Test with auth
curl -s -H "Authorization: Bearer TOKEN" \
  "https://api.example.com/jobs" | jq

# Test with rate limit
for i in {1..5}; do
  curl -w "\nStatus: %{http_code}\n" \
    "https://api.example.com/jobs"
  sleep 1
done
```

### Test in Swift

```swift
// Quick test script
import Foundation

let url = URL(string: "https://remotive.com/api/remote-jobs?limit=1")!
let (data, response) = try await URLSession.shared.data(from: url)

if let httpResponse = response as? HTTPURLResponse {
    print("Status: \(httpResponse.statusCode)")
    print("Headers: \(httpResponse.allHeaderFields)")
}

print("Body: \(String(data: data, encoding: .utf8) ?? "Invalid")")
```

---

## Integration Checklist

When integrating a new job board API:

1. **Research**
   - [ ] Find official API documentation
   - [ ] Identify authentication method
   - [ ] Note rate limits
   - [ ] Review response format
   - [ ] Check for SDKs or libraries

2. **Scaffold**
   - [ ] Run scaffold script
   - [ ] Update API endpoints
   - [ ] Add authentication
   - [ ] Configure rate limits

3. **Implement**
   - [ ] Update response models
   - [ ] Implement adapter logic
   - [ ] Extract skills properly
   - [ ] Parse dates correctly

4. **Test**
   - [ ] Test with curl/Postman
   - [ ] Unit test adapter
   - [ ] Integration test API client
   - [ ] Validate data quality

5. **Deploy**
   - [ ] Add to job source registry
   - [ ] Monitor performance
   - [ ] Track error rates
   - [ ] Validate Thompson scoring

---

## Quick Reference Commands

```bash
# Scaffold new integration
./scripts/scaffold_api_integration.sh SourceName https://api.example.com 100

# Test API connectivity
curl -s "https://api.example.com/jobs" | jq

# Validate integration
./scripts/validate_job_structure.sh sourcename 20

# Run integration tests
swift test --filter SourceNameTests

# Monitor rate limits
# Check RateLimiter.getUsage() in code
```
