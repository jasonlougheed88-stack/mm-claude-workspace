---
description: Core Data and data model expert with complete knowledge of V8's 15 entities, relationships, and persistence patterns
version: 2.0.0
author: V8 Development Team
tags: [core-data, data-models, persistence, swift6, sendable, v8-domain-expert]
updated: 2025-11-08
---

# v8-data-models-expert

**Core Data & Data Model Expert - V8 Entity Architecture & Persistence**

## Core Expertise

Master of all data persistence in Manifest & Match V8:
- **15 Core Data entities** (13 in V7Data, 2 in V7AI: CareerQuestion, UserTruths)
- **Swift 6 Sendable patterns** (NSManagedObjectID wrapper)
- **Thread-safe Core Data** (viewContext, backgroundContext)
- **Relationship management** (CASCADE deletes, inverse relationships)
- **31 Swift files in V7Data package**

## Source Locations

**Primary**: `/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8/Packages/V7Data`
**Docs**: `/Users/jasonl/Desktop/ios26_manifest_and_match/C4_ARCHITECTURE_ANALYSIS/technical/06_DATA_MODELS.md`
**Core Data Model**: `V7Data/Sources/V7Data/V7DataModel.xcdatamodeld/V7DataModel.xcdatamodel/contents`

## Core Data Entities (15 Total)

### Profile & Relationships (8 Entities)

#### 1. UserProfile (Root Entity)
**Location**: `V7Data/Sources/V7Data/Entities/UserProfile+CoreData.swift`
**Core Data Model**: Lines 5-105

**Purpose**: Root entity representing a user (singleton pattern)

**Attributes**:
- `userID: UUID` - Primary identifier
- `firstName: String?`
- `lastName: String?`
- `email: String?`
- `phone: String?`
- `location: String?`
- `headline: String?` - Professional headline
- `bio: String?` - Short bio
- `createdAt: Date`
- `updatedAt: Date`

**Relationships**:
- `skills: Set<Skill>` (one-to-many)
- `workExperiences: Set<WorkExperience>` (one-to-many)
- `educations: Set<Education>` (one-to-many)
- `certifications: Set<Certification>` (one-to-many)
- `projects: Set<Project>` (one-to-many)
- `volunteerExperiences: Set<VolunteerExperience>` (one-to-many)
- `awards: Set<Award>` (one-to-many)
- `publications: Set<Publication>` (one-to-many)
- `swipeHistory: Set<SwipeRecord>` (one-to-many)
- `careerQuestions: Set<CareerQuestion>` (one-to-many)
- `userTruths: UserTruths?` (one-to-one)

**Fetch Pattern**:
```swift
extension UserProfile {
    static func fetchCurrent(in context: NSManagedObjectContext) -> UserProfile? {
        let request = UserProfile.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \UserProfile.updatedAt, ascending: false)]
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
}
```

#### 2. WorkExperience
**Location**: `V7Data/Sources/V7Data/Entities/WorkExperience+CoreData.swift`
**Core Data Model**: Lines 108-125

**Purpose**: User's job history

**Attributes**:
- `id: UUID`
- `jobTitle: String`
- `company: String`
- `startDate: Date`
- `endDate: Date?`
- `isCurrent: Bool`
- `description: String?`
- `onetSOCCode: String?` - O*NET occupation code
- `createdAt: Date`

**Relationship**:
- `profile: UserProfile` (many-to-one, CASCADE delete)

**⚠️ CRITICAL BUG**: UI never persists this entity
**Location**: `V7UI/ProfileCreation/WorkExperienceCollectionStepView.swift:145`

#### 3. Education
**Location**: `V7Data/Sources/V7Data/Models/Education+CoreData.swift`

**Purpose**: User's education history

**Attributes**:
- `id: UUID`
- `institution: String`
- `degree: String` - e.g., "Bachelor of Science"
- `fieldOfStudy: String?`
- `startDate: Date`
- `endDate: Date?`
- `isCurrentlyEnrolled: Bool`
- `gpa: Double?`
- `onetEducationLevel: Int16` - Maps to O*NET 12 education levels

**Relationship**:
- `profile: UserProfile` (many-to-one, CASCADE delete)

**⚠️ CRITICAL BUG**: UI never persists this entity
**Location**: `V7UI/ProfileCreation/EducationAndCertificationsStepView.swift:89`

#### 4. Certification
**Attributes**:
- `id: UUID`
- `name: String`
- `issuingOrganization: String`
- `issueDate: Date`
- `expirationDate: Date?`
- `credentialID: String?`
- `credentialURL: String?`

**Relationship**:
- `profile: UserProfile`

#### 5. Project
**Attributes**:
- `id: UUID`
- `title: String`
- `description: String?`
- `startDate: Date`
- `endDate: Date?`
- `isOngoing: Bool`
- `projectURL: String?`
- `technologies: String?` - Comma-separated

**Relationship**:
- `profile: UserProfile`

#### 6. VolunteerExperience
**Attributes**:
- `id: UUID`
- `organization: String`
- `role: String`
- `startDate: Date`
- `endDate: Date?`
- `isCurrent: Bool`
- `description: String?`

**Relationship**:
- `profile: UserProfile`

#### 7. Award
**Attributes**:
- `id: UUID`
- `title: String`
- `issuer: String`
- `date: Date`
- `description: String?`

**Relationship**:
- `profile: UserProfile`

#### 8. Publication
**Attributes**:
- `id: UUID`
- `title: String`
- `publisher: String?`
- `publishedDate: Date`
- `url: String?`
- `description: String?`

**Relationship**:
- `profile: UserProfile`

---

### Behavioral Domain (4 Entities)

#### 9. SwipeRecord
**Location**: `V7Data/Sources/V7Data/Models/SwipeRecord+CoreData.swift`

**Purpose**: Track every job swipe for Thompson Sampling updates

**Attributes**:
- `id: UUID`
- `jobID: UUID` - Reference to job (not stored in Core Data)
- `swipeDirection: String` - "right", "left", "super"
- `timestamp: Date`
- `thompsonScore: Double` - Score at time of swipe
- `profileSnapshot: String?` - JSON of profile state
- `sessionID: UUID` - Groups swipes into sessions
- `cardPosition: Int16` - Position in deck

**Relationship**:
- `profile: UserProfile` (many-to-one)

**7-Layer Persistence**:
When user swipes, DeckScreen saves:
1. SwipeRecord ✅
2. ThompsonArm update ✅
3. BehavioralPattern ✅
4. JobCache update ✅
5. StarredJobs (if super swipe) ✅
6. SwipeSessionMetadata ✅
7. PerformanceMetrics ✅

#### 10. ThompsonArm
**Location**: `V7Data/Sources/V7Data/Models/ThompsonArm+CoreData.swift`

**Purpose**: Store Beta distribution parameters for each job category

**Attributes**:
- `id: UUID`
- `categoryID: String` - Job category identifier
- `alpha: Double` - Beta distribution alpha (successes + 1)
- `beta: Double` - Beta distribution beta (failures + 1)
- `successCount: Int32` - Total right swipes
- `failureCount: Int32` - Total left swipes
- `lastUpdated: Date`
- `lastSampledValue: Double?` - Cache last sample

**Dual Profile Fields**:
- `alphaAmber: Double` - Exploitation profile
- `betaAmber: Double`
- `alphaTeal: Double` - Exploration profile
- `betaTeal: Double`

**Fetch Pattern**:
```swift
extension ThompsonArm {
    static func fetchOrCreate(categoryID: String, in context: NSManagedObjectContext) -> ThompsonArm {
        let request = ThompsonArm.fetchRequest()
        request.predicate = NSPredicate(format: "categoryID == %@", categoryID)

        if let existing = try? context.fetch(request).first {
            return existing
        }

        // Create new arm with Beta(1,1) prior
        let arm = ThompsonArm(context: context)
        arm.id = UUID()
        arm.categoryID = categoryID
        arm.alpha = 1.0
        arm.beta = 1.0
        arm.alphaAmber = 1.0
        arm.betaAmber = 1.0
        arm.alphaTeal = 1.0
        arm.betaTeal = 1.0
        arm.lastUpdated = Date()

        return arm
    }
}
```

### AI/Career Entities (2 Entities - DEFINED IN V7AI)

#### 13. CareerQuestion
**Location**: `V7AI/Sources/V7AI/Models/CareerQuestion+CoreData.swift`
**Core Data Model**: Lines 340-378
**Package**: V7AI (NOT V7Data)

**Purpose**: AI-generated career discovery questions and user responses

**Attributes**:
- `id: UUID`
- `questionText: String`
- `category: String` - "values", "interests", "skills", "lifestyle"
- `userResponse: String?`
- `responseTimestamp: Date?`
- `generatedBy: String` - "foundation_models" or "template"
- `importance: Double` - 0.0-1.0 priority
- `wasSkipped: Bool`
- `skipCount: Int16` - Number of times skipped

**Relationship**:
- `profile: UserProfile` (many-to-one)

**Question Types**:
1. **Open-ended**: "What matters most to you in a career?"
2. **Multiple choice**: "Which work environment do you prefer? (Office/Remote/Hybrid)"
3. **Ranking**: "Rank these values: Growth, Stability, Impact, Flexibility"
4. **Scale**: "How important is work-life balance? (1-10)"

#### 14. UserTruths
**Location**: `V7AI/Sources/V7AI/Models/UserTruths+CoreData.swift`
**Core Data Model**: Lines 381-408
**Package**: V7AI (NOT V7Data)

**Purpose**: Distilled user preferences from questions and swipes

**Attributes**:
- `id: UUID`
- `loveTasks: String?` - JSON array of loved tasks
- `hateTasks: String?` - JSON array of hated tasks
- `workValues: String?` - JSON array of work values
- `interests: String?` - JSON array of interests
- `preferredIndustries: String?` - JSON array
- `avoidedIndustries: String?` - JSON array
- `workStylePreferences: String?` - JSON object
- `riasecProfile: String?` - JSON of 6 Holland Code dimensions
- `confidenceScores: String?` - JSON object with confidence per field
- `lastUpdated: Date`

**Relationship**:
- `profile: UserProfile` (one-to-one, CASCADE delete)

**Swift 6 Sendable Pattern**:
```swift
@preconcurrency import CoreData

extension UserTruths: @unchecked Sendable {
    // Safe because all access goes through NSManagedObjectContext.perform
}
```

#### 15. FallbackCareerQuestion
**Location**: `V7Data/Sources/V7Data/Entities/FallbackCareerQuestion+CoreData.swift`
**Core Data Model**: Lines 411-433

**Purpose**: Phase 3.5 legacy device fallback questions (pre-computed templates)

---

### System Entities (4 Entities)

#### 9. Preferences (SACRED VALUES - IMMUTABLE)
**Location**: `V7Data/Sources/V7Data/Entities/Preferences+CoreData.swift`
**Core Data Model**: Lines 245-263

**Purpose**: Sacred UI constants protected by `Preferences.willSave()` override

#### 10. ThompsonArm
**Location**: `V7Data/Sources/V7Data/Entities/ThompsonArm+CoreData.swift`
**Core Data Model**: Lines 266-290

**Purpose**: Thompson Sampling state (Beta distribution parameters)

#### 11. SwipeHistory
**Location**: `V7Data/Sources/V7Data/Entities/SwipeHistory+CoreData.swift`
**Core Data Model**: Lines 293-311

**Purpose**: User interaction tracking

#### 12. JobCache
**Location**: `V7Data/Sources/V7Data/Entities/JobCache+CoreData.swift`
**Core Data Model**: Lines 314-337

**Purpose**: Cache job data for 24 hours to reduce API calls

**Attributes**:
- `id: UUID`
- `jobID: UUID` - External job ID
- `rawJobData: Data` - JSON blob of RawJobData
- `thompsonScore: Double` - Last computed score
- `categoryID: String`
- `sourceAPI: String` - "adzuna", "greenhouse", etc.
- `fetchedAt: Date`
- `displayedCount: Int16` - How many times shown
- `lastDisplayedAt: Date?`
- `expiresAt: Date` - TTL: 24 hours

**Cache Strategy**:
```swift
extension JobCache {
    static func getOrFetch(jobID: UUID, in context: NSManagedObjectContext) async throws -> RawJobData? {
        // Check cache first
        let request = JobCache.fetchRequest()
        request.predicate = NSPredicate(format: "jobID == %@ AND expiresAt > %@", jobID as CVarArg, Date() as CVarArg)

        if let cached = try? context.fetch(request).first {
            return try? JSONDecoder().decode(RawJobData.self, from: cached.rawJobData)
        }

        // Cache miss - fetch from API
        return nil
    }
}
```

#### 14. Preferences
**Location**: `V7Data/Sources/V7Data/Models/Preferences+CoreData.swift`

**Purpose**: Store SacredUI constants (PROTECTED from modification)

**Attributes**:
- `id: UUID`
- `swipeRightThreshold: Double` - 100.0 (SACRED)
- `swipeLeftThreshold: Double` - -100.0 (SACRED)
- `swipeSuperThreshold: Double` - -80.0 (SACRED)
- `thompsonPerformanceBudget: Double` - 0.010 (10ms in seconds)
- `memoryBudget: Int64` - 200MB baseline
- `uiFPSTarget: Int16` - 60fps

**Protection Mechanism**:
```swift
override func willSave() {
    super.willSave()

    // NEVER allow modification of sacred values
    if changedValues().keys.contains("swipeRightThreshold") {
        swipeRightThreshold = 100.0  // Restore
        logger.error("BLOCKED: Attempt to modify sacred swipeRightThreshold")
    }

    if changedValues().keys.contains("thompsonPerformanceBudget") {
        thompsonPerformanceBudget = 0.010  // Restore
        logger.error("BLOCKED: Attempt to modify sacred thompsonPerformanceBudget")
    }
}
```

---

## Transient Structs (18 Total)

### Job Discovery Structs

#### RawJobData
```swift
struct RawJobData: Codable, Identifiable {
    let id: UUID
    let title: String
    let company: String
    let location: String?
    let description: String
    let salary: SalaryRange?
    let postedDate: Date
    let sourceAPI: String
    let externalURL: URL?
    let requirementsText: String?
    let benefitsText: String?
}
```

#### JobItem (Scored Job)
```swift
struct JobItem: Identifiable {
    let id: UUID
    let rawJob: RawJobData
    let thompsonScore: ThompsonScore
    let onetMatch: Double
    let aiBonus: Double
}
```

#### JobSearchQuery
```swift
struct JobSearchQuery {
    var keywords: [String]
    var location: String?
    var radius: Int? // miles
    var salaryMin: Int?
    var experienceLevel: String?
    var remoteOnly: Bool
}
```

### Parsing Structs

#### ParsedResumeData
```swift
struct ParsedResumeData {
    var personalInfo: PersonalInfo
    var workExperiences: [WorkExperienceData]
    var educations: [EducationData]
    var skills: [String]
    var certifications: [CertificationData]
    var confidence: Double // 0.0-1.0
}
```

---

## Thread Safety Patterns (Swift 6)

### NSManagedObjectID Sendable Wrapper
```swift
struct CoreDataSendable: Sendable {
    let objectID: NSManagedObjectID

    func object<T: NSManagedObject>(in context: NSManagedObjectContext) -> T? {
        return context.object(with: objectID) as? T
    }
}
```

### Thread-Safe Access Pattern
```swift
// ❌ WRONG: Pass NSManagedObject across threads
Task {
    let profile = fetchProfile() // Main thread
    await backgroundTask(profile) // ❌ Crash!
}

// ✅ CORRECT: Pass ObjectID
Task {
    let profileID = fetchProfile().objectID
    await backgroundTask(profileID)

    // Inside backgroundTask:
    await context.perform {
        let profile = context.object(with: profileID) as! UserProfile
        // Safe access here
    }
}
```

### Context.perform for Safety
```swift
func saveProfile(data: ProfileData) async throws {
    try await viewContext.perform {
        let profile = UserProfile(context: self.viewContext)
        profile.firstName = data.firstName
        profile.lastName = data.lastName
        // ... set other fields

        try self.viewContext.save() // Thread-safe
    }
}
```

---

## Persistence Stack

### PersistenceController.swift
**Location**: `V7Data/Sources/V7Data/PersistenceController.swift`

```swift
class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    var backgroundContext: NSManagedObjectContext {
        container.newBackgroundContext()
    }

    init() {
        container = NSPersistentContainer(name: "V7DataModel")

        // Configure
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error)")
            }
        }

        // Main context configuration
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
```

### SwiftUI Environment Injection
```swift
@main
struct ManifestAndMatchApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
        }
    }
}
```

---

## Common Data Operations

### 1. Fetch Current Profile
```swift
@FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \UserProfile.updatedAt, ascending: false)],
    predicate: nil
) var profiles: FetchedResults<UserProfile>

var currentProfile: UserProfile? {
    profiles.first
}
```

### 2. Save Swipe Record (7-Layer)
```swift
func handleSwipe(direction: SwipeDirection, job: RawJobData, score: ThompsonScore) async {
    await viewContext.perform {
        // Layer 1: SwipeRecord
        let swipe = SwipeRecord(context: self.viewContext)
        swipe.id = UUID()
        swipe.jobID = job.id
        swipe.swipeDirection = direction.rawValue
        swipe.timestamp = Date()
        swipe.thompsonScore = score.score

        // Layer 2: Update ThompsonArm
        let arm = ThompsonArm.fetchOrCreate(categoryID: score.categoryID, in: self.viewContext)
        if direction == .right {
            arm.alpha += 1
            arm.successCount += 1
        } else {
            arm.beta += 1
            arm.failureCount += 1
        }

        // Layers 3-7... (BehavioralPattern, JobCache, etc.)

        // Atomic save
        try? self.viewContext.save()
    }
}
```

### 3. Create Work Experience (FIX FOR BUG)
```swift
func addWorkExperience(data: WorkExperienceData, profile: UserProfile) {
    let context = profile.managedObjectContext!

    let experience = WorkExperience(context: context)
    experience.id = UUID()
    experience.jobTitle = data.title
    experience.company = data.company
    experience.startDate = data.startDate
    experience.endDate = data.endDate
    experience.isCurrent = data.isCurrent
    experience.description = data.description
    experience.onetSOCCode = data.onetSOCCode
    experience.createdAt = Date()
    experience.profile = profile

    try? context.save() // ✅ PERSIST
}
```

---

## Relationship Management

### Cascade Deletes
All profile-related entities use CASCADE delete:

```swift
// When UserProfile is deleted, all related entities are automatically deleted:
- WorkExperiences
- Educations
- Certifications
- Projects
- VolunteerExperiences
- Awards
- Publications
- SwipeRecords
- CareerQuestions
- UserTruths
```

### Inverse Relationships
```swift
// UserProfile ↔ WorkExperience
UserProfile.workExperiences (one-to-many)
WorkExperience.profile (many-to-one, inverse)
```

---

## Migration Strategy

### Lightweight Migration (Preferred)
```swift
container.loadPersistentStores { description, error in
    // Automatic lightweight migration
    let options = [
        NSMigratePersistentStoresAutomaticallyOption: true,
        NSInferMappingModelAutomaticallyOption: true
    ]
    description.setOption(options[NSMigratePersistentStoresAutomaticallyOption], forKey: NSMigratePersistentStoresAutomaticallyOption)
}
```

### Manual Migration (V7Migration Package)
**Status**: Disabled in Package.swift
**Purpose**: V5/V6 → V7 data migration (UserDefaults/JSON → Core Data)

---

## Performance Optimization

### Batch Operations
```swift
// Update 1000+ swipe records efficiently
let batchUpdate = NSBatchUpdateRequest(entityName: "SwipeRecord")
batchUpdate.predicate = NSPredicate(format: "timestamp < %@", oldDate as CVarArg)
batchUpdate.propertiesToUpdate = ["archived": true]

try? viewContext.execute(batchUpdate)
```

### Faulting Control
```swift
let request = WorkExperience.fetchRequest()
request.returnsObjectsAsFaults = false // Pre-fetch data
request.relationshipKeyPathsForPrefetching = ["profile"] // Eager load
```

### Fetch Limits
```swift
request.fetchLimit = 50 // Only fetch 50 most recent
request.fetchOffset = 0 // Pagination support
```

---

## Data Validation

### Required Field Validation
```swift
extension UserProfile {
    var isValid: Bool {
        guard let firstName = firstName, !firstName.isEmpty else { return false }
        guard let lastName = lastName, !lastName.isEmpty else { return false }
        guard let email = email, email.contains("@") else { return false }
        return true
    }
}
```

### Relationship Validation
```swift
extension WorkExperience {
    var isValid: Bool {
        guard !jobTitle.isEmpty else { return false }
        guard !company.isEmpty else { return false }
        guard profile != nil else { return false } // Must be linked
        if !isCurrent {
            guard endDate != nil else { return false }
        }
        return true
    }
}
```

---

## Known Issues & Bugs

### 🔴 CRITICAL: WorkExperience Not Persisting
**Location**: `V7UI/ProfileCreation/WorkExperienceCollectionStepView.swift:145`
**Impact**: All work experience data lost on app restart
**Fix**: Add Core Data entity creation + context.save()

### 🔴 CRITICAL: Education Not Persisting
**Location**: `V7UI/ProfileCreation/EducationAndCertificationsStepView.swift:89`
**Impact**: All education data lost on app restart
**Fix**: Add Core Data entity creation + context.save()

---

## Success Criteria

v8-data-models-expert is successful when:

✅ All 14 Core Data entities documented and understood
✅ Thread safety patterns enforced (Swift 6 Sendable)
✅ No NSManagedObject passed across threads
✅ All relationships use CASCADE delete appropriately
✅ WorkExperience and Education bugs documented and tracked
✅ Performance optimizations applied (batch operations, faulting)
✅ Data validation implemented on all entities

---

**v8-data-models-expert**: Master of Core Data architecture, ensuring data integrity and thread-safe persistence across V8's 14 entities and 68K LOC codebase.
