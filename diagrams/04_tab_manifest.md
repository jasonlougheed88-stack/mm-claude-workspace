# Tab 3: Manifest

Career building hub. Everything here is driven by `InferredManifestProfile` — the model built entirely from swipe behavior in Tab 0. A new user with zero swipes sees nothing meaningful here. This is by design.

```mermaid
flowchart TD
    subgraph FEED["What Builds the Manifest Tab"]
        SWIPES["Tab 0: every swipe"]
        FBL["Behavioral Learning"]
        MIA["Manifest Inference Actor\ndebounced 5s, threshold 3 swipes"]
        IMP["InferredManifestProfile\nCore Data — confidence score included"]
    end

    subgraph MANIFEST_UI["Tab 3 UI — ManifestTabView"]
        OVERVIEW["Overview"]
        SKILLS_GAP["Skills Gap"]
        CAREER["Career Path"]
        COURSES["Courses"]
    end

    subgraph SKILLS_SYS["Skills Gap System"]
        SGA["SkillsGapAnalyzer\ncurrent skills vs target role requirements"]
    end

    subgraph CAREER_SYS["Career Path System"]
        CPE["CareerPathEngine\nbuilds paths from inferred roles"]
        MDA["MarketDemandAPI\nBLS bundled occupation demand data — offline"]
    end

    subgraph COURSE_SYS["Course System"]
        CRE["CourseRecommendationEngine\n8-factor scoring, 3-tier fallback"]
        JSON["courses_v1.json\n4.1MB Coursera + Udemy + edX — bundled"]
        AFF["AffiliateTracker\nPhase 5 — Coursera 35% + Udemy 17.5%"]
    end

    SWIPES --> FBL --> MIA --> IMP

    IMP --> OVERVIEW
    IMP --> SGA --> SKILLS_GAP
    IMP --> CPE --> CAREER
    CPE --> MDA
    IMP --> CRE --> COURSES
    CRE --> JSON
    COURSES -->|tap course| AFF
```

## Key Fact: Manifest Tab Is Entirely Inference-Driven

No job listing data reaches this tab. No external APIs are called here (MarketDemandAPI uses bundled offline BLS data). Everything is derived from the user's own swipe behavior. The richer the swipe history, the more meaningful this tab becomes.

## What Was Broken in V7/V8 — Fixed in v1.1

| System | V7/V8 State | v1.1 |
|---|---|---|
| CourseRecommendationEngine | Never called, courses tab empty, filename crash bug | Wired, filename fixed |
| CareerPathEngine | Never called, ManifestTabView built paths ad-hoc | Routed through CareerPathEngine |
| SkillsGapAnalyzer | Marked ISSUE #2 in ManifestTabView — incomplete wiring | Wired |

## Gaps

- No empty state design for new users (fewer than 3 swipes)
- AffiliateTracker requires real credentials (Phase 5) — placeholder until then
- edX has no affiliate program (0% commission) — lower implementation priority
- TealPathGenerator (future career projections) exists but not shown in current tab destinations
