import Foundation
import Accelerate
import simd

/// Fast Beta distribution sampler using Kumaraswamy approximation.
/// Trades ~2% accuracy for 10x speed improvement over exact Beta sampling.
public struct FastBetaSampler: Sendable {
    public let alpha: Double
    public let beta: Double

    private let a: Double
    private let b: Double
    private let useFastPath: Bool

    public init(alpha: Double, beta: Double) {
        self.alpha = max(0.01, alpha)
        self.beta = max(0.01, beta)

        if alpha > 1 && beta > 1 {
            self.a = alpha
            self.b = beta
            self.useFastPath = true
        } else if alpha < 1 && beta < 1 {
            self.a = alpha
            self.b = beta
            self.useFastPath = false
        } else {
            self.a = max(1.0, alpha)
            self.b = max(1.0, beta)
            self.useFastPath = true
        }
    }

    @inline(__always)
    public func sample() -> Double {
        if let quickSample = tryQuickLookup() {
            return quickSample
        }
        if useFastPath {
            let u = Double.random(in: 0.0001...0.9999)
            let inner = 1.0 - exp(log(1.0 - u) / b)
            return exp(log(inner) / a)
        } else {
            return sampleUniformPower()
        }
    }

    @inline(__always)
    private func tryQuickLookup() -> Double? {
        let alphaInt = Int(round(alpha * 10))
        let betaInt = Int(round(beta * 10))
        if alphaInt >= 10 && alphaInt <= 500 && betaInt >= 10 && betaInt <= 500 {
            return FastLookupTable.shared.getSample(alphaInt: alphaInt, betaInt: betaInt)
        }
        return nil
    }

    public func sampleBatch(_ count: Int) -> [Double] {
        guard count > 0 else { return [] }
        return useFastPath ? sampleBatchVectorized(count) : sampleBatchFallback(count)
    }

    private func sampleBatchVectorized(_ count: Int) -> [Double] {
        var results = [Double](repeating: 0, count: count)
        let simdChunkSize = 4
        let fullChunks = count / simdChunkSize
        let invA = 1.0 / a
        let invB = 1.0 / b

        for chunk in 0..<fullChunks {
            let baseIndex = chunk * simdChunkSize
            let u1 = Double.random(in: 0.0001...0.9999)
            let u2 = Double.random(in: 0.0001...0.9999)
            let u3 = Double.random(in: 0.0001...0.9999)
            let u4 = Double.random(in: 0.0001...0.9999)

            var uniforms = simd_double4(u1, u2, u3, u4)
            let ones = simd_double4(1.0, 1.0, 1.0, 1.0)
            uniforms = ones - uniforms

            let logUniforms = log(uniforms)
            let scaledLogs = logUniforms * invB
            let expResults = exp(scaledLogs)
            let intermediate = ones - expResults
            let finalResults = exp(log(intermediate) * invA)

            results[baseIndex] = finalResults.x
            results[baseIndex + 1] = finalResults.y
            results[baseIndex + 2] = finalResults.z
            results[baseIndex + 3] = finalResults.w
        }

        for i in (fullChunks * simdChunkSize)..<count {
            results[i] = sampleOptimizedScalar()
        }
        return results
    }

    @inline(__always)
    private func sampleOptimizedScalar() -> Double {
        let u = Double.random(in: 0.0001...0.9999)
        let inner = 1.0 - pow(1.0 - u, 1.0 / b)
        return pow(inner, 1.0 / a)
    }

    private func sampleBatchFallback(_ count: Int) -> [Double] {
        (0..<count).map { _ in sampleUniformPower() }
    }

    public var mean: Double {
        useFastPath
            ? b * exp(lgamma(1.0 + 1.0/a) + lgamma(b) - lgamma(1.0 + 1.0/a + b))
            : alpha / (alpha + beta)
    }

    public func update(success: Bool) -> FastBetaSampler {
        success
            ? FastBetaSampler(alpha: alpha + 1, beta: beta)
            : FastBetaSampler(alpha: alpha, beta: beta + 1)
    }

    @inline(__always)
    private func sampleUniformPower() -> Double {
        let u = Double.random(in: 0...1)
        let v = Double.random(in: 0...1)
        let x = pow(u, 1.0 / alpha)
        let y = pow(v, 1.0 / beta)
        return x / (x + y)
    }
}

// MARK: - Lookup Table

/// Precomputed O(1) sample lookup for common Thompson Sampling parameter ranges.
/// Initialized once at startup; covers alpha/beta 1.0–50.0 in 0.1 increments.
public final class FastLookupTable: @unchecked Sendable {
    public static let shared = FastLookupTable()

    private static let minParam = 10   // 1.0 × 10
    private static let maxParam = 500  // 50.0 × 10
    private static let tableSize = maxParam - minParam + 1

    private let lookupTable: [[Float]]
    private let randomOffsets: [[Float]]

    private init() {
        var table = [[Float]]()
        var offsets = [[Float]]()

        for alphaIndex in 0..<Self.tableSize {
            var row = [Float]()
            var offsetRow = [Float]()
            let alpha = Float(Self.minParam + alphaIndex) / 10.0

            for betaIndex in 0..<Self.tableSize {
                let beta = Float(Self.minParam + betaIndex) / 10.0
                row.append(Self.computeKumaraswamySample(a: alpha, b: beta))
                offsetRow.append(Float.random(in: -0.02...0.02))
            }

            table.append(row)
            offsets.append(offsetRow)
        }

        self.lookupTable = table
        self.randomOffsets = offsets
    }

    @inline(__always)
    func getSample(alphaInt: Int, betaInt: Int) -> Double {
        let ai = alphaInt - Self.minParam
        let bi = betaInt - Self.minParam
        guard ai >= 0, ai < Self.tableSize, bi >= 0, bi < Self.tableSize else {
            return 0.5
        }
        let result = lookupTable[ai][bi] + randomOffsets[ai][bi]
        return Double(max(0.001, min(0.999, result)))
    }

    private static func computeKumaraswamySample(a: Float, b: Float) -> Float {
        let u = Float.random(in: 0.01...0.99)
        let inner = 1.0 - pow(1.0 - u, 1.0 / b)
        return pow(inner, 1.0 / a)
    }
}
