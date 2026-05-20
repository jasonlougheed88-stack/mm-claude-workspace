import Foundation

// MARK: - JSON decode structs (private — match actual courses_v1.json schema)

private struct CourseCatalogJSON: Codable {
    let courses: [CourseJSONModel]
}

private struct CourseJSONModel: Codable {
    let id: String
    let provider: String
    let title: String
    let instructor: String
    let institution: String
    let duration: TimeInterval
    let difficulty: String
    let skills: [String]
    let rating: Double
    let priceUSD: Double
    let affiliateURL: String
    let thumbnailURL: String
    let enrollmentCount: Int
}

// MARK: - CourseDatabase

public actor CourseDatabase {
    public static let shared = CourseDatabase()

    private var courses: [RecommendedCourse] = []
    private var isLoaded = false

    private init() {}

    public func loadIfNeeded() async throws {
        guard !isLoaded else { return }

        guard let url = Bundle.module.url(forResource: "courses_v1", withExtension: "json", subdirectory: "Courses.bundle") else {
            throw CourseDatabaseError.fileNotFound
        }

        let data = try Data(contentsOf: url)
        let catalog = try JSONDecoder().decode(CourseCatalogJSON.self, from: data)
        courses = catalog.courses.compactMap { Self.translate($0) }
        isLoaded = true
    }

    public func allCourses() async throws -> [RecommendedCourse] {
        try await loadIfNeeded()
        return courses
    }

    public func courses(matching skillNames: [String]) async throws -> [RecommendedCourse] {
        try await loadIfNeeded()
        let lowered = skillNames.map { $0.lowercased() }
        return courses.filter { course in
            course.skills.contains { skill in
                lowered.contains(skill.lowercased())
            }
        }
    }

    public func courses(containing keyword: String) async throws -> [RecommendedCourse] {
        try await loadIfNeeded()
        let lowered = keyword.lowercased()
        return courses.filter { course in
            course.title.lowercased().contains(lowered) ||
            course.skills.contains { $0.lowercased().contains(lowered) }
        }
    }

    // MARK: - Translation

    private static func translate(_ json: CourseJSONModel) -> RecommendedCourse? {
        let provider = CourseProvider(rawValue: json.provider.lowercased()) ?? .other
        let difficulty = parseDifficulty(json.difficulty)
        let price: CoursePrice = json.priceUSD == 0.0 ? .free : .paid(amount: Decimal(json.priceUSD), currency: "USD")

        return RecommendedCourse(
            id: json.id,
            title: json.title,
            provider: provider,
            instructor: json.instructor,
            institution: json.institution,
            duration: json.duration,
            difficulty: difficulty,
            skills: json.skills,
            rating: json.rating,
            price: price,
            affiliateURL: json.affiliateURL,
            thumbnailURL: json.thumbnailURL,
            enrollmentCount: json.enrollmentCount
        )
    }

    private static func parseDifficulty(_ string: String) -> DifficultyLevel {
        switch string.lowercased() {
        case "beginner": return .beginner
        case "intermediate": return .intermediate
        case "advanced": return .advanced
        default: return .beginner
        }
    }
}

// MARK: - Errors

public enum CourseDatabaseError: Error {
    case fileNotFound
    case decodingFailed
}
