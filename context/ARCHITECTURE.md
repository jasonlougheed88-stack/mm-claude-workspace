# Architecture Reference
**Pattern:** MV (Model-View) — no ViewModels. `@Observable`, `@State`, `@Environment`. Swift 6 strict concurrency. All SwiftUI views `@MainActor`.

---

## New Build Location
```
/Users/jasonl/Desktop/Claudes-Man&Man-build/ios-app/
```

## Reference Codebase (read-only)
```
/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8/ManifestAndMatchV7.xcworkspace
```

## Package Names
New build uses new names. Reference codebase uses V7* names. Full mapping: `context/PACKAGE_NAMES.md`

## Package Dependency Order (bottom → top) — New Build Names

```
CoreTaxonomy    ← zero dependencies (sacred)
Persistence     ← CoreTaxonomy
JobNormalizer   ← CoreTaxonomy
SemanticMatch   ← CoreTaxonomy
ScoringEngine   ← CoreTaxonomy, Persistence, SemanticMatch
Monitoring      ← CoreTaxonomy, ScoringEngine
ResumeParsing   ← CoreTaxonomy, ScoringEngine, Monitoring
JobPipeline     ← CoreTaxonomy, ScoringEngine, JobNormalizer, ResumeParsing, Persistence
Intelligence    ← CoreTaxonomy, Persistence, JobPipeline, ScoringEngine, Monitoring
CareerGrowth    ← CoreTaxonomy, Persistence, ScoringEngine, Intelligence, Monitoring
ProfileExtraction ← CoreTaxonomy, Persistence, CareerGrowth, Intelligence
DeckUI          ← CoreTaxonomy, JobPipeline, ScoringEngine, Monitoring, Intelligence, Persistence, CareerGrowth
AdCards         ← CoreTaxonomy, DeckUI, Monitoring  (inactive — Phase 5 only)
AppShell        ← all above
App Target      ← AppShell
```

## Key Files — Reference Codebase (use these paths to READ source code)
| File | Reference Package | New Build Package | What it is |
|------|------------------|-------------------|------------|
| `SacredUIConstants.swift` | V7Core | CoreTaxonomy | Sacred values — never touch |
| `PersistenceController.swift` | V7Data | Persistence | Core Data stack |
| `V7DataModel.xcdatamodeld` | V7Data | Persistence | 18 Core Data entities |
| `OptimizedThompsonEngine.swift` | V7Thompson | ScoringEngine | Production ML engine |
| `FastBetaSampler.swift` | V7Thompson | ScoringEngine | Beta distribution math |
| `ThompsonArm+CoreData.swift` | V7Data | Persistence | Thompson persistence entity |
| `JobDiscoveryCoordinator.swift` | V7Services | JobPipeline | Job pipeline orchestrator |
| `JSearchAPIClient.swift` | V7Services | JobPipeline | Primary job source |
| `DeckScreen.swift` | V7UI | DeckUI | Main swipe UI (decompose in new build) |
| `ContentView.swift` | ManifestAndMatchV7Package | AppShell | Root view + onboarding gate |
| `OnboardingFlow.swift` | ManifestAndMatchV7Package | AppShell | 12-step onboarding |
| `ManifestTabView.swift` | V7Career | CareerGrowth | Career hub UI |
| `SacredUIConstants.swift` | V7Core | CoreTaxonomy | Constants, never touch |

## App Entry Point Flow
```
@main App
  → ContentView (checks onboarding complete)
    → if incomplete: OnboardingFlow (12 steps)
    → if complete:   TabView
        Tab 0: DeckScreen (Discover) ← primary
        Tab 1: Tracker (CRM — name TBD, see OPEN_QUESTIONS.md Q1)
        Tab 2: Profile
        Tab 3: Manifest
```

## Tab Order (Sacred)
```
Discover = 0
Tracker  = 1   (name TBD)
Profile  = 2
Manifest = 3
```

## Build Target
- **Bundle ID:** `com.manifest.match.v7`
- **Device:** iPhone 16 Pro Max, UDID `00008140-001244112E43801C`
- **Min deployment:** iOS 17+
- **Target:** iOS 26+
- **Reference codebase total:** ~187,000 lines across 15 packages
