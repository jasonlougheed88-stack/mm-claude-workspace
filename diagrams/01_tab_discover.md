# Tab 0: Discover

The main swipe deck. Every interaction here either updates the scoring model or trains the intelligence layer.

```mermaid
flowchart TD
    subgraph LOAD["Deck Loading — before user sees anything"]
        JDC["Job Discovery Coordinator"]
        GEO["Geo Filter"]
        EN["O*NET Enricher"]
        OTE["Optimized Thompson Engine"]
        COLOR["DualProfileColorSystem\ncard color from amber/teal contribution"]
        TEE["Thompson Explanation Engine\ninline score reason"]
    end

    subgraph SCREEN["DeckScreen"]
        JOBCARD["Job Card\nscore + color + title + skills + Why?"]
        QCARD["Question Card\ninjected when data gap detected"]
    end

    subgraph ON_SWIPE["Every Swipe — all of these fire"]
        FBL["Fast Behavioral Learning\nsync, under 10ms"]
        DBA["Deep Behavioral Analysis"]
        MIA["Manifest Inference Actor\ndebounced 5s, threshold 3 swipes"]
        ARM["ThompsonArm\nrecordSuccess or recordFailure → Core Data"]
        CONF["Confidence Calibrator\ntracks convergence — output logged only"]
        SLOG["Slider Position Logger\nrecords slider value at swipe time"]
    end

    subgraph ON_APPLY["Tap Apply Now"]
        SAFARI["Opens job URL in Safari"]
        AT_WRITE["ApplicationTracker.addApplication\nstatus: applied → SwiftData"]
    end

    subgraph ON_WHY["Tap Why?"]
        MEG["Match Explanation Generator\nOpenAI GPT-3.5 — full ExplainFit sheet"]
    end

    subgraph ON_ANSWER["Submit Question Answer"]
        UETA["UserTruths Extractor\nFoundation Models iOS 26"]
        RSCORER["RIASEC Scorer\niOS 26 or keyword fallback"]
    end

    JDC --> GEO --> OTE
    JDC --> EN --> OTE
    OTE --> COLOR --> JOBCARD
    OTE --> TEE --> JOBCARD

    JOBCARD -->|swipe| ON_SWIPE
    FBL --> MIA
    DBA --> MIA
    MIA --> QCARD

    QCARD -->|answer submitted| ON_ANSWER
    UETA --> RSCORER --> MIA

    JOBCARD -->|tap Apply Now| ON_APPLY
    JOBCARD -->|tap Why?| ON_WHY
```

## What Has No UI Home (fires but user never sees it)

| System | Fires when | Output goes nowhere |
|---|---|---|
| ConfidenceCalibrator | Every swipe | Convergence data logged, never displayed |
| SliderPositionLogger | Every swipe | A/B analytics data, no display path yet |
| DeepBehavioralAnalysis | Every swipe | Feeds MIA only, no direct UI output |
