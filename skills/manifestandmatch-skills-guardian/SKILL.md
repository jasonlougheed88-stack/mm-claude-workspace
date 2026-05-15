---
name: manifestandmatch-skills-guardian
description: Enforces ManifestAndMatchV7 skills system patterns - ensures proper SkillTaxonomy, EnhancedSkillsMatcher, SkillsDatabase, and Thompson integration
allowed-tools:
  - Read
  - Grep
  - Edit
  - Write
  - Glob
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



# ManifestAndMatch Skills System Guardian

## Purpose

This skill ensures all code working with the ManifestAndMatchV7 skills system follows established patterns, maintains data flow integrity, and preserves the high-performance fuzzy matching architecture.

When writing ANY code that touches skills (extraction, matching, scoring, UI), this skill automatically activates to:
- ✅ Enforce skills system architecture patterns
- ✅ Validate data flow connections
- ✅ Ensure EnhancedSkillsMatcher usage is correct
- ✅ Maintain <10ms Thompson budget
- ✅ Prevent skills-related regressions
- ✅ Guide proper taxonomy integration

---

## Skills System Architecture (Sacred Knowledge)

### The 9 Core Components

```
1. SkillTaxonomy.json        → Foundation (200+ skills with aliases)
2. SkillTaxonomy.swift        → Loader with O(1) lookups
3. EnhancedSkillsMatcher      → 4-tier fuzzy matching
4. SkillsExtractor            → Resume skill extraction
5. JobSkillsExtractor         → Job requirement extraction (NLP)
6. SkillsDatabase             → Dynamic sector-diverse loading (actor)
7. SkillsReviewStepView       → User skill selection UI
8. ProfileConverter           → Role → skills conversion
9. OptimizedThompsonEngine    → ML scoring integration
```

### Sacred Data Flow (Never Break This)

```
ONBOARDING FLOW:
Resume → SkillsExtractor → ParsedResume.skills → SkillsReviewStepView
→ User Selection → AppState.userProfile.skills → UserDefaults → ProfileManager

JOB INGESTION FLOW:
Job Description → JobSkillsExtractor (NLP + Keywords + Sections)
→ ParsedJobMetadata(extractedSkills, requiredSkills, preferredSkills)
→ Job.requirements

MATCHING FLOW:
UserProfile.skills + Job.requirements → EnhancedSkillsMatcher.calculateMatchScore()
→ 4-Tier Fuzzy Match → Match Score [0.0-1.0]
→ OptimizedThompsonEngine → Thompson Sampling
→ job.thompsonScore → Sorted Jobs → DeckScreen
```

**CRITICAL**: Never bypass these flows or create alternative skill storage mechanisms.

---

## Pattern 1: Loading SkillTaxonomy

### ✅ CORRECT: Use SkillTaxonomyLoader (Actor-Based)

```swift
// In any package that needs taxonomy access
import V7Core

// Async loading with caching
let loader = SkillTaxonomyLoader()
let taxonomy = try await loader.loadTaxonomy()

// Access canonical skills
let canonical = taxonomy.getCanonical("JS")  // Returns: "JavaScript"

// Check synonyms
let areSame = taxonomy.areSynonyms("PostgreSQL", "Postgres")  // true

// Get skill weight for scoring
let weight = taxonomy.getWeight("Machine Learning")  // 1.0

// Get skill category
if let category = taxonomy.getCategory(for: "Swift") {
    print(category.name)  // "Programming Languages"
}
```

### ❌ WRONG: Hardcoding Skills or Creating Custom Loaders

```swift
// ❌ DON'T DO THIS - Bypasses taxonomy
let skills = ["Swift", "Python", "JavaScript"]

// ❌ DON'T DO THIS - Custom JSON loading
let url = Bundle.main.url(forResource: "MySkills", withExtension: "json")

// ❌ DON'T DO THIS - Synchronous blocking
let taxonomy = try SkillTaxonomyLoader().loadTaxonomy()  // Missing await!
```

---

## Pattern 2: EnhancedSkillsMatcher Integration

### ✅ CORRECT: Initialize and Use Matcher Properly

```swift
import V7Core

// Option 1: Load from bundle (recommended)
let matcher = try await EnhancedSkillsMatcher.loadFromBundle()

// Calculate match score
let score = await matcher.calculateMatchScore(
    userSkills: ["Swift", "iOS", "SwiftUI"],
    jobRequirements: ["Swift", "Mobile Development", "UI"]
)
// Returns: ~0.85 (high match with synonym awareness)

// For batch processing: precompute user skills ONCE
let normalizedUserSkills = matcher.precomputeUserSkills(userProfile.skills)
for job in jobs {
    let score = await matcher.calculateMatchScore(
        userSkills: normalizedUserSkills,  // Already normalized
        jobRequirements: job.requirements
    )
}
```

### ❌ WRONG: Simple String Matching

```swift
// ❌ DON'T DO THIS - No synonym awareness
let matches = userSkills.filter { jobRequirements.contains($0) }

// ❌ DON'T DO THIS - Recreating matcher in loop
for job in jobs {
    let matcher = try await EnhancedSkillsMatcher.loadFromBundle()  // BAD!
    let score = await matcher.calculateMatchScore(...)
}
```

---

## Pattern 3: SkillsDatabase Access (Sector-Diverse)

### ✅ CORRECT: Actor-Based Async Access

```swift
import V7JobParsing

// Access all skills (async)
let allSkills = await SkillsDatabase.shared.technicalSkills

// Get skills by category
let healthcareSkills = await SkillsDatabase.shared.getSkills(category: "Healthcare")

// Search for skills
let nursingSkills = await SkillsDatabase.shared.findSkills(matching: "nursing")

// Check if skill exists
let exists = await SkillsDatabase.shared.containsSkill("Python")
```

### ❌ WRONG: Synchronous or Hardcoded Access

```swift
// ❌ DON'T DO THIS - Hardcoded tech-only skills
let skills = ["Python", "Java", "JavaScript"]

// ❌ DON'T DO THIS - Not using actor isolation
let skills = SkillsDatabase.shared.technicalSkills  // Missing await!
```

---

## Performance Budget Enforcement

### Sacred Constraint: <10ms Thompson Scoring Per Job

```swift
// ✅ ALWAYS validate performance in scoring code
let startTime = CFAbsoluteTimeGetCurrent()
let scoredJobs = await thompsonEngine.scoreJobs(jobs, userProfile: profile)
let duration = CFAbsoluteTimeGetCurrent() - startTime
let avgPerJob = (duration * 1000) / Double(jobs.count)

assert(avgPerJob < 10.0, "Thompson budget violated: \(avgPerJob)ms per job")
```

### EnhancedSkillsMatcher Target: <0.5ms

```swift
let startTime = CFAbsoluteTimeGetCurrent()
let score = await matcher.calculateMatchScore(userSkills, jobRequirements)
let duration = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
assert(duration < 0.5, "Matcher budget exceeded: \(duration)ms")
```

---

## Common Pitfalls to Avoid

### 1. Bypassing EnhancedSkillsMatcher
**Problem**: Using simple string matching
**Impact**: 35-40% false negative rate
**Solution**: Always use `EnhancedSkillsMatcher.calculateMatchScore()`

### 2. Hardcoding Skills
**Problem**: Creating custom skill lists
**Impact**: Missing synonyms, outdated skills, tech bias
**Solution**: Load from SkillTaxonomy.json or SkillsDatabase

### 3. Synchronous SkillsDatabase Access
**Problem**: Missing `await`
**Impact**: Thread blocking, potential deadlocks
**Solution**: Always `await SkillsDatabase.shared.technicalSkills`

### 4. Not Precomputing for Batches
**Problem**: Normalizing user skills for every job
**Impact**: Wasted CPU cycles, slower scoring
**Solution**: Call `matcher.precomputeUserSkills()` before batch

---

## Code Review Checklist

Before committing skills-related code, verify:

### Skills System Integrity
- [ ] SkillTaxonomy used for all skill normalization
- [ ] EnhancedSkillsMatcher used for all fuzzy matching
- [ ] SkillsDatabase accessed via actor (await)
- [ ] JobSkillsExtractor used for job requirement parsing
- [ ] SkillsExtractor used for resume skill extraction

### Performance
- [ ] Thompson operations maintain <10ms budget
- [ ] Matcher operations target <0.5ms
- [ ] User skills precomputed for batch processing
- [ ] Proper caching used (SmartThompsonCache)

### Data Flow
- [ ] Resume skills flow through SkillsReviewStepView
- [ ] User selections saved to AppState + UserDefaults
- [ ] Job skills extracted with required/preferred classification
- [ ] Thompson engine receives proper UserProfile.skills

---

## Auto-Fix Examples

### Example 1: Wrong Matcher Usage

```swift
// ❌ WRONG:
let score = Double(userSkills.intersection(jobSkills).count) / Double(jobSkills.count)

// ✅ FIXED:
let matcher = try await EnhancedSkillsMatcher.loadFromBundle()
let score = await matcher.calculateMatchScore(
    userSkills: userSkills,
    jobRequirements: jobRequirements
)
```

### Example 2: Wrong Database Access

```swift
// ❌ WRONG:
let skills = ["Python", "Java", "JavaScript"]

// ✅ FIXED:
let skills = await SkillsDatabase.shared.technicalSkills
```

### Example 3: Wrong Thompson Integration

```swift
// ❌ WRONG:
for job in jobs {
    let matcher = try await EnhancedSkillsMatcher.loadFromBundle()
    let score = await matcher.calculateMatchScore(...)
    job.score = score
}

// ✅ FIXED:
let thompsonEngine = try await OptimizedThompsonEngine()
let scoredJobs = await thompsonEngine.scoreJobs(jobs, userProfile: userProfile)
```

---

**Last Updated**: October 24, 2025
**Based On**: Complete skills system audit (200+ V7 components verified)
**Coverage**: All 9 core skills components + data flows + performance requirements
