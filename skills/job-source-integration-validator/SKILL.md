---
name: job-source-integration-validator
description: Validates new job sources produce correctly structured JobCard data, verify API integrations work properly, test rate limiting, error handling, and ensure seamless integration with Thompson scoring and DeckScreen UI
allowed-tools:
  - Read
  - Bash
  - Grep
  - Edit
  - Write
---

# Job Source Integration Validator

## Purpose

Ensures new job board integrations (Remotive, AngelList, LinkedIn, Greenhouse, Lever, etc.) produce valid JobCard data and integrate seamlessly with the V7 system. Catches data structure issues, API problems, and integration bugs before they reach production.

## When This Skill Activates

**During development:**
- User says "Add new job source"
- User mentions job board names (Remotive, AngelList, LinkedIn, etc.)
- User asks "Validate job source integration"
- Working in `Packages/V7JobSources/` or `Packages/V7Services/`

**Before shipping:**
- User requests "Test job source"
- Before merging job source PRs
- During integration testing

**Debugging:**
- Jobs not displaying correctly
- Missing fields in job cards
- API errors from job sources

## Sacred JobCard Data Structure

All job sources MUST produce this structure:

```swift
// V7Thompson.Job (from V7Thompson package)
public struct Job: Identifiable, Codable, Sendable, Equatable {
    // REQUIRED FIELDS (must never be nil)
    public let id: UUID
    public let title: String
    public let company: String
    public let location: String

    // RECOMMENDED FIELDS (strongly encouraged)
    public let description: String?
    public let salary: String?
    public let skills: [String]?
    public let url: URL?

    // OPTIONAL FIELDS (nice to have)
    public let remote: Bool?
    public let postedDate: Date?
    public let source: String?
    public let applicationUrl: URL?

    // METADATA (for tracking)
    public let fetchedAt: Date
    public let sourceIdentifier: String
}
```

## Validation Checklist

### Level 1: Data Structure Validation

**Required Fields:**
- ✅ `id` is unique UUID
- ✅ `title` is non-empty string
- ✅ `company` is non-empty string
- ✅ `location` is non-empty string
- ✅ `fetchedAt` is valid Date
- ✅ `sourceIdentifier` matches source name

**Recommended Fields (80%+ coverage):**
- ✅ `description` exists and >100 characters
- ✅ `skills` array has 3+ items
- ✅ `url` is valid, working URL
- ✅ `salary` is present (when available from source)

**Quality Checks:**
- ❌ No duplicate job IDs
- ❌ No truncated descriptions
- ❌ No malformed URLs
- ❌ No "N/A" or placeholder values

### Level 2: API Integration Validation

**Connection:**
- ✅ API credentials configured correctly
- ✅ Base URL reachable
- ✅ Authentication working
- ✅ SSL/TLS certificates valid

**Rate Limiting:**
- ✅ Rate limits respected (e.g., 100 req/hour)
- ✅ Exponential backoff implemented
- ✅ Circuit breaker configured
- ✅ Retry logic with jitter

**Error Handling:**
- ✅ Network failures handled gracefully
- ✅ 4xx errors (auth, not found) handled
- ✅ 5xx errors (server issues) handled
- ✅ Timeout protection (5s max)
- ✅ Fallback to cached data

### Level 3: Thompson Integration Validation

**Scoring Compatibility:**
- ✅ Skills array properly formatted
- ✅ Location data usable for scoring
- ✅ Remote flag affects scoring correctly
- ✅ No scoring performance regression (<10ms maintained)

**Cache Integration:**
- ✅ Jobs cached with correct TTL
- ✅ Cache keys unique per source
- ✅ Cache invalidation working

### Level 4: UI Rendering Validation

**DeckScreen Display:**
- ✅ Job cards render correctly
- ✅ No layout issues (text overflow, clipping)
- ✅ Images load (if applicable)
- ✅ Swipe gestures work
- ✅ Application button functional

**Accessibility:**
- ✅ VoiceOver labels present
- ✅ Dynamic Type supported
- ✅ Color contrast meets WCAG AA

## Validation Scripts

### Script 1: Validate Job Data Structure

```bash
#!/bin/bash
# scripts/validate_job_structure.sh SOURCE_NAME

SOURCE=$1
OUTPUT=$(mktemp)

echo "🔍 Validating job data structure for: $SOURCE"

# Fetch sample jobs from source
swift run ValidateJobSource --source "$SOURCE" --count 10 > "$OUTPUT"

# Parse and validate
python3 - "$OUTPUT" "$SOURCE" <<'PYTHON'
import json
import sys
from urllib.parse import urlparse

if len(sys.argv) < 3:
    print("Usage: validate_job_structure.sh SOURCE_NAME")
    sys.exit(1)

output_file = sys.argv[1]
source_name = sys.argv[2]

try:
    with open(output_file) as f:
        jobs = json.load(f)
except Exception as e:
    print(f"❌ Failed to parse JSON: {e}")
    sys.exit(1)

if not jobs or not isinstance(jobs, list):
    print(f"❌ Invalid response: Expected array of jobs")
    sys.exit(1)

print(f"\n📊 Validating {len(jobs)} jobs from {source_name}")
print("=" * 80)

# Validation counters
errors = []
warnings = []

for idx, job in enumerate(jobs):
    job_num = idx + 1

    # Required fields
    if not job.get('id'):
        errors.append(f"Job {job_num}: Missing 'id' field")

    if not job.get('title') or len(job.get('title', '')) == 0:
        errors.append(f"Job {job_num}: Missing or empty 'title'")

    if not job.get('company') or len(job.get('company', '')) == 0:
        errors.append(f"Job {job_num}: Missing or empty 'company'")

    if not job.get('location') or len(job.get('location', '')) == 0:
        errors.append(f"Job {job_num}: Missing or empty 'location'")

    # Recommended fields
    if not job.get('description') or len(job.get('description', '')) < 100:
        warnings.append(f"Job {job_num}: Description missing or too short (<100 chars)")

    if not job.get('skills') or len(job.get('skills', [])) < 3:
        warnings.append(f"Job {job_num}: Skills missing or insufficient (<3 skills)")

    # URL validation
    if job.get('url'):
        parsed = urlparse(job.get('url'))
        if not parsed.scheme or not parsed.netloc:
            errors.append(f"Job {job_num}: Invalid URL format: {job.get('url')}")
    else:
        warnings.append(f"Job {job_num}: No URL provided")

    # Source identifier
    if job.get('sourceIdentifier') != source_name:
        errors.append(f"Job {job_num}: Wrong sourceIdentifier (expected '{source_name}', got '{job.get('sourceIdentifier')}')")

# Report
print("\n✅ REQUIRED FIELDS:")
print(f"  Jobs with valid IDs:       {len([j for j in jobs if j.get('id')])}/{len(jobs)}")
print(f"  Jobs with titles:          {len([j for j in jobs if j.get('title')])}/{len(jobs)}")
print(f"  Jobs with companies:       {len([j for j in jobs if j.get('company')])}/{len(jobs)}")
print(f"  Jobs with locations:       {len([j for j in jobs if j.get('location')])}/{len(jobs)}")

print("\n📊 RECOMMENDED FIELDS:")
print(f"  Jobs with descriptions:    {len([j for j in jobs if j.get('description')])}/{len(jobs)}")
print(f"  Jobs with skills (3+):     {len([j for j in jobs if len(j.get('skills', [])) >= 3])}/{len(jobs)}")
print(f"  Jobs with URLs:            {len([j for j in jobs if j.get('url')])}/{len(jobs)}")
print(f"  Jobs with salaries:        {len([j for j in jobs if j.get('salary')])}/{len(jobs)}")

if errors:
    print(f"\n❌ ERRORS ({len(errors)}):")
    for error in errors[:10]:  # Show first 10
        print(f"  • {error}")
    if len(errors) > 10:
        print(f"  ... and {len(errors) - 10} more errors")

if warnings:
    print(f"\n⚠️  WARNINGS ({len(warnings)}):")
    for warning in warnings[:10]:  # Show first 10
        print(f"  • {warning}")
    if len(warnings) > 10:
        print(f"  ... and {len(warnings) - 10} more warnings")

print("\n" + "=" * 80)

if errors:
    print("❌ VALIDATION FAILED")
    print("\n🔧 Action Required:")
    print("  1. Fix data structure issues in job source adapter")
    print("  2. Ensure all required fields are populated")
    print("  3. Re-run validation")
    sys.exit(1)
elif len(warnings) > len(jobs) * 0.5:  # More than 50% warnings
    print("⚠️  VALIDATION PASSED WITH WARNINGS")
    print("\n💡 Consider improving:")
    print("  1. Add more complete job descriptions")
    print("  2. Extract more skills from job data")
    print("  3. Include URLs and salary info when available")
    sys.exit(0)
else:
    print("✅ VALIDATION PASSED")
    print(f"\n🎉 {source_name} integration looks good!")
    print("✅ Ready for Thompson scoring integration")
    sys.exit(0)

PYTHON

rm -f "$OUTPUT"
```

### Script 2: Test API Rate Limiting

```bash
#!/bin/bash
# scripts/test_rate_limiting.sh SOURCE_NAME RATE_LIMIT

SOURCE=$1
RATE_LIMIT=${2:-100}  # Default 100 req/hour

echo "🔍 Testing rate limiting for: $SOURCE"
echo "📊 Rate limit: $RATE_LIMIT requests/hour"
echo ""

# Calculate requests per second
REQUESTS_PER_SEC=$(echo "scale=4; $RATE_LIMIT / 3600" | bc)

echo "Testing with $REQUESTS_PER_SEC req/sec..."

# Make rapid requests
START_TIME=$(date +%s)
SUCCESS=0
BLOCKED=0

for i in {1..20}; do
    RESPONSE=$(curl -s -w "\n%{http_code}" \
        "https://api.example.com/jobs" \
        -H "Authorization: Bearer $API_KEY" 2>&1)

    HTTP_CODE=$(echo "$RESPONSE" | tail -1)

    if [ "$HTTP_CODE" = "200" ]; then
        ((SUCCESS++))
        echo "✅ Request $i: Success"
    elif [ "$HTTP_CODE" = "429" ]; then
        ((BLOCKED++))
        echo "⏸️  Request $i: Rate limited (expected)"
    else
        echo "❌ Request $i: Error ($HTTP_CODE)"
    fi

    # Small delay
    sleep 0.1
done

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "=" * 80
echo "📊 RATE LIMITING TEST RESULTS"
echo "=" * 80
echo "Duration:        ${DURATION}s"
echo "Successful:      $SUCCESS"
echo "Rate limited:    $BLOCKED"
echo ""

if [ $BLOCKED -gt 0 ]; then
    echo "✅ Rate limiting is working correctly"
    echo "💡 Circuit breaker should kick in after rate limit hit"
else
    echo "⚠️  No rate limiting detected"
    echo "💡 Verify rate limit configuration"
fi
```

### Script 3: Integration Test Runner

```bash
#!/bin/bash
# scripts/run_integration_tests.sh SOURCE_NAME

SOURCE=$1

echo "🧪 Running integration tests for: $SOURCE"
echo "=" * 80

# Test 1: Data structure
echo ""
echo "Test 1: Data Structure Validation"
./scripts/validate_job_structure.sh "$SOURCE"
STRUCTURE_RESULT=$?

# Test 2: API connectivity
echo ""
echo "Test 2: API Connectivity"
timeout 10s swift run TestJobSource --source "$SOURCE" --test connectivity
CONNECTIVITY_RESULT=$?

# Test 3: Thompson scoring
echo ""
echo "Test 3: Thompson Scoring Integration"
swift run TestJobSource --source "$SOURCE" --test thompson
THOMPSON_RESULT=$?

# Test 4: UI rendering
echo ""
echo "Test 4: UI Rendering"
swift run TestJobSource --source "$SOURCE" --test ui
UI_RESULT=$?

# Summary
echo ""
echo "=" * 80
echo "INTEGRATION TEST SUMMARY: $SOURCE"
echo "=" * 80
echo ""

if [ $STRUCTURE_RESULT -eq 0 ]; then
    echo "✅ Data structure validation: PASS"
else
    echo "❌ Data structure validation: FAIL"
fi

if [ $CONNECTIVITY_RESULT -eq 0 ]; then
    echo "✅ API connectivity: PASS"
else
    echo "❌ API connectivity: FAIL"
fi

if [ $THOMPSON_RESULT -eq 0 ]; then
    echo "✅ Thompson scoring: PASS"
else
    echo "❌ Thompson scoring: FAIL"
fi

if [ $UI_RESULT -eq 0 ]; then
    echo "✅ UI rendering: PASS"
else
    echo "❌ UI rendering: FAIL"
fi

echo ""

if [ $STRUCTURE_RESULT -eq 0 ] && [ $CONNECTIVITY_RESULT -eq 0 ] && [ $THOMPSON_RESULT -eq 0 ] && [ $UI_RESULT -eq 0 ]; then
    echo "🎉 ALL TESTS PASSED"
    echo "✅ $SOURCE is ready for production"
    exit 0
else
    echo "❌ SOME TESTS FAILED"
    echo "🔧 Fix issues before deploying"
    exit 1
fi
```

## Common Integration Issues

### Issue 1: Missing Required Fields

**Symptom:**
```
❌ Jobs missing 'title' field
❌ Jobs missing 'company' field
```

**Solution:**
```swift
// ❌ WRONG: Optional required fields
public struct JobAdapter {
    func adapt(_ apiResponse: APIJob) -> Job? {
        return Job(
            id: UUID(),
            title: apiResponse.title,  // Could be nil!
            company: apiResponse.company,  // Could be nil!
            location: apiResponse.location ?? "Remote"
        )
    }
}

// ✅ CORRECT: Validate and provide defaults
public struct JobAdapter {
    func adapt(_ apiResponse: APIJob) -> Job? {
        guard let title = apiResponse.title, !title.isEmpty else {
            print("⚠️ Skipping job with missing title")
            return nil
        }

        guard let company = apiResponse.company, !company.isEmpty else {
            print("⚠️ Skipping job with missing company")
            return nil
        }

        return Job(
            id: UUID(),
            title: title,
            company: company,
            location: apiResponse.location ?? "Remote",
            description: apiResponse.description,
            skills: extractSkills(from: apiResponse),
            url: URL(string: apiResponse.url ?? ""),
            fetchedAt: Date(),
            sourceIdentifier: "remotive"
        )
    }
}
```

### Issue 2: Rate Limit Violations

**Symptom:**
```
❌ HTTP 429 Too Many Requests
❌ Source temporarily unavailable
```

**Solution:**
```swift
// ✅ Implement rate limiter
actor RateLimiter {
    private var requestTimes: [Date] = []
    private let maxRequests: Int = 100
    private let timeWindow: TimeInterval = 3600  // 1 hour

    func canMakeRequest() -> Bool {
        let now = Date()
        let cutoff = now.addingTimeInterval(-timeWindow)

        // Remove old requests
        requestTimes = requestTimes.filter { $0 > cutoff }

        return requestTimes.count < maxRequests
    }

    func recordRequest() {
        requestTimes.append(Date())
    }
}

// Use in job source
actor RemotiveJobSource {
    private let rateLimiter = RateLimiter()

    func fetchJobs() async throws -> [Job] {
        guard await rateLimiter.canMakeRequest() else {
            throw JobSourceError.rateLimitExceeded
        }

        let jobs = try await performAPICall()
        await rateLimiter.recordRequest()

        return jobs
    }
}
```

### Issue 3: Poor Skills Extraction

**Symptom:**
```
⚠️ Jobs with insufficient skills (<3 skills)
⚠️ Generic skills like "Teamwork", "Communication"
```

**Solution:**
```swift
// ✅ Intelligent skills extraction
struct SkillsExtractor {
    // Known technical skills
    private let technicalSkills = [
        "Swift", "Python", "JavaScript", "React", "Node.js",
        "AWS", "Docker", "Kubernetes", "SQL", "MongoDB"
        // ... more skills
    ]

    func extractSkills(from job: APIJob) -> [String] {
        var skills: [String] = []

        // 1. Use explicit skills from API
        if let apiSkills = job.skills {
            skills.append(contentsOf: apiSkills)
        }

        // 2. Extract from description
        let description = job.description ?? ""
        for skill in technicalSkills {
            if description.localizedCaseInsensitiveContains(skill) {
                skills.append(skill)
            }
        }

        // 3. Deduplicate and normalize
        skills = Array(Set(skills.map { $0.lowercased().capitalized }))

        // 4. Remove generic skills
        let genericSkills = ["Teamwork", "Communication", "Leadership"]
        skills = skills.filter { !genericSkills.contains($0) }

        return Array(skills.prefix(10))  // Max 10 skills
    }
}
```

## Job Source Template

Use this template when creating new job source adapters:

```swift
// Packages/V7JobSources/Sources/V7JobSources/RemotiveJobSource.swift

import Foundation
import V7Thompson
import V7Core

/// Remotive job board integration
/// API Docs: https://remotive.com/api/jobs
/// Rate Limit: 100 requests/hour
actor RemotiveJobSource: JobSourceProtocol {
    // MARK: - Configuration
    private let baseURL = "https://remotive.com/api/remote-jobs"
    private let rateLimiter = RateLimiter(maxRequests: 100, perHour: 1)
    private let cache = JobCache(ttl: 300)  // 5 minutes

    public var sourceIdentifier: String { "remotive" }

    // MARK: - Fetching
    public func fetchJobs() async throws -> [V7Thompson.Job] {
        // Check cache first
        if let cached = await cache.getJobs() {
            print("💾 Remotive: Using cached jobs")
            return cached
        }

        // Check rate limit
        guard await rateLimiter.canMakeRequest() else {
            throw JobSourceError.rateLimitExceeded
        }

        // Fetch from API
        let apiJobs = try await performAPIRequest()
        await rateLimiter.recordRequest()

        // Adapt to Job format
        let jobs = apiJobs.compactMap { adapt($0) }

        // Cache results
        await cache.setJobs(jobs)

        print("✅ Remotive: Fetched \(jobs.count) jobs")
        return jobs
    }

    // MARK: - Private Methods
    private func performAPIRequest() async throws -> [APIJob] {
        let url = URL(string: baseURL)!
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw JobSourceError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 429 {
                throw JobSourceError.rateLimitExceeded
            }
            throw JobSourceError.httpError(httpResponse.statusCode)
        }

        let apiResponse = try JSONDecoder().decode(RemotiveAPIResponse.self, from: data)
        return apiResponse.jobs
    }

    private func adapt(_ apiJob: APIJob) -> V7Thompson.Job? {
        // Validate required fields
        guard let title = apiJob.title, !title.isEmpty else { return nil }
        guard let company = apiJob.company_name, !company.isEmpty else { return nil }

        return V7Thompson.Job(
            id: UUID(),
            title: title,
            company: company,
            location: apiJob.candidate_required_location ?? "Remote",
            description: apiJob.description,
            salary: apiJob.salary,
            skills: extractSkills(from: apiJob),
            url: URL(string: apiJob.url ?? ""),
            remote: true,
            postedDate: parseDate(apiJob.publication_date),
            source: "Remotive",
            applicationUrl: URL(string: apiJob.url ?? ""),
            fetchedAt: Date(),
            sourceIdentifier: "remotive"
        )
    }

    private func extractSkills(from apiJob: APIJob) -> [String] {
        let extractor = SkillsExtractor()
        return extractor.extractSkills(from: apiJob)
    }

    private func parseDate(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString)
    }
}

// MARK: - API Response Types
private struct RemotiveAPIResponse: Codable {
    let jobs: [APIJob]
}

private struct APIJob: Codable {
    let id: Int
    let title: String?
    let company_name: String?
    let candidate_required_location: String?
    let description: String?
    let salary: String?
    let url: String?
    let publication_date: String?
    let tags: [String]?
}
```

## Quick Commands

When integrating job sources, you can say:

**Setup:**
- "Create job source adapter for [Remotive/AngelList/etc]"
- "Show me the job source template"

**Validation:**
- "Validate [source] job data structure"
- "Test [source] API integration"
- "Check [source] rate limiting"

**Debugging:**
- "Why are jobs missing fields?"
- "Fix skills extraction for [source]"
- "Show me malformed job data"

**Testing:**
- "Run integration tests for [source]"
- "Compare job quality across sources"

## Integration with Other Skills

Works alongside:
- **job-card-validator**: Validates JobCard UI rendering
- **v7-architecture-guardian**: Ensures proper actor isolation
- **performance-regression-detector**: Checks fetch performance
- **api-integration-architect**: Designs rate limiting strategies

## Usage

This skill activates when you:
- Add new job source integrations
- Debug job data issues
- Test API connectivity
- Validate job card rendering
- Use keywords: "job source", "integration", "validate", API names

The skill provides templates, validation scripts, and debugging guidance for seamless job source integration.

---

**Last Updated**: Created per user request
**Supported Sources**: Remotive, AngelList, LinkedIn, Greenhouse, Lever, and more
**Maintenance**: Update validation rules as Job model evolves
