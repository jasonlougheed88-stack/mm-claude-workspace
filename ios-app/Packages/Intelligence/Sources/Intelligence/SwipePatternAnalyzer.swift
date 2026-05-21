import Foundation
import Persistence

public struct SwipePattern: Sendable {
    public let rightSwipeRatio: Double
    public let topRoles: [String]
    public let topSkills: [String]
    /// 0–1 signal: how strongly swipe history points to Investigative RIASEC
    public let investigativeSignal: Double
    /// 0–1 signal: how strongly swipe history points to Enterprising RIASEC
    public let enterprisingSignal: Double
}

// PHASE8-UPGRADE: SwipePatternAnalyzer — replace keyword matching with O*NET-based RIASEC inference.
// Phase 7 maps every job to real RIASEC codes from the DOL database. Phase 8 uses those codes
// to compute riasecInferred from actual occupation data instead of keyword guessing.
// Full implementation: FastBehavioralLearning.swift + DeepBehavioralAnalysis.swift from V7/V8.
// Keep the SwipePattern struct — the output shape stays the same, only the internals change.
/// Stateless swipe history analyzer — Phase 6 stub.
/// Phase 8 replaces keyword matching with O*NET-based RIASEC inference (requires Phase 7 data).
public enum SwipePatternAnalyzer {

    private static let investigativeTerms: Set<String> = [
        "data", "analytics", "research", "engineer", "scientist", "science",
        "machine learning", "ai", "algorithm", "quantitative", "statistical",
        "analysis", "modeling", "inference", "backend", "software"
    ]

    private static let enterprisingTerms: Set<String> = [
        "manager", "director", "lead", "head", "vp", "president",
        "executive", "sales", "business development", "account", "growth"
    ]

    public static func analyze(_ interactions: [JobInteraction]) -> SwipePattern {
        let positive = interactions.filter {
            $0.action == "interested" || $0.action == "applied"
        }
        let rightSwipeRatio = interactions.isEmpty ? 0.0 :
            Double(positive.count) / Double(interactions.count)

        var roleCounts: [String: Int] = [:]
        for i in positive { roleCounts[i.jobRole, default: 0] += 1 }
        let topRoles = roleCounts.sorted { $0.value > $1.value }.prefix(5).map(\.key)

        var skillCounts: [String: Int] = [:]
        for i in positive { for s in i.jobSkills { skillCounts[s, default: 0] += 1 } }
        let topSkills = skillCounts.sorted { $0.value > $1.value }.prefix(10).map(\.key)

        let allTerms = Array(topSkills) + Array(topRoles)
        let investigativeSignal = termSignal(in: allTerms, keywords: investigativeTerms)
        let enterprisingSignal  = termSignal(in: Array(topRoles), keywords: enterprisingTerms)

        return SwipePattern(
            rightSwipeRatio: rightSwipeRatio,
            topRoles: Array(topRoles),
            topSkills: Array(topSkills),
            investigativeSignal: investigativeSignal,
            enterprisingSignal: enterprisingSignal
        )
    }

    private static func termSignal(in terms: [String], keywords: Set<String>) -> Double {
        guard !terms.isEmpty else { return 0.0 }
        let matches = terms.filter { term in
            let lower = term.lowercased()
            return keywords.contains { lower.contains($0) }
        }
        return min(1.0, Double(matches.count) / Double(terms.count))
    }
}
