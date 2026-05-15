# Overall Systems — Manifest & Match v1.1

Renders on GitHub, in VS Code (Markdown Preview Mermaid Support), or paste into mermaid.live

```mermaid
flowchart LR
    subgraph EXT["External"]
        JSEARCH["JSearch API"]
        OPENAI["OpenAI API"]
    end

    subgraph PIPE["Job Pipeline"]
        CF["Cloudflare Proxy"]
        JDC["Job Discovery Coordinator"]
        GEO["Geo Filter"]
        EN["O*NET Enricher"]
    end

    subgraph SE["Scoring Engine"]
        OTE["Optimized Thompson Engine"]
        BONUS["Truths + Career Bonus"]
        COLOR["Card Color Signal"]
    end

    subgraph INTEL["Intelligence"]
        FBL["Behavioral Learning"]
        MIA["Manifest Inference Actor"]
        QS["Question System"]
        UETA["UserTruths Extractor"]
    end

    subgraph CG["Career Growth"]
        CPE["Career Path Engine"]
        SGA["Skills Gap Analyzer"]
        CRE["Course Engine"]
    end

    subgraph CD["Core Data"]
        TA["ThompsonArm"]
        IMP["InferredManifestProfile"]
        UT["UserTruths"]
        UP["UserProfile"]
    end

    AT[("ApplicationTracker\nSwiftData")]

    T0["Tab 0: Discover"]
    T1["Tab 1: CRM"]
    T2["Tab 2: Profile"]
    T3["Tab 3: Manifest"]

    JSEARCH --> CF --> JDC
    JDC --> GEO --> OTE
    JDC --> EN --> OTE

    TA --> OTE
    UP --> OTE
    UT --> BONUS --> OTE
    IMP --> BONUS
    OTE --> COLOR --> T0

    T0 -->|every swipe| FBL --> MIA
    T0 -->|every swipe| TA
    MIA --> IMP

    T0 -->|submit answer| UETA --> UT
    OPENAI --> UETA
    MIA --> QS
    OPENAI --> QS
    QS -->|inject question card| T0

    IMP --> CPE --> T3
    IMP --> SGA --> T3
    IMP --> CRE --> T3

    T0 -->|apply| AT --> T1
    T2 -->|slider + profile edits| UP
```

## Key Architectural Truths

- Every swipe does two things simultaneously: updates `ThompsonArm` (future scoring) AND feeds `ManifestInferenceActor` (behavioral learning)
- `InferredManifestProfile` is both a scoring input (career bonus) AND the data source for the entire Manifest tab
- `OTE` = Optimized Thompson Engine — the single scoring instance, sync init, Core Data persistence
- The Question System is a closed loop: intelligence detects data gaps → injects question card → answer trains intelligence
- `ApplicationTracker` uses SwiftData (not Core Data) — it is self-contained and feeds only Tab 1
- The slider lives in Tab 2 (Profile), not Tab 0. Its value propagates to scoring at next deck load.
