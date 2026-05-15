---
name: privacy-security-guardian
description: Enforces on-device processing, Keychain security, and privacy-first architecture for sensitive job search data
allowed-tools:
  - Read
  - Grep
  - Edit
---

---
**PACKAGE NAMES — approved 2026-05-15. New build uses these names, NOT V7\* prefixes.**
Full mapping + DAG: `context/PACKAGE_NAMES.md` in the build folder.

| New Name | Old Name |
|---|---|
| CoreTaxonomy | V7Core |
| Persistence | V7Data |
| ScoringEngine | V7Thompson |
| JobPipeline | V7Services |
| DeckUI | V7UI |
| Intelligence | V7AI |
| ResumeParsing | V7AIParsing |
| CareerGrowth | V7Career |
| SemanticMatch | V7Embeddings |
| JobNormalizer | V7JobParsing |
| Monitoring | V7Performance |
| ProfileExtraction | V7ResumeAnalysis |
| AdCards | V7Ads |
| AppShell | ManifestAndMatchV7Package |

Reference codebase paths still use V7\* names — only NEW BUILD code uses new names.
---



## Purpose

Protects user privacy and security in a job search app that handles sensitive data (resumes, profiles, career history, API keys). Enforces Apple's privacy best practices and ensures compliance with privacy regulations.

## Sensitive Data Types

This app handles:
- **Resumes** - Education history, work experience, personal skills
- **Profile Data** - Name, email, phone, location preferences
- **Career History** - Past jobs, employers, salary expectations
- **API Keys** - Indeed, Greenhouse, Lever, OpenAI credentials
- **Search History** - Job preferences reveal career goals
- **Swipe History** - Reveals job preferences and biases

## Sacred Security Principles

1. **On-Device First** - Process sensitive data locally when possible
2. **Keychain for Credentials** - Never store API keys in UserDefaults/files
3. **No Logging of PII** - Never log personal identifiable information
4. **Opt-In Data Sharing** - Explicit consent for any external data sharing
5. **Temporary API Keys** - Refresh tokens, not long-lived credentials

## Activation Triggers

This skill activates when you're working on:
- `V7AIParsing/` - Resume processing with OpenAI
- `V7Services/` - API integrations (API key storage)
- `V7Data/` - Core Data persistence of user profiles
- `V7Migration/` - Migrating sensitive user data
- Any credential storage or authentication code
- Any logging that might include user data

## Critical Enforcement Areas

### 1. Keychain for All Credentials

**NEVER store API keys in UserDefaults or files:**

```swift
// ❌ WRONG: Storing API key in UserDefaults
UserDefaults.standard.set(apiKey, forKey: "openai_api_key")  // SECURITY VIOLATION

// ❌ WRONG: Storing in plist file
let config = ["openai_key": apiKey]
try config.write(to: configURL)  // SECURITY VIOLATION

// ✅ CORRECT: Use Keychain
import Security

actor KeychainService {
    enum KeychainError: Error {
        case saveFailure(OSStatus)
        case loadFailure(OSStatus)
        case deleteFailure(OSStatus)
        case dataConversionFailure
    }

    func saveAPIKey(_ key: String, service: String) throws {
        guard let data = key.data(using: .utf8) else {
            throw KeychainError.dataConversionFailure
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "api_key",
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        // Delete existing item first
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.saveFailure(status)
        }
    }

    func loadAPIKey(service: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "api_key",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else {
            throw KeychainError.loadFailure(status)
        }

        return key
    }

    func deleteAPIKey(service: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "api_key"
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailure(status)
        }
    }
}

// Usage:
let keychainService = KeychainService()
try await keychainService.saveAPIKey(openAIKey, service: "com.manifestandmatch.openai")
```

### 2. On-Device Resume Processing

**Process resumes locally when possible:**

```swift
// ✅ CORRECT: On-device NaturalLanguage processing first
actor ResumeProcessor {
    func extractSkills(from resumeText: String) async -> [String] {
        // Step 1: Try on-device NaturalLanguage framework (PRIVACY-FIRST)
        let localSkills = await extractSkillsLocally(resumeText)

        // Step 2: Only use OpenAI if user explicitly opted in
        guard UserPreferences.shared.allowCloudResumeProcessing else {
            return localSkills
        }

        // Step 3: If opted in, enhance with AI (with consent)
        do {
            let aiSkills = try await extractSkillsWithOpenAI(resumeText)
            return mergeSkills(local: localSkills, ai: aiSkills)
        } catch {
            logger.warning("AI enhancement failed, using local results")
            return localSkills
        }
    }

    private func extractSkillsLocally(_ text: String) async -> [String] {
        let tagger = NLTagger(tagSchemes: [.nameType, .lexicalClass])
        tagger.string = text

        var skills: [String] = []

        // Extract noun phrases (likely skills)
        tagger.enumerateTags(in: text.startIndex..<text.endIndex,
                            unit: .word,
                            scheme: .lexicalClass) { tag, range in
            if tag == .noun {
                skills.append(String(text[range]))
            }
            return true
        }

        return skills
    }
}
```

### 3. No PII in Logs

**Redact personal information from logs:**

```swift
// ❌ WRONG: Logging user email
logger.info("User logged in: \(user.email)")  // PRIVACY VIOLATION

// ❌ WRONG: Logging resume text
logger.debug("Resume text: \(resumeText)")  // PRIVACY VIOLATION

// ✅ CORRECT: Redact PII
extension Logger {
    func logUserAction(_ action: String, userId: UUID) {
        // Only log non-identifiable user ID
        self.info("\(action) - User: \(userId.uuidString.prefix(8))***")
    }

    func logResumeProcessing(resumeId: UUID, success: Bool) {
        // No resume content, just success/failure
        self.info("Resume processed - ID: \(resumeId) - Success: \(success)")
    }

    func logAPIRequest(endpoint: String, duration: TimeInterval) {
        // No API keys, no user data
        self.info("API \(endpoint) - Duration: \(duration)ms")
    }
}

// Usage:
logger.logUserAction("Profile updated", userId: user.id)
logger.logResumeProcessing(resumeId: resume.id, success: true)
```

### 4. Privacy-Aware Core Data Encryption

**Enable Core Data encryption for sensitive fields:**

```swift
// ✅ CORRECT: Encrypted Core Data store
func setupCoreDataStack() -> NSPersistentContainer {
    let container = NSPersistentContainer(name: "ManifestAndMatch")

    let storeURL = FileManager.default.urls(
        for: .applicationSupportDirectory,
        in: .userDomainMask
    ).first!.appendingPathComponent("ManifestAndMatch.sqlite")

    let description = NSPersistentStoreDescription(url: storeURL)

    // Enable encryption
    description.setOption(
        FileProtectionType.complete as NSObject,
        forKey: NSPersistentStoreFileProtectionKey
    )

    // Enable encryption at rest
    description.shouldAddStoreAsynchronously = true

    container.persistentStoreDescriptions = [description]

    container.loadPersistentStores { description, error in
        if let error = error {
            fatalError("Core Data store failed to load: \(error)")
        }
    }

    return container
}
```

### 5. Secure API Communication

**Enforce TLS 1.3 and certificate pinning:**

```swift
// ✅ CORRECT: Secure URLSession configuration
actor NetworkService {
    private let session: URLSession

    init() {
        let configuration = URLSessionConfiguration.default

        // Enforce TLS 1.3 minimum
        configuration.tlsMinimumSupportedProtocolVersion = .TLSv13

        // Disable caching of sensitive data
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData

        // Set timeout
        configuration.timeoutIntervalForRequest = 30.0

        self.session = URLSession(
            configuration: configuration,
            delegate: CertificatePinningDelegate(),
            delegateQueue: nil
        )
    }

    func makeSecureRequest(_ request: URLRequest) async throws -> Data {
        // Validate HTTPS
        guard request.url?.scheme == "https" else {
            throw NetworkError.insecureConnection
        }

        let (data, response) = try await session.data(for: request)

        // Validate TLS
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.url?.scheme == "https" else {
            throw NetworkError.insecureConnection
        }

        return data
    }
}

// Certificate pinning delegate
class CertificatePinningDelegate: NSObject, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // Implement certificate pinning for production API endpoints
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Validate certificate (implement pinning logic here)
        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }
}
```

### 6. User Consent for Data Sharing

**Explicit opt-in for cloud features:**

```swift
// ✅ CORRECT: Privacy consent flow
struct PrivacyConsentView: View {
    @State private var allowCloudProcessing = false
    @State private var allowAnalytics = false
    @State private var allowCrashReporting = false

    var body: some View {
        Form {
            Section(header: Text("Privacy Settings")) {
                Toggle("Enhanced Resume Processing", isOn: $allowCloudProcessing)
                Text("Uses OpenAI to extract skills. Your resume is sent to OpenAI's servers.")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Toggle("Anonymous Analytics", isOn: $allowAnalytics)
                Text("Helps improve the app. No personal data is collected.")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Toggle("Crash Reporting", isOn: $allowCrashReporting)
                Text("Sends anonymous crash logs to help fix bugs.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section {
                Button("View Privacy Policy") {
                    // Open privacy policy
                }

                Button("Delete All Data", role: .destructive) {
                    // Trigger full data deletion
                }
            }
        }
        .navigationTitle("Privacy")
    }
}

// Store preferences securely
actor PrivacyPreferences {
    func updateCloudProcessing(enabled: Bool) async {
        UserDefaults.standard.set(enabled, forKey: "privacy.cloud_processing")

        if !enabled {
            // Delete any cloud-stored data
            await deleteCloudData()
        }
    }

    private func deleteCloudData() async {
        // Implement cloud data deletion
        logger.info("User disabled cloud processing, deleting cloud data")
    }
}
```

### 7. Secure Data Deletion

**Implement right to deletion (GDPR compliance):**

```swift
// ✅ CORRECT: Complete data deletion
actor DataDeletionService {
    func deleteAllUserData() async throws {
        logger.info("Starting complete user data deletion")

        // 1. Delete Core Data
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserProfile")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(deleteRequest)

        // 2. Delete Keychain credentials
        let keychainService = KeychainService()
        try await keychainService.deleteAPIKey(service: "com.manifestandmatch.openai")
        try await keychainService.deleteAPIKey(service: "com.manifestandmatch.indeed")

        // 3. Delete UserDefaults
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)

        // 4. Delete cached files
        let fileManager = FileManager.default
        let cacheURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        try fileManager.removeItem(at: cacheURL)

        // 5. Notify analytics of deletion (if opted in)
        await AnalyticsService.shared.logDataDeletion()

        logger.info("User data deletion complete")
    }
}
```

### 8. Anonymized Analytics

**If analytics are needed, anonymize first:**

```swift
// ❌ WRONG: Sending identifiable data
analytics.track(event: "profile_updated", properties: [
    "email": user.email,           // PRIVACY VIOLATION
    "name": user.name,             // PRIVACY VIOLATION
    "location": user.location      // PRIVACY VIOLATION
])

// ✅ CORRECT: Anonymized analytics
actor AnalyticsService {
    private let anonymousUserId: UUID

    init() {
        // Generate anonymous ID (not linked to user)
        if let stored = UserDefaults.standard.string(forKey: "analytics.anonymous_id"),
           let uuid = UUID(uuidString: stored) {
            self.anonymousUserId = uuid
        } else {
            self.anonymousUserId = UUID()
            UserDefaults.standard.set(anonymousUserId.uuidString, forKey: "analytics.anonymous_id")
        }
    }

    func trackEvent(_ event: String, properties: [String: Any] = [:]) async {
        guard UserPreferences.shared.allowAnalytics else { return }

        var sanitizedProperties = properties

        // Remove any PII
        sanitizedProperties.removeValue(forKey: "email")
        sanitizedProperties.removeValue(forKey: "name")
        sanitizedProperties.removeValue(forKey: "phone")

        // Add only anonymous ID
        sanitizedProperties["anonymous_user_id"] = anonymousUserId.uuidString

        // Send to analytics service
        await sendToAnalytics(event: event, properties: sanitizedProperties)
    }
}
```

## Privacy & Security Checklist

Before merging code that handles sensitive data:

- [ ] API keys stored in Keychain (never UserDefaults/files)
- [ ] Resume processing on-device first (NaturalLanguage)
- [ ] Explicit user consent for cloud features
- [ ] No PII in logs (redact emails, names, phone numbers)
- [ ] Core Data encryption enabled (FileProtectionType.complete)
- [ ] HTTPS enforced (TLS 1.3 minimum)
- [ ] Certificate pinning for production APIs
- [ ] Analytics anonymized (no identifiable data)
- [ ] Data deletion implemented (GDPR compliance)
- [ ] Privacy policy linked in settings

## When This Skill Flags Issues

I will automatically warn you if:

1. **API keys in UserDefaults** - Use Keychain instead
2. **Logging PII** - Email, name, phone in logs
3. **Resume sent to cloud** - Without user consent
4. **Unencrypted Core Data** - Missing FileProtectionType
5. **HTTP connections** - Should be HTTPS
6. **No privacy consent** - Cloud features without opt-in
7. **Identifiable analytics** - User IDs, emails in events
8. **Missing data deletion** - No GDPR compliance

## Reference: Privacy Tiers

```
Tier 1: No Consent Needed (On-Device Only)
├─ NaturalLanguage skill extraction
├─ Local Thompson Sampling
├─ On-device job filtering
└─ Core Data storage (encrypted)

Tier 2: Explicit Consent Required
├─ OpenAI resume processing
├─ Cloud-based skill matching
├─ Analytics events
└─ Crash reporting

Tier 3: Never Collect
├─ Passwords (use Keychain, never store)
├─ Social Security Numbers
├─ Financial information
└─ Health information
```

---

# Privacy & Security Guardian

**Based On:**
- Apple's App Privacy Guidelines
- GDPR requirements (right to deletion)
- `/Packages/V7AIParsing/` - Resume processing
- `/Packages/V7Services/` - API key management
- `/Packages/V7Data/` - Core Data persistence
