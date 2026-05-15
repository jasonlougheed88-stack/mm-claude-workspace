# Taxonomy Build Plan
**Manifest & Match V8 | Created: 2026-05-14**
**Based on:** SCHEMATIC_06_taxonomy_and_matching.md + deep research findings

---

## What We're Solving

The current taxonomy layer has three distinct failure modes (from SCHEMATIC_06):

1. **RIASECKeywordMapper** — 90 keywords, bag-of-words. "engineer" always → Investigative regardless of type. This feeds user RIASEC back into job ranking at 5–25% weight. The noise compounds over time as swipes accumulate.

2. **Modern job title → O*NET code gap** — "Founding Engineer", "ML Engineer", "DevRel", "AI Product Manager" either miss or collapse into wrong SOC codes. The ONetCodeMapper has 51 curated modern mappings — not enough.

3. **Skill synonym coverage** — SkillTaxonomy.json has 787 canonical skills, ~3,500 total aliases. ESCO v1.2 has 13,500+ skill concepts built from actual job postings across 28 languages. Our synonym coverage has gaps that reduce skillsScore accuracy.

---

## The Three-Layer Architecture

```
Layer 1: O*NET (KEEP — no changes)
  923 occupations × RIASEC (6-dim, psychometrically validated)
  967 occupations × Work Activities (41-dim)
  726 occupations × Skills (importance + level per occupation)
  All offline, bundled, <5ms access
  → DO NOT REPLACE. The data quality is the best available.

Layer 2: ESCO v1.2 (ADD — skill synonym augmentation)
  13,500+ skill concepts with alternativeLabels
  3,039 occupations × skills (essential + optional matrix)
  Used as a one-time build-time enrichment of SkillTaxonomy.json
  → Extends synonym coverage without changing runtime architecture

Layer 3: Foundation Models (ADD — replaces RIASECKeywordMapper for iOS 26+)
  On-device, offline, free, already running in the app
  Used at job ingest time (async, background) — NOT in scoring hot path
  Produces 6-dim RIASEC profile per job, stored in Core Data
  → Semantic understanding replaces keyword counting
```

---

## Layer 1 — O*NET: What Changes and What Doesn't

### What Stays Exactly As-Is

- All 13 JSON files in `V7Core/Sources/V7Core/Resources/onet_*.json`
- `ONetCodeMapper.swift` — the 4-tier mapping pipeline
- `JobONetEnricher.swift` — the actor singleton wiring
- `OptimizedThompsonEngine.calculateWorkActivitiesScore()` — cosine similarity on 41-dim vectors
- `OptimizedThompsonEngine.calculateRIASECScore()` — cosine similarity on 6-dim vectors

### One Addition to ONetCodeMapper

The current modern mappings file has 51 entries (`onet_modern_mappings.json`). We add ~200 more covering titles that hit fuzzy fallback or miss entirely.

**Target titles to add (not exhaustive — derived from common JSearch result titles):**

| Modern Title | → SOC Code | Confidence |
|---|---|---|
| ML Engineer | 15-2051.00 (Data Scientists) | 0.85 |
| AI Engineer | 15-1221.00 (Computer/Info Research Scientists) | 0.82 |
| AI Product Manager | 11-3021.00 (Computer/IS Managers) | 0.78 |
| Platform Engineer | 15-1252.00 (Software Developers) | 0.88 |
| Infrastructure Engineer | 15-1244.00 (Network/System Administrators) | 0.84 |
| Site Reliability Engineer | 15-1244.00 | 0.86 |
| Staff Engineer | 15-1252.00 | 0.92 |
| Principal Engineer | 15-1252.00 | 0.90 |
| Founding Engineer | 15-1252.00 | 0.80 |
| Developer Advocate | 15-1299.09 (Web Developers) | 0.72 |
| DevRel | 15-1299.09 | 0.70 |
| Growth Engineer | 15-1252.00 | 0.78 |
| Prompt Engineer | 15-2051.00 | 0.75 |
| Data Infrastructure Engineer | 15-1244.00 | 0.83 |
| Analytics Engineer | 15-2041.00 (Statisticians) | 0.80 |
| Solutions Architect | 15-1299.08 (Computer Systems Engineers) | 0.88 |
| Technical Program Manager | 15-1299.09 | 0.82 |
| Engineering Manager | 11-9041.00 (Architectural/Engineering Managers) | 0.85 |
| Head of Engineering | 11-9041.00 | 0.84 |
| Head of Product | 11-2021.00 (Marketing Managers) | 0.72 |
| Creator Economy Manager | 11-2021.00 | 0.65 |
| Content Creator | 27-3043.00 (Writers/Authors) | 0.70 |

**Process:** Generate from job2vec nearest-neighbor or manual review of common JSearch results. Add to `onet_modern_mappings.json` as additional key-value entries. No code change needed — ONetCodeMapper already reads this file.

**Estimated effort:** 4–8 hours (data research + JSON editing + validation)

---

## Layer 2 — ESCO: Skill Synonym Augmentation

### What ESCO Is

ESCO v1.2.1 (December 2025) is the EU equivalent of O*NET:
- 13,500+ skill/knowledge concepts with `preferredLabel` + `alternativeLabels`
- Skills-to-occupations relationship table (essential vs optional)
- Free download: https://esco.ec.europa.eu/en/use-esco/download
- License: open reuse permitted
- Format: CSV, JSON-LD, RDF, XML
- Size: ~6MB for English-only CSVs

### What We Do With It

This is a **build-time enrichment**, not a runtime dependency. ESCO does not ship in the app.

**Step 1: Download**
Download the English CSV package from the ESCO download portal. The relevant files:
- `skills_en.csv` — all 13,500+ skills with preferredLabel + alternativeLabels
- `occupationSkillRelations_en.csv` — which skills are essential/optional per occupation
- `occupations_en.csv` — ISCO-08 occupation codes

**Step 2: Run enrichment pipeline (Python, one-time)**

```python
# enrichment_pipeline.py
# Input: skills_en.csv, existing SkillTaxonomy.json
# Output: SkillTaxonomy_enriched.json

import csv, json

# Load existing taxonomy
with open('SkillTaxonomy.json') as f:
    taxonomy = json.load(f)

# Build alias lookup from existing taxonomy
existing_canonical = {}
for skill in taxonomy['skills']:
    existing_canonical[skill['canonical'].lower()] = skill
    for alias in skill.get('aliases', []):
        existing_canonical[alias.lower()] = skill

# Process ESCO skills
with open('skills_en.csv') as f:
    reader = csv.DictReader(f)
    for row in reader:
        preferred = row['preferredLabel']
        alternatives = [a.strip() for a in row['altLabels'].split('\n') if a.strip()]
        
        # Find matching canonical in our taxonomy
        canonical_entry = existing_canonical.get(preferred.lower())
        if canonical_entry:
            # Add ESCO alt labels as new aliases
            existing_aliases = set(a.lower() for a in canonical_entry['aliases'])
            new_aliases = [a for a in alternatives if a.lower() not in existing_aliases]
            canonical_entry['aliases'].extend(new_aliases)

# Write enriched taxonomy
with open('SkillTaxonomy_enriched.json', 'w') as f:
    json.dump(taxonomy, f, indent=2)
```

**Step 3: Validate + replace**
- Run diff to verify alias count increased, no canonicals changed
- Replace `SkillTaxonomy.json` in V7Core/Sources/V7Core/Resources/ with the enriched version
- Expected outcome: ~787 canonical skills (unchanged), aliases grow from ~3,500 to ~6,000–8,000

**What this fixes:**
- "Postgres" → "PostgreSQL" (already handled), but gains: "Postgresql", "psql", "postgres database", "pg"
- "JavaScript" gains: "js", "javascript es6", "javascript es2015", "ecmascript 2015", "node javascript"
- Healthcare skills gain extensive clinical terminology alt labels
- Trade skills gain regional and informal variants

**Estimated effort:** 1 day (download + pipeline + validation + bundle update)

---

## Layer 3 — Foundation Models: RIASEC Inference

### Current State (from SCHEMATIC_06)

`RIASECKeywordMapper` (`V7AI/Sources/V7AI/Parsing/RIASECKeywordMapper.swift`):
- ~90 keywords across 6 Sets (static, hardcoded)
- Bag-of-words tokenization
- Normalizes keyword counts to 0–7 scale
- Used on question card answers to update `InferredManifestProfile`
- "engineer" and "developer" both in Investigative set → mechanical engineer misclassified

### What Changes

We split the RIASEC inference into two paths based on iOS version:

```
iOS 26+ with Apple Intelligence:
  Question answer text
    ↓ FoundationModelsRIASECExtractor (new)
    → structured generation via @Generable
    → {realistic: 2, investigative: 7, artistic: 1, social: 1, enterprising: 3, conventional: 5}
    → InferredManifestProfile update (same as before)

iOS 26 without Apple Intelligence / pre-iOS 26:
  Question answer text
    ↓ RIASECKeywordMapper (unchanged — fallback only)
    → keyword counting (current behavior)
    → InferredManifestProfile update
```

### New File: FoundationModelsRIASECExtractor.swift

**Location:** `V7AI/Sources/V7AI/Parsing/FoundationModelsRIASECExtractor.swift`

```swift
import FoundationModels

@Generable
struct RIASECInference {
    @Guide(description: "Realistic dimension 0-10: hands-on, mechanical, outdoor, physical, tools, construction, building, fixing")
    var realistic: Int
    @Guide(description: "Investigative dimension 0-10: analysis, research, data, scientific, mathematics, problem-solving, coding, diagnosis")
    var investigative: Int
    @Guide(description: "Artistic dimension 0-10: creative, design, expressive, writing, music, visual, unstructured, innovative")
    var artistic: Int
    @Guide(description: "Social dimension 0-10: helping others, teaching, counseling, healthcare, team collaboration, communication, service")
    var social: Int
    @Guide(description: "Enterprising dimension 0-10: leadership, selling, persuading, managing, business strategy, negotiating, influencing")
    var enterprising: Int
    @Guide(description: "Conventional dimension 0-10: organizing, data entry, following procedures, accuracy, compliance, systematic, scheduling")
    var conventional: Int
}

actor FoundationModelsRIASECExtractor {
    static let shared = FoundationModelsRIASECExtractor()
    private let session: LanguageModelSession

    private init() {
        session = LanguageModelSession()
    }

    func extractRIASEC(from text: String) async throws -> [String: Double] {
        let prompt = """
        Score the following work-related text on Holland Occupational Types (RIASEC).
        Consider what kind of work is described, not the person's background.
        Text: "\(text)"
        """

        let response = try await session.respond(
            to: prompt,
            generating: RIASECInference.self
        )

        let scale = 7.0 / 10.0
        return [
            "realistic":     Double(response.realistic) * scale,
            "investigative": Double(response.investigative) * scale,
            "artistic":      Double(response.artistic) * scale,
            "social":        Double(response.social) * scale,
            "enterprising":  Double(response.enterprising) * scale,
            "conventional":  Double(response.conventional) * scale
        ]
    }
}
```

**Note on scale:** O*NET uses 0–7. Foundation Models output is guided 0–10 for natural language reasons. The `× (7.0/10.0)` normalizes to O*NET scale so the output slots directly into the existing `InferredManifestProfile` fields without any downstream changes.

### Modified File: SmartQuestionGenerator.swift or the answer handler

**Location:** Wherever `RIASECKeywordMapper.extractRIASEC()` is currently called (in `AnswerParsingActor` or `SmartQuestionGenerator`)

**Current call site (SCHEMATIC_06 finding):**
```swift
// Current — keyword bag
let riasecScores = RIASECKeywordMapper.shared.extractRIASEC(from: answerText)
```

**New call site:**
```swift
let riasecScores: [String: Double]
if LanguageModelSession.isAvailable {
    riasecScores = (try? await FoundationModelsRIASECExtractor.shared.extractRIASEC(from: answerText))
        ?? RIASECKeywordMapper.shared.extractRIASEC(from: answerText)
} else {
    riasecScores = RIASECKeywordMapper.shared.extractRIASEC(from: answerText)
}
```

**The existing RIASECKeywordMapper stays untouched** — it becomes the fallback only.

### Additional Use: Job RIASEC Enrichment at Ingest (Optional Phase 2)

Once the above is working, a second application: when a job arrives from JSearch without an O*NET code match (enrichment confidence < 0.5), instead of returning 0.5 neutral, use Foundation Models to infer a RIASEC profile from the job title + description snippet.

This is Phase 2 — do not build until the user RIASEC path is validated.

**Estimated effort (Layer 3, user RIASEC path only):** 2–3 days

---

## What This Does NOT Change

The following are explicitly out of scope for this plan:

- `OptimizedThompsonEngine.swift` — scoring formula unchanged
- `EnhancedSkillsMatcher.swift` — 4-strategy cascade unchanged
- `StringSimilarity.swift` — Levenshtein implementation unchanged
- `ONetCodeMapper.swift` — pipeline logic unchanged (only JSON data file extended)
- `ThompsonArm` Core Data entity — unchanged
- `InferredManifestProfile` Core Data entity — unchanged (same fields, better input)
- The <10ms scoring requirement — unchanged, Foundation Models runs at ingest not at score time

---

## Implementation Sequence

```
Week 1:
  Day 1–2:  Layer 2 — ESCO enrichment pipeline
            Download CSVs → run Python script → validate → replace SkillTaxonomy.json
            Test: skillsScore changes on 20 sample job matchings (expect small improvement)

  Day 3–4:  Layer 1 — Modern title expansion
            Compile ~200 modern title → SOC mappings
            Add to onet_modern_mappings.json
            Test: ONetCodeMapper hit rate on sample of 100 recent JSearch job titles

  Day 5:    Validate both layers together
            Run end-to-end scoring on 50 representative jobs
            Compare combinedScore distributions before/after
            Check for regressions in existing title mappings

Week 2:
  Day 1–3:  Layer 3 — FoundationModelsRIASECExtractor
            Write FoundationModelsRIASECExtractor.swift
            Wire into answer handler with fallback
            Test: Same 10 question answers through old keyword mapper vs new Foundation Models
            Validate output is on 0–7 scale and writes correctly to InferredManifestProfile

  Day 4:    Integration testing
            Full onboarding flow → answer 5 questions → check InferredManifestProfile RIASEC
            Confirm fallback triggers correctly on simulated non-Apple-Intelligence device

  Day 5:    Cleanup
            Remove any dead code that was depending on keyword mapper as primary
            Update SCHEMATIC_06 with new accuracy baselines
```

---

## Success Criteria

| Metric | Before | Target After |
|---|---|---|
| Skill synonym coverage (aliases per canonical) | ~4.5 average | ~8–10 average |
| ONetCodeMapper hit rate on modern tech titles | ~60% (estimated) | ~85%+ |
| RIASEC inference accuracy (iOS 26+ with AI) | ~50% (semantic errors from keyword overlap) | ~85%+ (semantic classification) |
| RIASEC fallback (pre-iOS 26) | unchanged keyword mapper | no change |
| Thompson scoring latency | <10ms | <10ms (unchanged) |
| App binary size impact | — | +6MB (ESCO pipeline output in taxonomy JSON) |

---

## Files to Create

| File | Location | Purpose |
|---|---|---|
| `FoundationModelsRIASECExtractor.swift` | `V7AI/Sources/V7AI/Parsing/` | Replaces keyword mapper for iOS 26+ |
| `enrichment_pipeline.py` | Build tools (not in app bundle) | One-time ESCO → SkillTaxonomy merger |

## Files to Modify

| File | Change |
|---|---|
| `V7Core/Sources/V7Core/Resources/SkillTaxonomy.json` | Replace with ESCO-enriched version (pipeline output) |
| `V7Core/Sources/V7Core/Resources/onet_modern_mappings.json` | Add ~200 modern title entries |
| Answer handler (call site of RIASECKeywordMapper) | Add Foundation Models path with fallback |

## Files Unchanged

Everything else — ONetCodeMapper, EnhancedSkillsMatcher, StringSimilarity, OptimizedThompsonEngine, all Core Data entities, all Thompson logic.
