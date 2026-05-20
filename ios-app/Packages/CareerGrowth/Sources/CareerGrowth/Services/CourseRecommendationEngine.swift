import Foundation

// MARK: - CourseRecommendationEngine

public actor CourseRecommendationEngine {
    public static let shared = CourseRecommendationEngine()

    // NSCache is not Sendable; nonisolated(unsafe) required for Swift 6 actor isolation
    nonisolated(unsafe) private let cache = NSCache<NSString, CachedRecommendations>()
    private let database = CourseDatabase.shared

    private init() {
        cache.countLimit = 20
    }

    // MARK: - Public API

    // targetSkills and targetRole are extracted from InferredManifestProfile on @MainActor
    // before calling this method — NSManagedObject cannot cross actor boundaries in Swift 6.
    public func getRecommendations(
        targetSkills: [String],
        targetRole: String,
        limit: Int
    ) async -> [RecommendedCourse] {
        let cacheKey = NSString(string: "\(targetRole)-\(targetSkills.joined(separator: ","))")
        if let cached = cache.object(forKey: cacheKey) {
            return Array(cached.courses.prefix(limit))
        }

        var courses: [RecommendedCourse]

        if targetSkills.isEmpty {
            courses = await fallbackSearch(keyword: targetRole)
        } else {
            courses = await recommendFromSkillGaps(targetSkills: targetSkills, targetRole: targetRole)
        }

        let scored = CoursePrioritizer.rank(courses, targetSkills: targetSkills, targetRole: targetRole)
        let result = Array(scored.prefix(limit))
        cache.setObject(CachedRecommendations(courses: result), forKey: cacheKey)
        return result
    }

    public func recommendCourses(for gap: SkillsGap) async -> [RecommendedCourse] {
        guard let courses = try? await database.courses(matching: [gap.skill.name]) else { return [] }
        return courses
    }

    // MARK: - Private

    private func recommendFromSkillGaps(targetSkills: [String], targetRole: String) async -> [RecommendedCourse] {
        guard let skillMatches = try? await database.courses(matching: targetSkills) else {
            return await fallbackSearch(keyword: targetRole)
        }
        if skillMatches.isEmpty {
            return await fallbackSearch(keyword: targetRole)
        }
        return skillMatches
    }

    private func fallbackSearch(keyword: String) async -> [RecommendedCourse] {
        (try? await database.courses(containing: keyword)) ?? []
    }
}

// MARK: - CoursePrioritizer

private enum CoursePrioritizer {
    static func rank(_ courses: [RecommendedCourse], targetSkills: [String], targetRole: String) -> [RecommendedCourse] {
        let loweredSkills = targetSkills.map { $0.lowercased() }
        let loweredRole = targetRole.lowercased()

        return courses
            .map { course -> RecommendedCourse in
                var scored = course
                scored.skillMatchPercentage = SkillMatcher.matchPercentage(
                    courseSkills: course.skills,
                    targetSkills: loweredSkills
                )
                scored.relevanceScore = computeRelevance(
                    course: course,
                    skillMatch: scored.skillMatchPercentage,
                    targetRole: loweredRole
                )
                return scored
            }
            .sorted { $0.relevanceScore > $1.relevanceScore }
    }

    private static func computeRelevance(course: RecommendedCourse, skillMatch: Double, targetRole: String) -> Double {
        let ratingNorm = course.rating / 5.0
        let titleBonus = course.title.lowercased().contains(targetRole) ? 0.1 : 0.0
        // Weighted: skill match 60%, rating 30%, title bonus 10%
        return (skillMatch * 0.6) + (ratingNorm * 0.3) + titleBonus
    }
}

// MARK: - SkillMatcher

private enum SkillMatcher {
    static func matchPercentage(courseSkills: [String], targetSkills: [String]) -> Double {
        guard !targetSkills.isEmpty else { return 0.5 }
        let loweredCourse = courseSkills.map { $0.lowercased() }
        let matched = targetSkills.filter { target in
            loweredCourse.contains { $0.contains(target) || target.contains($0) }
        }
        return Double(matched.count) / Double(targetSkills.count)
    }
}

// MARK: - Cache helper

private final class CachedRecommendations: NSObject {
    let courses: [RecommendedCourse]
    init(courses: [RecommendedCourse]) { self.courses = courses }
}
