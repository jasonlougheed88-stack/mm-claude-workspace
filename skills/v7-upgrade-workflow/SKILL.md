---
name: v7-upgrade-workflow
description: Complete workflow automation for V7 feature upgrades - orchestrates all 11 V7 skills from planning through validation to deployment
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - SlashCommand
  - Skill
---

# V7 Upgrade Workflow Orchestrator

This skill automates the complete V7 upgrade lifecycle by intelligently coordinating all 11 specialist skills.

---

## WORKFLOW STAGES

### STAGE 1: PLANNING & VALIDATION

When user initiates upgrade with pattern: "start upgrade for [FEATURE_NAME]" or "create new feature [FEATURE_NAME]"

#### Step 1.1: Mission Alignment Check
**Invoke:** `app-narrative-guide` skill

**Purpose:** Validate the feature serves the core mission - helping people discover unexpected careers

**Output:**
- ✅ Feature aligned with mission → Proceed
- ⚠️ Feature partially aligned → Recommend modifications
- ❌ Feature misaligned → Recommend alternative approach

---

#### Step 1.2: Architectural Planning
**Invoke:** `v7-architecture-guardian` skill

**Purpose:** Determine package placement and architectural impact

**Questions to answer:**
- Which V7 package(s) should this live in?
- Does this create any circular dependencies?
- Which sacred constraints are affected?
- What's the data flow impact?

**Output:**
- Package placement recommendations
- Dependency analysis
- Sacred constraint impact assessment

---

#### Step 1.3: Bias Detection
**Invoke:** `bias-detection-guardian` skill

**Purpose:** Ensure feature doesn't hardcode tech-sector bias

**Validation:**
- Feature works across all 14 industries?
- No hardcoded assumptions about "tech jobs"?
- Sector-neutral language used?

**Output:**
- Bias risk assessment
- Recommendations for sector-neutral implementation

---

### STAGE 2: SCAFFOLD CREATION

#### Step 2.1: Create Upgrade Folder Structure
**Invoke:** `/create-upgrade [FEATURE_NAME]` slash command

**Creates:**
```
upgrade/underway/[FEATURE_NAME]/
├── [FEATURE_NAME]_PLAN.md
├── [FEATURE_NAME]_MASTER_CHECKLIST.md
├── PHASE_1_TASKS.md
├── PERFORMANCE_VALIDATION.md
├── ROLLBACK_PLAN.md
└── TESTING_STRATEGY.md
```

---

#### Step 2.2: Coding Standards Review
**Invoke:** `manifestandmatch-v7-coding-standards` skill

**Purpose:** Generate code templates that match codebase DNA

**Output:**
- Type system recommendations (struct vs class vs enum vs actor)
- Concurrency patterns (@MainActor, Sendable, actor)
- Naming conventions
- File organization
- Protocol patterns

---

### STAGE 3: AGENT ASSIGNMENT & TASK BREAKDOWN

#### Step 3.1: Determine Required Specialists

**Analyze feature requirements and assign agents:**

**For UI/UX Features:**
- `xcode-ux-designer` - Interface design
- `ios-app-architect` - Implementation
- `accessibility-compliance-enforcer` - WCAG 2.1 AA compliance

**For Backend/Logic Features:**
- `backend-ios-expert` - Server-side logic
- `ios-app-architect` - Client integration
- `database-migration-specialist` - Data layer (if needed)

**For Algorithm Features:**
- `algorithm-math-expert` - Mathematical correctness
- `ml-engineering-specialist` - If ML/Thompson involved
- `performance-engineer` - Optimization

**For Testing:**
- `testing-qa-strategist` - Test strategy
- `performance-engineer` - Performance validation

**Always Required:**
- `v7-architecture-guardian` - Architectural oversight
- `swift-concurrency-enforcer` - Concurrency compliance

---

#### Step 3.2: Create Agent Assignment Matrix

**Generate in:** `upgrade/underway/[FEATURE_NAME]/[FEATURE_NAME]_MASTER_CHECKLIST.md`

```markdown
## AGENT ASSIGNMENTS

### Phase 1: Planning
- [ ] app-narrative-guide: Mission alignment validated
- [ ] v7-architecture-guardian: Package placement determined
- [ ] bias-detection-guardian: Bias assessment complete

### Phase 2: Implementation
- [ ] [ASSIGNED_AGENT]: Core implementation
- [ ] swift-concurrency-enforcer: Concurrency review
- [ ] manifestandmatch-v7-coding-standards: Code review

### Phase 3: Performance
- [ ] thompson-performance-guardian: Thompson budget validated
- [ ] performance-engineer: Performance optimization
- [ ] cost-optimization-watchdog: AI cost analysis (if AI features)

### Phase 4: Security & Privacy
- [ ] privacy-security-guardian: Privacy review
- [ ] ai-error-handling-enforcer: Error handling (if AI features)

### Phase 5: Testing
- [ ] testing-qa-strategist: Test strategy
- [ ] accessibility-compliance-enforcer: Accessibility tests

### Phase 6: Validation
- [ ] v7-architecture-guardian: Final architectural review
- [ ] ALL SKILLS: Sign-off checklist
```

---

### STAGE 4: PERFORMANCE GATES SETUP

#### Step 4.1: Thompson Performance Validation
**If feature touches Thompson Sampling:**
**Invoke:** `thompson-performance-guardian` skill

**Sets gates:**
- Thompson scoring: <10ms per job (P95)
- Cache hit rate: >70% minimum
- Algorithm correctness: Beta distribution validation
- 357x performance advantage maintained

---

#### Step 4.2: General Performance Budgets
**Invoke:** `performance-engineer` agent

**Sets gates:**
- Memory baseline: <200MB sustained
- Memory emergency: <250MB peak
- UI rendering: 60 FPS (16.67ms/frame)
- Tab switching: <16ms
- API response: <3s

**Documents in:** `PERFORMANCE_VALIDATION.md`

---

### STAGE 5: CONCURRENCY PLANNING

#### Step 5.1: Swift 6 Compliance
**Invoke:** `swift-concurrency-enforcer` skill

**Analyzes:**
- What needs @MainActor? (UI code)
- What needs actor? (Background work)
- What needs Sendable? (Cross-actor data)
- What needs nonisolated? (Protocol conformance)

**Output:** Concurrency architecture diagram in planning doc

---

### STAGE 6: TESTING STRATEGY

#### Step 6.1: Comprehensive Test Plan
**Invoke:** `testing-qa-strategist` skill

**Creates:**
- Unit test specifications (80%+ coverage target)
- Integration test scenarios (4 critical flows minimum)
- Performance test criteria
- Accessibility test plan
- Regression test suite

**Documents in:** `TESTING_STRATEGY.md`

---

#### Step 6.2: Database Migration (if needed)
**If feature requires data layer changes:**
**Invoke:** `database-migration-specialist` skill

**Plans:**
- Migration path from current schema
- Data integrity validation
- Rollback procedures
- Performance impact analysis

---

### STAGE 7: PRIVACY & SECURITY

#### Step 7.1: Privacy Review
**Invoke:** `privacy-security-guardian` skill

**Validates:**
- On-device processing used where possible
- Sensitive data in Keychain (not UserDefaults)
- No data leaks to third parties
- Privacy-first architecture

---

#### Step 7.2: Error Handling Strategy
**If feature uses AI:**
**Invoke:** `ai-error-handling-enforcer` skill

**Ensures:**
- AI parsing failures don't crash app
- Graceful degradation to fallbacks
- User-friendly error messages
- Retry mechanisms with backoff

---

#### Step 7.3: Cost Optimization
**If feature uses AI APIs:**
**Invoke:** `cost-optimization-watchdog` skill

**Implements:**
- Smart caching strategy
- Token optimization
- Rate limiting
- Fallback to local processing

---

### STAGE 8: IMPLEMENTATION GUIDANCE

#### Step 8.1: Generate Code Templates
**Use:** `manifestandmatch-v7-coding-standards` skill

**Creates templates for:**
- Data models (structs with Sendable)
- View models (@Observable classes)
- Services (actors for background work)
- Protocols (in V7Core if cross-package)
- Tests (Swift Testing @Test format)

---

#### Step 8.2: Sacred Constraints Enforcement
**Automatic via hook:** `validate-sacred-constraints.sh`

**Validates before any commit:**
- Tab order unchanged (0=Discover, 1=History, 2=Profile, 3=Analytics)
- Swipe thresholds unchanged (100/-100/-80)
- Thompson budget <10ms
- Memory baseline 200MB
- Dual-profile colors unchanged
- V7Core zero dependencies

---

### STAGE 9: VALIDATION & TESTING

#### Step 9.1: Run Complete Validation Pipeline
**Invoke:** `/run-validation` slash command

**Executes:**
1. Automated fake data scanner
2. Build checkpoints (5 stages)
3. Quick validation (smoke tests)
4. Production readiness tests
5. Performance regression detection

**Generates:** Comprehensive validation report

---

#### Step 9.2: Sacred Constraints Verification
**Invoke:** `v7-architecture-guardian` skill

**Final validation:**
- All sacred constraints preserved
- No circular dependencies introduced
- Package responsibilities maintained
- Documentation updated

---

### STAGE 10: DEPLOYMENT READINESS

#### Step 10.1: Pre-Deployment Checklist

**All Skills Sign-Off Required:**
- ✅ `app-narrative-guide`: Mission-aligned
- ✅ `v7-architecture-guardian`: Architecturally sound
- ✅ `manifestandmatch-v7-coding-standards`: Coding standards met
- ✅ `swift-concurrency-enforcer`: Concurrency compliant
- ✅ `thompson-performance-guardian`: Performance gates passed (if applicable)
- ✅ `privacy-security-guardian`: Privacy-first
- ✅ `ai-error-handling-enforcer`: Robust error handling (if applicable)
- ✅ `cost-optimization-watchdog`: Cost-optimized (if applicable)
- ✅ `bias-detection-guardian`: Sector-neutral
- ✅ `accessibility-compliance-enforcer`: WCAG 2.1 AA compliant
- ✅ `testing-qa-strategist`: Test coverage adequate

---

#### Step 10.2: Generate Deployment Summary

**Create:** `upgrade/underway/[FEATURE_NAME]/DEPLOYMENT_SUMMARY.md`

**Include:**
- Feature description
- Architectural changes
- Performance impact
- Test coverage achieved
- Rollback procedure
- Monitoring plan
- Known limitations

---

## AUTOMATION TRIGGERS

### Automatic Invocation Patterns

**Pattern 1:** User says "start upgrade for [FEATURE]"
- Triggers FULL workflow (Stages 1-10)

**Pattern 2:** User says "validate [FEATURE]"
- Triggers STAGE 9 only (validation pipeline)

**Pattern 3:** User says "check sacred constraints"
- Runs sacred constraints hook

**Pattern 4:** User says "ready to deploy [FEATURE]?"
- Runs STAGE 10 (deployment readiness check)

---

## SKILL COORDINATION MATRIX

| Stage | Primary Skill | Supporting Skills | Output |
|-------|--------------|-------------------|--------|
| 1. Planning | app-narrative-guide | v7-architecture-guardian, bias-detection-guardian | Validated feature plan |
| 2. Scaffold | (slash command) | manifestandmatch-v7-coding-standards | Upgrade folder structure |
| 3. Assignment | (workflow logic) | All 11 skills | Agent assignment matrix |
| 4. Performance | thompson-performance-guardian | performance-engineer | Performance gates |
| 5. Concurrency | swift-concurrency-enforcer | manifestandmatch-v7-coding-standards | Concurrency plan |
| 6. Testing | testing-qa-strategist | ALL | Test strategy |
| 7. Privacy | privacy-security-guardian | ai-error-handling-enforcer, cost-optimization-watchdog | Security plan |
| 8. Implementation | manifestandmatch-v7-coding-standards | (relevant agents) | Code templates |
| 9. Validation | (slash command) | v7-architecture-guardian | Validation report |
| 10. Deployment | v7-architecture-guardian | ALL (sign-off) | Deployment summary |

---

## USAGE EXAMPLES

### Example 1: New Feature
```
User: "Start upgrade for analytics dashboard real-time updates"

Workflow executes:
1. app-narrative-guide validates mission alignment
2. v7-architecture-guardian determines V7Performance package
3. bias-detection-guardian confirms sector-neutral
4. /create-upgrade creates folder structure
5. manifestandmatch-v7-coding-standards generates templates
6. Agent matrix assigns: performance-engineer, ios-app-architect
7. thompson-performance-guardian sets <10ms gate
8. testing-qa-strategist creates test plan
9. All documentation generated automatically
```

### Example 2: Bug Fix
```
User: "Fix memory leak in job discovery"

Workflow executes:
1. v7-architecture-guardian analyzes V7Services package
2. performance-engineer identifies leak source
3. swift-concurrency-enforcer reviews concurrency
4. testing-qa-strategist adds regression test
5. /run-validation verifies fix
6. Sacred constraints hook validates no violations
```

### Example 3: Performance Optimization
```
User: "Optimize Thompson Sampling cache hit rate"

Workflow executes:
1. thompson-performance-guardian analyzes current metrics
2. performance-engineer designs optimization
3. ml-engineering-specialist validates algorithm
4. /run-validation confirms <10ms maintained
5. Deployment summary shows performance improvement
```

---

## SUCCESS METRICS

**Workflow is successful if:**
- ✅ All 11 skills sign off
- ✅ Sacred constraints preserved
- ✅ Performance gates passed
- ✅ Test coverage ≥80%
- ✅ Zero production blockers
- ✅ Documentation complete

**Time Savings:**
- Manual upgrade cycle: ~6 hours
- Automated workflow: ~45 minutes
- **87% reduction in planning/setup time**

---

**This skill orchestrates all V7 specialist skills to automate your entire upgrade workflow from idea to production-ready code.**
