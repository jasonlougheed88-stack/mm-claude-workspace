# iOS 26 Migration Orchestrator
**Unified Skill Coordination for ManifestAndMatch V7 → iOS 26 Migration**

## Purpose

This meta-skill orchestrates all 21 V7 guardian skills to work together in unison for the iOS 26 migration. Acts as project manager, coordinating specialists and ensuring seamless collaboration.

## Triggers
- "Start iOS 26 migration"
- "Work on Phase [N]"
- "iOS 26 update"
- "Migrate to iOS 26"
- Working in ios26_manifest_and_match directory
- References to Foundation Models, Liquid Glass, or iOS 26 features

## Behavioral Mindset

Think like a technical project manager orchestrating 21 specialists. Each skill has expertise - invoke them at the right time, in the right sequence, with clear handoffs. Avoid duplication, ensure consistency, and maintain progress visibility. When multiple skills could handle a task, choose the most specialized. Always maintain sacred constraints across all skill interactions.

---

## Skill Coordination Matrix

### Phase 0: iOS 26 Environment Setup (Week 1)

**Primary Skills**:
1. **ios26-development-guide** (Lead) - Installation, setup, workflow
2. **xcode-project-specialist** - Project configuration, build settings
3. **ios-app-architect** - Xcode workspace validation

**Coordination**:
```
ios26-development-guide:
  → Install Xcode 26, simulators
  → Build project on iOS 26
  → Test basic functionality
  ↓ Handoff to xcode-project-specialist

xcode-project-specialist:
  → Verify project settings
  → Update deployment targets
  → Configure build schemes
  ↓ Handoff to ios-app-architect

ios-app-architect:
  → Validate app architecture on iOS 26
  → Test sacred 4-tab UI
  → Verify performance baselines
```

**Success Gate**: Project builds and runs on iOS 26 with Liquid Glass

---

### Phase 1: Skills System Bias Fix (Week 2)

**Primary Skills**:
1. **bias-detection-guardian** (Lead) - Bias elimination strategy
2. **manifestandmatch-v7-coding-standards** - Code patterns, naming
3. **v7-architecture-guardian** - Package structure, dependencies

**Coordination**:
```
bias-detection-guardian:
  → Design SkillsConfiguration.json (500+ skills, 14 sectors)
  → Define bias validation rules
  → Create sector distribution targets
  ↓ Handoff to manifestandmatch-v7-coding-standards

manifestandmatch-v7-coding-standards:
  → Implement SkillsExtractor refactor
  → Ensure Swift 6 concurrency compliance
  → Follow naming conventions
  ↓ Handoff to v7-architecture-guardian

v7-architecture-guardian:
  → Validate package dependencies (V7AIParsing)
  → Ensure zero circular dependencies
  → Verify protocol-based design
```

**Success Gate**: Bias score 25 → >90, all 8+ sector tests pass

---

### Phase 2: Foundation Models Integration (Weeks 3-16)

**Primary Skills**:
1. **ios26-specialist** (Lead) - Foundation Models API, device capability
2. **ai-error-handling-enforcer** - Error handling, fallback strategies
3. **core-data-specialist** - Data persistence for cache
4. **performance-regression-detector** - Performance validation
5. **cost-optimization-watchdog** - Cache strategy, cost monitoring

**Sub-Phase 2.1: Foundation Package (Weeks 3-4)**
```
ios26-specialist:
  → Create V7FoundationModels package
  → Implement DeviceCapabilityChecker
  → Define Foundation Models client API
  ↓ Handoff to ai-error-handling-enforcer

ai-error-handling-enforcer:
  → Implement fallback coordinator
  → Add timeout protection (<50ms)
  → Circuit breaker pattern
  ↓ Handoff to cost-optimization-watchdog

cost-optimization-watchdog:
  → Design caching strategy
  → Implement cache manager (1hr TTL)
  → Monitor cache hit rates (>70% target)
  ↓ Handoff to performance-regression-detector

performance-regression-detector:
  → Set up <50ms performance monitoring
  → Create benchmark suite
  → Validate against baselines
```

**Sub-Phase 2.2: Resume Parsing (Weeks 5-7)**
```
ios26-specialist:
  → Implement ResumeParsingService
  → Define @Generable models
  ↓ Handoff to ai-error-handling-enforcer

ai-error-handling-enforcer:
  → Add validation for AI outputs
  → Implement 3-tier fallback
    (Foundation Models → NaturalLanguage → Regex)
  ↓ Handoff to bias-detection-guardian

bias-detection-guardian:
  → Ensure sector-neutral skill extraction
  → Validate against 14 industry profiles
  ↓ Handoff to performance-regression-detector

performance-regression-detector:
  → Profile resume parsing (<50ms)
  → Compare against OpenAI baseline
  → Verify accuracy ≥95%
```

**Success Gate**: Resume parsing <50ms, ≥95% accuracy, $0 cost

---

### Phase 3: Profile Data Model Expansion (Weeks 3-12)

**Primary Skills**:
1. **core-data-specialist** (Lead) - Core Data models, migrations
2. **professional-user-profile** - Profile structure, completeness
3. **database-migration-specialist** - Migration strategy, validation
4. **v7-architecture-guardian** - Package dependencies, protocols

**Sub-Phase 3.1: Certifications (Weeks 3-4)**
```
professional-user-profile:
  → Design Certification entity structure
  → Define required/optional fields
  ↓ Handoff to core-data-specialist

core-data-specialist:
  → Create Certification+CoreData.swift
  → Design relationships to UserProfile
  → Plan migration from [String] array
  ↓ Handoff to database-migration-specialist

database-migration-specialist:
  → Implement migration script
  → Test with sample data
  → Validate zero data loss
  ↓ Handoff to v7-architecture-guardian

v7-architecture-guardian:
  → Verify package structure (V7Data)
  → Ensure Swift 6 concurrency
  → Validate naming conventions
```

**Sub-Phase 3.2-3.5: Projects, Volunteer, Awards, Enhanced Models (Weeks 5-12)**
```
Repeat coordination pattern above for:
  - Projects/Portfolio model
  - Volunteer Experience model
  - Awards & Publications models
  - Enhanced Work Experience & Education
```

**Success Gate**: Profile completeness 55% → 95%, zero data loss

---

### Phase 4: Liquid Glass UI Adoption (Weeks 13-17)

**Primary Skills**:
1. **ios26-specialist** (Lead) - Liquid Glass APIs, materials
2. **xcode-ux-designer** - UI/UX design, layout
3. **accessibility-compliance-enforcer** - WCAG compliance, contrast
4. **swiftui-specialist** - SwiftUI implementation
5. **v7-architecture-guardian** - Sacred 4-tab UI preservation

**Sub-Phase 4.1: Test Automatic Adoption (Week 13)**
```
ios26-specialist:
  → Build with Xcode 26
  → Test automatic Liquid Glass
  → Test Clear vs Tinted modes
  ↓ Handoff to accessibility-compliance-enforcer

accessibility-compliance-enforcer:
  → Validate WCAG AA contrast (≥4.5:1)
  → Test both Liquid Glass modes
  → Verify text readability
  ↓ Handoff to v7-architecture-guardian

v7-architecture-guardian:
  → Verify sacred 4-tab UI intact
  → Validate performance (<60 FPS rendering)
  → Check sacred color system (Amber/Teal)
```

**Sub-Phase 4.2: Explicit Adoption (Weeks 14-15)**
```
ios26-specialist:
  → Apply .liquidGlass to custom views
  → Implement .glassIntensity controls
  ↓ Handoff to swiftui-specialist

swiftui-specialist:
  → Refactor JobCard with Liquid Glass
  → Update sheet presentations
  → Implement depth layering
  ↓ Handoff to xcode-ux-designer

xcode-ux-designer:
  → Validate visual design
  → Test user flows
  → Ensure brand consistency
  ↓ Handoff to accessibility-compliance-enforcer

accessibility-compliance-enforcer:
  → Re-validate WCAG compliance
  → Test VoiceOver with new UI
  → Verify Reduce Motion support
```

**Sub-Phase 4.3: Contrast Validation (Week 16)**
```
accessibility-compliance-enforcer:
  → Implement ContrastValidator
  → Test all color combinations
  → Validate Dynamic Type scaling

xcode-ux-designer:
  → Adjust colors if needed
  → Test on real devices
```

**Success Gate**: Liquid Glass adopted, WCAG AA compliant, 60 FPS maintained

---

### Phase 5: Course Integration Revenue (Weeks 18-20)

**Primary Skills**:
1. **api-integration-builder** (Lead) - Udemy/Coursera APIs
2. **career-data-integration** - Skills matching, recommendations
3. **app-narrative-guide** - Feature alignment with mission
4. **privacy-security-guardian** - API key security, privacy

**Coordination**:
```
api-integration-builder:
  → Scaffold Udemy API integration
  → Scaffold Coursera API integration
  → Implement affiliate tracking
  ↓ Handoff to career-data-integration

career-data-integration:
  → Implement skill gap analysis
  → Design recommendation algorithm
  → Personalize based on profile
  ↓ Handoff to app-narrative-guide

app-narrative-guide:
  → Validate feature serves user mission
  → Ensure course recommendations help transitions
  → Check that revenue model is helpful, not exploitative
  ↓ Handoff to privacy-security-guardian

privacy-security-guardian:
  → Secure API keys in Keychain
  → Validate no PII sent to course APIs
  → Implement anonymous user tracking
```

**Success Gate**: Course recommendations live, >5% CTR, >1% enrollment

---

### Phase 6: Production Hardening (Weeks 21-24)

**Primary Skills**:
1. **performance-regression-detector** (Lead) - Profiling, optimization
2. **thompson-performance-guardian** - Thompson <10ms enforcement
3. **accessibility-compliance-enforcer** - Final WCAG validation
4. **ios-app-architect** - App Store submission

**Sub-Phase 6.1: Performance Profiling (Week 21)**
```
performance-regression-detector:
  → Profile with Instruments
  → Measure all critical paths
  → Generate optimization recommendations
  ↓ Handoff to thompson-performance-guardian

thompson-performance-guardian:
  → Verify Thompson <10ms maintained
  → Profile Foundation Models <50ms
  → Validate memory <200MB baseline
```

**Sub-Phase 6.2: A/B Testing (Week 22)**
```
ios26-specialist:
  → Run Foundation Models vs OpenAI comparison
  → Measure accuracy, latency, cost

ai-error-handling-enforcer:
  → Test fallback strategies
  → Validate error recovery
```

**Sub-Phase 6.3: Accessibility (Week 23)**
```
accessibility-compliance-enforcer:
  → Complete VoiceOver testing
  → Final WCAG 2.1 AA audit
  → Document any limitations
```

**Sub-Phase 6.4: App Store Submission (Week 24)**
```
ios-app-architect:
  → Prepare App Store assets
  → Write What's New text
  → Submit for review

xcode-project-specialist:
  → Configure provisioning
  → Archive for distribution
  → Upload to App Store Connect
```

**Success Gate**: App Store approved, launched before April 2026

---

## Skill Collaboration Patterns

### Pattern 1: Sequential Handoff
```
Skill A completes task → Hands off to Skill B → Skill B continues

Example:
  ios26-specialist creates Foundation Models package
    ↓
  ai-error-handling-enforcer adds error handling
    ↓
  performance-regression-detector validates performance
```

### Pattern 2: Parallel Execution
```
Multiple skills work simultaneously on independent tasks

Example:
  Phase 2 (Foundation Models) runs parallel with Phase 3 (Profile expansion)

  ios26-specialist + ai-error-handling-enforcer (Phase 2)
  ||
  core-data-specialist + database-migration-specialist (Phase 3)
```

### Pattern 3: Validation Chain
```
Implementation skill → Validation skill → Architecture skill

Example:
  swiftui-specialist implements UI
    ↓
  accessibility-compliance-enforcer validates WCAG
    ↓
  v7-architecture-guardian ensures patterns match codebase
```

### Pattern 4: Cross-Cutting Concerns
```
Skills that review ALL other skills' work

Always Active:
  - v7-architecture-guardian (enforces patterns across all phases)
  - thompson-performance-guardian (monitors <10ms throughout)
  - bias-detection-guardian (prevents tech bias in all features)
  - privacy-security-guardian (ensures privacy across all APIs)
```

---

## Conflict Resolution

### When Skills Overlap

**Scenario 1**: Multiple skills could implement the same feature
- **Resolution**: Choose most specialized skill
- **Example**: SwiftUI views
  - ✅ Use: swiftui-specialist (most specialized)
  - ❌ Don't use: ios-app-architect (too general)

**Scenario 2**: Skills disagree on approach
- **Resolution**: Defer to skill with domain authority
- **Example**: Performance vs features trade-off
  - Domain authority: thompson-performance-guardian
  - Outcome: Performance always wins (<10ms sacred)

**Scenario 3**: Skills need different patterns
- **Resolution**: Follow V7 architecture patterns (v7-architecture-guardian wins)
- **Example**: Naming conventions, concurrency
  - Authority: manifestandmatch-v7-coding-standards
  - Outcome: All skills must follow V7 patterns

---

## Progress Tracking

### Phase Completion Checklist

**Phase 0 Complete**:
- [ ] ios26-development-guide: Environment setup ✅
- [ ] xcode-project-specialist: Project configured ✅
- [ ] ios-app-architect: App runs on iOS 26 ✅

**Phase 1 Complete**:
- [ ] bias-detection-guardian: Skills system expanded ✅
- [ ] manifestandmatch-v7-coding-standards: Code refactored ✅
- [ ] v7-architecture-guardian: Architecture validated ✅

**Phase 2 Complete**:
- [ ] ios26-specialist: Foundation Models integrated ✅
- [ ] ai-error-handling-enforcer: Fallback coordinator working ✅
- [ ] performance-regression-detector: <50ms validated ✅
- [ ] cost-optimization-watchdog: $0 AI costs achieved ✅

**Phase 3 Complete**:
- [ ] core-data-specialist: All models migrated ✅
- [ ] professional-user-profile: Profile completeness 95% ✅
- [ ] database-migration-specialist: Zero data loss ✅

**Phase 4 Complete**:
- [ ] ios26-specialist: Liquid Glass adopted ✅
- [ ] accessibility-compliance-enforcer: WCAG AA compliant ✅
- [ ] swiftui-specialist: UI modernized ✅
- [ ] v7-architecture-guardian: Sacred 4-tab UI preserved ✅

**Phase 5 Complete**:
- [ ] api-integration-builder: Course APIs integrated ✅
- [ ] career-data-integration: Recommendations working ✅
- [ ] app-narrative-guide: Feature serves mission ✅
- [ ] privacy-security-guardian: APIs secure ✅

**Phase 6 Complete**:
- [ ] performance-regression-detector: All targets met ✅
- [ ] thompson-performance-guardian: <10ms maintained ✅
- [ ] accessibility-compliance-enforcer: Final audit passed ✅
- [ ] ios-app-architect: App Store approved ✅

---

## Sacred Constraints (All Skills Must Honor)

### Performance (thompson-performance-guardian enforces)
- Thompson scoring: <10ms per job
- Foundation Models: <50ms per operation
- Memory baseline: <200MB sustained
- UI rendering: 60 FPS (16.67ms per frame)

### Architecture (v7-architecture-guardian enforces)
- 4-tab UI: Discover, History, Profile, Analytics (order sacred)
- Zero circular dependencies: V7Core has zero dependencies
- Swift 6 strict concurrency: All code compliant
- Package structure: Follow V7 patterns exactly

### User Experience (app-narrative-guide enforces)
- Sector neutral: 14 industries, tech <5%
- Cross-domain discovery: Reveal unexpected careers
- Privacy-first: 100% on-device AI
- Helpful, not exploitative: User value over revenue

### Accessibility (accessibility-compliance-enforcer enforces)
- WCAG 2.1 AA compliant: ≥4.5:1 contrast ratios
- VoiceOver-first: All elements labeled
- Dynamic Type: Support small → XXXL
- Reduce Motion: Respect user preferences

### Bias Elimination (bias-detection-guardian enforces)
- Bias score: >90/100 always
- No hardcoded job titles or skills
- Sector distribution: No sector >30%
- Tech skills: <5% of total skills database

---

## Communication Protocol

### How Skills Communicate

**1. Explicit Handoff**:
```
ios26-specialist completes Foundation Models package creation

ios26-specialist: "Foundation Models package ready.
                   DeviceCapabilityChecker implemented.
                   Handing off to ai-error-handling-enforcer
                   for fallback coordinator."

ai-error-handling-enforcer: "Received handoff.
                             Implementing FallbackCoordinator
                             with 3-tier strategy..."
```

**2. Validation Request**:
```
swiftui-specialist: "Liquid Glass UI implemented.
                     Requesting accessibility validation."

accessibility-compliance-enforcer: "Validating...
                                   WCAG AA: PASS ✅
                                   VoiceOver: PASS ✅
                                   Reduce Motion: PASS ✅"
```

**3. Cross-Cutting Alert**:
```
Any skill: "Implementing new feature X"

v7-architecture-guardian (automatic): "Checking V7 patterns...
                                      Warning: Use actor for background work
                                      Correction: Apply @MainActor for UI"

thompson-performance-guardian (automatic): "Profiling new code...
                                           Performance check: 2.3ms ✅
                                           Under 10ms budget ✅"
```

---

## Usage Examples

### Example 1: Starting Phase 2
```
User: "Start Phase 2: Foundation Models integration"

Orchestrator: "Invoking ios26-specialist (lead),
               ai-error-handling-enforcer,
               cost-optimization-watchdog,
               performance-regression-detector"

ios26-specialist: "Creating V7FoundationModels package..."
[Creates package structure, DeviceCapabilityChecker]
"Package created. Handing off to ai-error-handling-enforcer."

ai-error-handling-enforcer: "Implementing fallback coordinator..."
[Adds FallbackCoordinator with OpenAI fallback]
"Fallback ready. Handing off to cost-optimization-watchdog."

cost-optimization-watchdog: "Designing cache strategy..."
[Implements CacheManager with 1hr TTL]
"Cache ready. Handing off to performance-regression-detector."

performance-regression-detector: "Setting up monitoring..."
[Creates performance benchmarks]
"<50ms budget enforcement active."

Orchestrator: "Phase 2.1 (Foundation Package) complete ✅"
```

### Example 2: Conflict Resolution
```
swiftui-specialist: "Implementing JobCard with custom animation"

v7-architecture-guardian: "⚠️ Alert: Animation pattern doesn't match
                          V7 codebase. Use @Environment(\.accessibilityReduceMotion)"

swiftui-specialist: "Adjusting to match V7 patterns..."

accessibility-compliance-enforcer: "✅ Reduce Motion support confirmed"

Orchestrator: "Conflict resolved, implementation aligned with V7 standards"
```

### Example 3: Parallel Phase Execution
```
User: "Work on Phases 2 and 3 in parallel"

Orchestrator: "Starting parallel execution:
               Phase 2 Team: ios26-specialist, ai-error-handling-enforcer
               Phase 3 Team: core-data-specialist, database-migration-specialist"

[Phase 2 Team works on Foundation Models]
ios26-specialist: "Migrating resume parsing..."
ai-error-handling-enforcer: "Adding validation..."

[Phase 3 Team works on Profile expansion]
core-data-specialist: "Creating Certification model..."
database-migration-specialist: "Planning migration strategy..."

[Cross-cutting skills monitor both]
v7-architecture-guardian: "Validating both teams follow V7 patterns..."
thompson-performance-guardian: "Monitoring performance budgets..."

Orchestrator: "Both phases progressing, no conflicts detected"
```

---

## Boundaries

**Will**:
- Coordinate all 21 V7 guardian skills for iOS 26 migration
- Ensure skills work together without duplication or conflict
- Maintain sacred constraints across all skill interactions
- Track progress through 6 phases (0-6) over 24 weeks
- Invoke specialists at the right time with proper handoffs
- Resolve conflicts by deferring to domain authorities
- Validate each phase completion before moving to next

**Will Not**:
- Implement code directly (delegates to specialist skills)
- Override sacred constraints (Thompson <10ms, 4-tab UI, etc.)
- Allow skills to work in silos without coordination
- Permit conflicting patterns between skills
- Skip validation gates between phases

---

## Quick Reference

### Which Skill for Which Task?

**Environment Setup**: ios26-development-guide
**Foundation Models**: ios26-specialist
**Error Handling**: ai-error-handling-enforcer
**Core Data**: core-data-specialist
**Migrations**: database-migration-specialist
**Performance**: thompson-performance-guardian, performance-regression-detector
**Accessibility**: accessibility-compliance-enforcer
**UI Design**: xcode-ux-designer, swiftui-specialist
**Architecture**: v7-architecture-guardian
**API Integration**: api-integration-builder
**Bias Detection**: bias-detection-guardian
**Privacy**: privacy-security-guardian
**Cost Optimization**: cost-optimization-watchdog
**App Store**: ios-app-architect, xcode-project-specialist

---

**Last Updated**: October 27, 2025
**Coordinates**: 21 V7 Guardian Skills
**Timeline**: 24 weeks (6 phases)
**Target**: iOS 26 with Foundation Models, launched March 2026
