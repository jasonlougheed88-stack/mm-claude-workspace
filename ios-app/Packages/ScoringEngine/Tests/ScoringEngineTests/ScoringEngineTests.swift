import XCTest
import JobNormalizer
@testable import ScoringEngine

final class ScoringEngineTests: XCTestCase {

    // MARK: - Performance Gate

    /// Sacred budget: score 100 jobs in <10ms.
    /// Run with: swift test --filter ScoringEngineTests/testScoringPerformance
    func testScoringPerformance() async {
        let engine = await makeEngine()
        let jobs = makeSyntheticJobs(count: 100)
        let profile = makeSyntheticProfile()

        // Warm up (excludes FastLookupTable init from measurement)
        _ = await engine.scoreJobs(jobs, profile: profile)

        let start = CFAbsoluteTimeGetCurrent()
        let results = await engine.scoreJobs(jobs, profile: profile)
        let elapsedMs = (CFAbsoluteTimeGetCurrent() - start) * 1000

        XCTAssertEqual(results.count, 100)
        XCTAssertLessThan(elapsedMs, 10.0, "Scoring 100 jobs took \(String(format: "%.2f", elapsedMs))ms — exceeds 10ms sacred budget")

        print("✅ Scoring 100 jobs: \(String(format: "%.2f", elapsedMs))ms")
    }

    // MARK: - Correctness: Title Match

    func testTitleMatch_exactSubstring_returns1() async {
        let engine = await makeEngine()
        let jobs = [makeJob(title: "Senior Software Engineer")]
        let profile = makeProfile(desiredRoles: ["Software Engineer"])
        let results = await engine.scoreJobs(jobs, profile: profile)
        // title weight at default blend (0.5): should produce a high score
        XCTAssertGreaterThan(results[0].matchScore, 0.5)
    }

    func testTitleMatch_partialWordOverlap_higherThanNoMatch() async {
        let engine = await makeEngine()
        let partial = makeJob(title: "Platform Engineer")
        let unrelated = makeJob(title: "Content Writer")
        let profile = makeProfile(desiredRoles: ["Software Engineer"])
        let results = await engine.scoreJobs([partial, unrelated], profile: profile)
        // "Engineer" is a shared significant word — partial should outscore unrelated
        XCTAssertGreaterThan(results[0].matchScore, results[1].matchScore)
    }

    // MARK: - Correctness: Thompson Score Structure

    func testScoreJobs_producesThompsonScore() async {
        let engine = await makeEngine()
        let jobs = makeSyntheticJobs(count: 1)
        let profile = makeSyntheticProfile()
        let results = await engine.scoreJobs(jobs, profile: profile)
        XCTAssertNotNil(results[0].thompsonScore)
        let score = results[0].thompsonScore!
        XCTAssertGreaterThanOrEqual(score.combinedScore, 0.0)
        XCTAssertLessThanOrEqual(score.combinedScore, 1.0)
        XCTAssertGreaterThanOrEqual(score.personalScore, 0.0)
        XCTAssertLessThanOrEqual(score.personalScore, 1.0)
    }

    // MARK: - Correctness: combinedScore bounds

    func testCombinedScore_alwaysInZeroToOne() async {
        let engine = await makeEngine()
        let jobs = makeSyntheticJobs(count: 50)
        let profile = makeSyntheticProfile()
        let results = await engine.scoreJobs(jobs, profile: profile)
        for job in results {
            XCTAssertGreaterThanOrEqual(job.matchScore, 0.0)
            XCTAssertLessThanOrEqual(job.matchScore, 1.0)
        }
    }

    // MARK: - Helpers

    private func makeEngine() async -> OptimizedThompsonEngine {
        let engine = OptimizedThompsonEngine.shared
        await engine.setProfileBlend(0.5)
        return engine
    }

    private func makeSyntheticJobs(count: Int) -> [Job] {
        let titles = ["Software Engineer", "Product Manager", "Data Scientist",
                      "UX Designer", "DevOps Engineer", "Marketing Manager",
                      "Sales Representative", "Financial Analyst", "HR Specialist", "Operations Lead"]
        return (0..<count).map { i in
            Job(
                title: titles[i % titles.count],
                company: "Company \(i)",
                location: i % 3 == 0 ? "Remote" : "San Francisco, CA",
                requirements: ["Swift", "Python", "SQL", "Leadership", "Communication"].shuffled().prefix(3).map(String.init),
                isRemote: i % 3 == 0,
                workLocationType: i % 3 == 0 ? .remote : .onsite
            )
        }
    }

    private func makeSyntheticProfile() -> UserProfile {
        UserProfile(
            preferences: UserPreferences(
                desiredRoles: ["Software Engineer", "iOS Developer"],
                primaryLocation: LocationData(
                    city: "San Francisco",
                    country: "United States",
                    countryCode: "US",
                    timezone: TimeZone(identifier: "America/Los_Angeles")!,
                    latitude: 37.7749,
                    longitude: -122.4194
                )
            ),
            professionalProfile: ProfessionalProfile(
                skills: ["Swift", "Python", "SQL"],
                resumeSkills: ["Swift", "iOS", "Xcode"],
                onetSkills: ["Python", "SQL", "Leadership"]
            )
        )
    }

    private func makeJob(title: String) -> Job {
        Job(title: title, company: "Acme", requirements: ["Swift", "Python"])
    }

    private func makeProfile(desiredRoles: [String]) -> UserProfile {
        UserProfile(
            preferences: UserPreferences(desiredRoles: desiredRoles),
            professionalProfile: ProfessionalProfile(skills: ["Swift"])
        )
    }
}
