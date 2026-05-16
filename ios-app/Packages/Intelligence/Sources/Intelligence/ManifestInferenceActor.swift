import CoreData
import Foundation
import os
import Persistence

private let logger = Logger(subsystem: "com.manifestandmatch.app", category: "ManifestInferenceActor")

/// Behavioral inference engine for the Manifest (Teal/aspirational) profile.
///
/// Analyzes JobInteraction swipe history to infer target roles, skills, and RIASEC profile.
/// Minimum swipes for inference: 3 (threshold reduced from V7's 10).
/// Debounce: 5 seconds — won't re-process more than once per 5s.
public actor ManifestInferenceActor {
    public static let shared = ManifestInferenceActor()
    private init() {}

    private static let minimumSwipesRequired = 3
    private static let processingInterval: TimeInterval = 5.0

    private var isProcessing = false
    private var lastProcessedTimestamp: Date?

    // MARK: - Public API

    /// Analyze swipe history and update InferredManifestProfile in Core Data.
    /// Debounced — safe to call after every swipe.
    public func updateManifestProfile(in context: NSManagedObjectContext) async {
        if let last = lastProcessedTimestamp,
           Date().timeIntervalSince(last) < Self.processingInterval {
            return
        }
        guard !isProcessing else { return }
        isProcessing = true
        defer { isProcessing = false }

        let start = CFAbsoluteTimeGetCurrent()

        let (interactions, profile) = await context.perform { [context] in
            let interactions = JobInteraction.fetchAll(in: context)
            let profile = InferredManifestProfile.fetchOrCreate(in: context)
            return (interactions, profile.objectID)
        }

        guard interactions.count >= Self.minimumSwipesRequired else {
            await context.perform { [context] in
                guard let profileObject = try? context.existingObject(with: profile) as? InferredManifestProfile else { return }
                profileObject.totalSwipesAnalyzed = Int32(interactions.count)
                profileObject.lastUpdated = Date()
                try? context.save()
            }
            logger.debug("Only \(interactions.count) swipes — need \(Self.minimumSwipesRequired)+ for inference")
            return
        }

        logger.debug("Analyzing \(interactions.count) swipes for manifest inference")

        let skillPreferences = calculateSkillPreferences(from: interactions)
        let roleInference = inferTargetRole(from: interactions)
        let confidence = calculateConfidence(dataPoints: interactions.count)

        await context.perform { [context] in
            guard let profileObject = try? context.existingObject(with: profile) as? InferredManifestProfile else { return }

            profileObject.targetSkills = Array(skillPreferences.prefix(10).map { $0.skill })
            profileObject.skillConfidences = Dictionary(
                uniqueKeysWithValues: skillPreferences.prefix(10).map { ($0.skill, $0.score) }
            )
            profileObject.targetRole = roleInference.role
            profileObject.targetRoleConfidence = roleInference.confidence
            profileObject.riasecInferredConfidence = confidence
            profileObject.totalSwipesAnalyzed = Int32(interactions.count)
            profileObject.lastUpdated = Date()

            let convergenceError = 1.0 / sqrt(Double(interactions.count))
            profileObject.convergenceError = convergenceError
            profileObject.hasConverged = convergenceError < 0.10

            try? context.save()
        }

        lastProcessedTimestamp = Date()
        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
        logger.debug("Manifest inference complete in \(elapsed, format: .fixed(precision: 1))ms — role: \(roleInference.role) conf: \(roleInference.confidence, format: .fixed(precision: 2))")
    }

    // MARK: - Inference Algorithms

    private func calculateSkillPreferences(
        from interactions: [JobInteraction]
    ) -> [(skill: String, score: Double)] {
        var skillScores: [String: Double] = [:]
        let now = Date()

        for interaction in interactions {
            let daysAgo = now.timeIntervalSince(interaction.timestamp ?? now) / 86400
            let lambda = decayRate(for: interaction.action)
            let timeWeight = exp(-lambda * daysAgo)

            let actionWeight: Double
            switch interaction.action {
            case "applied":    actionWeight = 2.0
            case "interested": actionWeight = 1.0
            case "pass":       actionWeight = -0.5
            default:           actionWeight = 0.0
            }

            let thompsonWeight = 1.0 / (1.0 + exp(-(0.5 - interaction.thompsonScore)))
            let contextWeight = 0.5 + interaction.amberTealPosition
            let totalWeight = timeWeight * actionWeight * thompsonWeight * contextWeight

            for skill in interaction.jobSkills {
                skillScores[skill, default: 0.0] += totalWeight
            }
        }

        return skillScores
            .sorted { $0.value > $1.value }
            .map { (skill: $0.key, score: $0.value) }
    }

    private func inferTargetRole(
        from interactions: [JobInteraction]
    ) -> (role: String, confidence: Double) {
        var roleCounts: [String: Double] = [:]

        for interaction in interactions where interaction.action == "interested" || interaction.action == "applied" {
            roleCounts[interaction.jobRole, default: 0.0] += interaction.actionWeight
        }

        guard !roleCounts.isEmpty else { return (role: "Unknown", confidence: 0.0) }

        let maxScore = roleCounts.values.max() ?? 0.0
        let expScores = roleCounts.mapValues { exp($0 - maxScore) }
        let sumExp = expScores.values.reduce(0, +)
        let probabilities = expScores.mapValues { $0 / sumExp }

        guard let top = probabilities.max(by: { $0.value < $1.value }) else {
            return (role: "Unknown", confidence: 0.0)
        }
        return (role: top.key, confidence: top.value)
    }

    private func calculateConfidence(dataPoints: Int) -> Double {
        guard dataPoints > 0 else { return 0.0 }
        return max(0.0, min(1.0, 1.0 - 1.0 / sqrt(Double(dataPoints))))
    }

    private func decayRate(for action: String) -> Double {
        switch action {
        case "applied":    return 0.05
        case "interested": return 0.10
        case "save":       return 0.15
        case "pass":       return 0.20
        default:           return 0.10
        }
    }
}
