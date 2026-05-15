---
name: job-card-validator
description: Validates job sources produce correctly structured JobCard data that conforms to V7Thompson.Job model and renders properly in DeckScreen UI
allowed-tools:
  - Read
  - Grep
  - Glob
  - Edit
  - Write
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



## Purpose

This skill ensures all job sources (RSS feeds, Indeed, Greenhouse, Lever, etc.) produce properly structured job data that:
1. Conforms to the `V7Thompson.Job` model
2. Renders correctly in the `DeckScreen` job card UI
3. Provides all required fields for Thompson Sampling scoring
4. Maintains thread safety (Sendable compliance)
5. Follows V7 architectural patterns

## Job Card Data Model Requirements

### Core Job Model (V7Thompson.Job)

**Location**: `Packages/V7Thompson/Sources/V7Thompson/ThompsonTypes.swift`

```swift
public struct Job: Identifiable, Sendable {
    public let id: UUID                         // REQUIRED: Unique identifier
    public let title: String                    // REQUIRED: Job title
    public let company: String                  // REQUIRED: Company name
    public let location: String                 // REQUIRED: Location (default "Remote")
    public let description: String              // REQUIRED: Full job description
    public let requirements: [String]           // REQUIRED: Skills/requirements array
    public let url: URL                         // REQUIRED: Application URL (NOT placeholder)
    public var thompsonScore: ThompsonScore?    // OPTIONAL: Set by Thompson engine
    public let sector: String                   // REQUIRED: One of 14 sectors
    public var matchScore: Double               // REQUIRED: Base match (0.0-1.0)
}
```

### UI JobItem Model (V7Services.JobItem)

**Location**: `Packages/V7Services/Sources/V7Services/JobDiscoveryCoordinator.swift`

```swift
public struct JobItem: Identifiable, Sendable {
    public let id: UUID                   // REQUIRED: Maps to Job.id
    public let title: String              // REQUIRED: Job title
    public let company: String            // REQUIRED: Company name
    public let location: String           // REQUIRED: Location
    public let description: String        // REQUIRED: Description
    public let salary: String?            // OPTIONAL: Salary range
    public let isRemote: Bool             // REQUIRED: Remote flag
    public let tags: [String]             // REQUIRED: Skills tags (from requirements)
    public let thompsonScore: Double      // REQUIRED: Combined Thompson score
    public let fitScore: Double           // REQUIRED: Base fit score
}
```

### JobModel for Accessibility (V7UI.JobModel)

**Location**: `Packages/V7UI/Sources/V7UI/Accessibility/AccessibleJobCard.swift`

```swift
public struct JobModel {
    let id: String                // REQUIRED: String version of UUID
    let title: String             // REQUIRED: Job title
    let company: String           // REQUIRED: Company name
    let location: String          // REQUIRED: Location
    let salary: String?           // OPTIONAL: Salary
    let isRemote: Bool            // REQUIRED: Remote flag
    let tags: [String]            // REQUIRED: Skills tags
    let description: String       // REQUIRED: Description
}
```

---

## Required Fields Validation

### Mandatory Fields (NEVER omit)

```swift
// ✅ CORRECT: All required fields present
Job(
    id: UUID(),
    title: "Senior iOS Developer",
    company: "Apple Inc.",
    location: "Cupertino, CA",
    description: "We're looking for an experienced iOS developer...",
    requirements: ["Swift", "SwiftUI", "Combine", "iOS 18+"],
    url: URL(string: "https://jobs.apple.com/apply/12345")!,
    sector: "Technology",
    matchScore: 0.75
)

// ❌ WRONG: Missing requirements array
Job(
    id: UUID(),
    title: "Senior iOS Developer",
    company: "Apple Inc.",
    location: "Cupertino, CA",
    description: "We're looking for...",
    requirements: [],  // EMPTY - Thompson can't match skills!
    url: URL(string: "https://example.com")!,  // Placeholder URL!
    sector: "Technology",
    matchScore: 0.0
)
```

### Field Requirements

1. **title**
   - Must be non-empty
   - Should be descriptive (not just "Job Opening")
   - Max 100 characters for UI rendering
   - Example: "Senior Backend Engineer - Python/Django"

2. **company**
   - Must be non-empty
   - Should be real company name
   - Not "Unknown Company"
   - Example: "Stripe" or "GitHub"

3. **location**
   - Must be non-empty
   - Use "Remote" for fully remote
   - Use "City, State" for specific locations
   - Examples: "Remote", "San Francisco, CA", "New York, NY"

4. **description**
   - Must be non-empty
   - Minimum 100 characters recommended
   - Should include role details, responsibilities
   - Used for AI matching and cover letters

5. **requirements** (Critical for Thompson Sampling)
   - Must be non-empty array
   - Each requirement should be a skill keyword
   - Used for Thompson feature matching
   - Examples: ["Swift", "SwiftUI", "Combine", "CoreData"]

6. **url**
   - Must be valid URL
   - NEVER use placeholder URLs (https://example.com)
   - Should link to actual job application
   - Must be absolute URL with scheme

7. **sector**
   - Must be one of 14 valid sectors:
     - Technology
     - Healthcare
     - Finance
     - Education
     - Retail
     - Manufacturing
     - Transportation
     - Energy
     - Media
     - Legal
     - Real Estate
     - Hospitality
     - Agriculture
     - Government

8. **matchScore**
   - Range: 0.0 to 1.0
   - Default: 0.50 (50%)
   - Will be refined by Thompson Sampling

---

## Job Source Validation Checklist

When reviewing or creating job sources, verify:

### Architecture Compliance

- [ ] Located in `Packages/V7Services/Sources/V7Services/JobSources/`
- [ ] Conforms to `JobSource` protocol
- [ ] Implements `fetchJobs(query:limit:)` method
- [ ] Returns `[V7Thompson.Job]` array
- [ ] Marked as `actor` for thread safety (if maintains state)
- [ ] All returned types are `Sendable`

### Data Quality

- [ ] All jobs have non-empty `title`
- [ ] All jobs have non-empty `company`
- [ ] All jobs have non-empty `location`
- [ ] All jobs have `description` with ≥100 characters
- [ ] All jobs have non-empty `requirements` array (minimum 3 skills)
- [ ] All jobs have valid, non-placeholder `url`
- [ ] All jobs have valid `sector` from approved list
- [ ] All jobs have `matchScore` between 0.0 and 1.0

### Thompson Sampling Integration

- [ ] `requirements` array properly populated for skill matching
- [ ] `sector` correctly categorizes job
- [ ] `matchScore` initialized (will be refined by Thompson)
- [ ] No hardcoded Thompson scores (let engine calculate)

### Performance

- [ ] Implements rate limiting (max 200 req/hour for APIs)
- [ ] Implements caching (24-hour TTL minimum)
- [ ] Implements circuit breaker for external APIs
- [ ] Fetch completes in <3s for company APIs, <2s for RSS
- [ ] Returns reasonable batch size (20-50 jobs)

---

## Common Job Source Violations

### ❌ VIOLATION 1: Empty Requirements Array

```swift
// ❌ WRONG
Job(
    // ... other fields ...
    requirements: [],  // Thompson can't match skills!
    // ...
)

// ✅ CORRECT
Job(
    // ... other fields ...
    requirements: [
        "Python", "Django", "PostgreSQL",
        "Redis", "Docker", "AWS"
    ],
    // ...
)
```

**Why it matters**: Thompson Sampling needs skills to calculate match scores. Empty requirements = no personalized matching.

---

### ❌ VIOLATION 2: Placeholder URLs

```swift
// ❌ WRONG
Job(
    // ... other fields ...
    url: URL(string: "https://example.com")!,  // Placeholder!
    // ...
)

// ✅ CORRECT
Job(
    // ... other fields ...
    url: URL(string: "https://jobs.stripe.com/apply/senior-backend-engineer")!,
    // ...
)
```

**Why it matters**: Users can't apply. "Apply Now" button will fail.

---

### ❌ VIOLATION 3: Generic Company Names

```swift
// ❌ WRONG
Job(
    company: "Unknown Company",  // Useless
    // ...
)

// ✅ CORRECT
Job(
    company: "Stripe",  // Real company
    // ...
)
```

**Why it matters**: Users need to know who they're applying to. Brand recognition affects decision-making.

---

### ❌ VIOLATION 4: Short/Missing Description

```swift
// ❌ WRONG
Job(
    description: "Great job!",  // Too short
    // ...
)

// ✅ CORRECT
Job(
    description: """
    We're seeking a Senior Backend Engineer to join our Payments Platform team.
    You'll work on high-throughput distributed systems processing billions of
    transactions annually. Key responsibilities include designing scalable APIs,
    optimizing database queries, and mentoring junior engineers.

    Requirements:
    - 5+ years Python/Django experience
    - Strong SQL and NoSQL database skills
    - Experience with AWS or GCP
    - Excellent communication skills
    """,
    // ...
)
```

**Why it matters**: AI uses description for cover letter generation and match scoring. Short descriptions = poor results.

---

### ❌ VIOLATION 5: Invalid Sector

```swift
// ❌ WRONG
Job(
    sector: "Tech",  // Not in approved list
    // ...
)

// ✅ CORRECT
Job(
    sector: "Technology",  // Exact match from approved list
    // ...
)
```

**Why it matters**: Sector filtering and bias detection rely on exact sector names.

---

### ❌ VIOLATION 6: Non-Sendable Types

```swift
// ❌ WRONG
class JobData {  // Not Sendable
    var title: String
    var company: String
}

// ✅ CORRECT
struct Job: Sendable {  // Sendable struct
    let title: String
    let company: String
}
```

**Why it matters**: Swift 6 strict concurrency requires Sendable for cross-actor data transfer.

---

## Job Source Implementation Pattern

### Correct Job Source Structure

```swift
// File: Packages/V7Services/Sources/V7Services/JobSources/ExampleJobSource.swift

import Foundation
import V7Thompson
import V7Core

/// Example job source implementation
actor ExampleJobSource: JobSource {
    public let identifier = "example_job_source"
    public let displayName = "Example Job Site"
    public let supportedSectors: [String] = ["Technology", "Healthcare"]

    // Rate limiting
    private var requestCount = 0
    private var rateLimitResetTime = Date()
    private let maxRequestsPerHour = 200

    // Caching
    private var cache: [String: (jobs: [Job], timestamp: Date)] = [:]
    private let cacheTTL: TimeInterval = 86400  // 24 hours

    public func fetchJobs(query: JobSearchQuery, limit: Int) async throws -> [Job] {
        // Check rate limit
        try await checkRateLimit()

        // Check cache
        if let cached = getCachedJobs(for: query) {
            return Array(cached.prefix(limit))
        }

        // Fetch from API
        let rawJobs = try await fetchFromAPI(query: query)

        // Convert to V7Thompson.Job with ALL required fields
        let jobs = rawJobs.map { rawJob in
            Job(
                id: UUID(),
                title: rawJob.title,  // ✅ Real title
                company: rawJob.company,  // ✅ Real company
                location: rawJob.location.isEmpty ? "Remote" : rawJob.location,
                description: rawJob.description,  // ✅ Full description
                requirements: parseSkills(from: rawJob.description),  // ✅ Extract skills
                url: URL(string: rawJob.applyUrl) ?? URL(string: "https://example.com")!,
                sector: determineSector(from: rawJob.category),  // ✅ Map to valid sector
                matchScore: 0.50  // ✅ Default score (Thompson will refine)
            )
        }

        // Cache results
        cacheJobs(jobs, for: query)

        return Array(jobs.prefix(limit))
    }

    // Helper: Parse skills from description
    private func parseSkills(from description: String) -> [String] {
        // Extract skills using keyword matching
        let skillKeywords = [
            "Swift", "SwiftUI", "Combine", "CoreData",
            "Python", "Django", "PostgreSQL", "Redis",
            "JavaScript", "React", "Node.js", "TypeScript"
        ]

        return skillKeywords.filter { skill in
            description.localizedCaseInsensitiveContains(skill)
        }
    }

    // Helper: Map category to valid sector
    private func determineSector(from category: String) -> String {
        let mapping: [String: String] = [
            "tech": "Technology",
            "healthcare": "Healthcare",
            "finance": "Finance",
            // ... more mappings
        ]

        return mapping[category.lowercased()] ?? "Technology"
    }
}
```

---

## Validation Commands

### Check Job Source Implementation

```bash
# Find all job sources
find Packages/V7Services/Sources/V7Services/JobSources -name "*.swift"

# Check for required protocol conformance
grep -r "JobSource" Packages/V7Services/Sources/V7Services/JobSources/

# Verify Sendable conformance
grep -r "Sendable" Packages/V7Services/Sources/V7Services/JobSources/
```

### Test Job Data Quality

```swift
// Test job validation
func validateJob(_ job: Job) -> [String] {
    var violations: [String] = []

    if job.title.isEmpty {
        violations.append("Empty title")
    }

    if job.company.isEmpty || job.company == "Unknown Company" {
        violations.append("Invalid company name")
    }

    if job.description.count < 100 {
        violations.append("Description too short (<100 chars)")
    }

    if job.requirements.isEmpty {
        violations.append("Empty requirements array - Thompson can't match!")
    }

    if job.url.absoluteString.contains("example.com") {
        violations.append("Placeholder URL detected")
    }

    let validSectors = [
        "Technology", "Healthcare", "Finance", "Education",
        "Retail", "Manufacturing", "Transportation", "Energy",
        "Media", "Legal", "Real Estate", "Hospitality",
        "Agriculture", "Government"
    ]

    if !validSectors.contains(job.sector) {
        violations.append("Invalid sector: \(job.sector)")
    }

    if job.matchScore < 0.0 || job.matchScore > 1.0 {
        violations.append("Match score out of range: \(job.matchScore)")
    }

    return violations
}
```

---

## Usage

This skill automatically activates when:

1. **Creating new job sources**
   - Validates JobSource protocol conformance
   - Checks all required fields are populated
   - Verifies data quality standards

2. **Reviewing existing job sources**
   - Scans for common violations
   - Suggests fixes for invalid data
   - Validates against Job model schema

3. **Debugging job card rendering issues**
   - Checks if job data matches UI expectations
   - Identifies missing optional fields affecting display
   - Validates accessibility requirements

4. **Testing job source integration**
   - Ensures Thompson Sampling can score jobs
   - Verifies all required fields for UI rendering
   - Checks Sendable compliance for concurrency

---

## Sacred Job Card UI Constraints

### Card Dimensions (from DeckScreen.swift)

```swift
// SACRED - NEVER CHANGE
enum Card {
    static let widthRatio: CGFloat = 0.92       // 92% screen width
    static let heightRatio: CGFloat = 0.85      // 85% screen height
    static let maxWidth: CGFloat = 520          // Maximum card width
    static let maxHeight: CGFloat = 750         // Maximum card height
    static let cornerRadius: CGFloat = 24       // Corner radius
}
```

### Text Truncation Limits

```swift
// Job title: Max 2 lines
Text(job.title)
    .lineLimit(2)

// Job description: Max 6 lines on card
Text(job.description)
    .lineLimit(6)

// Tags: Show first 5 only
ForEach(job.tags.prefix(5), id: \.self) { tag in
    skillTag(tag)
}
```

### Required UI Fields

For proper rendering in `JobCardView`:
- `title` - Displays in header
- `company` - Displays below title
- `location` - Displays with location icon
- `salary` (optional) - Displays with dollar icon if present
- `description` - Displays in body (truncated to 6 lines)
- `thompsonScore` - Displays as "X% Match" badge
- `fitScore` - Displays as "Base: X%" if different from Thompson score
- `tags`/`requirements` - Displays as skill pills (first 5)

---

## Auto-Fix Suggestions

When violations are found, this skill provides automatic fixes:

### Fix 1: Empty Requirements

```swift
// Before
requirements: []

// Auto-fix: Parse from description
requirements: parseSkillsFromDescription(job.description)

func parseSkillsFromDescription(_ text: String) -> [String] {
    // Use SkillTaxonomy from V7Core
    let skillTaxonomy = SkillTaxonomy.shared
    return skillTaxonomy.extractSkills(from: text)
}
```

### Fix 2: Invalid Sector

```swift
// Before
sector: "Tech"

// Auto-fix: Map to valid sector
sector: mapToValidSector("Tech")  // Returns "Technology"
```

### Fix 3: Placeholder URL

```swift
// Before
url: URL(string: "https://example.com")!

// Auto-fix: Generate company careers page
url: generateCareersURL(company: job.company)

func generateCareersURL(company: String) -> URL {
    // Try common patterns
    let domain = company.lowercased().replacingOccurrences(of: " ", with: "")
    return URL(string: "https://\(domain).com/careers")
        ?? URL(string: "https://google.com/search?q=\(company)+careers")!
}
```

---

## Key Takeaways

1. **All job sources MUST populate `requirements` array** - Thompson Sampling depends on it
2. **Never use placeholder URLs** - "Apply Now" button must work
3. **Validate sector against approved list** - Bias detection needs exact matches
4. **Ensure descriptions are ≥100 chars** - AI cover letter generation needs context
5. **All data must be Sendable** - Swift 6 strict concurrency requirement
6. **Follow V7 package dependency rules** - JobSources are in V7Services, depend on V7Thompson and V7Core

---

**Last Updated**: January 2025
**Codebase Version**: V7 (Phase 3A.3 - Career Discovery Integration)
**Based On**: ThompsonTypes.swift, DeckScreen.swift, AccessibleJobCard.swift, INTEGRATION_GUIDE.md
