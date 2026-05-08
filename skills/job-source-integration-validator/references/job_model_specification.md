# Job Model Specification

Complete specification for the `V7Thompson.Job` model that all job sources must produce.

## Model Definition

```swift
// Packages/V7Thompson/Sources/V7Thompson/Models/Job.swift

import Foundation

/// Represents a job opportunity from any source
/// CRITICAL: All job sources must produce this exact structure
public struct Job: Identifiable, Codable, Sendable, Equatable {
    // MARK: - Required Fields (MUST be present)

    /// Unique identifier for this job
    /// CRITICAL: Must be unique UUID, never reuse IDs
    public let id: UUID

    /// Job title (e.g., "Senior iOS Engineer")
    /// CRITICAL: Must be non-empty, descriptive
    public let title: String

    /// Company name (e.g., "Apple Inc.")
    /// CRITICAL: Must be non-empty, real company name
    public let company: String

    /// Location (e.g., "San Francisco, CA" or "Remote")
    /// CRITICAL: Must be non-empty, use "Remote" if fully remote
    public let location: String

    // MARK: - Recommended Fields (80%+ coverage expected)

    /// Full job description
    /// RECOMMENDED: >100 characters for quality
    public let description: String?

    /// Salary range (e.g., "$120k - $180k")
    /// RECOMMENDED: Include when available from source
    public let salary: String?

    /// Required/desired skills
    /// RECOMMENDED: 3-10 skills for Thompson scoring
    public let skills: [String]?

    /// URL to job posting
    /// RECOMMENDED: Valid, working URL
    public let url: URL?

    // MARK: - Optional Fields (Nice to have)

    /// Whether job is fully remote
    /// OPTIONAL: true/false/nil
    public let remote: Bool?

    /// When job was posted
    /// OPTIONAL: Parse from source if available
    public let postedDate: Date?

    /// Human-readable source name (e.g., "Remotive")
    /// OPTIONAL: For display purposes
    public let source: String?

    /// Direct application URL (may differ from job URL)
    /// OPTIONAL: Used for "Apply" button
    public let applicationUrl: URL?

    // MARK: - Metadata (Required for tracking)

    /// When this job was fetched from the source
    /// REQUIRED: Set to Date() when creating
    public let fetchedAt: Date

    /// Source identifier (matches JobSourceProtocol.sourceIdentifier)
    /// REQUIRED: Must match source name exactly (e.g., "remotive", "angellist")
    public let sourceIdentifier: String
}
```

## Field Requirements

### Required Fields (100% Coverage)

| Field | Type | Constraint | Example | Notes |
|-------|------|------------|---------|-------|
| `id` | UUID | Never nil, must be unique | `550e8400-e29b-...` | Generate fresh UUID for each job |
| `title` | String | Non-empty, meaningful | `"Senior iOS Engineer"` | No placeholders like "Job" or "TBD" |
| `company` | String | Non-empty, real name | `"Apple Inc."` | No "Unknown" or "N/A" |
| `location` | String | Non-empty | `"San Francisco, CA"` or `"Remote"` | Use "Remote" for fully remote jobs |
| `fetchedAt` | Date | Valid date | `Date()` | Timestamp when job was fetched |
| `sourceIdentifier` | String | Exact match | `"remotive"` | Must match your source name |

### Recommended Fields (80%+ Coverage)

| Field | Type | Target | Quality Criteria | Impact |
|-------|------|--------|------------------|--------|
| `description` | String? | 80% | >100 characters, meaningful content | Thompson scoring, user decision making |
| `skills` | [String]? | 80% | 3-10 technical skills | **Critical for Thompson scoring** |
| `url` | URL? | 90% | Valid, working URL | User can view full posting |
| `salary` | String? | 60% | Range or estimate | Helps user filter |

### Optional Fields

| Field | Type | Notes |
|-------|------|-------|
| `remote` | Bool? | Set to true if fully remote |
| `postedDate` | Date? | Parse from source if available |
| `source` | String? | Human-readable name (e.g., "Remotive Job Board") |
| `applicationUrl` | URL? | Direct apply link (may differ from job URL) |

## Examples

### ✅ GOOD Example (High Quality)

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Senior iOS Engineer",
  "company": "Stripe",
  "location": "San Francisco, CA (Hybrid)",
  "description": "We're looking for an experienced iOS engineer to join our Payments Platform team. You'll work on building delightful mobile experiences for millions of users worldwide. The ideal candidate has 5+ years of iOS development, deep Swift expertise, and a passion for creating pixel-perfect UIs. You'll collaborate with designers, backend engineers, and product managers to ship high-impact features.",
  "salary": "$150k - $220k + equity",
  "skills": [
    "Swift",
    "SwiftUI",
    "UIKit",
    "iOS",
    "Xcode",
    "Git",
    "REST APIs",
    "Mobile Architecture"
  ],
  "url": "https://stripe.com/jobs/123456",
  "remote": false,
  "postedDate": "2025-10-20T10:00:00Z",
  "source": "Stripe Careers",
  "applicationUrl": "https://stripe.com/jobs/123456/apply",
  "fetchedAt": "2025-10-26T14:30:00Z",
  "sourceIdentifier": "stripe"
}
```

**Why this is good:**
- All required fields present and meaningful
- Description >100 characters, informative
- 8 relevant technical skills (great for Thompson scoring!)
- Valid URLs
- Salary info included
- Proper date formats

### ⚠️ ACCEPTABLE Example (Minimum Viable)

```json
{
  "id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
  "title": "iOS Developer",
  "company": "Tech Startup Inc",
  "location": "Remote",
  "description": "Looking for iOS developer with Swift experience. Must know SwiftUI.",
  "salary": null,
  "skills": ["Swift", "SwiftUI", "iOS"],
  "url": "https://example.com/jobs/789",
  "remote": true,
  "postedDate": null,
  "source": "Remote Job Board",
  "applicationUrl": null,
  "fetchedAt": "2025-10-26T14:30:00Z",
  "sourceIdentifier": "remotejobs"
}
```

**Why this is acceptable:**
- All required fields present
- Description is minimal but not empty
- Has 3 skills (minimum for Thompson)
- Missing some recommended fields (salary, dates)
- Will work but scoring may be suboptimal

### ❌ BAD Example (Will Fail Validation)

```json
{
  "id": null,
  "title": "",
  "company": "N/A",
  "location": "",
  "description": null,
  "salary": null,
  "skills": [],
  "url": null,
  "remote": null,
  "postedDate": null,
  "source": null,
  "applicationUrl": null,
  "fetchedAt": "2025-10-26T14:30:00Z",
  "sourceIdentifier": "badsource"
}
```

**Problems:**
- ❌ `id` is null (CRITICAL ERROR)
- ❌ `title` is empty (CRITICAL ERROR)
- ❌ `company` is placeholder "N/A" (CRITICAL ERROR)
- ❌ `location` is empty (CRITICAL ERROR)
- ❌ No description
- ❌ No skills (Thompson can't score!)
- ❌ No URL (user can't apply)

**Result:** This job will be rejected during validation

## Skills Extraction Guidelines

Skills are **critical** for Thompson Sampling scoring. Follow these guidelines:

### Good Skills

✅ **Technical Skills:**
- Programming languages: `"Swift"`, `"Python"`, `"JavaScript"`
- Frameworks: `"SwiftUI"`, `"React"`, `"Node.js"`
- Tools: `"Git"`, `"Docker"`, `"Xcode"`
- Technologies: `"AWS"`, `"GraphQL"`, `"REST APIs"`

✅ **Domain Skills:**
- `"iOS Development"`, `"Backend Engineering"`
- `"Machine Learning"`, `"Data Analysis"`
- `"Mobile Architecture"`, `"System Design"`

### Skills to Avoid

❌ **Too Generic:**
- `"Teamwork"`, `"Communication"`, `"Leadership"`
- `"Problem Solving"`, `"Critical Thinking"`
- `"Fast Learner"`, `"Self-Motivated"`

❌ **Too Vague:**
- `"Programming"`, `"Software"`, `"Technology"`
- `"Computer Science"`, `"Engineering"`

❌ **Duplicates:**
- `"Swift"` and `"Swift Programming"` → Use `"Swift"`
- `"React"` and `"ReactJS"` → Use `"React"`

### Skills Extraction Strategy

```swift
struct SkillsExtractor {
    // 1. Use explicit skills from API
    func extractFromAPI(_ apiJob: APIJob) -> [String] {
        return apiJob.skills ?? []
    }

    // 2. Extract from description using keyword matching
    func extractFromDescription(_ description: String) -> [String] {
        let knownSkills = loadSkillsTaxonomy()  // 1000+ technical skills
        var found: [String] = []

        for skill in knownSkills {
            if description.localizedCaseInsensitiveContains(skill) {
                found.append(skill)
            }
        }

        return found
    }

    // 3. Combine and deduplicate
    func extract(from apiJob: APIJob) -> [String] {
        var skills = Set<String>()

        // Add explicit skills
        skills.formUnion(extractFromAPI(apiJob))

        // Add extracted skills
        if let description = apiJob.description {
            skills.formUnion(extractFromDescription(description))
        }

        // Normalize (capitalize, trim)
        let normalized = skills.map { $0.trimmingCharacters(in: .whitespaces).capitalized }

        // Remove generic skills
        let filtered = normalized.filter { !isGenericSkill($0) }

        // Return top 10
        return Array(filtered.prefix(10))
    }

    private func isGenericSkill(_ skill: String) -> Bool {
        let generic = ["Teamwork", "Communication", "Leadership",
                      "Problem Solving", "Fast Learner"]
        return generic.contains(skill)
    }
}
```

## Common Data Issues

### Issue: Empty or Null Required Fields

```swift
// ❌ WRONG: Allowing nil required fields
let job = Job(
    id: nil,  // Will crash!
    title: apiJob.title,  // Could be nil!
    company: apiJob.company,  // Could be nil!
    location: apiJob.location ?? "",  // Empty string!
    ...
)

// ✅ CORRECT: Validate and skip if invalid
func adapt(_ apiJob: APIJob) -> Job? {
    guard let title = apiJob.title, !title.isEmpty else {
        print("⚠️ Skipping job with missing title")
        return nil  // Skip invalid jobs
    }

    guard let company = apiJob.company, !company.isEmpty else {
        print("⚠️ Skipping job with missing company")
        return nil
    }

    return Job(
        id: UUID(),  // Always generate fresh UUID
        title: title,
        company: company,
        location: apiJob.location?.isEmpty == false ? apiJob.location! : "Remote",
        ...
    )
}
```

### Issue: Placeholder Values

```swift
// ❌ WRONG: Allowing placeholder values
let job = Job(
    id: UUID(),
    title: apiJob.title ?? "N/A",  // Placeholder!
    company: apiJob.company ?? "Unknown",  // Placeholder!
    location: apiJob.location ?? "TBD",  // Placeholder!
    ...
)

// ✅ CORRECT: Reject jobs with placeholders
func adapt(_ apiJob: APIJob) -> Job? {
    let placeholders = ["N/A", "TBD", "Unknown", "null", "None"]

    let title = apiJob.title ?? ""
    if title.isEmpty || placeholders.contains(title) {
        return nil  // Skip job
    }

    let company = apiJob.company ?? ""
    if company.isEmpty || placeholders.contains(company) {
        return nil
    }

    // ... continue validation
}
```

### Issue: Invalid URLs

```swift
// ❌ WRONG: Not validating URLs
let job = Job(
    ...
    url: URL(string: apiJob.url ?? ""),  // Could be invalid!
    ...
)

// ✅ CORRECT: Validate URLs
func parseURL(_ urlString: String?) -> URL? {
    guard let urlString = urlString, !urlString.isEmpty else {
        return nil
    }

    guard let url = URL(string: urlString) else {
        print("⚠️ Invalid URL format: \(urlString)")
        return nil
    }

    // Validate scheme
    guard url.scheme == "http" || url.scheme == "https" else {
        print("⚠️ Invalid URL scheme: \(url.scheme ?? "none")")
        return nil
    }

    return url
}
```

## Validation Checklist

Before submitting a job source integration:

### Data Structure
- [ ] All required fields present (id, title, company, location, fetchedAt, sourceIdentifier)
- [ ] No null/nil required fields
- [ ] No empty strings in required fields
- [ ] No placeholder values (N/A, TBD, Unknown, etc.)
- [ ] UUIDs are unique and properly formatted
- [ ] Source identifier matches source name exactly

### Quality Metrics
- [ ] 80%+ jobs have descriptions >100 characters
- [ ] 80%+ jobs have 3+ technical skills
- [ ] 90%+ jobs have valid URLs
- [ ] 60%+ jobs have salary information (if available from source)

### Skills Extraction
- [ ] Skills extracted from API when available
- [ ] Skills extracted from description as fallback
- [ ] Generic skills filtered out
- [ ] 3-10 skills per job on average
- [ ] Skills properly capitalized and normalized

### Error Handling
- [ ] Invalid jobs skipped (return nil)
- [ ] Errors logged with context
- [ ] No crashes on malformed data
- [ ] Graceful degradation on missing optional fields

### Integration
- [ ] Jobs cacheable (all fields Codable)
- [ ] Jobs sendable (all fields Sendable)
- [ ] Jobs work with Thompson scoring (<10ms maintained)
- [ ] Jobs render correctly in DeckScreen UI

## Testing Your Integration

```bash
# 1. Validate data structure
./scripts/validate_job_structure.sh your_source_name 20

# 2. Check a sample job manually
swift run FetchJobs --source your_source_name --count 1 | python3 -m json.tool

# 3. Run full integration tests
./scripts/run_integration_tests.sh your_source_name

# 4. Performance test with Thompson
swift test --filter ThompsonPerformanceTests

# 5. UI rendering test
swift test --filter DeckScreenTests
```

## Reference Implementation

See `Packages/V7JobSources/Sources/V7JobSources/RemotiveJobSource.swift` for a complete, production-ready example.
