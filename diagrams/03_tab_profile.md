# Tab 2: Profile

User settings and data management. The slider lives here. Changes here propagate directly into scoring at next deck load.

```mermaid
flowchart TD
    subgraph PROFILE_UI["Tab 2 UI"]
        SLIDER["Amber/Teal Slider\nprofileBlend 0.0 to 1.0"]
        SKILLS["Skills section"]
        WORKHIST["Work history"]
        EDUCATION["Education"]
        RESUME["Resume upload"]
        SETTINGS["Settings\n8 stubs in V7/V8 — real views in v1.1"]
        COVERLETTER["Cover Letter Generator\nCoverLetterService — GPT-4o-mini"]
    end

    subgraph SLIDER_EFFECT["Slider Controls Scoring + Discovery"]
        TW["ThompsonWeights\n5 lever weights interpolated from blend"]
        GEO["Geo Filter threshold\n40mi at amber → 100mi at teal"]
        OAD["OccupationAdjacencyService\nexpands job titles when blend above 0.25"]
    end

    subgraph PROFILE_DATA["Core Data"]
        UP["UserProfile\namberTealPosition, skills, desiredRoles"]
        WE["WorkExperience"]
        ED["Education"]
        CERT["Certification"]
    end

    subgraph RESUME_PIPE["Resume Upload Pipeline"]
        PDF["PDF text extraction"]
        RPARSE["ResumeParser\nOpenAI key from Keychain"]
        ENRICH["ProfileEnrichmentService\nO*NET field mapping"]
    end

    subgraph DOWNSTREAM["What Changes in Tab 0 Deck"]
        OTE["Thompson Engine\nreads updated UserProfile on next load"]
        JDC["Job Discovery Coordinator\nreads blend for Geo + Adjacency"]
    end

    SLIDER --> UP
    UP --> TW --> OTE
    UP --> GEO --> JDC
    UP --> OAD --> JDC

    SKILLS --> UP
    WORKHIST --> WE
    EDUCATION --> ED

    RESUME --> PDF --> RPARSE --> ENRICH --> UP
    ENRICH --> WE
    ENRICH --> ED
    ENRICH --> CERT
```

## Key Fact: Slider Lives in Tab 2, Not Tab 0

The slider is in ProfileScreen (Tab 2). Its value persists to `UserProfile.amberTealPosition` in Core Data. DeckScreen reads it at init. Changing the slider does not instantly re-sort the current deck — it takes effect on the next job fetch.

## Gaps

- 8 settings links are stubs in V7/V8 — need real views: Change Password, Privacy Settings, Data Management, etc.
- No Keychain UI — users have no way to enter/update their OpenAI key from Settings
- Slider change does not trigger immediate deck refresh — user must navigate away and back
