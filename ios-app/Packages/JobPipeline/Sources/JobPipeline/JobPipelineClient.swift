import Foundation
import OSLog
import JobNormalizer

private let logger = Logger(subsystem: "com.manifestandmatch.app", category: "JobPipeline")

// UserDefaults keys for cross-launch rate limit state
private let kBackoffEnd  = "jsearch_backoff_end"
private let kBackoffHits = "jsearch_backoff_hits"

public actor JobPipelineClient {
    public static let shared = JobPipelineClient()
    private init() {}

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        return URLSession(configuration: config)
    }()

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    // MARK: - Public API

    /// Fetch real jobs for the given role query. Falls back to empty array on any failure.
    public func fetchJobs(for query: String) async -> [Job] {
        guard let apiKey = ProcessInfo.processInfo.environment["JSEARCH_API_KEY"],
              !apiKey.isEmpty else {
            logger.debug("JSEARCH_API_KEY not set — skipping real jobs fetch")
            return []
        }
        if let backoffEnd = UserDefaults.standard.object(forKey: kBackoffEnd) as? Date,
           Date() < backoffEnd {
            logger.warning("JSearch in backoff until \(backoffEnd) — skipping fetch")
            return []
        }
        do {
            let raw = try await fetchFromAPI(query: query, apiKey: apiKey)
            let jobs = raw.compactMap { mapToJob($0) }
            clearBackoff()
            logger.info("JSearch: fetched \(jobs.count) jobs for '\(query)'")
            return jobs
        } catch let error as URLError where error.code == .cancelled {
            return []
        } catch {
            handleFetchError(error)
            return []
        }
    }

    // MARK: - Private

    private func fetchFromAPI(query: String, apiKey: String) async throws -> [JSearchJob] {
        var components = URLComponents(string: "https://jsearch.p.rapidapi.com/search")!
        components.queryItems = [
            URLQueryItem(name: "query",      value: query),
            URLQueryItem(name: "page",       value: "1"),
            URLQueryItem(name: "num_pages",  value: "5"),
            URLQueryItem(name: "date_posted", value: "month")
        ]
        var request = URLRequest(url: components.url!)
        request.setValue(apiKey,                     forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue("jsearch.p.rapidapi.com",   forHTTPHeaderField: "X-RapidAPI-Host")
        request.setValue("application/json",          forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw JobFetchError.invalidResponse
        }
        if http.statusCode == 429 {
            recordRateLimitHit()
            throw JobFetchError.rateLimited
        }
        guard http.statusCode == 200 else {
            throw JobFetchError.httpError(http.statusCode)
        }
        let parsed = try decoder.decode(JSearchResponse.self, from: data)
        return parsed.data ?? []
    }

    private func mapToJob(_ raw: JSearchJob) -> Job? {
        guard !raw.jobTitle.isEmpty, !raw.employerName.isEmpty,
              let applyURL = URL(string: raw.jobApplyLink) else { return nil }

        var locationParts: [String] = []
        if let city    = raw.jobCity    { locationParts.append(city) }
        if let state   = raw.jobState   { locationParts.append(state) }
        if let country = raw.jobCountry { locationParts.append(country) }
        let location = locationParts.isEmpty ? "Remote" : locationParts.joined(separator: ", ")

        let isRemote = raw.jobIsRemote ?? false
        let workType: WorkLocationType = isRemote ? .remote : .onsite

        var skills: [String] = []
        if let s = raw.jobRequiredSkills, !s.isEmpty {
            skills = s.components(separatedBy: CharacterSet(charactersIn: ",;|\n"))
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }
        if skills.isEmpty, let desc = raw.jobDescription {
            skills = extractKeySkills(from: desc, title: raw.jobTitle)
        }

        var salary: String? = nil
        if let lo = raw.jobMinSalary, let hi = raw.jobMaxSalary {
            salary = "$\(Int(lo))–$\(Int(hi))"
        }

        var benefits: [String] = []
        if let b = raw.jobBenefits {
            benefits = b.components(separatedBy: CharacterSet(charactersIn: ",\n"))
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }

        let postedDate: Date? = raw.jobPostedAtTimestamp.map { Date(timeIntervalSince1970: $0) }

        let jobLocationData = (raw.jobLatitude != nil || raw.jobLongitude != nil)
            ? JobLocationData(
                locationString: location,
                city: raw.jobCity,
                country: raw.jobCountry,
                timezone: nil,
                latitude: raw.jobLatitude,
                longitude: raw.jobLongitude
              )
            : nil

        return Job(
            title: raw.jobTitle,
            company: raw.employerName,
            location: location,
            description: raw.jobDescription ?? "",
            requirements: skills,
            url: applyURL,
            sector: extractSector(from: raw.jobTitle, description: raw.jobDescription ?? ""),
            benefits: benefits,
            jobType: raw.jobEmploymentType,
            experienceLevel: nil,
            postedDate: postedDate,
            isRemote: isRemote,
            salary: salary,
            requiredSkills: skills,
            workLocationType: workType,
            jobLocationData: jobLocationData
        )
    }

    private func extractKeySkills(from description: String, title: String) -> [String] {
        let combined = "\(title) \(description)".lowercased()
        let known = [
            "Swift", "SwiftUI", "UIKit", "Xcode", "Python", "JavaScript",
            "TypeScript", "React", "Vue", "Angular", "Node.js", "Java",
            "Kotlin", "SQL", "PostgreSQL", "MySQL", "MongoDB", "AWS",
            "Azure", "GCP", "Docker", "Kubernetes", "Git", "CI/CD",
            "Agile", "Scrum", "REST APIs", "GraphQL", "Machine Learning",
            "Salesforce", "HubSpot", "Excel", "Tableau", "Power BI",
            "Project Management", "Product Management", "Leadership",
            "Communication", "Data Analysis", "Customer Service", "Sales"
        ]
        return known.filter { combined.contains($0.lowercased()) }
    }

    private func extractSector(from title: String, description: String) -> String {
        let combined = "\(title) \(description)".lowercased()
        if combined.contains("health") || combined.contains("medical") || combined.contains("nurs") { return "Healthcare" }
        if combined.contains("financ") || combined.contains("bank") || combined.contains("account") { return "Finance" }
        if combined.contains("educat") || combined.contains("teach") { return "Education" }
        if combined.contains("legal") || combined.contains("lawyer") { return "Legal" }
        if combined.contains("retail") || combined.contains("store") { return "Retail" }
        if combined.contains("market") || combined.contains("advertis") { return "Media" }
        return "Technology"
    }

    // MARK: - Backoff

    private func recordRateLimitHit() {
        let hits = UserDefaults.standard.integer(forKey: kBackoffHits) + 1
        UserDefaults.standard.set(hits, forKey: kBackoffHits)
        let delay = min(600.0, 60.0 * pow(2.0, Double(hits - 1)))
        UserDefaults.standard.set(Date().addingTimeInterval(delay), forKey: kBackoffEnd)
        logger.warning("JSearch 429: backoff \(Int(delay))s (hit \(hits))")
    }

    private func clearBackoff() {
        UserDefaults.standard.removeObject(forKey: kBackoffEnd)
        UserDefaults.standard.set(0, forKey: kBackoffHits)
    }

    private func handleFetchError(_ error: Error) {
        if case JobFetchError.rateLimited = error { return }
        logger.error("JSearch fetch failed: \(error)")
    }
}

// MARK: - Errors

private enum JobFetchError: Error {
    case invalidResponse
    case rateLimited
    case httpError(Int)
}

// MARK: - Response Models

private struct JSearchResponse: Decodable, Sendable {
    let status: String?
    let data: [JSearchJob]?
    let error: String?
}

private struct JSearchJob: Decodable, Sendable {
    let jobId: String
    let jobTitle: String
    let employerName: String
    let jobApplyLink: String
    let jobCity: String?
    let jobState: String?
    let jobCountry: String?
    let jobLatitude: Double?
    let jobLongitude: Double?
    let jobDescription: String?
    let jobIsRemote: Bool?
    let jobEmploymentType: String?
    let jobPostedAtTimestamp: TimeInterval?
    let jobMinSalary: Double?
    let jobMaxSalary: Double?
    let jobBenefits: String?
    let jobRequiredSkills: String?

    enum CodingKeys: String, CodingKey {
        case jobId = "job_id"
        case jobTitle = "job_title"
        case employerName = "employer_name"
        case jobApplyLink = "job_apply_link"
        case jobCity = "job_city"
        case jobState = "job_state"
        case jobCountry = "job_country"
        case jobLatitude = "job_latitude"
        case jobLongitude = "job_longitude"
        case jobDescription = "job_description"
        case jobIsRemote = "job_is_remote"
        case jobEmploymentType = "job_employment_type"
        case jobPostedAtTimestamp = "job_posted_at_timestamp"
        case jobMinSalary = "job_min_salary"
        case jobMaxSalary = "job_max_salary"
        case jobBenefits = "job_benefits"
        case jobRequiredSkills = "job_required_skills"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        jobId            = try  c.decode(String.self, forKey: .jobId)
        jobTitle         = try  c.decode(String.self, forKey: .jobTitle)
        employerName     = try  c.decode(String.self, forKey: .employerName)
        jobApplyLink     = try  c.decode(String.self, forKey: .jobApplyLink)
        jobCity          = try? c.decodeIfPresent(String.self,       forKey: .jobCity)
        jobState         = try? c.decodeIfPresent(String.self,       forKey: .jobState)
        jobCountry       = try? c.decodeIfPresent(String.self,       forKey: .jobCountry)
        jobLatitude      = try? c.decodeIfPresent(Double.self,       forKey: .jobLatitude)
        jobLongitude     = try? c.decodeIfPresent(Double.self,       forKey: .jobLongitude)
        jobDescription   = try? c.decodeIfPresent(String.self,       forKey: .jobDescription)
        jobIsRemote      = try? c.decodeIfPresent(Bool.self,         forKey: .jobIsRemote)
        jobEmploymentType = try? c.decodeIfPresent(String.self,      forKey: .jobEmploymentType)
        jobPostedAtTimestamp = try? c.decodeIfPresent(TimeInterval.self, forKey: .jobPostedAtTimestamp)
        jobMinSalary     = try? c.decodeIfPresent(Double.self,       forKey: .jobMinSalary)
        jobMaxSalary     = try? c.decodeIfPresent(Double.self,       forKey: .jobMaxSalary)
        jobBenefits      = try? c.decodeIfPresent(String.self,       forKey: .jobBenefits)
        jobRequiredSkills = try? c.decodeIfPresent(String.self,      forKey: .jobRequiredSkills)
    }
}
