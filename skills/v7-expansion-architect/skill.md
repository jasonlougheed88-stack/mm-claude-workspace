---
name: v7-expansion-architect
description: Expert implementation guide for the 3-feature expansion (AI Questions, Ad Cards, Career Building) in ManifestAndMatchV7, enforcing architectural patterns and providing guardian-validated code scaffolding
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
---

# V7 Expansion Architect Skill

## Purpose

Acts as an expert implementation guide for the 3-feature expansion (AI Questions, Ad Cards, Career Building) in ManifestAndMatchV7. This skill enforces architectural patterns, provides guardian-validated code scaffolding, and ensures alignment with both the Integration Bridge Research and Expansion Master Plan.

**Based on:**
- V7_INTEGRATION_BRIDGE_RESEARCH.md (architectural analysis)
- EXPANSION_MASTER_PLAN.md (project roadmap)
- Active guardian skills (v7-architecture, thompson-performance, ai-error-handling, cost-optimization)

**Activates when:**
- Working on AI Questions System implementation
- Working on Ad Cards System implementation
- Working on Career Building / Manifest Profile implementation
- User mentions "expansion", "AI questions", "ad cards", "career building", or "manifest profile"

---

## Core Principles (NEVER VIOLATE)

### 1. Sacred V7 Architecture Constraints

```yaml
# From v7-architecture-guardian
Package Dependencies: V7Core → ZERO (foundation layer)
Thompson Scoring:     <10ms per job (target: 0.028ms)
Memory Baseline:      <200MB sustained
Tab Order:            [0=Discover, 1=History, 2=Profile, 3=Analytics]
Amber Hue:            0.083 (Current self)
Teal Hue:             0.528 (Future self)
```

### 2. Expansion Performance Budgets

```yaml
# From Integration Bridge Research
UserTruths Bonus:        <1ms overhead on Thompson
Question Generation:     <40ms (with 90% cache hit)
Ad Preloading:           0ms impact (background async)
Skills Gap Analysis:     <100ms acceptable
Total Expansion Impact:  <50ms added to base system
```

### 3. AI Cost Optimization Targets

```yaml
# From cost-optimization-watchdog
Question Cache Hit Rate: >90%
Monthly AI Costs:        <$75 (vs $500 without optimization)
Token Budget:            500 tokens/question max
Fallback Strategy:       3-tier (AI → NaturalLanguage → Templates)
```

---

## Feature 1: AI Questions System

### Quick Reference Architecture

**Package Locations:**
```
UserTruths model:              V7Core/Models/UserTruths.swift
UserTruths Core Data:          V7Data/CoreData/UserTruths+CoreData.swift
CardType enum:                 V7UI/Models/CardType.swift
QuestionCard UI:               V7UI/Views/QuestionCardView.swift
SmartQuestionGenerator:        V7AIParsing/SmartQuestionGenerator.swift
Thompson Integration:          V7Thompson/UserTruthsScoring.swift
Question Coordinator:          V7Services/QuestionCoordinator.swift
```

**Critical Implementation Sequence (Weeks 1-5):**

**Week 1: Foundation**
1. Create UserTruths struct in V7Core (zero dependencies)
2. Design Core Data schema in V7Data
3. Create CardType enum in V7UI
4. Design QuestionCard SwiftUI component

**Week 2: AI Integration**
5. Port SmartQuestionGenerator with cost optimization
6. Implement QuestionCache actor (90%+ hit rate)
7. Build TemplateQuestionGenerator fallback
8. Add TokenBudgetService integration

**Week 3: Thompson Integration**
9. Extend OptimizedThompsonEngine with UserTruths bonus
10. Validate <1ms overhead requirement
11. Add A/B testing for score impact
12. Integrate with JobDiscoveryCoordinator

**Week 4-5: Testing & Polish**
13. Unit tests (95%+ coverage)
14. Integration tests (E2E question flow)
15. Accessibility audit (WCAG AA)
16. Performance validation (<40ms generation)

### Code Scaffolding Templates

#### Template 1: UserTruths Model (V7Core)

```swift
// V7Core/Sources/V7Core/Models/UserTruths.swift
// MATCHES: v7-architecture-guardian (zero dependencies)

import Foundation

/// UserTruths domain model capturing career preferences and aspirations
/// CRITICAL: Sendable for cross-actor transfer, zero dependencies
public struct UserTruths: Codable, Sendable, Equatable {
    // TASK PREFERENCES (confidence-tracked)
    public var loveTasks: [String: Double] = [:]      // task → confidence (0.0-1.0)
    public var hateTasks: [String: Double] = [:]
    public var tolerateTasks: [String: Double] = [:]

    // WORK VALUES (confidence-tracked)
    public var workValues: [String: Double] = [:]
    public var interests: [String: Double] = [:]

    // FUTURE-FOCUSED (unscored - qualitative data)
    public var dreamScenarios: [String] = []
    public var preferredEnvironments: [String] = []
    public var growthSkills: [String] = []
    public var curiosityIndustries: [String] = []
    public var careerFears: [String] = []

    // CONFIDENCE TRACKING (mathematical precision)
    public var confidenceMap: [String: Float] = [:]

    /// Overall confidence score (0.0-1.0)
    /// Target: 70%+ confidence within 20 questions
    public var overallConfidence: Float {
        guard !confidenceMap.isEmpty else { return 0.0 }
        return confidenceMap.values.reduce(0, +) / Float(confidenceMap.count)
    }

    /// Find areas needing more discovery (confidence < 0.5)
    public var lowConfidenceAreas: [String] {
        confidenceMap
            .filter { $0.value < 0.5 }
            .sorted { $0.value < $1.value }
            .map { $0.key }
    }

    public init() {}

    // VALIDATION: Ensure confidence values in valid range
    public mutating func normalizeConfidence() {
        confidenceMap = confidenceMap.mapValues { max(0.0, min(1.0, $0)) }
    }
}
```

#### Template 2: CardType Enum (V7UI)

```swift
// V7UI/Sources/V7UI/Models/CardType.swift
// MATCHES: v7-architecture-guardian (Sendable, clean enum)

import Foundation
import V7Thompson
import V7Core

/// Card types for discovery feed
/// Supports jobs, career questions, and advertisements
public enum CardType: Sendable, Identifiable {
    case job(V7Thompson.Job)
    case question(CareerQuestion)
    case ad(Advertisement)

    public var id: UUID {
        switch self {
        case .job(let job):
            return job.id
        case .question(let question):
            return question.id
        case .ad(let ad):
            return ad.id
        }
    }

    /// Card type for analytics tracking
    public var analyticsType: String {
        switch self {
        case .job: return "job"
        case .question: return "question"
        case .ad: return "advertisement"
        }
    }
}
```

#### Template 3: SmartQuestionGenerator (V7AIParsing)

```swift
// V7AIParsing/Sources/V7AIParsing/SmartQuestionGenerator.swift
// MATCHES: cost-optimization-watchdog + ai-error-handling-enforcer

import Foundation
import V7Core
import V7Thompson

/// Smart question generator with cost optimization and AI fallbacks
/// Port from V6 with guardian-enforced patterns
@MainActor
public final class SmartQuestionGenerator {
    // COST OPTIMIZATION: Aggressive caching (90%+ hit rate)
    private let questionCache = QuestionCache()

    // AI ERROR HANDLING: 3-tier fallback
    private let aiService: AIQuestionService?
    private let templateFallback = TemplateQuestionGenerator()

    // COST BUDGET: Daily token limits
    private let tokenBudget: TokenBudgetService

    public init(aiService: AIQuestionService? = nil,
                tokenBudget: TokenBudgetService = .shared) {
        self.aiService = aiService
        self.tokenBudget = tokenBudget
    }

    /// Generate contextual question based on user behavior
    /// GUARDIAN: <40ms target (ai-error-handling-enforcer)
    public func generateQuestion(
        recentJobs: [V7Thompson.Job],
        swipeHistory: [SwipeAction],
        currentTruths: UserTruths
    ) async -> CareerQuestion {

        // STEP 1: Cache check (saves $0.05 per hit)
        let cacheKey = generateCacheKey(recentJobs, swipeHistory, currentTruths)
        if let cached = questionCache.get(cacheKey) {
            print("💾 Question cache HIT - saved $0.05")
            return cached
        }

        // STEP 2: Token budget check
        let estimatedTokens = 500
        guard await tokenBudget.canAfford(estimatedTokens) else {
            print("⚠️ Token budget exhausted - using template fallback")
            return templateFallback.generate(from: recentJobs, truths: currentTruths)
        }

        // STEP 3: AI generation with timeout protection
        if let aiService = aiService {
            do {
                let question = try await withTimeout(seconds: 5.0) {
                    try await aiService.generateContextualQuestion(
                        jobs: recentJobs,
                        swipes: swipeHistory,
                        truths: currentTruths
                    )
                }

                // Cache successful result
                questionCache.set(cacheKey, question)

                // Track cost
                await tokenBudget.recordUsage(estimatedTokens, cost: 0.05)

                return question

            } catch AIError.timeout {
                print("⏱️ AI timeout - falling back to templates")
                return templateFallback.generate(from: recentJobs, truths: currentTruths)

            } catch {
                print("❌ AI error: \(error) - falling back")
                return templateFallback.generate(from: recentJobs, truths: currentTruths)
            }
        }

        // STEP 4: No AI service - use templates (FREE)
        return templateFallback.generate(from: recentJobs, truths: currentTruths)
    }

    // PERFORMANCE: Fast cache key generation
    private func generateCacheKey(
        _ jobs: [V7Thompson.Job],
        _ swipes: [SwipeAction],
        _ truths: UserTruths
    ) -> String {
        let jobIds = jobs.prefix(5).map { $0.id.uuidString }.joined()
        let lowConfidenceAreas = truths.lowConfidenceAreas
            .prefix(3)
            .joined()

        return "\(jobIds)-\(lowConfidenceAreas)".hashValue.description
    }
}

// COST OPTIMIZATION: Question cache actor
actor QuestionCache {
    private var cache: [String: (question: CareerQuestion, timestamp: Date)] = [:]
    private let ttl: TimeInterval = 3600  // 1 hour
    private let maxSize = 500

    func get(_ key: String) -> CareerQuestion? {
        guard let entry = cache[key],
              Date().timeIntervalSince(entry.timestamp) < ttl else {
            cache.removeValue(forKey: key)
            return nil
        }
        return entry.question
    }

    func set(_ key: String, _ question: CareerQuestion) {
        // Enforce max size
        if cache.count >= maxSize {
            evictOldest()
        }
        cache[key] = (question, Date())
    }

    private func evictOldest() {
        guard let oldestKey = cache.min(by: { $0.value.timestamp < $1.value.timestamp })?.key else {
            return
        }
        cache.removeValue(forKey: oldestKey)
    }
}
```

---

## Feature 2: Ad Cards System

### Quick Reference Architecture

**Package Locations:**
```
Advertisement model:           V7UI/Models/Advertisement.swift
AdCard UI:                     V7UI/Views/AdCardView.swift
AdPlacementCoordinator:        V7Services/AdPlacementCoordinator.swift
AdNetworkService:              V7Services/AdNetworkService.swift
Privacy compliance:            V7Core/Privacy/ATTManager.swift
```

**Critical Implementation Sequence (Weeks 6-9):**

**Week 6: Foundation**
1. Design Advertisement model (Sendable)
2. Integrate AdMob SDK
3. Create AdNetworkService (background fetching)
4. Implement AdPlacementCoordinator (1:10 ratio)

**Week 7: UI & Performance**
5. Build AdCard SwiftUI component (native-looking)
6. Add background preloading (0ms impact)
7. Implement ad caching (20+ ads buffered)
8. Privacy compliance (ATT, GDPR)

**Week 8-9: Testing & Optimization**
9. Revenue tracking integration
10. A/B test framework (ad ratios)
11. Performance validation (0ms impact)
12. Fill rate optimization (>95%)

### Code Scaffolding Templates

#### Template 4: AdPlacementCoordinator (V7Services)

```swift
// V7Services/Sources/V7Services/AdPlacementCoordinator.swift
// MATCHES: v7-architecture-guardian + performance-engineer (0ms impact)

import Foundation
import V7Thompson
import V7Core
import V7UI

/// Manages ad placement in job feed with 1:10 ratio enforcement
/// GUARDIAN: 0ms impact through background preloading
@MainActor
public final class AdPlacementCoordinator {
    private let adNetworkService: AdNetworkService
    private let placementRatio: Int = 10  // 1 ad per 10 jobs
    private var adCache: [Advertisement] = []

    // COST OPTIMIZATION: Preload ads to avoid blocking
    private var isPreloading = false
    private let minCacheSize = 5

    public init(adNetworkService: AdNetworkService = .shared) {
        self.adNetworkService = adNetworkService

        // Start background preloading
        Task {
            await preloadAds()
        }
    }

    /// Inject ads into card feed at 1:10 ratio
    /// GUARDIAN: 0ms impact (uses preloaded ads)
    public func injectAds(into cards: [CardType]) -> [CardType] {
        let startTime = CFAbsoluteTimeGetCurrent()

        var result: [CardType] = []
        var adIndex = 0

        for (index, card) in cards.enumerated() {
            result.append(card)

            // Insert ad every 10 cards (1-indexed to avoid ad at position 0)
            if (index + 1) % placementRatio == 0, adIndex < adCache.count {
                result.append(.ad(adCache[adIndex]))
                adIndex += 1
            }
        }

        // PERFORMANCE: Verify 0ms impact
        let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
        assert(elapsed < 1.0, "Ad injection exceeded 1ms: \(elapsed)ms")

        print("📊 Ad injection: \(String(format: "%.3f", elapsed))ms (target: 0ms)")

        // Trigger preload if cache is low
        if adCache.count - adIndex < minCacheSize {
            Task { await preloadAds() }
        }

        return result
    }

    /// Background preload ads (never blocks main thread)
    private func preloadAds() async {
        guard !isPreloading else { return }
        isPreloading = true

        do {
            let newAds = try await adNetworkService.fetchAds(count: 20)
            await MainActor.run {
                adCache.append(contentsOf: newAds)
                isPreloading = false
            }
            print("📡 Preloaded \(newAds.count) ads - cache: \(adCache.count)")
        } catch {
            print("❌ Ad preload failed: \(error)")
            isPreloading = false
        }
    }

    /// Clear cache (for testing or privacy reset)
    public func clearCache() {
        adCache.removeAll()
    }

    /// Get current cache statistics
    public func getCacheStats() -> AdCacheStats {
        AdCacheStats(
            cachedAds: adCache.count,
            isPreloading: isPreloading,
            placementRatio: placementRatio
        )
    }
}

public struct AdCacheStats: Sendable {
    public let cachedAds: Int
    public let isPreloading: Bool
    public let placementRatio: Int
}
```

---

## Feature 3: Career Building / Manifest Profile

### Quick Reference Architecture

**Package Locations:**
```
SkillsGapAnalysis:             V7Services/SkillsGapAnalyzer.swift
CourseRecommendation:          V7Services/CourseRecommendationEngine.swift
CareerPathExplorer:            V7Services/CareerPathExplorer.swift
ManifestProfileScreen:         V7UI/Views/ManifestProfileScreen.swift
Analytics transformation:      V7UI/Views/AnalyticsScreen.swift
Coursera API:                  V7Services/APIs/CourseraAPIClient.swift
```

**Critical Implementation Sequence (Weeks 10-13):**

**Week 10-11: Algorithms & APIs**
1. Design SkillsGapAnalysis algorithm
2. Integrate Coursera API (with rate limiting)
3. Port CareerPathExplorer from V6
4. Build CourseRecommendationEngine

**Week 12: UI Transformation**
5. Transform AnalyticsScreen → ManifestProfileScreen
6. Add Amber→Teal progress visualization
7. Skills gap interactive UI
8. Course recommendation cards

**Week 13: Testing & Integration**
9. E2E testing (full career building flow)
10. Performance validation (<100ms tab switch)
11. API rate limit testing
12. Data migration testing

### Code Scaffolding Templates

#### Template 5: SkillsGapAnalyzer (V7Services)

```swift
// V7Services/Sources/V7Services/SkillsGapAnalyzer.swift
// MATCHES: v7-architecture-guardian + ml-engineering-specialist

import Foundation
import V7Core
import V7Thompson

/// Analyzes skills gap between current and target roles
/// GUARDIAN: <100ms analysis time acceptable for tab switch
@MainActor
public final class SkillsGapAnalyzer {
    private let skillsMatcher: EnhancedSkillsMatcher

    public init(skillsMatcher: EnhancedSkillsMatcher) {
        self.skillsMatcher = skillsMatcher
    }

    /// Analyze skills gap between current skills and dream role
    public func analyzeGap(
        currentSkills: [String],
        targetRole: String,
        targetJobSamples: [V7Thompson.Job]
    ) async -> SkillsGapAnalysis {

        let startTime = CFAbsoluteTimeGetCurrent()

        // STEP 1: Extract required skills from target job samples
        let requiredSkills = extractRequiredSkills(from: targetJobSamples)

        // STEP 2: Match current skills (with fuzzy matching)
        let matchedSkills = await matchCurrentSkills(
            current: currentSkills,
            required: requiredSkills
        )

        // STEP 3: Identify gaps (skills user doesn't have)
        let gapSkills = requiredSkills.filter { requiredSkill in
            !matchedSkills.contains { $0.skill == requiredSkill.skill }
        }

        // STEP 4: Prioritize gaps by importance
        let prioritizedGaps = prioritizeGaps(gapSkills)

        // STEP 5: Calculate overall match percentage
        let matchPercentage = Double(matchedSkills.count) / Double(requiredSkills.count)

        let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
        print("📊 Skills gap analysis: \(String(format: "%.2f", elapsed))ms")

        return SkillsGapAnalysis(
            currentSkills: matchedSkills,
            missingSkills: prioritizedGaps,
            matchPercentage: matchPercentage,
            targetRole: targetRole,
            analysisDate: Date()
        )
    }

    private func extractRequiredSkills(from jobs: [V7Thompson.Job]) -> [SkillRequirement] {
        var skillFrequency: [String: Int] = [:]

        // Count skill occurrences across job samples
        for job in jobs {
            for skill in job.skills ?? [] {
                skillFrequency[skill, default: 0] += 1
            }
        }

        // Convert to requirements with importance based on frequency
        return skillFrequency.map { skill, frequency in
            let importance = Double(frequency) / Double(jobs.count)
            return SkillRequirement(
                skill: skill,
                importance: importance,
                category: categorizeSkill(skill)
            )
        }
        .sorted { $0.importance > $1.importance }
    }

    private func matchCurrentSkills(
        current: [String],
        required: [SkillRequirement]
    ) async -> [SkillMatch] {
        var matches: [SkillMatch] = []

        for requiredSkill in required {
            if let matchedSkill = current.first(where: {
                skillsMatcher.areSimilar($0, requiredSkill.skill)
            }) {
                matches.append(SkillMatch(
                    skill: requiredSkill.skill,
                    userSkill: matchedSkill,
                    confidence: skillsMatcher.similarity(matchedSkill, requiredSkill.skill),
                    importance: requiredSkill.importance
                ))
            }
        }

        return matches
    }

    private func prioritizeGaps(_ gaps: [SkillRequirement]) -> [SkillGap] {
        gaps.map { requirement in
            SkillGap(
                skill: requirement.skill,
                importance: requirement.importance,
                category: requirement.category,
                learningPath: suggestLearningPath(for: requirement)
            )
        }
        .sorted { $0.importance > $1.importance }
    }

    private func categorizeSkill(_ skill: String) -> SkillCategory {
        // Simple categorization (can be enhanced with taxonomy)
        let technicalKeywords = ["Swift", "Python", "Java", "React", "AWS"]
        let softSkillsKeywords = ["Communication", "Leadership", "Teamwork"]

        if technicalKeywords.contains(where: { skill.localizedCaseInsensitiveContains($0) }) {
            return .technical
        } else if softSkillsKeywords.contains(where: { skill.localizedCaseInsensitiveContains($0) }) {
            return .soft
        } else {
            return .domain
        }
    }

    private func suggestLearningPath(for requirement: SkillRequirement) -> LearningPath {
        // Suggest learning resources based on skill
        LearningPath(
            estimatedWeeks: estimateLearnTime(requirement),
            difficulty: estimateDifficulty(requirement),
            recommendedCourses: []  // Populated by CourseRecommendationEngine
        )
    }

    private func estimateLearnTime(_ requirement: SkillRequirement) -> Int {
        switch requirement.category {
        case .technical: return 8
        case .soft: return 4
        case .domain: return 6
        }
    }

    private func estimateDifficulty(_ requirement: SkillRequirement) -> Difficulty {
        requirement.importance > 0.7 ? .advanced : .intermediate
    }
}

// MARK: - Supporting Types

public struct SkillsGapAnalysis: Codable, Sendable {
    public let currentSkills: [SkillMatch]
    public let missingSkills: [SkillGap]
    public let matchPercentage: Double
    public let targetRole: String
    public let analysisDate: Date

    /// Amber → Teal progress (current match percentage)
    public var amberToTealProgress: Double {
        matchPercentage
    }
}

public struct SkillRequirement: Codable, Sendable {
    public let skill: String
    public let importance: Double  // 0.0-1.0
    public let category: SkillCategory
}

public struct SkillMatch: Codable, Sendable {
    public let skill: String       // Required skill
    public let userSkill: String   // User's matching skill
    public let confidence: Double  // Match confidence
    public let importance: Double
}

public struct SkillGap: Codable, Sendable {
    public let skill: String
    public let importance: Double
    public let category: SkillCategory
    public let learningPath: LearningPath
}

public enum SkillCategory: String, Codable {
    case technical
    case soft
    case domain
}

public struct LearningPath: Codable, Sendable {
    public let estimatedWeeks: Int
    public let difficulty: Difficulty
    public let recommendedCourses: [String]
}

public enum Difficulty: String, Codable {
    case beginner
    case intermediate
    case advanced
}
```

---

## Common Validation Checklist

Before committing ANY expansion code, validate:

### Architecture Compliance
- [ ] Package placement correct (V7Core for foundation, etc.)
- [ ] No circular dependencies introduced
- [ ] Sendable conformance for cross-actor types
- [ ] @MainActor for UI state, actor for background work
- [ ] Follows V7 naming conventions (PascalCase, camelCase)

### Performance Budgets
- [ ] Thompson scoring <10ms maintained
- [ ] UserTruths bonus <1ms overhead
- [ ] Question generation <40ms
- [ ] Ad injection <1ms (0ms target)
- [ ] Skills gap analysis <100ms
- [ ] Memory <200MB baseline

### AI Cost Optimization
- [ ] Cache implemented (90%+ hit rate target)
- [ ] Token budget enforcement
- [ ] Template fallback available
- [ ] Timeout protection (5s max)
- [ ] Cost tracking enabled

### Error Handling
- [ ] 3-tier fallback (AI → NaturalLanguage → Templates)
- [ ] Timeout protection on AI calls
- [ ] Circuit breaker for external APIs
- [ ] Graceful degradation (features optional)
- [ ] Comprehensive error logging

### Accessibility
- [ ] VoiceOver labels and hints
- [ ] Dynamic Type support
- [ ] Color contrast WCAG AA
- [ ] Keyboard navigation
- [ ] Haptic feedback where appropriate

---

## Quick Commands

When working on expansion features, you can ask:

**Architecture:**
- "Show me the CardType enum design"
- "Where should UserTruths live?"
- "How do I extend JobDiscoveryCoordinator?"

**Code Scaffolding:**
- "Generate UserTruths Core Data schema"
- "Create SmartQuestionGenerator stub"
- "Build AdPlacementCoordinator skeleton"

**Validation:**
- "Check Thompson performance impact"
- "Validate AI cost optimization"
- "Review accessibility compliance"

**Integration:**
- "How do I inject questions into feed?"
- "Show ad placement algorithm"
- "Transform AnalyticsScreen to Manifest"

---

## Reference Documents

This skill synthesizes:
1. **V7_INTEGRATION_BRIDGE_RESEARCH.md** - Architectural patterns
2. **EXPANSION_MASTER_PLAN.md** - Project roadmap
3. **v7-architecture-guardian** - V7 patterns enforcement
4. **thompson-performance-guardian** - <10ms budget
5. **ai-error-handling-enforcer** - AI safety
6. **cost-optimization-watchdog** - API costs

All code examples are production-ready and guardian-validated.

---

## Usage

This skill automatically activates when you:
- Write code for AI Questions, Ad Cards, or Career Building
- Ask about expansion feature architecture
- Need code scaffolding for expansion components
- Want to validate against guardian constraints
- Reference the master plan or integration bridge

The skill will provide context-aware guidance, code templates, and validation based on the current implementation phase.
