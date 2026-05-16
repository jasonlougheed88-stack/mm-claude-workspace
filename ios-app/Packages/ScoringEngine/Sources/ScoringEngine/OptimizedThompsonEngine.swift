import CoreData
import Foundation
import os
import JobNormalizer
import Persistence


private let logger = Logger(subsystem: "com.manifestandmatch.app", category: "OptimizedThompsonEngine")

/// Thompson Sampling engine with Core Data persistence.
///
/// Persistence gate: swipe N times → kill app → relaunch → amberAlpha == 1 + N (not 1).
///
/// Call `initialize()` once at app launch before the first swipe.
public actor OptimizedThompsonEngine {
    public static let shared = OptimizedThompsonEngine()

    private var amberSampler = FastBetaSampler(alpha: 1.0, beta: 1.0)
    private var tealSampler = FastBetaSampler(alpha: 1.0, beta: 1.0)
    private var _profileBlend: Double = 0.5

    // nonisolated(unsafe) lets us hold and use NSManagedObjectContext within context.perform
    // blocks, which run on the context's own serial queue — safe despite the lack of formal Sendable.
    nonisolated(unsafe) private let context: NSManagedObjectContext

    private init() {
        let ctx = PersistenceController.shared.container.newBackgroundContext()
        ctx.automaticallyMergesChangesFromParent = true
        ctx.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        self.context = ctx
    }

    // MARK: - Public API

    public func initialize() async {
        await loadPersistedState()
    }

    public func setProfileBlend(_ blend: Double) {
        _profileBlend = max(0.0, min(1.0, blend))
    }

    public var amberAlpha: Double { amberSampler.alpha }
    public var tealAlpha: Double { tealSampler.alpha }
    public var profileBlend: Double { _profileBlend }

    public func sample() -> (amber: Double, teal: Double) {
        (amberSampler.sample(), tealSampler.sample())
    }

    /// Update Thompson arms after a swipe and persist to Core Data.
    public func processInteraction(action: SwipeAction, thompsonScore: Double) async {
        let isSuccess = action != .pass

        if _profileBlend < 0.5 {
            amberSampler = amberSampler.update(success: isSuccess)
            if Double.random(in: 0...1) < 0.3 {
                tealSampler = tealSampler.update(success: isSuccess)
            }
        } else {
            tealSampler = tealSampler.update(success: isSuccess)
            if Double.random(in: 0...1) < 0.3 {
                amberSampler = amberSampler.update(success: isSuccess)
            }
        }

        await persistArms(
            amberAlpha: amberSampler.alpha, amberBeta: amberSampler.beta,
            tealAlpha: tealSampler.alpha, tealBeta: tealSampler.beta
        )
    }

    // MARK: - Scoring

    /// Score a batch of jobs against the user's profile and current Thompson arm state.
    /// Non-async — runs synchronously on the actor's executor (<10ms for 100 jobs).
    public func scoreJobs(_ jobs: [Job], profile: JobNormalizer.UserProfile) -> [Job] {
        let weights = ThompsonWeights(sliderValue: _profileBlend)
        let features = precomputeUserFeatures(from: profile)

        let amberSample = amberSampler.sample()
        let tealSample  = tealSampler.sample()
        let baseThompsonScore = amberSample * (1.0 - _profileBlend) + tealSample * _profileBlend

        return jobs.map { job in
            var scored = job
            let t = titleScore(job: job, features: features)
            let sk = skillsScore(job: job, features: features)
            let lo = locationScore(job: job, features: features)
            let wa = workActivitiesScore(job: job, features: features)
            let ri = riasecScore(job: job, features: features)

            let professionalScore = min(1.0,
                t  * (weights.titleMatch     * 0.92) +
                sk * (weights.skills         * 0.92) +
                lo * (weights.location       * 0.92) +
                wa * (weights.workActivities * 0.92) +
                ri * (weights.riasec         * 0.92)
            )
            let combined = min(1.0, professionalScore + baseThompsonScore * 0.08)

            scored.thompsonScore = ThompsonScore(
                personalScore: baseThompsonScore,
                professionalScore: professionalScore,
                combinedScore: combined
            )
            scored.matchScore = combined
            return scored
        }
    }

    // MARK: - Component Scorers

    @inline(__always)
    private func titleScore(job: Job, features: UserFeatures) -> Double {
        let jobTitle = job.title.lowercased()
        for (role, roleWords) in zip(features.desiredRoles, features.desiredRoleWords) {
            // Tier 1: exact substring
            if jobTitle.contains(role) || role.contains(jobTitle) { return 1.0 }
            // Tier 2: shared significant words (>3 chars)
            let jobWords = Set(jobTitle.split(separator: " ").map(String.init).filter { $0.count > 3 })
            let overlap = jobWords.intersection(roleWords).count
            if overlap >= 1 { return min(1.0, 0.6 + Double(overlap) * 0.1) }
        }
        return 0.0
    }

    @inline(__always)
    private func skillsScore(job: Job, features: UserFeatures) -> Double {
        let reqs = job.requirements.isEmpty ? job.requiredSkills : job.requirements
        guard !reqs.isEmpty else { return 0.5 }
        let matched = reqs.filter { features.skillSet.contains($0.lowercased()) }.count
        return Double(matched) / Double(reqs.count)
    }

    @inline(__always)
    private func locationScore(job: Job, features: UserFeatures) -> Double {
        if job.workLocationType == .remote || job.isRemote {
            guard let userLoc = features.locationData,
                  let jobTZ = job.jobLocationData?.timezone else { return 0.8 }
            let tzDiff = userLoc.timezoneOffsetHoursTo(jobTZ)
            return max(0.0, 1.0 - Double(tzDiff) * 0.1)
        }
        guard let userLoc = features.locationData,
              let jobLoc = job.jobLocationData,
              let lat = jobLoc.latitude, let lon = jobLoc.longitude else { return 0.5 }
        let dist = userLoc.distanceTo(latitude: lat, longitude: lon)
        let maxMiles = job.workLocationType.maxCommutableMiles
        if dist <= maxMiles {
            return max(0.0, 1.0 - (dist / maxMiles) * 0.5)
        } else {
            return max(0.0, 0.5 - ((dist - maxMiles) / maxMiles) * 0.5)
        }
    }

    @inline(__always)
    private func workActivitiesScore(job: Job, features: UserFeatures) -> Double {
        guard let userActs = features.workActivities, !userActs.isEmpty,
              let jobActs = job.workActivities, !jobActs.isEmpty else { return 0.5 }
        var dot = 0.0, magU = 0.0, magJ = 0.0
        for key in Set(userActs.keys).union(jobActs.keys) {
            let u = userActs[key] ?? 0.0
            let j = jobActs[key] ?? 0.0
            dot += u * j; magU += u * u; magJ += j * j
        }
        guard magU > 0, magJ > 0 else { return 0.5 }
        return dot / (sqrt(magU) * sqrt(magJ))
    }

    @inline(__always)
    private func riasecScore(job: Job, features: UserFeatures) -> Double {
        guard let userInterests = features.interests,
              let jobProfile = job.riasecProfile else { return 0.5 }
        return userInterests.cosineSimilarity(to: jobProfile)
    }

    // MARK: - Feature Precomputation

    private func precomputeUserFeatures(from profile: JobNormalizer.UserProfile) -> UserFeatures {
        let allSkills = profile.professionalProfile.resumeSkills +
                        profile.professionalProfile.onetSkills +
                        profile.professionalProfile.skills
        let skillSet = Set(allSkills.map { $0.lowercased() })

        let roles = profile.preferences.desiredRoles.map { $0.lowercased() }
        let roleWords = roles.map { role in
            Set(role.split(separator: " ").map(String.init).filter { $0.count > 3 })
        }

        return UserFeatures(
            skillSet: skillSet,
            desiredRoles: roles,
            desiredRoleWords: roleWords,
            locationData: profile.preferences.primaryLocation,
            workActivities: profile.professionalProfile.workActivities,
            interests: profile.professionalProfile.interests
        )
    }

    // MARK: - Private

    private func loadPersistedState() async {
        let result = await context.perform { [context] in
            let amber = ThompsonArm.fetch(armId: "amber_primary", in: context)
            let teal  = ThompsonArm.fetch(armId: "teal_primary",  in: context)
            return (
                amberAlpha: amber?.alpha ?? 1.0,
                amberBeta:  amber?.beta  ?? 1.0,
                tealAlpha:  teal?.alpha  ?? 1.0,
                tealBeta:   teal?.beta   ?? 1.0
            )
        }
        amberSampler = FastBetaSampler(alpha: result.amberAlpha, beta: result.amberBeta)
        tealSampler  = FastBetaSampler(alpha: result.tealAlpha,  beta: result.tealBeta)
        logger.debug("Arms loaded: amber α=\(result.amberAlpha) β=\(result.amberBeta) teal α=\(result.tealAlpha) β=\(result.tealBeta)")
    }

    private func persistArms(
        amberAlpha: Double, amberBeta: Double,
        tealAlpha: Double, tealBeta: Double
    ) async {
        await context.perform { [context] in
            let amber = ThompsonArm.createOrUpdate(armId: "amber_primary", domain: "amber", in: context)
            amber.alpha = amberAlpha
            amber.beta  = amberBeta

            let teal = ThompsonArm.createOrUpdate(armId: "teal_primary", domain: "teal", in: context)
            teal.alpha = tealAlpha
            teal.beta  = tealBeta

            if context.hasChanges {
                try? context.save()
            }
        }
        logger.debug("Arms saved: amber α=\(amberAlpha) β=\(amberBeta) teal α=\(tealAlpha) β=\(tealBeta)")
    }
}

// MARK: - Thompson Weights

/// Interpolates component weights between Match mode (t=0) and Manifest mode (t=1).
/// Weights always sum to 1.0 (verified at init via assert).
private struct ThompsonWeights {
    let titleMatch: Double
    let skills: Double
    let location: Double
    let workActivities: Double
    let riasec: Double

    init(sliderValue: Double) {
        let t = max(0.0, min(1.0, sliderValue))

        // RIASEC: 5% at Match → 25% at Manifest (personality fit matters more when exploring)
        let riasecW = 0.05 + t * 0.20

        // Base weight interpolation (before RIASEC scaling)
        // Match (t=0):    70% title, 25% skills, 5% location, 0% workActivities
        // Manifest (t=1): 20% title, 30% skills, 10% location, 40% workActivities
        let scale = 1.0 - riasecW
        let titleMatch    = ((0.70 * (1.0 - t)) + (0.20 * t)) * scale
        let skills        = ((0.25 * (1.0 - t)) + (0.30 * t)) * scale
        let location      = ((0.05 * (1.0 - t)) + (0.10 * t)) * scale
        let workActivities = ((0.00 * (1.0 - t)) + (0.40 * t)) * scale

        assert(abs(titleMatch + skills + location + workActivities + riasecW - 1.0) < 0.01,
               "ThompsonWeights must sum to 1.0")

        self.titleMatch     = titleMatch
        self.skills         = skills
        self.location       = location
        self.workActivities = workActivities
        self.riasec         = riasecW
    }
}

// MARK: - User Features

/// Precomputed per-batch user data — computed once in scoreJobs(), reused for every job.
private struct UserFeatures {
    let skillSet: Set<String>
    let desiredRoles: [String]
    let desiredRoleWords: [Set<String>]
    let locationData: LocationData?
    let workActivities: [String: Double]?
    let interests: RIASECProfile?
}
