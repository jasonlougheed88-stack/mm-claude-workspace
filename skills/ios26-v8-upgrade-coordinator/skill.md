# iOS 26 V8 Upgrade Coordinator

## Purpose
Orchestrates all 21 guardian and specialist skills for the iOS 26 ManifestAndMatch V8 upgrade project.

## Triggers
- "start Phase [NUMBER]"
- "check Phase [NUMBER]"
- "validate V8 upgrade"
- "run all guardians"
- Working on iOS 26 ManifestAndMatch V8 upgrade tasks

## Skills Reference
All 21 guardian skills in `/.claude/skills/`:

### iOS 26 Specialists
- ios26-specialist - iOS 26 features, Liquid Glass, Foundation Models, breaking changes
- ios26-development-guide - iOS 26 workflows, migration, daily development cycles

### V7/V8 Architecture
- v7-architecture-guardian - V7/V8 architectural patterns, naming conventions, sacred constraints
- manifestandmatch-v7-coding-standards - Deep codebase knowledge, V7/V8 patterns

### Performance Guardians
- thompson-performance-guardian - <10ms Thompson requirement, 357x advantage protection
- performance-engineer - Memory, CPU, performance optimization
- performance-regression-detector - Automated performance regression detection

### Bias & Accessibility
- accessibility-compliance-enforcer - WCAG 2.1 AA compliance, VoiceOver support

### AI & Cost
- ai-error-handling-enforcer - AI parsing failure prevention, error recovery
- cost-optimization-watchdog - AI API cost control, caching, token optimization

### Security & Privacy
- privacy-security-guardian - On-device processing, Keychain security, privacy-first
- swift-concurrency-enforcer - Swift 6 strict concurrency, data race prevention

### Data & Skills
- core-data-specialist - Core Data, SwiftData, migrations, CloudKit
- database-migration-specialist - Database migration planning, V5.7→V7 transitions
- manifestandmatch-skills-guardian - SkillTaxonomy, EnhancedSkillsMatcher enforcement
- job-card-validator - JobCard data structure validation, DeckScreen UI rendering

### Integration & Testing
- api-integration-builder - Job board API integration scaffolding
- job-source-integration-validator - Job source validation, API testing, rate limiting
- testing-qa-strategist - Testing strategy, QA architecture, test implementation

### Application Specialists
- app-narrative-guide - Core mission alignment, feature validation
- ios-app-architect - iOS development, Swift, SwiftUI, App Store deployment
- xcode-ux-designer - UX/UI design for Apple platforms

## Workflow Execution

### Phase Validation Pattern
When user says "start Phase [N]":

1. **Read Phase Checklist**
   - Read `/Users/jasonl/Desktop/ios26_manifest_and_match/PHASE_[N]_CHECKLIST_*.md`
   - Understand objectives, success criteria, timeline

2. **Read Actual V8 Code**
   - Navigate to `/Users/jasonl/Desktop/ios26_manifest_and_match/manifest and match V8`
   - Check what's already implemented
   - Compare checklist requirements vs actual code state

3. **Invoke Relevant Skills**
   - Based on phase requirements, invoke appropriate guardian skills
   - Let skills analyze code and provide validation

4. **Execute Checklist Tasks**
   - Follow checklist step-by-step
   - Use guardians for validation at each step
   - Update todos as work progresses

5. **Final Validation**
   - Run all relevant guardians for sign-off
   - Document actual completion status
   - **Thoroughly update phase checklist** with completion details

### Skill Coordination Matrix

| Phase | Lead Skills | Supporting Skills |
|-------|-------------|-------------------|
| **Phase 0**: Environment Setup | ios26-development-guide | ios26-specialist, xcode-project-specialist |
| **Phase 1**: Skills System Bias Fix | bias-detection-guardian | manifestandmatch-skills-guardian, v7-architecture-guardian |
| **Phase 2**: Foundation Models | ios26-specialist | ai-error-handling-enforcer, cost-optimization-watchdog |
| **Phase 3**: Profile Expansion | core-data-specialist | database-migration-specialist, privacy-security-guardian |
| **Phase 4**: Charts & Analytics | xcode-ux-designer | accessibility-compliance-enforcer, performance-engineer |
| **Phase 5**: Job Source Integration | api-integration-builder | job-source-integration-validator, job-card-validator |
| **Phase 6**: Testing & QA | testing-qa-strategist | performance-regression-detector, all guardians |

## Guardian Sign-Off Requirements

Before marking any phase complete, ALL relevant guardians must validate:

### Always Required
- ✅ v7-architecture-guardian - Architecture compliant
- ✅ swift-concurrency-enforcer - No data races
- ✅ app-narrative-guide - Mission-aligned

### Phase-Specific
**Phase 1 (Skills)**:
- ✅ bias-detection-guardian - Bias score >90, tech <5%
- ✅ manifestandmatch-skills-guardian - SkillTaxonomy correct

**Phase 2 (Foundation Models)**:
- ✅ ios26-specialist - Foundation Models correctly integrated
- ✅ ai-error-handling-enforcer - Error handling robust
- ✅ cost-optimization-watchdog - AI costs optimized

**Phase 3 (Profile)**:
- ✅ core-data-specialist - Data layer correct
- ✅ database-migration-specialist - Migration safe
- ✅ privacy-security-guardian - User data protected

**Phase 4 (Charts)**:
- ✅ xcode-ux-designer - UX follows Apple HIG
- ✅ accessibility-compliance-enforcer - WCAG 2.1 AA compliant

**Phase 5 (Job Sources)**:
- ✅ api-integration-builder - API integration correct
- ✅ job-source-integration-validator - All sources validated
- ✅ job-card-validator - JobCard data correct

**Phase 6 (Testing)**:
- ✅ testing-qa-strategist - Test coverage adequate
- ✅ performance-regression-detector - No regressions
- ✅ ALL GUARDIANS - Final sign-off

## Sacred Constraints (Never Violate)

### Thompson Performance
- <10ms per job scoring (P95)
- 357x performance advantage maintained
- Monitored by: thompson-performance-guardian

### Bias Elimination
- Tech skills <5% of total
- All 14 sectors represented
- No hardcoded tech preferences
- Monitored by: bias-detection-guardian

### Concurrency
- Swift 6 strict concurrency compliant
- @MainActor for UI, actor for background
- All cross-actor types Sendable
- Monitored by: swift-concurrency-enforcer

### Privacy
- On-device processing preferred
- Sensitive data in Keychain only
- No third-party data leaks
- Monitored by: privacy-security-guardian

### Accessibility
- WCAG 2.1 AA compliant
- Full VoiceOver support
- Dynamic Type support
- Monitored by: accessibility-compliance-enforcer

## Automation Rules

### Before Any Code Changes
1. Read relevant phase checklist
2. Check actual code state
3. Invoke appropriate guardians
4. Get guardian approval before proceeding

### After Any Code Changes
1. Run relevant guardian validations
2. Update todos with progress
3. Document any issues found
4. Re-validate if guardians flag issues

### Before Marking Phase Complete
1. **ALL** guardian sign-offs required
2. **ALL** success criteria met
3. **ALL** deliverables complete
4. **Thoroughly update phase checklist** with completion details

## Usage Example

```
User: "start Phase 1"

Coordinator:
1. Reads /Users/jasonl/Desktop/ios26_manifest_and_match/PHASE_1_CHECKLIST_Skills_System_Bias_Fix.md
2. Reads actual V8 code in manifest and match V8/Packages/
3. Invokes bias-detection-guardian to analyze current state
4. Invokes manifestandmatch-skills-guardian to check SkillTaxonomy
5. Invokes v7-architecture-guardian to validate architecture
6. Compares checklist requirements vs actual implementation
7. Creates todos based on ACTUAL work needed
8. Executes checklist step-by-step with guardian validation
9. Gets ALL guardian sign-offs
10. Thoroughly updates PHASE_1_CHECKLIST with completion details
```

## Key Principles

1. **Always read actual code first** - Don't assume checklist matches reality
2. **Invoke guardians proactively** - Don't wait for issues
3. **Update todos frequently** - Mark complete immediately when done
4. **Get sign-offs** - All guardians must approve before phase complete
5. **Document thoroughly** - Update phase checklist with actual completion details

---

**This meta skill coordinates all 21 guardian skills for the iOS 26 V8 upgrade project.**
