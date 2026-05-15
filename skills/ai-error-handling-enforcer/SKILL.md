---
name: ai-error-handling-enforcer
description: Prevents AI parsing failures from breaking the app and enforces robust error recovery patterns
allowed-tools:
  - Read
  - Grep
  - Edit
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

Ensures that AI-powered features (resume parsing, job description analysis, embeddings) fail gracefully without breaking the user experience. AI models are unreliable by nature - this skill enforces defensive programming patterns.

## The Problem (Documented)

**AI parsing bugs identified in V6:**
- Cosine similarity crash on line 169 (accessing index out of bounds)
- OpenAI rate limit errors causing app freezes
- Resume parsing failures silently returning empty results
- Embedding generation timeouts blocking UI
- No fallback when AI services are unavailable

**Result**: App becomes unusable when AI features fail

## Sacred Principle

**NEVER TRUST AI OUTPUTS** - Always validate, sanitize, and provide fallbacks. AI features should enhance the experience, not break it.

## Activation Triggers

This skill activates when you're working on:
- `V7AIParsing/` - Resume parsing with OpenAI
- `V7JobParsing/` - Job description analysis with NaturalLanguage
- `V7Embeddings/` - Vector embedding generation
- `V7Services/` - API integrations with external AI services
- Any code that calls OpenAI, Anthropic, or other AI APIs

## Critical Enforcement Areas

### 1. Always Validate AI Outputs

**NEVER trust AI responses without validation:**

```swift
// ❌ WRONG: Blind trust in AI output
func parseResume(_ text: String) async -> Resume {
    let response = try await openAIClient.chat(messages: [...])
    let resume = try JSONDecoder().decode(Resume.self, from: response.data)
    return resume  // DANGEROUS: Could be malformed
}

// ✅ CORRECT: Validate before returning
func parseResume(_ text: String) async -> Resume {
    do {
        let response = try await openAIClient.chat(messages: [...])

        // Validate response structure
        guard let data = response.data,
              !data.isEmpty else {
            logger.warning("Empty AI response, returning fallback")
            return Resume.emptyFallback()
        }

        // Attempt decode with validation
        let resume = try JSONDecoder().decode(Resume.self, from: data)

        // Validate required fields
        guard resume.isValid() else {
            logger.warning("Invalid resume structure: \(resume)")
            return Resume.emptyFallback()
        }

        return resume

    } catch {
        logger.error("Resume parsing failed: \(error)")
        return Resume.emptyFallback()
    }
}
```

### 2. Implement Fallback Strategies

**Every AI feature must have a non-AI fallback:**

```swift
// ✅ CORRECT: Multi-tier fallback strategy
actor SkillExtractor {
    // Tier 1: AI-powered extraction (best results)
    func extractSkills(_ jobDescription: String) async -> [String] {
        do {
            return try await extractSkillsWithAI(jobDescription)
        } catch AIError.rateLimitExceeded {
            logger.warning("AI rate limit, falling back to NaturalLanguage")
            return await extractSkillsWithNL(jobDescription)
        } catch {
            logger.error("AI extraction failed: \(error)")
            return await extractSkillsWithNL(jobDescription)
        }
    }

    // Tier 2: NaturalLanguage framework (good results, always available)
    private func extractSkillsWithNL(_ text: String) async -> [String] {
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text

        var skills: [String] = []
        tagger.enumerateTags(in: text.startIndex..<text.endIndex,
                            unit: .word,
                            scheme: .nameType) { tag, range in
            if tag == .personalName || tag == .organizationName {
                skills.append(String(text[range]))
            }
            return true
        }

        // Tier 3: Regex-based extraction (basic, always works)
        if skills.isEmpty {
            logger.warning("NaturalLanguage returned empty, using regex")
            return extractSkillsWithRegex(text)
        }

        return skills
    }

    // Tier 3: Regex fallback (crude but reliable)
    private func extractSkillsWithRegex(_ text: String) -> [String] {
        let skillPatterns = [
            "Swift", "Python", "JavaScript", "React", "AWS",
            "Microsoft Office", "Customer Service", "Sales"
        ]

        return skillPatterns.filter { text.localizedCaseInsensitiveContains($0) }
    }
}
```

### 3. Rate Limiting and Circuit Breakers

**Prevent AI API abuse and cascading failures:**

```swift
// ✅ CORRECT: Circuit breaker pattern for AI services
actor AICircuitBreaker {
    private var failureCount: Int = 0
    private var lastFailureTime: Date?
    private let maxFailures = 5
    private let resetInterval: TimeInterval = 60.0  // 1 minute

    enum CircuitState {
        case closed   // Normal operation
        case open     // Too many failures, stop calling AI
        case halfOpen // Testing if service recovered
    }

    private var state: CircuitState = .closed

    func execute<T>(_ operation: () async throws -> T,
                    fallback: () async -> T) async -> T {
        // Check if circuit should reset
        if let lastFailure = lastFailureTime,
           Date().timeIntervalSince(lastFailure) > resetInterval {
            state = .halfOpen
            failureCount = 0
        }

        // If circuit is open, use fallback immediately
        guard state != .open else {
            logger.warning("Circuit breaker OPEN, using fallback")
            return await fallback()
        }

        // Attempt operation
        do {
            let result = try await operation()

            // Success: Reset circuit
            if state == .halfOpen {
                state = .closed
                failureCount = 0
            }

            return result

        } catch {
            logger.error("AI operation failed: \(error)")

            // Record failure
            failureCount += 1
            lastFailureTime = Date()

            // Open circuit if too many failures
            if failureCount >= maxFailures {
                state = .open
                logger.critical("Circuit breaker OPENED after \(failureCount) failures")
            }

            return await fallback()
        }
    }
}

// Usage:
let circuitBreaker = AICircuitBreaker()

func parseJobDescription(_ text: String) async -> ParsedJob {
    await circuitBreaker.execute(
        { try await parseWithAI(text) },
        fallback: { await parseWithNL(text) }
    )
}
```

### 4. Timeout Protection

**Never let AI calls block indefinitely:**

```swift
// ✅ CORRECT: Timeout enforcement
func callAIWithTimeout<T>(
    timeout: TimeInterval = 10.0,
    operation: @escaping () async throws -> T
) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        // Add operation task
        group.addTask {
            try await operation()
        }

        // Add timeout task
        group.addTask {
            try await Task.sleep(for: .seconds(timeout))
            throw AIError.timeout
        }

        // Return first result (either success or timeout)
        let result = try await group.next()!

        // Cancel remaining tasks
        group.cancelAll()

        return result
    }
}

// Usage:
func generateEmbedding(_ text: String) async -> [Double] {
    do {
        return try await callAIWithTimeout(timeout: 5.0) {
            try await openAIClient.embeddings.create(input: text)
        }
    } catch AIError.timeout {
        logger.warning("Embedding generation timed out after 5s")
        return Array(repeating: 0.0, count: 1536)  // Zero vector fallback
    } catch {
        logger.error("Embedding generation failed: \(error)")
        return Array(repeating: 0.0, count: 1536)
    }
}
```

### 5. Cosine Similarity Safety

**Critical fix for documented line 169 crash:**

```swift
// ❌ WRONG: Unsafe array access (line 169 crash)
func cosineSimilarity(_ a: [Double], _ b: [Double]) -> Double {
    var dotProduct = 0.0
    for i in 0..<a.count {
        dotProduct += a[i] * b[i]  // CRASH: Index out of bounds if b.count < a.count
    }
    // ...
}

// ✅ CORRECT: Safe bounds checking
func cosineSimilarity(_ a: [Double], _ b: [Double]) -> Double? {
    // Validate inputs
    guard !a.isEmpty, !b.isEmpty else {
        logger.warning("Empty vectors in cosine similarity")
        return nil
    }

    guard a.count == b.count else {
        logger.error("Vector dimension mismatch: \(a.count) vs \(b.count)")
        return nil
    }

    // Safe calculation
    var dotProduct = 0.0
    var magnitudeA = 0.0
    var magnitudeB = 0.0

    for i in 0..<a.count {
        dotProduct += a[i] * b[i]
        magnitudeA += a[i] * a[i]
        magnitudeB += b[i] * b[i]
    }

    let denominator = sqrt(magnitudeA) * sqrt(magnitudeB)

    // Avoid division by zero
    guard denominator > 0.0 else {
        logger.warning("Zero magnitude vector in cosine similarity")
        return nil
    }

    return dotProduct / denominator
}
```

### 6. OpenAI Error Handling

**Handle all OpenAI-specific errors:**

```swift
// ✅ CORRECT: Comprehensive OpenAI error handling
enum AIError: Error {
    case rateLimitExceeded(retryAfter: Int)
    case invalidAPIKey
    case contextLengthExceeded
    case timeout
    case invalidResponse
    case serverError(statusCode: Int)
}

func callOpenAI<T>(
    request: @escaping () async throws -> T,
    retries: Int = 3
) async throws -> T {
    var lastError: Error?

    for attempt in 0..<retries {
        do {
            return try await request()

        } catch let error as URLError where error.code == .timedOut {
            logger.warning("OpenAI timeout (attempt \(attempt + 1)/\(retries))")
            lastError = AIError.timeout
            try await Task.sleep(for: .seconds(pow(2.0, Double(attempt))))  // Exponential backoff

        } catch let error as URLError where error.code == .notConnectedToInternet {
            logger.error("No internet connection")
            throw AIError.serverError(statusCode: 0)

        } catch {
            // Check for rate limit (HTTP 429)
            if let httpError = error as? HTTPError,
               httpError.statusCode == 429 {
                let retryAfter = httpError.retryAfter ?? 60
                logger.warning("Rate limit exceeded, retry after \(retryAfter)s")
                throw AIError.rateLimitExceeded(retryAfter: retryAfter)
            }

            // Check for context length (HTTP 400)
            if let httpError = error as? HTTPError,
               httpError.statusCode == 400,
               httpError.message?.contains("context_length_exceeded") == true {
                logger.error("Context length exceeded")
                throw AIError.contextLengthExceeded
            }

            lastError = error
        }
    }

    throw lastError ?? AIError.invalidResponse
}
```

### 7. Progressive Enhancement Pattern

**AI features should be optional enhancements:**

```swift
// ✅ CORRECT: AI as optional enhancement
struct JobRecommendation {
    let job: Job
    let baseScore: Double           // Always available (Thompson Sampling)
    let aiEnhancedScore: Double?    // Optional AI enhancement
    let aiSkillMatch: [String]?     // Optional AI-extracted skills

    var displayScore: Double {
        aiEnhancedScore ?? baseScore  // Fall back to base score
    }

    var displaySkills: [String] {
        aiSkillMatch ?? job.skills    // Fall back to job's own skills
    }
}

// AI enhancement doesn't block core functionality
func recommendJobs(_ profile: UserProfile) async -> [JobRecommendation] {
    // Step 1: Get base recommendations (Thompson Sampling - ALWAYS WORKS)
    let baseRecommendations = await thompsonEngine.scoreJobs(allJobs)

    // Step 2: Attempt AI enhancement (OPTIONAL)
    let enhanced = await baseRecommendations.concurrentMap { job in
        let aiScore: Double?
        let aiSkills: [String]?

        do {
            // Try AI enhancement with timeout
            aiScore = try await callAIWithTimeout(timeout: 2.0) {
                try await enhanceScoreWithAI(job, profile)
            }
            aiSkills = try await extractSkillsWithAI(job.description)
        } catch {
            logger.warning("AI enhancement failed for job \(job.id): \(error)")
            aiScore = nil
            aiSkills = nil
        }

        return JobRecommendation(
            job: job.job,
            baseScore: job.score,
            aiEnhancedScore: aiScore,
            aiSkillMatch: aiSkills
        )
    }

    return enhanced
}
```

## AI Error Handling Checklist

Before merging AI-related code:

- [ ] All AI outputs validated before use
- [ ] Fallback strategy implemented (AI → NaturalLanguage → Regex)
- [ ] Circuit breaker pattern for external AI APIs
- [ ] Timeout protection (5-10 seconds max)
- [ ] Rate limiting enforcement
- [ ] Cosine similarity bounds checking
- [ ] OpenAI error handling (429, 400, timeouts)
- [ ] Progressive enhancement (AI is optional)
- [ ] Empty/nil checks on all arrays
- [ ] Zero-division checks in calculations
- [ ] Logging for debugging failures

## When This Skill Flags Issues

I will automatically warn you if:

1. **Direct AI output usage** - Using AI response without validation
2. **Missing fallbacks** - No non-AI alternative provided
3. **Unsafe array access** - Cosine similarity without bounds checking
4. **No timeout** - AI calls that could block indefinitely
5. **Missing circuit breaker** - External API calls without failure protection
6. **Blocking UI** - AI operations on @MainActor
7. **No error logging** - Silent failures

## Reference: 3-Tier Fallback Strategy

For every AI feature:

```
Tier 1: AI-Powered (OpenAI, Anthropic)
├─ Best quality results
├─ Highest latency (2-10 seconds)
├─ Can fail (rate limits, timeouts)
└─ Fallback to Tier 2 on failure

Tier 2: NaturalLanguage Framework (On-Device)
├─ Good quality results
├─ Low latency (<100ms)
├─ Always available
└─ Fallback to Tier 3 if empty results

Tier 3: Regex/Rules-Based (On-Device)
├─ Basic quality results
├─ Minimal latency (<10ms)
├─ Never fails
└─ Always returns something useful
```

---

# AI Error Handling Enforcer

**Based On:**
- `/upgrade/researching/AI_IMPLEMENTATION_ANALYSIS.md` (Line 169 cosine similarity crash)
- `/upgrade/researching/CRITICAL_FIXES_IMPLEMENTATION_GUIDE.md` (Rate limiting, error handling)
- `/Packages/V7AIParsing/` - Resume parsing implementation
- `/Packages/V7JobParsing/` - Job description analysis
- `/Packages/V7Embeddings/` - Vector embedding generation
