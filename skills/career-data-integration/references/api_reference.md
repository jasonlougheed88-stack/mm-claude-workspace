# Job Board API Reference

Comprehensive documentation for integrating with major job board APIs.

## Indeed API

### Authentication
```
Publisher ID: Required
API Key: Required (apply at https://ads.indeed.com/jobroll/xmlfeed)
```

### Job Search Endpoint
```
GET https://api.indeed.com/ads/apisearch
```

**Parameters:**
- `publisher` (required): Your publisher ID
- `q` (string): Job keywords
- `l` (string): Location (city, state, zip)
- `radius` (integer): Search radius in miles (default: 25)
- `salary` (integer): Minimum salary
- `limit` (integer): Results per page (max: 25)
- `start` (integer): Pagination offset
- `format` (string): Response format (json, xml)

**Response:**
```json
{
  "results": [
    {
      "jobtitle": "Software Engineer",
      "company": "Example Corp",
      "city": "San Francisco",
      "state": "CA",
      "country": "US",
      "formattedLocation": "San Francisco, CA",
      "source": "Example Corp",
      "date": "Mon, 02 Jan 2023 12:00:00 GMT",
      "snippet": "Job description preview...",
      "url": "https://www.indeed.com/viewjob?jk=abc123",
      "salary": "$120,000 - $180,000"
    }
  ]
}
```

**Rate Limits:**
- Free tier: 100 requests/day
- Paid tier: Custom limits

---

## LinkedIn Jobs API

### Authentication
```
OAuth 2.0
Client ID: Required
Client Secret: Required
Scopes: r_jobs, w_jobs
```

### Job Search Endpoint
```
GET https://api.linkedin.com/v2/jobs
```

**Headers:**
```
Authorization: Bearer {access_token}
LinkedIn-Version: 202401
```

**Parameters:**
- `keywords` (string): Job search terms
- `location` (string): Geographic location
- `distance` (integer): Radius in miles
- `experience` (array): Experience levels (internship, entry, associate, mid-senior, director, executive)
- `jobType` (array): Full-time, part-time, contract, temporary, volunteer, internship
- `industries` (array): Industry codes
- `companies` (array): Company IDs
- `remote` (boolean): Remote positions only

**Response:**
```json
{
  "elements": [
    {
      "id": "123456789",
      "title": "Senior Software Engineer",
      "description": "Full job description...",
      "company": {
        "id": "company123",
        "name": "Tech Company Inc",
        "universalName": "tech-company"
      },
      "location": "San Francisco Bay Area",
      "salary": {
        "min": 150000,
        "max": 200000,
        "currency": "USD"
      },
      "experienceLevel": "MID_SENIOR",
      "employmentType": "FULL_TIME",
      "postedDate": 1672617600000,
      "expiresDate": 1675296000000,
      "applyUrl": "https://www.linkedin.com/jobs/view/123456789"
    }
  ],
  "paging": {
    "count": 10,
    "start": 0,
    "total": 150
  }
}
```

**Rate Limits:**
- 500 requests/day (standard)
- 100 requests/minute

---

## Glassdoor API

### Authentication
```
Partner ID: Required
Partner Key: Required
```

### Job Search Endpoint
```
GET https://api.glassdoor.com/api/api.htm
```

**Parameters:**
- `t.p` (required): Partner ID
- `t.k` (required): Partner Key
- `action`: "jobs-prog" for job search
- `q` (string): Job title keywords
- `l` (string): Location
- `radius` (integer): Search radius
- `jobType` (string): fulltime, parttime, contract, temporary, internship
- `minSalary` (integer): Minimum salary
- `maxSalary` (integer): Maximum salary
- `format`: "json"

**Response:**
```json
{
  "response": {
    "jobListings": [
      {
        "jobTitle": "Product Manager",
        "employer": "Example Company",
        "location": "New York, NY",
        "salary": "$110,000 - $140,000",
        "jobDescription": "Full description...",
        "jobSource": "Glassdoor",
        "postedDate": "2023-01-15",
        "jobUrl": "https://www.glassdoor.com/job-listing/...",
        "companyRating": 4.2,
        "companyReviews": 523
      }
    ],
    "totalResults": 87
  }
}
```

**Rate Limits:**
- 1000 requests/day
- No minute-based throttling

---

## ZipRecruiter API

### Authentication
```
API Key: Required (request from ZipRecruiter partner team)
```

### Job Search Endpoint
```
GET https://api.ziprecruiter.com/jobs/v1
```

**Parameters:**
- `api_key` (required): Your API key
- `search` (string): Job keywords
- `location` (string): City, state, or zip
- `radius_miles` (integer): Search radius
- `days_ago` (integer): Jobs posted within X days
- `jobs_per_page` (integer): Results per page (max: 100)
- `page` (integer): Page number

**Response:**
```json
{
  "jobs": [
    {
      "job_title": "Data Scientist",
      "hiring_company": {
        "name": "Analytics Corp",
        "url": "https://www.ziprecruiter.com/c/Analytics-Corp"
      },
      "location": "Seattle, WA",
      "posted_time": "2 days ago",
      "snippet": "Description preview...",
      "url": "https://www.ziprecruiter.com/jobs/analytics-corp-...",
      "salary": "$130,000 - $170,000",
      "employment_type": "Full-Time"
    }
  ],
  "total_jobs": 245,
  "page": 1,
  "jobs_per_page": 20
}
```

**Rate Limits:**
- Varies by partnership agreement
- Typical: 10,000 requests/day

---

## Error Handling

### Common HTTP Status Codes

- `200 OK`: Success
- `400 Bad Request`: Invalid parameters
- `401 Unauthorized`: Invalid credentials
- `403 Forbidden`: Rate limit exceeded or invalid permissions
- `404 Not Found`: Endpoint doesn't exist
- `429 Too Many Requests`: Rate limit exceeded
- `500 Internal Server Error`: API server error
- `503 Service Unavailable`: API temporarily down

### Recommended Retry Strategy

```python
def retry_with_backoff(func, max_retries=3, base_delay=1):
    for attempt in range(max_retries):
        try:
            return func()
        except RateLimitError:
            if attempt == max_retries - 1:
                raise
            delay = base_delay * (2 ** attempt)
            time.sleep(delay)
```

---

## Data Normalization

### Standardized Job Schema

When aggregating from multiple sources, normalize to this schema:

```json
{
  "id": "string (source-specific)",
  "source": "string (indeed|linkedin|glassdoor|ziprecruiter)",
  "title": "string",
  "company": {
    "name": "string",
    "url": "string (optional)"
  },
  "location": {
    "city": "string",
    "state": "string",
    "country": "string",
    "remote": "boolean"
  },
  "description": "string",
  "snippet": "string (short preview)",
  "salary": {
    "min": "number (optional)",
    "max": "number (optional)",
    "currency": "string (USD, EUR, etc.)"
  },
  "employment_type": "string (full-time|part-time|contract|temporary|internship)",
  "experience_level": "string (entry|mid|senior|executive)",
  "posted_date": "ISO 8601 timestamp",
  "expires_date": "ISO 8601 timestamp (optional)",
  "apply_url": "string",
  "required_skills": ["string"],
  "preferred_skills": ["string"]
}
```

---

## Caching Strategy

### Recommended TTL by Data Type

- Job search results: 1-6 hours
- Company data: 24 hours
- Salary ranges: 7 days
- Skills taxonomy: 30 days

### Cache Keys

```
job_search:{source}:{keywords}:{location}:{filters_hash}
company:{source}:{company_id}
salary_range:{job_title}:{location}
```

---

## Cost Optimization Tips

1. **Batch Requests**: Combine multiple searches when possible
2. **Aggressive Caching**: Cache results for 1-6 hours
3. **Smart Pagination**: Only fetch additional pages on demand
4. **Filter on Client**: Do basic filtering client-side to reduce API calls
5. **Monitor Quotas**: Track daily usage to avoid overages
6. **Free Tiers First**: Prioritize APIs with generous free tiers
7. **Lazy Loading**: Only fetch job details when user clicks
