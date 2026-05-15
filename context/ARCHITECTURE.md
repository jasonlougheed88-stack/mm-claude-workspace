# Architecture Reference
**Pattern:** MV (Model-View) — no ViewModels. `@Observable`, `@State`, `@Environment`. Swift 6 strict concurrency. All SwiftUI views `@MainActor`.

---

## Workspace
```
/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8/ManifestAndMatchV7.xcworkspace
```

## Package Dependency Order (bottom → top)
```
V7Core          ← zero dependencies (sacred)
V7Data          ← V7Core
V7Thompson      ← V7Core, V7Data, V7Embeddings
V7Services      ← V7Core, V7Data, V7Thompson
V7UI            ← V7Core, V7Data, V7Thompson, V7Services
V7AI            ← V7Core, V7Data
V7AIParsing     ← V7Core, V7Data
V7Career        ← V7Core, V7Data, V7Thompson
V7Embeddings    ← V7Core
V7JobParsing    ← V7Core, V7Data
V7Performance   ← V7Core
V7ResumeAnalysis← V7Core, V7Data
V7Ads           ← V7Core (inactive)
ManifestAndMatchV7Package ← all above
ManifestAndMatchV7 (app target) ← ManifestAndMatchV7Package
```

## Key Files
| File | Package | What it is |
|------|---------|-----------|
| `SacredUIConstants.swift` | V7Core | Sacred values — never touch |
| `PersistenceController.swift` | V7Data | Core Data stack |
| `V7DataModel.xcdatamodeld` | V7Data | 18 Core Data entities |
| `OptimizedThompsonEngine.swift` | V7Thompson | Production ML engine |
| `FastBetaSampler.swift` | V7Thompson | Beta distribution math |
| `ThompsonArm+CoreData.swift` | V7Data | Persistence entity for Thompson |
| `JobDiscoveryCoordinator.swift` | V7Services | Job pipeline orchestrator (3,682 lines) |
| `JSearchAPIClient.swift` | V7Services | Primary job source |
| `GreenhouseAPIClient.swift` | V7Services | 62 companies, free |
| `LeverAPIClient.swift` | V7Services | 50 companies, free |
| `DeckScreen.swift` | V7UI | Main swipe UI (3,353 lines) |
| `ContentView.swift` | ManifestAndMatchV7Package | Root view + onboarding gate |
| `OnboardingFlow.swift` | ManifestAndMatchV7Package | 12-step onboarding |
| `ManifestTabView.swift` | V7Career | Career hub (1,500+ lines) |

## App Entry Point Flow
```
@main App
  → ContentView (checks onboarding complete)
    → if incomplete: OnboardingFlow (12 steps)
    → if complete:   TabView
        Tab 0: DeckScreen (Discover) ← primary
        Tab 1: History
        Tab 2: Profile
        Tab 3: Analytics
```

## Tab Order (Sacred)
```
Discover = 0
History  = 1
Profile  = 2
Analytics = 3
```

## Build Target
- **Bundle ID:** `com.manifest.match.v7`
- **Device:** iPhone 16 Pro Max, UDID `00008140-001244112E43801C`
- **Min deployment:** iOS 18
- **Target:** iOS 26+
- **Total codebase:** ~187,000 lines across 14 packages
