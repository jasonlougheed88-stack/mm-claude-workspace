# Phase 3.5 Checklist Executor
**Type**: Meta-Task Orchestrator
**Purpose**: Automated execution of PHASE_3.5_CHECKLIST_INTEGRATED_v3.md with foolproof task management

## Core Function

Execute Phase 3.5 implementation tasks in exact order from the checklist, preventing mid-task changes and ensuring document consistency.

## Workflow

### 1. Task Extraction
```
- Read /Users/jasonl/Desktop/ios26_manifest_and_match/O*net research/phase upgrages/PHASE_3.5_CHECKLIST_INTEGRATED_v3.md
- Parse all unchecked `- [ ]` tasks in document order
- Extract task description and line number
- Build ordered task queue
```

### 2. Batch Loading (5 tasks at a time)
```
- Load next 5 unchecked tasks from queue
- Write to TodoWrite with:
  - content: Exact task text from document
  - status: pending (first task) or pending (others)
  - activeForm: Present continuous form
- Reference: "From PHASE_3.5_CHECKLIST_INTEGRATED_v3.md line {number}"
```

### 3. Task Execution Rules

**CRITICAL: Once tasks are loaded, DO NOT modify the todo list until all 5 are complete**

For each task:
1. Mark as `in_progress` in TodoWrite
2. Read relevant section from PHASE_3.5_CHECKLIST_INTEGRATED_v3.md
3. Execute work referencing document code/instructions
4. **UPDATE DOCUMENT IMMEDIATELY**:
   - Use Edit tool to change `- [ ]` → `- [x]` in PHASE_3.5_CHECKLIST_INTEGRATED_v3.md
   - Update on the exact line number where task was found
   - Verify checkbox is checked before proceeding
5. Mark as `completed` in TodoWrite
6. Move to next task

**MANDATORY**: Every task completion MUST update the source document. This is non-negotiable.

### 4. Auto-Load Next Batch

When all 5 tasks are `completed`:
```
- Clear completed tasks from todo list
- Re-scan document to find next 5 unchecked tasks
- Report progress: "Completed batch X/Y (Z% complete)"
- Load next 5 unchecked tasks from document
- Continue execution
- Repeat until no unchecked tasks remain
```

### 5. Progress Tracking in Document

**Add progress header to document** at the top after each batch:

```markdown
<!-- PROGRESS TRACKING - AUTO-UPDATED -->
**Overall Progress**: 15/127 tasks complete (11.8%)
**Current Section**: Week 11, Day 8-9 - BehavioralEventLog
**Last Updated**: 2025-11-01 14:30:00
**Status**: IN PROGRESS
**Next Milestone**: Complete Week 11 (27 tasks remaining)
<!-- END PROGRESS TRACKING -->
```

This header will be updated after each batch of 5 tasks completes.

## Execution Commands

**Start Phase 3.5 Execution**:
```
/phase35 start
```

**Resume from specific section**:
```
/phase35 resume "Week 11, Day 6"
```

**Status check**:
```
/phase35 status
```

## Task Completion Criteria

A task is ONLY marked complete when:
- [ ] Code written/modified as specified in document
- [ ] Document checkbox updated: `- [ ]` → `- [x]`
- [ ] Validation criteria met (if any)
- [ ] No errors in implementation

## Document Update Workflow

**After EVERY task completion**, the following happens automatically:

### Step 1: Update Task Checkbox
Use Edit tool on PHASE_3.5_CHECKLIST_INTEGRATED_v3.md:

**Before**:
```markdown
**Validation**:
- [ ] Process 100 swipes in <1 second (< 10ms each)
- [ ] RIASEC values update correctly
```

**After**:
```markdown
**Validation**:
- [x] Process 100 swipes in <1 second (< 10ms each)  ✅ 2025-11-01 14:30
- [x] RIASEC values update correctly  ✅ 2025-11-01 14:35
```

### Step 2: Update Section Progress
When a section is complete, mark it:

**Before**:
```markdown
### Week 11, Day 8-9: 🆕 BehavioralEventLog (Data Loss Prevention) (4-6 hours)
```

**After**:
```markdown
### Week 11, Day 8-9: 🆕 BehavioralEventLog (Data Loss Prevention) (4-6 hours) ✅ COMPLETE
```

### Step 3: Update Progress Header
Update the progress tracking header at top of document (after each batch of 5):

```markdown
<!-- PROGRESS TRACKING - AUTO-UPDATED -->
**Overall Progress**: 20/127 tasks complete (15.7%)
**Current Section**: Week 11, Day 10 - BehavioralProfile Model
**Completed Sections**: Pre-Week 11 ✅, Week 11 Day 8-9 ✅
**Last Updated**: 2025-11-01 15:45:00
**Status**: IN PROGRESS
**Next Milestone**: Complete Week 11 (22 tasks remaining)
<!-- END PROGRESS TRACKING -->
```

### Step 4: Verify Update
Before marking task as complete in TodoWrite:
- Re-read the document line to confirm `- [x]` is present
- If checkbox not updated, retry Edit operation
- Only proceed when document shows completion

## Error Handling

If a task fails:
1. DO NOT mark as complete
2. Keep task as `in_progress` in todo list
3. Report error to user
4. Wait for user decision: fix, skip, or abort

## Guardian Skills Integration

**CRITICAL**: Activate these specific guardian skills for each phase. The executor will invoke them automatically.

### Pre-Week 11: Blocker Resolution (Day -1 to Day 1)
**Primary Skills** (MUST be active):
1. `thompson-performance-guardian` - Validates <10ms constraint, performance tests
2. `swift-concurrency-enforcer` - Enforces actor isolation, Swift 6 compliance
3. `privacy-security-guardian` - Validates PII removal, on-device only

**Supporting Skills**:
4. `v7-architecture-guardian` - Validates architectural patterns
5. `manifestandmatch-v7-coding-standards` - Overall code compliance

**Why**: Performance testing (Blocker 1-2), actor fixes (Blocker 3), privacy (HP 4-5)

---

### Week 10: Foundation Setup
**Primary Skills**:
1. `v7-architecture-guardian` - UI removal, architectural decisions
2. `ios26-specialist` - Foundation Models detection
3. `core-data-specialist` - Work Styles schema validation

**Why**: Core architecture changes, iOS 26 feature detection, Core Data verification

---

### Week 11-13: PRIMARY System (Swipe-Based Learning)
**Primary Skills** (ALL must be active):
1. `thompson-performance-guardian` - SACRED <10ms constraint enforcement
2. `swift-concurrency-enforcer` - Actor isolation for BehavioralEventLog, DeepAnalysis
3. `ios26-specialist` - Foundation Models API integration
4. `privacy-security-guardian` - On-device processing, no PII retention
5. `v7-architecture-guardian` - MV pattern, package dependencies
6. `swiftui-specialist` - DeckScreen integration, state management

**Supporting Skills**:
7. `manifestandmatch-skills-guardian` - Skills taxonomy integration (if relevant)
8. `app-narrative-guide` - User experience validation

**Why**: Core ML system with strict performance, concurrency, and privacy requirements

---

### Week 14: FALLBACK System (Question-Based)
**Primary Skills**:
1. `core-data-specialist` - CareerQuestion entity, migrations
2. `ai-error-handling-enforcer` - Cloud AI fallback, retry logic
3. `privacy-security-guardian` - Cloud vs on-device boundary
4. `v7-architecture-guardian` - Legacy device support

**Why**: Core Data modeling, cloud AI error handling, privacy boundary

---

### Week 15-16: Adaptive Questions
**Primary Skills**:
1. `ios26-specialist` - Foundation Models for question generation
2. `swiftui-specialist` - Question card UI integration
3. `app-narrative-guide` - Conversational question tone
4. `privacy-security-guardian` - User data handling

**Why**: AI-generated questions, UI integration, user experience

---

### Week 17-18: Thompson Integration
**Primary Skills**:
1. `thompson-performance-guardian` - SACRED <10ms maintained with new data
2. `v7-architecture-guardian` - Thompson bridge architecture
3. `core-data-specialist` - Profile updates, Core Data persistence

**Supporting Skills**:
4. `manifestandmatch-skills-guardian` - Skills data flow validation

**Why**: Thompson scoring integration must maintain performance

---

### Week 19: Testing & Deployment
**ALL GUARDIAN SKILLS MUST BE ACTIVE**:
1. `thompson-performance-guardian` - Final performance validation
2. `swift-concurrency-enforcer` - Swift 6 strict mode verification
3. `ios26-specialist` - Foundation Models integration complete
4. `privacy-security-guardian` - Privacy compliance final check
5. `accessibility-compliance-enforcer` - WCAG 2.1 AA compliance
6. `v7-architecture-guardian` - Overall architecture validation
7. `swiftui-specialist` - UI/UX final review
8. `core-data-specialist` - Data persistence validation
9. `ai-error-handling-enforcer` - Error scenarios tested
10. `app-narrative-guide` - User experience validation
11. `manifestandmatch-v7-coding-standards` - Code quality review

**Why**: Comprehensive validation before production deployment

---

## Skill Activation Commands

**Executor will automatically run these commands at section boundaries**:

```bash
# Pre-Week 11
skill thompson-performance-guardian
skill swift-concurrency-enforcer
skill privacy-security-guardian
skill v7-architecture-guardian

# Week 11-13
skill thompson-performance-guardian
skill swift-concurrency-enforcer
skill ios26-specialist
skill privacy-security-guardian
skill v7-architecture-guardian
skill swiftui-specialist

# Week 14
skill core-data-specialist
skill ai-error-handling-enforcer
skill privacy-security-guardian

# Week 19 (ALL)
skill thompson-performance-guardian
skill swift-concurrency-enforcer
skill ios26-specialist
skill privacy-security-guardian
skill accessibility-compliance-enforcer
skill v7-architecture-guardian
skill swiftui-specialist
skill core-data-specialist
skill ai-error-handling-enforcer
skill app-narrative-guide
skill manifestandmatch-v7-coding-standards
```

## Skill Validation Checkpoints

After each section completes, the executor will:
1. Invoke all active guardian skills for that section
2. Request sign-off from each guardian
3. Document any issues or blockers
4. Only proceed to next section when all guardians approve

## State Persistence

Maintain execution state:
```json
{
  "currentBatch": 1,
  "completedTasks": 15,
  "totalTasks": 127,
  "currentSection": "Week 11, Day 8-9",
  "tasksInProgress": [
    "Create BehavioralEventLog.swift"
  ],
  "lastUpdated": "2025-11-01T14:30:00Z"
}
```

## Example Execution Flow

**Batch 1 (Pre-Week 11 Blockers)**:
```
TodoWrite:
1. [in_progress] Create Tests/V7AITests/ValidationPerformanceTests.swift
2. [pending] Implement testValidationOverhead()
3. [pending] Run test → document median result
4. [pending] Create Tests/V7AITests/FastBehavioralLearningPerformanceTests.swift
5. [pending] Implement testFastLearningPerformance()

Execute task 1 → Update document → Mark complete
Execute task 2 → Update document → Mark complete
Execute task 3 → Update document → Mark complete
Execute task 4 → Update document → Mark complete
Execute task 5 → Update document → Mark complete

All 5 complete → Load Batch 2
```

**Batch 2 (Week 10 Foundation)**:
```
TodoWrite:
1. [in_progress] Remove O*NET UI from ProfileScreen
2. [pending] Verify Work Styles Core Data schema
3. [pending] Create FoundationModelsDetector.swift
4. [pending] Implement device capability detection
5. [pending] Test detector on iPhone 15 Pro

(Continue execution...)
```

## Success Criteria

- [ ] All 127 tasks from checklist executed in order
- [ ] Document fully updated with all checkboxes marked
- [ ] No mid-task todo list modifications
- [ ] Guardian validations passed for each section
- [ ] All tests passing
- [ ] Code compiles with Swift 6 strict concurrency

## Anti-Patterns to Prevent

❌ **DO NOT**:
- Change todo list mid-batch (wait for all 5 to complete)
- Skip tasks without user approval
- Mark tasks complete without updating document
- Load more than 5 tasks per batch
- Execute tasks out of order

✅ **DO**:
- Reference document for all implementation details
- Update document checkbox immediately after completion
- Invoke guardian skills proactively
- Report progress after each batch
- Maintain strict task order

---

**Status**: Ready for activation
**Command**: `skill phase-3.5-executor` or `/phase35 start`
**Document**: PHASE_3.5_CHECKLIST_INTEGRATED_v3.md
**Total Tasks**: ~127 (estimated from document structure)
**Estimated Time**: 10 weeks (with 1 day pre-work)
