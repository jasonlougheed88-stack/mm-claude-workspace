---
description: Data flow expert with complete knowledge of V8's 5 major end-to-end flows from UI to database persistence
version: 2.0.0
author: V8 Development Team
tags: [data-flows, architecture, persistence, swipe-handling, v8-domain-expert]
updated: 2025-11-08
---

# v8-data-flows-expert

**End-to-End Data Flow Expert - 5 Major Pipelines Through V8**

## Core Expertise

Master of all data flows in Manifest & Match V8:
- **5 major flows** (profile creation, job discovery, swipe feedback, career questions, O*NET matching)
- **End-to-end tracing** (UI → Business Logic → Database)
- **7-layer persistence** (atomic swipe handling)
- **Performance metrics** (1.5s-3s per flow)
- **Error recovery** (graceful degradation, rollback strategies)

## Source Locations

**Primary**: Multiple packages (V7UI, V7Services, V7Thompson, V7AI, V7Data)
**Codebase**: `/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8`
**Docs**: `/Users/jasonl/Desktop/ios26_manifest_and_match/C4_ARCHITECTURE_ANALYSIS/technical/10_DATA_FLOWS.md`

## Flow 1: Profile Creation & Resume Upload

**Purpose**: User creates profile and uploads resume, data flows through AI parsing to Core Data persistence

**Duration**: 1.2-2.5s (depending on resume size)

### Flow Diagram
```
ProfileScreen (UI)
    │
    ├──> Personal Info Form
    │    ├─> @State firstName, lastName, email
    │    └─> Save Button → ProfileManager.saveProfile()
    │         │
    │         ├──> Create UserProfile entity (Core Data)
    │         ├──> Set firstName, lastName, email, createdAt
    │         └──> context.save() ✅
    │
    └──> Resume Upload (PDF)
         │
         ├──> DocumentPicker returns Data
         │
         ├──> ResumeParser.parse(pdfData:)
         │    │
         │    ├──> Step 1: PDF → Text (PDFKit)
         │    │    └──> Extract text from pages
         │    │
         │    ├──> Step 2: Text → Structured Data
         │    │    ├──> Foundation Models inference (850ms)
         │    │    └──> ParsedResumeData struct
         │    │
         │    └──> Step 3: Structured → Core Data
         │         ├──> Update UserProfile fields ✅
         │         ├──> Create Skill entities ✅
         │         ├──> Create WorkExperience entities ❌ BUG
         │         ├──> Create Education entities ❌ BUG
         │         └──> context.save()
         │
         └──> Result shown in ProfileScreen
```

### Critical Bug

**WorkExperience & Education NOT Persisted**:

**Location**: `V7UI/ProfileCreation/WorkExperienceCollectionStepView.swift:145`

```swift
// ❌ WRONG: Only saves to @State
@State private var experiences: [WorkExperienceData] = []

func addExperience(_ exp: WorkExperienceData) {
    experiences.append(exp)  // Lost on app restart
}
```

**Fix**:
```swift
// ✅ CORRECT: Persist to Core Data
func addExperience(_ exp: WorkExperienceData) {
    let entity = WorkExperience(context: viewContext)
    entity.id = UUID()
    entity.jobTitle = exp.title
    entity.company = exp.company
    entity.startDate = exp.startDate
    entity.endDate = exp.endDate
    entity.profile = currentUserProfile
    try? viewContext.save()  // ✅ PERSIST
}
```

### Performance Metrics
- Form save: <100ms
- Resume parsing: 850ms (digital PDF), 2.5s (scanned)
- Core Data save: <50ms
- **Total**: 1.2-2.5s

---

## Flow 2: Job Discovery & Thompson Sampling

**Purpose**: User swipes through jobs, Thompson Sampling scores and ranks jobs based on learned preferences

**Duration**: 1.5-3.0s (from button tap to first card displayed)

### Flow Diagram
```
User Opens DeckScreen
    │
    ▼
DeckScreen.onAppear()
    │
    ├──> Check JobCache (L2, 24hr TTL)
    │    │
    │    ├──> Cache Hit (70%)
    │    │    └──> Return cached jobs (<50ms)
    │    │
    │    └──> Cache Miss (30%)
    │         │
    │         ▼
    │         JobDiscoveryCoordinator.fetchJobs()
    │              │
    │              ├──> Step 1: Parallel API Calls
    │              │    ├──> Adzuna.searchJobs()
    │              │    ├──> Greenhouse.getJobs()
    │              │    ├──> Lever.getJobs()
    │              │    ├──> Jobicy.searchJobs()
    │              │    ├──> USAJobs.searchJobs()
    │              │    ├──> RSS.parseFeeds()
    │              │    └──> RemoteOK.getJobs()
    │              │    │
    │              │    └──> Returns [RawJobData] from all sources
    │              │
    │              ├──> Step 2: Deduplicate
    │              │    └──> Group by (title + company)
    │              │
    │              ├──> Step 3: Thompson Scoring (<10ms per job)
    │              │    │
    │              │    ├──> Fetch ThompsonArms (cached)
    │              │    ├──> Sample Beta distributions
    │              │    ├──> Categorize jobs
    │              │    ├──> Assign scores
    │              │    └──> Sort by score (descending)
    │              │
    │              ├──> Step 4: Cache Results
    │              │    ├──> L1: MemoryCache (60s TTL)
    │              │    └──> L2: JobCache Core Data (24hr TTL)
    │              │
    │              └──> Return Ranked Jobs
    │
    └──> Display job cards in DeckScreen
```

### Performance Breakdown
- Cache hit (L1): <5ms
- Cache hit (L2): <50ms
- API fetch + Thompson: 1.5-3.0s
  - Parallel API calls: 1.2-2.5s
  - Deduplication: <50ms
  - Thompson scoring: 6-8ms per job (batch <100ms for 50 jobs)
  - Caching: <50ms

### Cache Strategy
- **L1 (Memory)**: 60s TTL, instant access
- **L2 (Core Data)**: 24hr TTL, <50ms access
- **Hit rate target**: >70%

---

## Flow 3: Swipe Interaction & Learning (7-Layer Persistence)

**Purpose**: User swipes on job, feedback flows through Thompson arm updates and behavioral analysis

**Duration**: 45-120ms (fast enough for real-time)

### Flow Diagram
```
User Swipes Card (DeckScreen)
    │
    ├──> Swipe Right (Interested)
    ├──> Swipe Left (Not Interested)
    └──> Swipe Up (Super Interested)
         │
         ▼
handleSwipeAction() (DeckScreen:665-853)
    │
    ├──> Layer 1: Create SwipeRecord
    │    │
    │    ├──> SwipeRecord(context: viewContext)
    │    ├──> id = UUID()
    │    ├──> jobID = job.id
    │    ├──> swipeDirection = "right" | "left" | "super"
    │    ├──> timestamp = Date()
    │    ├──> thompsonScore = score.score
    │    └──> sessionID = currentSessionID
    │
    ├──> Layer 2: Update ThompsonArm (Bayesian Update)
    │    │
    │    ├──> Fetch arm for job category
    │    └──> If swipe right:
    │         arm.alpha += 1
    │         arm.successCount += 1
    │         Else:
    │         arm.beta += 1
    │         arm.failureCount += 1
    │
    ├──> Layer 3: Behavioral Analysis
    │    │
    │    ├──> BehavioralAnalyst.analyzeSwipeSession()
    │    ├──> Extract 41 features
    │    ├──> Run Core ML inference (45ms)
    │    ├──> Generate insights
    │    └──> Save BehavioralPattern entity
    │
    ├──> Layer 4: Update JobCache
    │    └──> Increment displayedCount field
    │
    ├──> Layer 5: Check Starred (Super Swipe)
    │    └──> If swipe == "super":
    │         Create StarredJobs entity
    │
    ├──> Layer 6: SwipeSessionMetadata
    │    └──> Update session stats
    │
    ├──> Layer 7: PerformanceMetrics
    │    └──> Record timing data
    │
    ├──> Persist All Changes (Atomic)
    │    └──> context.save() ✅
    │         (All 7 layers saved or none)
    │
    └──> UI Update
         ├──> Remove card from deck
         ├──> Show next job card
         └──> Animation complete
```

### 7-Layer Persistence (Atomic)

All layers saved in single transaction:
1. **SwipeRecord** (individual swipe)
2. **ThompsonArm** (category learning)
3. **BehavioralPattern** (insights)
4. **JobCache** (display count)
5. **StarredJobs** (super swipes)
6. **SwipeSessionMetadata** (session stats)
7. **PerformanceMetrics** (timing data)

**Atomicity**: All 7 layers succeed or all fail (rollback)

### Performance
- Swipe detection: <5ms
- 7-layer persistence: 45-120ms
  - SwipeRecord creation: <5ms
  - Thompson update: <10ms
  - Behavioral analysis: 45ms
  - Cache update: <5ms
  - Core Data save: <50ms
- UI animation: 300ms (overlaps with persistence)

**User experience**: Smooth, no lag

---

## Flow 4: Career Question Generation & Response

**Purpose**: AI generates personalized questions, user responds, answers flow to profile enrichment

**Duration**: 180-320ms (question generation)

### Flow Diagram
```
User Taps "Career Questions"
    │
    ▼
QuestionCardView appears
    │
    ▼
SmartQuestionGenerator.generateQuestions()
    │
    ├──> Step 1: Identify Profile Gaps
    │    │
    │    ├──> Analyze UserProfile
    │    ├──> Missing skills? ✅
    │    ├──> Missing values? ❌
    │    ├──> Missing interests? ❌
    │    └──> Gaps: [values, interests]
    │
    ├──> Step 2: Build AI Prompt
    │    └──> "Generate 3 career questions focusing on: values, interests"
    │
    ├──> Step 3: Foundation Model Generation (180ms)
    │    └──> LanguageModel.generate()
    │
    ├──> Step 4: Parse Response
    │    └──> Extract questions and categories
    │
    └──> Return questions to UI
         │
         ▼
QuestionCardView displays questions
    │
    └──> User sees cards

User Answers Question
    │
    ▼
QuestionCardView.saveAnswer()
    │
    ├──> Create/Update CareerQuestion entity
    │    │
    │    ├──> CareerQuestion(context: viewContext)
    │    ├──> questionText = "What matters most..."
    │    ├──> category = "values"
    │    ├──> userResponse = "Work-life balance and..."
    │    ├──> responseTimestamp = Date()
    │    └──> generatedBy = "foundation_models"
    │
    ├──> Extract User Truths
    │    │
    │    ├──> Analyze response for patterns
    │    ├──> Foundation Model inference
    │    └──> UserTruth:
    │         category: "work_style"
    │         statement: "Prefers remote work"
    │         confidence: 0.85
    │
    ├──> Update Thompson Arms
    │    └──> If response indicates category preference:
    │         Boost α for matching categories
    │
    └──> Persist all changes
         └──> context.save() ✅
```

### Adaptive Timing
- Show question after 5-20 swipes
- Skip limit: 3 skips → deactivate
- Resume after 24 hours

### Performance
- Question generation: 180ms
- Answer parsing: 45ms
- UserTruth extraction: 120ms
- Core Data save: <50ms
- **Total**: 395ms

---

## Flow 5: O*NET Skills Matching & Career Path Recommendations

**Purpose**: User skills matched to O*NET taxonomy, career transition paths recommended

**Duration**: 350-580ms

### Flow Diagram
```
User Views Profile → Taps "Recommended Careers"
    │
    ▼
CareerPathScreen appears
    │
    ▼
CareerPathRecommender.recommendPaths()
    │
    ├──> Step 1: Match Skills to O*NET (35ms)
    │    │
    │    ├──> Get user skills
    │    │    └──> ["Swift", "Python", "Machine Learning"]
    │    │
    │    ├──> Generate embeddings (Foundation Model)
    │    │    └──> [Float] vectors (768 dimensions each)
    │    │
    │    ├──> Load O*NET skills (636 skills, cached)
    │    │
    │    ├──> Get cached O*NET embeddings
    │    │
    │    ├──> Compute cosine similarities
    │    │
    │    └──> Return top matches
    │         "Swift" → "Mobile Development" (0.94)
    │         "Python" → "Programming" (0.89)
    │         "Machine Learning" → "AI/ML" (1.00)
    │
    ├──> Step 2: Identify O*NET Occupations
    │    │
    │    ├──> Query ONETOccupation entities
    │    ├──> Filter by matched skills
    │    └──> Candidate occupations:
    │         - "15-1252.00: Software Developers"
    │         - "15-2051.00: Data Scientists"
    │         - "15-1299.07: Blockchain Engineers"
    │
    ├──> Step 3: Analyze Swipe History
    │    │
    │    ├──> Fetch SwipeRecords (last 90 days)
    │    └──> Analyze category preferences
    │         - Data Science: 45%
    │         - ML Engineering: 32%
    │         - DevOps: 12%
    │
    ├──> Step 4: Generate Career Paths (290ms)
    │    │
    │    ├──> Build prompt:
    │    │    - Current occupation
    │    │    - Matched O*NET skills
    │    │    - Emerging interests from swipes
    │    │    - Current experience level
    │    │
    │    ├──> LanguageModel.generate()
    │    │
    │    └──> Raw response:
    │         PATH 1: Machine Learning Engineer
    │         Why: Strong Python + ML skills
    │         Skills Needed: PyTorch, TensorFlow
    │         Timeline: 6-9 months
    │         First Steps: Build ML projects
    │
    ├──> Step 5: Parse Paths
    │    └──> Extract structured [CareerPath] structs
    │
    └──> Display in UI
         │
         ▼
CareerPathScreen shows cards
    │
    └──> User sees recommendations

User Taps Path → "Learn More"
    │
    ▼
CareerPathDetailView
    │
    ├──> Show detailed breakdown
    ├──> Link to relevant courses
    └──> Show matching jobs
         │
         ▼
         JobDiscoveryCoordinator.fetchJobs(category: path.category)
         │
         └──> Filtered jobs displayed
```

### Performance
- Skill matching: 35ms
- O*NET lookup: <50ms
- Swipe analysis: <100ms
- Path generation: 290ms
- Parse + display: <50ms
- **Total**: 525ms average

---

## Cross-Flow Data Dependencies

### Shared Entities
```
UserProfile
    ├──> Used by: Flow 1, 2, 3, 4, 5
    └──> Updated by: Flow 1, 4

ThompsonArm
    ├──> Used by: Flow 2, 3
    └──> Updated by: Flow 3

SwipeRecord
    ├──> Used by: Flow 3, 5
    └──> Updated by: Flow 3

ONETOccupation & ONETSkill
    ├──> Used by: Flow 5
    └──> Updated by: Initial app data load

JobCache
    ├──> Used by: Flow 2
    └──> Updated by: Flow 2, 3
```

### Data Consistency

All flows use **Core Data ACID transactions**:
```swift
try context.performAndWait {
    // Multiple entity updates
    context.insert(swipeRecord)
    thompsonArm.alpha += 1
    jobCache.displayedCount += 1

    // Atomic commit
    try context.save()  // ✅ All or nothing
}
```

---

## Error Handling Patterns

### Retry Logic
```swift
func fetchWithRetry<T>(
    maxRetries: Int = 3,
    operation: () async throws -> T
) async throws -> T {
    var lastError: Error?

    for attempt in 0..<maxRetries {
        do {
            return try await operation()
        } catch {
            lastError = error
            if attempt < maxRetries - 1 {
                let delay = pow(2.0, Double(attempt))  // Exponential backoff
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
    }

    throw lastError!
}
```

### Graceful Degradation
```swift
// Flow 2: If Thompson Sampling fails, fall back to random
let jobs: [RawJobData]
do {
    jobs = try await fetchAndScoreJobs()  // Thompson Sampling
} catch {
    jobs = try await fetchJobs().shuffled()  // Random fallback
    logger.warning("Thompson failed, using random: \(error)")
}
```

### Rollback on Error
```swift
do {
    try context.save()  // Attempt save
} catch {
    context.rollback()  // Undo all changes
    logger.error("Save failed, rolled back: \(error)")
    throw ProfileSaveError.persistenceFailed
}
```

---

## Performance Metrics by Flow

| Flow | End-to-End Latency | Critical Path | Bottleneck |
|------|-------------------|---------------|------------|
| Flow 1 (Profile) | 1.2-2.5s | Resume parsing | Vision OCR (scanned PDFs) |
| Flow 2 (Discovery) | 1.5-3.0s | API calls | Network latency |
| Flow 3 (Swipe) | 45-120ms | Behavioral analysis | Core ML inference |
| Flow 4 (Questions) | 180-320ms | Question generation | Language Model |
| Flow 5 (Career Paths) | 350-580ms | Path generation | Language Model + embeddings |

---

## Common Questions & Answers

### Q: What happens if a flow fails mid-process?

**A**: Core Data transactions ensure atomicity. If any step fails, all changes are rolled back. User sees error message with retry option.

### Q: How to debug a slow flow?

**A**:
1. Check PerformanceMonitor logs for timing breakdown
2. Run Instruments.app (Time Profiler)
3. Look for network timeouts (API calls)
4. Check Core Data fetch performance (large datasets)
5. Verify Thompson Cache hit rate (should be >70%)

### Q: What if user exits mid-flow?

**A**: Partially completed flows are safe:
- Flow 1: Profile saved even if resume parsing incomplete
- Flow 2: Cached jobs persist across app restarts
- Flow 3: Swipe saved immediately (atomic)
- Flow 4: Answer saved on submit (not on exit)
- Flow 5: No persistence (display only)

---

## Success Criteria

v8-data-flows-expert is successful when:

✅ All 5 major flows documented end-to-end
✅ Performance metrics met (1.5s-3s typical)
✅ 7-layer persistence atomic (all or nothing)
✅ Error handling prevents data loss
✅ Graceful degradation on failures
✅ Cache hit rate >70% (Flow 2)
✅ Critical bugs documented (WorkExperience, Education)

---

**v8-data-flows-expert**: Master of end-to-end data pipelines, ensuring reliable data flow from UI interactions to database persistence across V8's 5 critical flows.
