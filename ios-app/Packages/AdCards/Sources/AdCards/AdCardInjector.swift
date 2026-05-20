import Foundation

// MARK: - Seeded Random Generator

/// Deterministic LCG for reproducible ad position variance. Enables unit testing
/// with predictable outcomes while maintaining variance in production.
struct SeededRandomGenerator: Sendable {
    private var state: UInt64

    init(seed: UInt64) { self.state = seed }

    mutating func nextInt(in range: ClosedRange<Int>) -> Int {
        let a: UInt64 = 1_664_525
        let c: UInt64 = 1_013_904_223
        let m: UInt64 = UInt64(1) << 32
        state = (a &* state &+ c) % m
        return range.lowerBound + Int(state % UInt64(range.count))
    }
}

// MARK: - Configuration

public struct AdInjectionConfiguration: Sendable {
    public let baseRatio: Int
    public let variance: Int
    public let maxAdsPerSession: Int
    public let minimumJobsBetweenAds: Int
    public let newUserRatio: Int
    public let newUserThreshold: Int
    public let firstAdMinimumPosition: Int
    public let antiClusteringGap: Int

    public static let standard = AdInjectionConfiguration(
        baseRatio: 10,
        variance: 1,
        maxAdsPerSession: 20,
        minimumJobsBetweenAds: 10,
        newUserRatio: 15,
        newUserThreshold: 50,
        firstAdMinimumPosition: 5,
        antiClusteringGap: 8
    )

    public static let testing = AdInjectionConfiguration(
        baseRatio: 5,
        variance: 1,
        maxAdsPerSession: 50,
        minimumJobsBetweenAds: 5,
        newUserRatio: 8,
        newUserThreshold: 20,
        firstAdMinimumPosition: 2,
        antiClusteringGap: 4
    )
}

// MARK: - Ad Card Injector

/// Actor-isolated ad position calculator. Determines where in the job feed ad cards
/// should appear based on ratio, session state, and anti-clustering rules.
public actor AdCardInjector {
    public static let shared = AdCardInjector()

    private let configuration: AdInjectionConfiguration
    private var randomGenerator: SeededRandomGenerator
    private var sessionAdCount: Int = 0
    private var usedPositions: Set<Int> = []

    public init(configuration: AdInjectionConfiguration = .standard, seed: UInt64? = nil) {
        self.configuration = configuration
        self.randomGenerator = SeededRandomGenerator(
            seed: seed ?? UInt64(Date().timeIntervalSince1970 * 1000)
        )
    }

    // MARK: - Public API

    /// Returns positions (0-based) in a job array where ad cards should be inserted.
    /// Call once per batch of jobs; pass the current session ad count for limit enforcement.
    public func calculateAdPositions(
        totalJobs: Int,
        sessionAdCount: Int,
        isNewUser: Bool
    ) -> [Int] {
        self.sessionAdCount = sessionAdCount
        let ratio = isNewUser ? configuration.newUserRatio : configuration.baseRatio
        var positions = calculateBasePositions(totalJobs: totalJobs, ratio: ratio)
        positions = applyVariance(to: positions)
        positions = filterBySessionLimits(positions: positions)
        positions = enforceAntiClustering(positions: positions)
        positions = filterEdgePositions(positions: positions, totalJobs: totalJobs)
        return positions
    }

    public func recordAdShown(at position: Int) {
        sessionAdCount += 1
        usedPositions.insert(position)
    }

    public func resetSession() {
        sessionAdCount = 0
        usedPositions.removeAll()
    }

    // MARK: - Private Helpers

    private func calculateBasePositions(totalJobs: Int, ratio: Int) -> [Int] {
        stride(from: ratio, to: totalJobs, by: ratio).map { $0 }
    }

    private func applyVariance(to positions: [Int]) -> [Int] {
        positions.map { pos in
            pos + randomGenerator.nextInt(in: -configuration.variance...configuration.variance)
        }
    }

    private func filterBySessionLimits(positions: [Int]) -> [Int] {
        Array(positions.prefix(configuration.maxAdsPerSession - sessionAdCount))
    }

    private func enforceAntiClustering(positions: [Int]) -> [Int] {
        var valid: [Int] = []
        for pos in positions.sorted() {
            if let last = valid.last, pos - last < configuration.antiClusteringGap { continue }
            valid.append(pos)
        }
        return valid
    }

    private func filterEdgePositions(positions: [Int], totalJobs: Int) -> [Int] {
        positions.filter { $0 >= configuration.firstAdMinimumPosition && $0 < totalJobs - 3 }
    }
}

#if DEBUG
extension AdCardInjector {
    public static func testInstance(seed: UInt64, configuration: AdInjectionConfiguration = .testing) -> AdCardInjector {
        AdCardInjector(configuration: configuration, seed: seed)
    }
}
#endif
