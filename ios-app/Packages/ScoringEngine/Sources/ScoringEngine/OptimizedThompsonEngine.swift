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
