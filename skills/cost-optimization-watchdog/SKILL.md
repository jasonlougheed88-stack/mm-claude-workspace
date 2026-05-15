---
name: cost-optimization-watchdog
description: Prevents excessive AI API costs through smart caching, token optimization, and fallback strategies
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

Prevents runaway AI API costs that can quickly spiral from $50/month to $5,000/month with poor implementation. OpenAI, Anthropic, and embedding APIs charge per token - every optimization saves real money.

## Cost Reality Check

**Documented AI API costs for job search app:**
- OpenAI GPT-4: $0.03/1K input tokens, $0.06/1K output tokens
- OpenAI Embeddings: $0.0001/1K tokens
- Resume parsing: ~2,000 tokens average = $0.12/resume
- Job description analysis: ~1,500 tokens = $0.09/job
- Embeddings: ~500 tokens = $0.0005/embedding

**Without optimization:**
- 100 resumes/day × $0.12 = $12/day = $360/month
- 1,000 jobs/day × $0.09 = $90/day = $2,700/month
- **Total: $3,060/month minimum**

**With optimization (90% cache hit rate):**
- Resume parsing: $36/month (90% cached)
- Job parsing: $270/month (90% cached)
- **Total: $306/month (10× cheaper)**

## Sacred Cost Principles

1. **Cache Everything** - 90%+ hit rate saves 10× in costs
2. **Prompt Engineering** - Shorter prompts = lower costs
3. **Graceful Degradation** - Free on-device first, AI as enhancement
4. **Token Budgets** - Hard limits per user per day
5. **Batch Processing** - Reduce API calls through batching

## Activation Triggers

This skill activates when you're working on:
- `V7AIParsing/` - OpenAI resume parsing
- `V7JobParsing/` - Job description analysis
- `V7Embeddings/` - Vector embeddings
- `V7Services/` - Any external API calls
- Cost tracking or usage monitoring code

## Critical Enforcement Areas

### 1. Aggressive Caching Strategy

**Cache EVERYTHING that's repeatable:**

```swift
// ❌ WRONG: No caching (burns money)
func parseResume(_ text: String) async -> Resume {
    // $0.12 every single time, even for same resume
    return try await openAIClient.chat(messages: [
        Message(role: "system", content: systemPrompt),
        Message(role: "user", content: text)
    ])
}

// ✅ CORRECT: Aggressive caching
actor ResumeCacheService {
    private var cache: [String: CachedResume] = [:]
    private let maxCacheSize = 5000
    private let ttl: TimeInterval = 86400 * 30  // 30 days

    struct CachedResume {
        let resume: Resume
        let timestamp: Date
        let cost: Double
    }

    func parseResume(_ text: String) async -> Resume {
        let cacheKey = text.sha256Hash()

        // Check cache first
        if let cached = cache[cacheKey],
           Date().timeIntervalSince(cached.timestamp) < ttl {
            logger.info("Resume cache HIT - saved $\(String(format: "%.4f", 0.12))")
            return cached.resume
        }

        // Cache miss - call API
        logger.warning("Resume cache MISS - cost: $0.12")
        let resume = try await callOpenAI(text)

        // Store in cache
        cache[cacheKey] = CachedResume(
            resume: resume,
            timestamp: Date(),
            cost: 0.12
        )

        // Evict old entries if needed
        if cache.count > maxCacheSize {
            evictOldest()
        }

        return resume
    }

    func getCacheStats() -> CacheStats {
        let totalSavings = cache.values.reduce(0.0) { $0 + $1.cost }
        return CacheStats(
            entries: cache.count,
            estimatedSavings: totalSavings,
            hitRate: calculateHitRate()
        )
    }
}
```

### 2. Token Budget Enforcement

**Hard limits prevent runaway costs:**

```swift
// ✅ CORRECT: Per-user daily token budget
actor TokenBudgetService {
    private var dailyUsage: [UUID: DailyTokenUsage] = [:]

    struct DailyTokenUsage {
        var tokens: Int
        var cost: Double
        var date: Date
    }

    // Budget limits
    let dailyTokenLimit = 50_000      // ~$1.50/day per user
    let monthlyTokenLimit = 1_000_000  // ~$30/month per user

    func checkBudget(userId: UUID, estimatedTokens: Int) async -> BudgetStatus {
        // Reset if new day
        if let usage = dailyUsage[userId],
           !Calendar.current.isDateInToday(usage.date) {
            dailyUsage[userId] = nil
        }

        let currentUsage = dailyUsage[userId]?.tokens ?? 0
        let remaining = dailyTokenLimit - currentUsage

        if estimatedTokens > remaining {
            logger.warning("User \(userId) exceeded daily token budget")
            return .exceeded(remaining: remaining)
        }

        return .allowed(remaining: remaining - estimatedTokens)
    }

    func recordUsage(userId: UUID, tokens: Int, cost: Double) async {
        if var usage = dailyUsage[userId] {
            usage.tokens += tokens
            usage.cost += cost
            dailyUsage[userId] = usage
        } else {
            dailyUsage[userId] = DailyTokenUsage(
                tokens: tokens,
                cost: cost,
                date: Date()
            )
        }

        // Alert if approaching limit
        let currentUsage = dailyUsage[userId]!.tokens
        if Double(currentUsage) / Double(dailyTokenLimit) > 0.8 {
            logger.warning("User \(userId) at 80% of daily token budget")
        }
    }
}

// Usage:
let budgetService = TokenBudgetService()

func parseResume(_ text: String, userId: UUID) async -> Resume {
    let estimatedTokens = text.count / 4  // Rough estimate: 1 token ≈ 4 chars

    switch await budgetService.checkBudget(userId: userId, estimatedTokens: estimatedTokens) {
    case .exceeded:
        logger.warning("User exceeded budget, using free on-device parsing")
        return await parseResumeLocally(text)

    case .allowed:
        let resume = try await parseResumeWithOpenAI(text)
        let actualTokens = calculateTokens(text)
        let cost = Double(actualTokens) * 0.00003  // GPT-4 pricing
        await budgetService.recordUsage(userId: userId, tokens: actualTokens, cost: cost)
        return resume
    }
}
```

### 3. Prompt Engineering (Token Reduction)

**Shorter prompts = lower costs:**

```swift
// ❌ WRONG: Verbose prompt (3,000 tokens = $0.09)
let systemPrompt = """
You are an expert resume parser with deep knowledge of the job market, \
recruitment practices, and career development. Your task is to carefully \
analyze the provided resume text and extract relevant information including \
but not limited to: candidate name, email address, phone number, physical \
address, education history with degree names and graduation dates, work \
experience with company names, job titles, start dates, end dates, and \
detailed descriptions of responsibilities, skills both technical and soft, \
certifications, languages spoken, and any other relevant information that \
would be useful for matching the candidate to appropriate job opportunities. \
Please structure your response as a valid JSON object with the following schema...
"""

// ✅ CORRECT: Concise prompt (500 tokens = $0.015)
let systemPrompt = """
Extract: name, email, phone, education (degree, school, year), \
work history (company, title, dates), skills. JSON format.
"""

// ✅ CORRECT: Few-shot examples (better results, fewer tokens)
let systemPrompt = """
Extract resume data as JSON.

Example:
Input: "John Doe, john@email.com, MIT BS CS 2020, Google SWE 2020-2023"
Output: {"name":"John Doe","email":"john@email.com","education":[{"degree":"BS CS","school":"MIT","year":2020}],"experience":[{"company":"Google","title":"SWE","start":2020,"end":2023}]}

Now extract from:
"""
```

### 4. Batch Processing (Reduce API Calls)

**Process multiple items in one API call:**

```swift
// ❌ WRONG: Individual API calls (100 jobs = 100 API calls)
func extractSkills(_ jobs: [Job]) async -> [String: [String]] {
    var results: [String: [String]] = [:]

    for job in jobs {
        // Separate API call for each job = $$$$
        let skills = try await openAI.extractSkills(job.description)
        results[job.id] = skills
    }

    return results
}

// ✅ CORRECT: Batch processing (100 jobs = 5 API calls)
func extractSkills(_ jobs: [Job]) async -> [String: [String]] {
    let batchSize = 20  // Process 20 jobs per API call
    var results: [String: [String]] = [:]

    for batch in jobs.chunked(into: batchSize) {
        let prompt = """
        Extract skills from these job descriptions. Return JSON array.

        Jobs:
        \(batch.enumerated().map { "\($0): \($1.description)" }.joined(separator: "

"))
        """

        let batchResults = try await openAI.extractSkillsBatch(prompt)

        for (index, skills) in batchResults.enumerated() {
            results[batch[index].id] = skills
        }
    }

    return results
}
```

### 5. Embedding Deduplication

**Don't generate duplicate embeddings:**

```swift
// ❌ WRONG: Generate embedding every time
func generateEmbedding(_ text: String) async -> [Double] {
    // $0.0001 per call, adds up fast
    return try await openAI.embeddings.create(input: text)
}

// ✅ CORRECT: Deduplicate before generating
actor EmbeddingCache {
    private var cache: [String: [Double]] = [:]

    func generateEmbedding(_ text: String) async -> [Double] {
        // Normalize text to improve cache hits
        let normalized = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let cacheKey = normalized.sha256Hash()

        if let cached = cache[cacheKey] {
            logger.info("Embedding cache HIT - saved $0.0001")
            return cached
        }

        logger.warning("Embedding cache MISS - cost: $0.0001")
        let embedding = try await openAI.embeddings.create(input: text)

        cache[cacheKey] = embedding
        return embedding
    }

    // Batch embeddings for efficiency
    func generateEmbeddings(_ texts: [String]) async -> [[Double]] {
        // Check cache first
        var cachedResults: [Int: [Double]] = [:]
        var uncachedIndices: [Int] = []

        for (index, text) in texts.enumerated() {
            let normalized = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            let cacheKey = normalized.sha256Hash()

            if let cached = cache[cacheKey] {
                cachedResults[index] = cached
            } else {
                uncachedIndices.append(index)
            }
        }

        // Generate embeddings for uncached items (batched)
        if !uncachedIndices.isEmpty {
            let uncachedTexts = uncachedIndices.map { texts[$0] }
            let embeddings = try await openAI.embeddings.create(inputs: uncachedTexts)

            for (arrayIndex, originalIndex) in uncachedIndices.enumerated() {
                let text = texts[originalIndex]
                let normalized = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                let cacheKey = normalized.sha256Hash()

                cache[cacheKey] = embeddings[arrayIndex]
                cachedResults[originalIndex] = embeddings[arrayIndex]
            }

            let savedCost = Double(cachedResults.count - uncachedIndices.count) * 0.0001
            logger.info("Embedding batch: \(cachedResults.count) cached, \(uncachedIndices.count) generated - saved $\(String(format: "%.4f", savedCost))")
        }

        return texts.indices.map { cachedResults[$0]! }
    }
}
```

### 6. Free On-Device First

**Use NaturalLanguage before calling OpenAI:**

```swift
// ✅ CORRECT: 3-tier strategy (Free → Cheap → Expensive)
actor SkillExtractor {
    func extractSkills(_ jobDescription: String) async -> [String] {
        // Tier 1: Free on-device (NaturalLanguage framework)
        let localSkills = await extractSkillsLocally(jobDescription)

        // If we got good results, don't waste money on API
        if localSkills.count >= 5 {
            logger.info("On-device extraction sufficient - $0 cost")
            return localSkills
        }

        // Tier 2: Check budget before calling API
        guard await TokenBudgetService.shared.canAfford(estimatedCost: 0.05) else {
            logger.warning("Budget exhausted - using free results")
            return localSkills
        }

        // Tier 3: AI enhancement (only if budget allows)
        logger.warning("On-device insufficient, using AI - cost: $0.05")
        let aiSkills = try await extractSkillsWithAI(jobDescription)

        // Merge results
        return Array(Set(localSkills + aiSkills))
    }

    private func extractSkillsLocally(_ text: String) async -> [String] {
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text

        var skills: [String] = []

        tagger.enumerateTags(in: text.startIndex..<text.endIndex,
                            unit: .word,
                            scheme: .nameType) { tag, range in
            if tag == .organizationName {
                skills.append(String(text[range]))
            }
            return true
        }

        return skills
    }
}
```

### 7. Cost Monitoring Dashboard

**Track costs in real-time:**

```swift
// ✅ CORRECT: Real-time cost tracking
actor CostMonitoringService {
    struct DailyCosts {
        var resumeParsing: Double = 0.0
        var jobParsing: Double = 0.0
        var embeddings: Double = 0.0
        var total: Double { resumeParsing + jobParsing + embeddings }
    }

    private var dailyCosts: [Date: DailyCosts] = [:]

    func recordCost(_ cost: Double, category: CostCategory) async {
        let today = Calendar.current.startOfDay(for: Date())

        if var costs = dailyCosts[today] {
            switch category {
            case .resumeParsing:
                costs.resumeParsing += cost
            case .jobParsing:
                costs.jobParsing += cost
            case .embeddings:
                costs.embeddings += cost
            }
            dailyCosts[today] = costs
        } else {
            var costs = DailyCosts()
            switch category {
            case .resumeParsing:
                costs.resumeParsing = cost
            case .jobParsing:
                costs.jobParsing = cost
            case .embeddings:
                costs.embeddings = cost
            }
            dailyCosts[today] = costs
        }

        // Alert if daily costs exceed threshold
        let todayCosts = dailyCosts[today]!.total
        if todayCosts > 10.0 {
            logger.critical("Daily AI costs exceeded $10: $\(String(format: "%.2f", todayCosts))")
            await sendCostAlert(todayCosts)
        }
    }

    func getMonthlyCosts() -> Double {
        let calendar = Calendar.current
        let now = Date()

        return dailyCosts
            .filter { calendar.isDate($0.key, equalTo: now, toGranularity: .month) }
            .reduce(0.0) { $0 + $1.value.total }
    }

    func getCostBreakdown() -> CostBreakdown {
        let today = Calendar.current.startOfDay(for: Date())
        let costs = dailyCosts[today] ?? DailyCosts()

        return CostBreakdown(
            resumeParsing: costs.resumeParsing,
            jobParsing: costs.jobParsing,
            embeddings: costs.embeddings,
            total: costs.total
        )
    }
}
```

### 8. Smart Rate Limiting

**Prevent accidental cost spikes:**

```swift
// ✅ CORRECT: Rate limiting to prevent runaway costs
actor RateLimiter {
    private var requestTimestamps: [Date] = []
    private let maxRequestsPerMinute = 60
    private let maxRequestsPerHour = 1000

    func canMakeRequest() async -> Bool {
        let now = Date()
        let oneMinuteAgo = now.addingTimeInterval(-60)
        let oneHourAgo = now.addingTimeInterval(-3600)

        // Remove old timestamps
        requestTimestamps.removeAll { $0 < oneHourAgo }

        // Check limits
        let recentRequests = requestTimestamps.filter { $0 > oneMinuteAgo }

        if recentRequests.count >= maxRequestsPerMinute {
            logger.warning("Rate limit exceeded: \(recentRequests.count)/min")
            return false
        }

        if requestTimestamps.count >= maxRequestsPerHour {
            logger.warning("Hourly rate limit exceeded: \(requestTimestamps.count)/hour")
            return false
        }

        requestTimestamps.append(now)
        return true
    }
}

// Usage:
let rateLimiter = RateLimiter()

func parseResume(_ text: String) async -> Resume {
    guard await rateLimiter.canMakeRequest() else {
        logger.warning("Rate limited - using free on-device parsing")
        return await parseResumeLocally(text)
    }

    return try await parseResumeWithOpenAI(text)
}
```

## Cost Optimization Checklist

Before merging AI API code:

- [ ] Caching implemented (90%+ hit rate target)
- [ ] Token budget enforcement per user
- [ ] Prompt engineering (concise, few-shot)
- [ ] Batch processing where possible
- [ ] Embedding deduplication
- [ ] Free on-device tier implemented
- [ ] Cost monitoring with alerts
- [ ] Rate limiting to prevent spikes
- [ ] Cache eviction strategy (LRU)
- [ ] SHA256 hashing for cache keys
- [ ] Cost dashboard in admin UI

## When This Skill Flags Issues

I will automatically warn you if:

1. **No caching** - AI API calls without cache check
2. **Verbose prompts** - >1,000 token system prompts
3. **Individual API calls** - Should be batched
4. **No budget check** - Unlimited AI spending
5. **Duplicate embeddings** - Same text embedded twice
6. **No on-device fallback** - AI as only option
7. **Missing cost tracking** - No usage monitoring
8. **No rate limiting** - Unbounded API calls

## Reference: Cost Breakdown

```
Monthly AI Costs (1,000 active users):

WITHOUT Optimization:
├─ Resume Parsing: 100 resumes/day × $0.12 = $360/month
├─ Job Parsing: 1,000 jobs/day × $0.09 = $2,700/month
├─ Embeddings: 5,000 embeddings/day × $0.0005 = $75/month
└─ Total: $3,135/month

WITH Optimization (90% cache hit):
├─ Resume Parsing: $36/month (90% cached)
├─ Job Parsing: $270/month (90% cached)
├─ Embeddings: $7.50/month (90% cached)
└─ Total: $313.50/month

Savings: $2,821.50/month (90% reduction)
```

## Cost Optimization Strategies Summary

1. **Cache First** - Check cache before every API call
2. **Budget Hard** - Per-user daily/monthly limits
3. **Prompt Short** - Concise prompts (500 tokens max)
4. **Batch Smart** - 20-50 items per API call
5. **Dedupe Always** - Hash-based deduplication
6. **Free First** - NaturalLanguage before OpenAI
7. **Monitor Real-Time** - Alert at $10/day threshold
8. **Rate Limit** - 60/min, 1000/hour max

---

# Cost Optimization Watchdog

**Based On:**
- `/upgrade/researching/AI_IMPLEMENTATION_ANALYSIS.md` (Cost optimization strategies)
- OpenAI pricing: https://openai.com/pricing
- `/Packages/V7AIParsing/` - Resume parsing costs
- `/Packages/V7Embeddings/` - Embedding generation costs
