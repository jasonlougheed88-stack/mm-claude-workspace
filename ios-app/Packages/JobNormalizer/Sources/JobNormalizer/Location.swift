import Foundation

// MARK: - Work Location Type

public enum WorkLocationType: String, Codable, Sendable {
    case remote
    case hybrid
    case onsite

    public var maxCommutableMiles: Double {
        switch self {
        case .remote:  return Double.infinity
        case .hybrid:  return 50.0
        case .onsite:  return 40.0
        }
    }
}

// MARK: - Location Data

/// User's home location for distance/timezone scoring
public struct LocationData: Codable, Sendable, Equatable {
    public let city: String
    public let country: String
    public let countryCode: String
    public let timezone: TimeZone
    public let latitude: Double
    public let longitude: Double

    public init(
        city: String,
        country: String,
        countryCode: String = "XX",
        timezone: TimeZone,
        latitude: Double,
        longitude: Double
    ) {
        self.city = city
        self.country = country
        self.countryCode = countryCode
        self.timezone = timezone
        self.latitude = latitude
        self.longitude = longitude
    }

    /// Haversine great-circle distance in miles
    public func distanceTo(latitude: Double, longitude: Double) -> Double {
        let R = 3959.0
        let lat1 = self.latitude * .pi / 180
        let lat2 = latitude * .pi / 180
        let dLat = (latitude - self.latitude) * .pi / 180
        let dLon = (longitude - self.longitude) * .pi / 180
        let a = sin(dLat/2)*sin(dLat/2) + cos(lat1)*cos(lat2)*sin(dLon/2)*sin(dLon/2)
        return R * 2 * atan2(sqrt(a), sqrt(1 - a))
    }

    public func timezoneOffsetHoursTo(_ other: TimeZone) -> Int {
        abs(timezone.secondsFromGMT() / 3600 - other.secondsFromGMT() / 3600)
    }
}

// MARK: - Job Location Data

/// Parsed location data from a job listing's location string
public struct JobLocationData: Codable, Sendable, Equatable {
    public let locationString: String
    public let city: String?
    public let country: String?
    public let timezone: TimeZone?
    public let latitude: Double?
    public let longitude: Double?

    public var isGeocoded: Bool {
        latitude != nil && longitude != nil && country != nil && timezone != nil
    }

    public init(
        locationString: String,
        city: String? = nil,
        country: String? = nil,
        timezone: TimeZone? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.locationString = locationString
        self.city = city
        self.country = country
        self.timezone = timezone
        self.latitude = latitude
        self.longitude = longitude
    }
}

// MARK: - RIASEC Profile

/// Holland Code personality profile. Scores on O*NET 0–7 scale.
public struct RIASECProfile: Codable, Sendable, Equatable {
    public let realistic: Double
    public let investigative: Double
    public let artistic: Double
    public let social: Double
    public let enterprising: Double
    public let conventional: Double

    public init(
        realistic: Double = 0,
        investigative: Double = 0,
        artistic: Double = 0,
        social: Double = 0,
        enterprising: Double = 0,
        conventional: Double = 0
    ) {
        self.realistic = realistic
        self.investigative = investigative
        self.artistic = artistic
        self.social = social
        self.enterprising = enterprising
        self.conventional = conventional
    }

    /// Cosine similarity to another RIASEC profile (0–1)
    public func cosineSimilarity(to other: RIASECProfile) -> Double {
        let a = [realistic, investigative, artistic, social, enterprising, conventional]
        let b = [other.realistic, other.investigative, other.artistic, other.social, other.enterprising, other.conventional]
        let dot = zip(a, b).map(*).reduce(0, +)
        let magA = sqrt(a.map { $0 * $0 }.reduce(0, +))
        let magB = sqrt(b.map { $0 * $0 }.reduce(0, +))
        guard magA > 0, magB > 0 else { return 0 }
        return dot / (magA * magB)
    }
}
