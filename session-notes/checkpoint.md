# Checkpoint — 2026-05-21 (pre-Phase 7)

## CURRENT STATE
Phase 6 COMPLETE. Phase 7 NOT STARTED.
Build: zero errors, zero warnings.
Last commit: `7873bfb` on main.

---

## PHASE 7 FULL SCOPE — READ THIS BEFORE ANY SESSION

Phase 7 is the keystone. Right now riasecScore and workActivitiesScore return 0.5 (neutral
fallback) on EVERY job card. The amber/teal slider does nothing in Teal mode. Phase 7 fixes this
by wiring the O*NET enrichment pipeline so that every job card has real RIASEC + work activities
data before it reaches the scoring engine. It also wires the user side (onboarding declared role
→ O*NET RIASEC baseline on UserProfile).

### Why the pipeline order matters
```
JSearch API → raw Job (title + company + location only)
  ↓ JobONetEnricher (Session 7.2)
Job with onetCode, riasecProfile [6-dim], workActivities [41-dim]
  ↓ OptimizedThompsonEngine.scoreJobs()
riasecScore and workActivitiesScore NOW produce real per-job values
  ↓ DeckScreen renders
Card color and deck order reflect actual career fit
```

### Sacred constraint that controls every package placement decision
CoreTaxonomy has ZERO package dependencies. It is the foundation. Every system that needs
to import JobNormalizer.Job, Persistence, or any other package CANNOT live in CoreTaxonomy.
This means:
- ONetCodeMapper → CoreTaxonomy OK (takes String → returns String, no external deps)
- ONetDataService → CoreTaxonomy OK (reads Bundle.module JSON, no external deps)
- EnhancedSkillsMatcher → CoreTaxonomy OK (takes strings, no external deps)
- OccupationAdjacencyService → CoreTaxonomy OK (reads JSON bundle, no external deps)
- JobONetEnricher → JobPipeline REQUIRED (imports JobNormalizer.Job)
- ProfileConverter → JobPipeline REQUIRED (imports Persistence.UserProfile + JobNormalizer.UserProfile)
- ProfileEnrichmentService → JobPipeline REQUIRED (imports Persistence.UserProfile)

---

## SESSION 7.1 — DATA FOUNDATION + CORETAXONOMY INFRASTRUCTURE

### NEXT ACTION (execute in order, stop at end)

1. `session_show_defaults` — verify workspace/scheme/sim
2. `build_run_sim` — confirm zero errors/warnings before any changes
3. Read the following V7 reference files before writing ANY code (read, don't copy blindly):
   - `find /Users/jasonl/Desktop/ios26_manifest_and_match -path "*/V7Core/Sources/V7Core/ONetDataModels.swift" 2>/dev/null`
   - `find /Users/jasonl/Desktop/ios26_manifest_and_match -path "*/V7Core/Sources/V7Core/ONetDataService.swift" 2>/dev/null`
   - `find /Users/jasonl/Desktop/ios26_manifest_and_match -path "*/V7Core/Sources/V7Core/SkillsMatching/SkillTaxonomy.swift" 2>/dev/null`
   - `find /Users/jasonl/Desktop/ios26_manifest_and_match -path "*/V7Core/Sources/V7Core/SkillsMatching/EnhancedSkillsMatcher.swift" 2>/dev/null`
   - `find /Users/jasonl/Desktop/ios26_manifest_and_match -path "*/V7Core/Sources/V7Core/SkillsMatching/StringSimilarity.swift" 2>/dev/null`
   - `find /Users/jasonl/Desktop/ios26_manifest_and_match -path "*ONetCodeMapper.swift" 2>/dev/null`
4. Verify O*NET data files exist in reference:
   `find /Users/jasonl/Desktop/ios26_manifest_and_match -name "onet_*.json" 2>/dev/null | head -20`
   `find /Users/jasonl/Desktop/ios26_manifest_and_match -name "SkillTaxonomy.json" 2>/dev/null`
5. Create CoreTaxonomy Resources directory:
   `mkdir -p "/Users/jasonl/Desktop/Claudes-Man&Man-build/ios-app/Packages/CoreTaxonomy/Sources/CoreTaxonomy/Resources"`
6. Copy all O*NET JSON files from reference to CoreTaxonomy/Resources/:
   All 13 onet_*.json files + SkillTaxonomy.json.
   Target: `ios-app/Packages/CoreTaxonomy/Sources/CoreTaxonomy/Resources/`
7. Update CoreTaxonomy/Package.swift: add `resources: [.copy("Resources")]` to the target
8. Port ONetDataModels.swift to CoreTaxonomy — type definitions:
   RIASECProfile (6-dim, scale 0–7), WorkActivities ([String: Double], 41 dims),
   ONetOccupation (onetCode, title, RIASEC, workActivities)
   NO external imports. Foundation only.
9. Port ONetDataService.swift to CoreTaxonomy — actor that loads O*NET JSON bundles at init
   and provides lookup: given SOC code → RIASECProfile + WorkActivities.
   Uses Bundle.module to find files. NO external imports.
10. Port SkillTaxonomy.swift + SkillTaxonomyLoader to CoreTaxonomy —
    loads SkillTaxonomy.json (787 canonical skills, 36 categories, ~3,500 aliases).
    NO external imports.
11. Port EnhancedSkillsMatcher.swift to CoreTaxonomy — 4-strategy matching cascade:
    exact canonical → synonym → substring → Levenshtein. 50K LRU cache.
    Depends on SkillTaxonomy + StringSimilarity (same package). NO external imports.
12. Port StringSimilarity.swift to CoreTaxonomy — Levenshtein distance utility.
    NO external imports.
13. Port ONetCodeMapper.swift to CoreTaxonomy — 4-tier title → SOC code pipeline:
    Tier 1: exact cache, Tier 2: onet_modern_mappings.json (51 curated),
    Tier 3: onet_keyword_index_tier1.json fuzzy, Tier 4: Levenshtein on occupation titles.
    Reads from Bundle.module. NO external imports.
14. `build_sim` — must be zero errors, zero warnings
15. Commit: "Phase 7 Session 1 — CoreTaxonomy data foundation and taxonomy services"
16. Update this checkpoint: mark Session 7.1 complete, set NEXT ACTION to Session 7.2

---

## SESSION 7.2 — O*NET ENRICHMENT PIPELINE + JOBPIPELINE WIRING

DO NOT start this session unless Session 7.1 is committed and building clean.

### NEXT ACTION (Session 7.2)

1. `session_show_defaults` + `build_run_sim` — confirm clean baseline
2. Read these V7 reference files before writing:
   - `find /Users/jasonl/Desktop/ios26_manifest_and_match -path "*JobONetEnricher.swift" 2>/dev/null`
   - `find /Users/jasonl/Desktop/ios26_manifest_and_match -path "*ONetCacheWarmer.swift" 2>/dev/null`
   - `find /Users/jasonl/Desktop/ios26_manifest_and_match -path "*ProfileConverter.swift" 2>/dev/null`
3. Read current JobPipelineClient.swift fully — understand where enrichment call goes
4. Read current DeckScreen.swift recordInteraction() — understand where jobONETCode save goes
5. Read current ManifestAndMatchApp.swift (or equivalent app entry point) — where ONetCacheWarmer fires
6. ⚠️ SILENT FAILURE TRAP — before writing ProfileConverter, read current AppShell to
   understand how Core Data UserProfile → JobNormalizer.UserProfile conversion happens today.
   If ProfileConverter doesn't exist yet, the user's onetRIASEC* fields from Core Data NEVER
   reach the scoring engine even after Phase 7 enriches them. This must be verified before
   anything else in Session 7.2.
   Search: `grep -rn "UserProfile\|profileConverter\|toThompsonProfile\|JobNormalizer.UserProfile" ios-app/Packages/AppShell/Sources/AppShell/ | head -30`
7. Port JobONetEnricher.swift to JobPipeline — takes Job → returns Job enriched with:
   - onetCode (String) from ONetCodeMapper
   - riasecProfile (RIASECProfile) from ONetDataService lookup on SOC code
   - workActivities ([String: Double]) from ONetDataService lookup on SOC code
   Imports: CoreTaxonomy, JobNormalizer
8. Port ONetCacheWarmer.swift to JobPipeline — preloads O*NET JSON at startup
   Call site: ManifestAndMatchApp (or wherever app initializes, at onAppear/init)
9. Port ProfileConverter.swift to JobPipeline — converts Persistence.UserProfile →
   JobNormalizer.UserProfile. CRITICAL: must copy these Core Data fields to the value type:
   - onetRIASECRealistic, onetRIASECInvestigative, onetRIASECArtistic,
     onetRIASECSocial, onetRIASECEnterprising, onetRIASECConventional
   - onetWorkActivities (Transformable [String: Double])
   - onetSkills (Transformable [String]) → professionalProfile.onetSkills
   - skills (Transformable [String]) → professionalProfile.skills
   If these fields aren't copied, riasecScore returns 0.5 regardless of onboarding data.
10. Update JobPipelineClient.fetchJobs() to call JobONetEnricher on every job:
    After mapping raw API response → Job, but BEFORE returning. Async, fire-and-forget
    per job is OK (each enrichment is fast, cached after first lookup).
11. Update DeckScreen.swift recordInteraction() to save jobONETCode:
    Add: `interaction.jobONETCode = job.onetCode` after existing field assignments.
    This field already exists in Core Data JobInteraction entity. ManifestInferenceActor
    (Phase 8 full implementation) reads jobONETCode to aggregate RIASEC from swipe history.
12. Wire ONetCacheWarmer call at app startup
13. `build_sim` — zero errors/warnings
14. `build_run_sim` — launch app, verify oslog shows ONetCacheWarmer loaded
15. Fetch jobs (let deck load) — verify oslog shows JobONetEnricher enriching jobs
16. Check runtime: `grep "onetCode\|riasecProfile\|ONetEnrich" <oslog path>`
17. Commit: "Phase 7 Session 2 — O*NET enrichment pipeline, ProfileConverter wired"
18. Update checkpoint: mark Session 7.2 complete, set NEXT ACTION to Session 7.3

---

## SESSION 7.3 — USER PROFILE ENRICHMENT + ADVANCED SYSTEMS + FULL GATE

DO NOT start unless Session 7.2 is committed and building clean.

### NEXT ACTION (Session 7.3)

1. `session_show_defaults` + `build_run_sim` — confirm clean baseline
2. Read these V7 reference files before writing:
   - `find /Users/jasonl/Desktop/ios26_manifest_and_match -path "*ProfileEnrichmentService.swift" 2>/dev/null`
   - `find /Users/jasonl/Desktop/ios26_manifest_and_match -path "*OccupationAdjacencyService.swift" 2>/dev/null`
   - `find /Users/jasonl/Desktop/ios26_manifest_and_match -path "*CareerRelationshipDiscovery.swift" 2>/dev/null`
   - `find /Users/jasonl/Desktop/ios26_manifest_and_match -path "*RIASECKeywordMapper.swift" 2>/dev/null`
3. Port ProfileEnrichmentService.swift to JobPipeline — takes declared role string →
   calls ONetCodeMapper → looks up in ONetDataService → populates UserProfile Core Data
   entity with onetRIASEC*, onetWorkActivities, onetSkills, onetEducationLevel.
4. Wire ProfileEnrichmentService in OnboardingView.completeOnboarding():
   After `try context.save()` succeeds, call ProfileEnrichmentService with profile.desiredRoles.first.
   This populates the user's O*NET baseline immediately from their declared role.
5. Port OccupationAdjacencyService.swift to CoreTaxonomy — reads onet_related_occupations.json
   and alternate titles to expand job search scope when profileBlend ≥ 0.25 (Teal mode).
   Called by JobDiscoveryCoordinator in Phase 8 but foundation must be in CoreTaxonomy now.
   NO external imports.
6. Port CareerRelationshipDiscovery.swift to CoreTaxonomy — maps relationship types between
   occupations (lateral, advancement, adjacent, pivot). Used by Phase 9 Manifest tab career
   paths. Foundation must exist before Phase 9 builds on it. NO external imports.
7. Port RIASECKeywordMapper.swift to Intelligence package — keyword bag-of-words RIASEC
   extraction (~90 keyword categories). Fallback for pre-iOS 26 question answer parsing.
   Phase 8 SmartQuestionGenerator needs it. Type must exist before Phase 8 builds on it.
8. `build_sim` — zero errors/warnings
9. FULL RUNTIME GATE (uninstall sim first to get fresh Core Data):
   `xcrun simctl uninstall 4F4EF23F-6FDE-4976-BEB9-987A09DECC79 com.manifestandmatch.app`
   `build_run_sim`
   a. Complete onboarding → verify oslog: "ProfileEnrichmentService populated RIASEC for [role]"
   b. Find SQLite:
      `find ~/Library/Developer/CoreSimulator/Devices/4F4EF23F-6FDE-4976-BEB9-987A09DECC79 -name "ManifestAndMatch.sqlite" 2>/dev/null`
   c. Query UserProfile O*NET fields:
      `sqlite3 <path> "SELECT ZONETRIASECINVESTIGATIVE, ZONETRIASECENTERPRISING, ZONETWORKACTIVITIESDATA IS NOT NULL FROM ZUSERPROFILE;"`
      → All values must be non-zero/non-null
   d. Verify jobs have O*NET data:
      `grep "onetCode\|riasecProfile\|JobONetEnricher" <oslog path>`
      → Should show enrichment for every fetched job
   e. Swipe 3 cards right
   f. Query JobInteraction O*NET code:
      `sqlite3 <path> "SELECT ZJOBONETCODE FROM ZJOBINTERACTION WHERE ZACTION='interested';"`
      → Must be non-null SOC codes (e.g., "15-1252.00")
   g. Verify scoring differentiation:
      oslog should show different riasecScore values per job (not all 0.5)
10. Commit: "Phase 7 complete — O*NET enrichment, user RIASEC baseline, career systems"
11. Update BUILD_SEQUENCE.md: mark Phase 7 COMPLETE ✅, set Phase 8 as next
12. Write fresh checkpoint for Phase 8

---

## ACTIVE FILES
All files clean and committed as of this checkpoint.

## SESSION SCOPE
- [x] Phase 6 complete
- [x] Stub tagging + BUILD_SEQUENCE.md mandate
- [x] Full Phase 7 scope planned + documented
- [ ] Phase 7 Session 1 — CoreTaxonomy data foundation
- [ ] Phase 7 Session 2 — O*NET enrichment pipeline
- [ ] Phase 7 Session 3 — User profile enrichment + full gate

---

## OPEN STATE — TRAPS AND NON-OBVIOUS THINGS

**Silent failure trap (most dangerous):**
The JSON files in CoreTaxonomy/Resources/ MUST be declared in CoreTaxonomy/Package.swift with
`resources: [.copy("Resources")]`. If this is missing, the files aren't bundled, everything
compiles, but ONetDataService finds nothing at runtime and silently returns nil for all lookups.
Jobs will have no O*NET data, riasecScore stays at 0.5, and there's no error — just wrong behavior.
VERIFY: after adding resources, do a clean build and check that Bundle.module can find the files.

**Silent failure trap #2 (second most dangerous):**
ProfileConverter must copy O*NET fields from Core Data UserProfile → JobNormalizer.UserProfile.
If it doesn't (or if it doesn't exist yet), the user's onboarding RIASEC data sits in Core Data
forever but never reaches OptimizedThompsonEngine. Verify by querying Core Data AND checking
the UserFeatures struct that OTE builds — both must have the data.

**JobInteraction.jobONETCode field already exists:**
The Core Data entity JobInteraction already has `jobONETCode` (String, optional). DeckScreen's
recordInteraction() needs to save it: `interaction.jobONETCode = job.onetCode`. If this isn't
done in Session 7.2, Phase 8's ManifestInferenceActor full implementation can't aggregate real
RIASEC data from swipe history — it will use keyword inference instead of O*NET ground truth.

**FallbackCareerQuestion Core Data entity is pre-wired for O*NET:**
FallbackCareerQuestion already has onetEducationSignal, onetWorkActivitiesJSON,
onetRIASECDimensionsJSON fields in Core Data. Phase 8's FallbackQuestionCoordinator reads
these when seeding fallback questions. Phase 7 doesn't need to do anything here — it's noted
so Phase 8 knows the schema is already correct.

**RIASECKeywordMapper vs RIASECScorer:**
RIASECKeywordMapper = fallback for pre-iOS 26 (keyword matching, weak signal). Goes in Intelligence.
RIASECScorer = iOS 26+ Foundation Models path (strong signal). Also goes in Intelligence.
Phase 7 ports RIASECKeywordMapper only. RIASECScorer is Phase 8.

**OccupationAdjacencyService timing:**
OccupationAdjacencyService expands job search scope when profileBlend ≥ 0.25 (any Teal position).
In Phase 7 we port it to CoreTaxonomy. It's NOT yet called by JobDiscoveryCoordinator — that
wiring happens in Phase 8 when the full Intelligence pipeline is built. Phase 7 just ensures the
type exists and compiles so Phase 8 can wire it without a new package dependency.

**Testing workflow:**
Always uninstall before fresh Core Data tests:
`xcrun simctl uninstall 4F4EF23F-6FDE-4976-BEB9-987A09DECC79 com.manifestandmatch.app`
hasCompletedOnboarding persists across reinstalls but Core Data is wiped, causing save failures
if deck shows without UserProfile.

**Reference codebase location:**
All V7/V8 reference files are at:
`/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8/Packages/`
V7Core → source for CoreTaxonomy systems
V7Services → source for JobPipeline systems (ONetCodeMapper, JobONetEnricher, ProfileConverter)
V7AI → source for Intelligence systems (RIASECKeywordMapper)
Read before porting. Do not copy blindly — check for V7-specific imports and remove them.

**Phase 8 upgrade tags (check before any new file in Phase 8):**
`grep -rn "PHASE8-UPGRADE" ios-app/Packages/`
Returns: SwipePatternAnalyzer, QuestionBank, QuestionCardSheet
These must be upgraded, not replaced with parallel systems.
