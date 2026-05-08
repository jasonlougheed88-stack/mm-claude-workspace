# O*NET Implementation Coordinator

**Meta-skill for managing the O*NET Tiered Loading implementation across 8 phases**

## Purpose

Coordinates the implementation of O*NET Tiered Loading system by:
1. **Batch Management:** Loads tasks in digestible batches (5-10 todos at a time)
2. **Progress Tracking:** Updates implementation checklist with completion status
3. **Phase Transitions:** Moves from Phase 1 → Phase 8 systematically
4. **Validation:** Ensures each phase completes before advancing
5. **Documentation:** Updates progress in real-time

## Implementation Phases

### PHASE 1: Data Acquisition & Preparation (2-3 hours)
- 1.1 Register for O*NET Web Services (15 min)
- 1.2 Download O*NET Alternate Titles Database (30 min)
- 1.3 Curate Modern Mappings (200 titles) (60 min)
- 1.4 Build Keyword Index (45 min)

**Deliverables:**
- `onet_occupation_alternates_tier1.json` (200KB)
- `onet_occupation_alternates_tier2.json` (300KB)
- `onet_modern_mappings.json` (30KB)
- `onet_keyword_index_tier1.json` (38KB)

### PHASE 2: Code Implementation - New Files (2 hours)
- 2.1 Create ONetCodeMapperTypes.swift (20 min)
- 2.2 Create KeywordIndex.swift (20 min)
- 2.3 Create ONetAIFallback.swift (60 min)

**Deliverables:**
- 3 new Swift files in V7Services and V7AI packages

### PHASE 3: Modify Existing Files (3-4 hours)
- 3.1 Modify ONetDataService.swift - Add loadResource<T>() (30 min)
- 3.2 Modify ONetCodeMapper.swift - Major rewrite (2.5 hours)
  - 3.2.1 Update Properties
  - 3.2.2 Rewrite mapJobTitle()
  - 3.2.3 Add searchKeywordIndex()
  - 3.2.4 Add Tier Loading Methods
  - 3.2.5 Replace ensureDataLoaded()
  - 3.2.6 Add performOptimizedFuzzyMatch()

**Deliverables:**
- Modified ONetDataService.swift
- Modified ONetCodeMapper.swift (418 → 900 lines)

### PHASE 4: Add JSON Files to Xcode (15 min)
- 4.1 Add files to V7Core target via Xcode

**Deliverables:**
- 4 JSON files bundled in V7Core Resources

### PHASE 5: Update Package Dependencies (10 min)
- 5.1 Add V7Services to V7AI dependencies

**Deliverables:**
- Updated Package.swift for V7AI

### PHASE 6: Testing (3-4 hours)
- 6.1 Unit Tests (1 hour)
- 6.2 Integration Tests (1 hour)
- 6.3 Manual Testing on Simulator (1.5 hours)

**Deliverables:**
- 15+ passing unit tests
- 3+ passing integration tests
- Manual test validation

### PHASE 7: Performance Validation (30 min)
- 7.1 Run Performance Benchmarks

**Deliverables:**
- Benchmark results meeting targets

### PHASE 8: Documentation & Deployment (1 hour)
- 8.1 Update Documentation (30 min)
- 8.2 Create Rollback Plan (15 min)
- 8.3 Prepare Deployment Checklist (15 min)

**Deliverables:**
- Implementation complete report
- Rollback plan
- Deployment checklist

## Current State Tracking

**Current Phase:** 1
**Current Batch:** 1
**Tasks Completed:** 0/9 (Phase 1 Batch 1)
**Overall Progress:** 0% (0/8 phases)

## Batch System

### Batch 1 (Phase 1: Data Setup)
1. ✅/❌ Register for O*NET Web Services API
2. ✅/❌ Test O*NET API credentials
3. ✅/❌ Create data extraction directory
4. ✅/❌ Download Tier 1 alternates (2000 entries)
5. ✅/❌ Download Tier 2 alternates (3000 entries)
6. ✅/❌ Curate modern mappings (200 titles)
7. ✅/❌ Convert modern mappings to JSON
8. ✅/❌ Build keyword index
9. ✅/❌ Validate all JSON schemas

### Batch 2 (Phase 1: Validation + Phase 2 Start)
1. ✅/❌ Phase 1 completion checklist validation
2. ✅/❌ Create ONetCodeMapperTypes.swift
3. ✅/❌ Create KeywordIndex.swift
4. ✅/❌ Build and test new files
5. ✅/❌ Start ONetAIFallback.swift

### Batch 3 (Phase 2: Complete New Files)
1. ✅/❌ Complete ONetAIFallback.swift
2. ✅/❌ Test iOS 26 availability checks
3. ✅/❌ Build V7AI with new file
4. ✅/❌ Phase 2 completion validation

### Batch 4 (Phase 3: Modify ONetDataService)
1. ✅/❌ Add public loadResource<T>() to ONetDataService
2. ✅/❌ Test generic resource loading
3. ✅/❌ Build V7Core package

### Batch 5 (Phase 3: ONetCodeMapper Part 1)
1. ✅/❌ Update ONetCodeMapper properties (Tier 1/2/3)
2. ✅/❌ Rewrite mapJobTitle() with 3-tier logic
3. ✅/❌ Add searchKeywordIndex() method
4. ✅/❌ Build and check for compile errors

### Batch 6 (Phase 3: ONetCodeMapper Part 2)
1. ✅/❌ Add ensureTier1Loaded() method
2. ✅/❌ Add ensureTier2Loaded() method
3. ✅/❌ Add resource loading methods
4. ✅/❌ Build V7Services package

### Batch 7 (Phase 3: ONetCodeMapper Part 3)
1. ✅/❌ Add performOptimizedFuzzyMatch()
2. ✅/❌ Delete old ensureDataLoaded()
3. ✅/❌ Final build of ONetCodeMapper
4. ✅/❌ Phase 3 completion validation

### Batch 8 (Phase 4 & 5: Xcode Integration)
1. ✅/❌ Open Xcode workspace
2. ✅/❌ Add 4 JSON files to V7Core target
3. ✅/❌ Verify Bundle.module access
4. ✅/❌ Update V7AI Package.swift dependencies
5. ✅/❌ Full project build

### Batch 9 (Phase 6: Unit Tests)
1. ✅/❌ Create ONetCodeMapperTieredLoadingTests
2. ✅/❌ Test exact match core
3. ✅/❌ Test modern mappings (Account Executive, etc.)
4. ✅/❌ Test keyword index
5. ✅/❌ Test batch performance

### Batch 10 (Phase 6: Integration Tests)
1. ✅/❌ Create ProfileConverterIntegrationTests
2. ✅/❌ Test skill extraction for modern titles
3. ✅/❌ Run all tests
4. ✅/❌ Fix any test failures

### Batch 11 (Phase 6: Manual Testing)
1. ✅/❌ Cold start test (Tier 1 load time)
2. ✅/❌ Profile setup test (modern titles)
3. ✅/❌ Job discovery test (enrichment performance)
4. ✅/❌ Tier 2 lazy load test
5. ✅/❌ AI fallback test (iOS 26)

### Batch 12 (Phase 7 & 8: Finalization)
1. ✅/❌ Run performance benchmarks
2. ✅/❌ Update implementation complete report
3. ✅/❌ Create rollback plan
4. ✅/❌ Prepare deployment checklist
5. ✅/❌ Final validation and sign-off

## Commands

### Start Next Batch
**User says:** "Load next batch" or "Continue" or "Next"

**Action:**
1. Mark current batch complete in progress tracker
2. Load next batch of todos (5-10 items)
3. Update phase progress
4. Show batch summary

### Update Progress
**User says:** "Update progress" or "Mark complete: [task name]"

**Action:**
1. Update completion status in tracker
2. Calculate phase and overall progress percentages
3. Update implementation checklist document
4. Show next recommended action

### Skip to Phase
**User says:** "Skip to Phase [N]"

**Action:**
1. Validate previous phases complete
2. Load first batch of requested phase
3. Update current phase tracker

### Show Status
**User says:** "Show status" or "Where are we?"

**Action:**
1. Display current phase and batch
2. Show completed tasks count
3. Show overall progress percentage
4. Estimate time remaining

## Progress Tracking Format

```markdown
## Implementation Progress Tracker

**Updated:** 2025-11-06 [TIME]
**Current Phase:** [N] - [Phase Name]
**Current Batch:** [N] of 12
**Tasks Completed:** [X]/[Y] in current batch
**Phase Progress:** [X]% (Phase [N]/8)
**Overall Progress:** [X]% ([N] phases complete)

### Recently Completed
- ✅ [Task name] (completed [time])
- ✅ [Task name] (completed [time])

### Current Tasks (Batch [N])
- 🔄 [Task name] (in progress)
- ⏳ [Task name] (pending)
- ⏳ [Task name] (pending)

### Next Up
- Phase [N+1]: [Phase Name]
- Estimated time: [X] hours
```

## Success Criteria

### Batch Completion
- ✅ All todos in batch marked complete
- ✅ Validation commands executed successfully
- ✅ No blocking errors or failures

### Phase Completion
- ✅ All batches in phase complete
- ✅ Phase deliverables created/modified
- ✅ Phase completion checklist validated

### Overall Completion
- ✅ All 8 phases complete
- ✅ All 12 batches complete
- ✅ All tests passing
- ✅ Performance benchmarks met
- ✅ Documentation updated

## Integration with V8-Omniscient-Guardian

This coordinator skill works alongside v8-omniscient-guardian:

- **Coordinator:** Manages task batching and progress tracking
- **Omniscient:** Provides codebase knowledge and validation
- **Together:** Systematic implementation with expert guidance

## File Updates

**Progress Tracker File:**
`/Users/jasonl/Desktop/ios26_manifest_and_match/afterphase6/IMPLEMENTATION_PROGRESS.md`

**Main Checklist:**
`/Users/jasonl/Desktop/ios26_manifest_and_match/afterphase6/ONET_TIERED_LOADING_IMPLEMENTATION_CHECKLIST.md`

## Usage Example

```
User: "Start O*NET implementation"
Coordinator:
  ✅ Loaded Batch 1 (Phase 1: Data Acquisition)
  📋 9 tasks loaded to todo list
  ⏱️ Estimated time: 2-3 hours
  🎯 Goal: Download and prepare all O*NET data files

  Ready to begin? First task: Register for O*NET Web Services

User: "Yes, registered. Credentials saved."
Coordinator:
  ✅ Task 1 complete: Register for O*NET API
  🔄 Moving to Task 2: Test API credentials

  Run this command:
  curl -X GET "https://services.onetcenter.org/ws/online/occupations/15-1252.00" \
    -H "Authorization: Basic YOUR_CREDENTIALS"

User: "Load next batch"
Coordinator:
  ✅ Batch 1 complete (9/9 tasks)
  📊 Phase 1 Progress: 100%
  ✅ Deliverables validated:
     - onet_occupation_alternates_tier1.json (200KB)
     - onet_occupation_alternates_tier2.json (300KB)
     - onet_modern_mappings.json (30KB)
     - onet_keyword_index_tier1.json (38KB)

  🚀 Loading Batch 2 (Phase 2: New Swift Files)...
```

---

**Coordinator Status:** ACTIVE
**V8-Omniscient-Guardian:** ACTIVE
**Implementation Mode:** BATCH-BY-BATCH
**Ready:** ✅
