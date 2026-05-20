import Foundation
import CoreData
import Persistence

// MARK: - AffiliateTracker

public actor AffiliateTracker {
    public static let shared = AffiliateTracker()
    private init() {}

    public func recordClickInCoreData(
        course: RecommendedCourse,
        affiliateURL: URL,
        context: NSManagedObjectContext
    ) async throws {
        let objectID = try await context.perform {
            let click = AffiliateClick.create(in: context)
            click.courseID = course.id
            click.courseTitle = course.title
            click.provider = course.provider.rawValue
            click.affiliateURL = affiliateURL.absoluteString
            click.coursePrice = {
                if case .paid(let amount, _) = course.price { return (amount as NSDecimalNumber).doubleValue }
                return 0.0
            }()
            click.estimatedCommission = click.coursePrice * 0.10
            try context.save()
            return click.objectID
        }
        _ = objectID // saved; objectID available for cross-context use if needed
    }
}

// MARK: - AffiliateURLBuilder

public final class AffiliateURLBuilder: @unchecked Sendable {
    public static let shared = AffiliateURLBuilder()

    // Credentials are empty strings until Cloudflare Workers proxy is deployed in Phase 6.
    // Check: !id.isEmpty (not !id.contains("YOUR_") — credentials are empty strings here)
    private static let courseraAffiliateID = ""
    private static let udemyAffiliateID = ""

    private init() {}

    public func buildAffiliateURL(for course: RecommendedCourse) -> URL {
        switch course.provider {
        case .coursera:
            return buildCourseraURL(course: course)
        case .udemy:
            return buildUdemyURL(course: course)
        default:
            return URL(string: course.affiliateURL) ?? fallbackURL(course: course)
        }
    }

    private func buildCourseraURL(course: RecommendedCourse) -> URL {
        let id = Self.courseraAffiliateID
        guard !id.isEmpty,
              var components = URLComponents(string: course.affiliateURL) else {
            return URL(string: course.affiliateURL) ?? fallbackURL(course: course)
        }
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "siteID", value: id))
        components.queryItems = queryItems
        return components.url ?? fallbackURL(course: course)
    }

    private func buildUdemyURL(course: RecommendedCourse) -> URL {
        let id = Self.udemyAffiliateID
        guard !id.isEmpty,
              var components = URLComponents(string: course.affiliateURL) else {
            return URL(string: course.affiliateURL) ?? fallbackURL(course: course)
        }
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "aff_user", value: id))
        components.queryItems = queryItems
        return components.url ?? fallbackURL(course: course)
    }

    private func fallbackURL(course: RecommendedCourse) -> URL {
        URL(string: "https://www.google.com/search?q=\(course.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!
    }
}
