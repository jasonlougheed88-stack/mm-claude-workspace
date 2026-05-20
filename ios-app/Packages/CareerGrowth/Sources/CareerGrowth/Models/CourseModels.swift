import Foundation

// MARK: - Provider

public enum CourseProvider: String, Sendable, Codable, CaseIterable {
    case coursera
    case udemy
    case edx
    case linkedin
    case pluralsight
    case skillshare
    case other

    public var displayName: String {
        switch self {
        case .coursera: return "Coursera"
        case .udemy: return "Udemy"
        case .edx: return "edX"
        case .linkedin: return "LinkedIn Learning"
        case .pluralsight: return "Pluralsight"
        case .skillshare: return "Skillshare"
        case .other: return "Online Course"
        }
    }

    // Hex color strings — converted to SwiftUI Color via Color(hex:) in AppShell
    public var brandColor: String {
        switch self {
        case .coursera: return "#0056D2"
        case .udemy: return "#A435F0"
        case .edx: return "#02262B"
        case .linkedin: return "#0A66C2"
        case .pluralsight: return "#F15B2A"
        case .skillshare: return "#00FF84"
        case .other: return "#6B7280"
        }
    }

    public var logoSystemImage: String {
        switch self {
        case .coursera: return "graduationcap.fill"
        case .udemy: return "play.circle.fill"
        case .edx: return "book.fill"
        case .linkedin: return "briefcase.fill"
        case .pluralsight: return "chevron.right.2"
        case .skillshare: return "paintbrush.fill"
        case .other: return "globe"
        }
    }
}

// MARK: - Price

public enum CoursePrice: Sendable, Codable, Hashable {
    case free
    case paid(amount: Decimal, currency: String)
    case subscription

    public var displayText: String {
        switch self {
        case .free: return "Free"
        case .paid(let amount, let currency):
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = currency
            return formatter.string(from: amount as NSDecimalNumber) ?? "\(currency) \(amount)"
        case .subscription: return "Subscription"
        }
    }

    // Custom Codable to handle associated values
    private enum CodingKeys: String, CodingKey { case type, amount, currency }
    private enum PriceType: String, Codable { case free, paid, subscription }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(PriceType.self, forKey: .type)
        switch type {
        case .free: self = .free
        case .subscription: self = .subscription
        case .paid:
            let amount = try container.decode(Decimal.self, forKey: .amount)
            let currency = try container.decode(String.self, forKey: .currency)
            self = .paid(amount: amount, currency: currency)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .free:
            try container.encode(PriceType.free, forKey: .type)
        case .subscription:
            try container.encode(PriceType.subscription, forKey: .type)
        case .paid(let amount, let currency):
            try container.encode(PriceType.paid, forKey: .type)
            try container.encode(amount, forKey: .amount)
            try container.encode(currency, forKey: .currency)
        }
    }
}

// MARK: - Difficulty

public enum DifficultyLevel: Int, Sendable, Codable, CaseIterable {
    case beginner = 1
    case intermediate = 2
    case advanced = 3

    public var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }
}

// MARK: - Skill

public struct Skill: Hashable, Codable, Sendable, Identifiable {
    public let id: String
    public let name: String
    public let category: String

    public init(id: String, name: String, category: String) {
        self.id = id
        self.name = name
        self.category = category
    }
}

// MARK: - SkillsGap

public struct SkillsGap: Identifiable, Sendable, Hashable {
    public let id: String
    public let skill: Skill
    public let priorityScore: Double
    public let impactScore: Double
    public let frequencyScore: Double
    public let difficultyScore: Double
    public let timeToClose: TimeInterval
    public let dependencies: [Skill]

    public init(
        id: String,
        skill: Skill,
        priorityScore: Double,
        impactScore: Double,
        frequencyScore: Double,
        difficultyScore: Double,
        timeToClose: TimeInterval,
        dependencies: [Skill] = []
    ) {
        self.id = id
        self.skill = skill
        self.priorityScore = priorityScore
        self.impactScore = impactScore
        self.frequencyScore = frequencyScore
        self.difficultyScore = difficultyScore
        self.timeToClose = timeToClose
        self.dependencies = dependencies
    }
}

// MARK: - RecommendedCourse

public struct RecommendedCourse: Sendable, Identifiable, Codable, Hashable {
    public let id: String
    public let title: String
    public let provider: CourseProvider
    public let instructor: String
    public let institution: String
    public let duration: TimeInterval
    public let difficulty: DifficultyLevel
    public let skills: [String]
    public let rating: Double
    public let price: CoursePrice
    public let affiliateURL: String
    public let thumbnailURL: String
    public let enrollmentCount: Int
    public var skillMatchPercentage: Double
    public var relevanceScore: Double

    public init(
        id: String,
        title: String,
        provider: CourseProvider,
        instructor: String,
        institution: String,
        duration: TimeInterval,
        difficulty: DifficultyLevel,
        skills: [String],
        rating: Double,
        price: CoursePrice,
        affiliateURL: String,
        thumbnailURL: String,
        enrollmentCount: Int,
        skillMatchPercentage: Double = 0,
        relevanceScore: Double = 0
    ) {
        self.id = id
        self.title = title
        self.provider = provider
        self.instructor = instructor
        self.institution = institution
        self.duration = duration
        self.difficulty = difficulty
        self.skills = skills
        self.rating = rating
        self.price = price
        self.affiliateURL = affiliateURL
        self.thumbnailURL = thumbnailURL
        self.enrollmentCount = enrollmentCount
        self.skillMatchPercentage = skillMatchPercentage
        self.relevanceScore = relevanceScore
    }

    public var formattedDuration: String {
        let hours = Int(duration / 3600)
        if hours < 1 { return "< 1 hr" }
        if hours == 1 { return "1 hr" }
        return "\(hours) hrs"
    }
}
