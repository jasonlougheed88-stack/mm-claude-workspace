# Package Names — Approved Mapping
**Decided: 2026-05-15. Authoritative source for the new build.**

New build location: `/Users/jasonl/Desktop/Claudes-Man&Man-build/ios-app/`
Reference codebase (V7/V8, read-only): `/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8/`

---

## Naming Map

| New Build Name | Reference Codebase Name | What It Actually Does |
|---|---|---|
| **CoreTaxonomy** | V7Core | O*NET job taxonomy (1016 roles), 3864-skill database, sacred UI constants, occupation adjacency, skills matching, app-wide state, configuration |
| **Persistence** | V7Data | All Core Data entities + PersistenceController + migration |
| **ScoringEngine** | V7Thompson | Thompson Sampling ML engine — Beta distributions, job relevance scoring, swipe pattern analysis, caching |
| **JobPipeline** | V7Services | Job source APIs (JSearch, Greenhouse, Lever, Adzuna, etc.), JobDiscoveryCoordinator, O*NET enrichment, rate limiting |
| **DeckUI** | V7UI | All SwiftUI views: DeckScreen, form views, accessibility system, amber/teal color system |
| **Intelligence** | V7AI | ManifestInferenceActor, question generation, RIASEC analysis, behavioral learning, ThompsonBridge |
| **ResumeParsing** | V7AIParsing | PDF resume parsing via OpenAI — PDFTextExtractor, SkillsExtractor, ParsedResume |
| **CareerGrowth** | V7Career | Career path building, skill gap analysis, course recommendations, affiliate revenue, ManifestTabView |
| **SemanticMatch** | V7Embeddings | Vector embeddings for semantic job/resume similarity (inactive in prod) |
| **JobNormalizer** | V7JobParsing | Extracts skills, seniority, metadata from raw job listing text |
| **Monitoring** | V7Performance | Performance budgets, FPS tracking, bias detection, health monitoring, Thompson guardian |
| **ProfileExtraction** | V7ResumeAnalysis | Resume PDF → user Core Data profile population pipeline |
| **AdCards** | V7Ads | Ad card injection, ATT consent, ad caching (inactive — keep, investigate) |
| **AppShell** | ManifestAndMatchV7Package | ContentView, MainTabView, 12-step onboarding, settings, error recovery |
| **ChartsLab** | ChartsColorTestPackage | Chart color utility — purpose unclear, keep and investigate before deciding |

---

## Rules

- **New build code uses new names.** `import ScoringEngine` not `import V7Thompson`
- **Reading the reference codebase uses old names.** File paths like `Packages/V7Thompson/Sources/...` are correct for the reference codebase — don't change them when looking things up
- **Zero circular dependencies.** CoreTaxonomy has zero dependencies. Everything else depends on CoreTaxonomy. This constraint carries over exactly from the reference codebase.
- **V7 prefix is retired.** No new packages get V7 prefix or any version number in their name.

## DAG (new names)

```
CoreTaxonomy          ← zero dependencies (sacred)
Persistence           ← CoreTaxonomy
JobNormalizer         ← CoreTaxonomy
SemanticMatch         ← CoreTaxonomy
ScoringEngine         ← CoreTaxonomy, Persistence, SemanticMatch
Monitoring            ← CoreTaxonomy, ScoringEngine
ResumeParsing         ← CoreTaxonomy, ScoringEngine, Monitoring
JobPipeline           ← CoreTaxonomy, ScoringEngine, JobNormalizer, ResumeParsing, Persistence
Intelligence          ← CoreTaxonomy, Persistence, JobPipeline, ScoringEngine, Monitoring
CareerGrowth          ← CoreTaxonomy, Persistence, ScoringEngine, Intelligence, Monitoring
ProfileExtraction     ← CoreTaxonomy, Persistence, CareerGrowth, Intelligence
DeckUI                ← CoreTaxonomy, JobPipeline, ScoringEngine, Monitoring, Intelligence, Persistence, CareerGrowth
AdCards               ← CoreTaxonomy, DeckUI, Monitoring (inactive — add back in Phase 5 only)
AppShell              ← all above
App Target            ← AppShell
```
