# Manifest & Match — Project Plan

**App:** Tinder-style job matching with dual-self Thompson Sampling AI  
**Device:** iPhone 16 Pro Max  
**Workspace:** `/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8/ManifestAndMatchV7.xcworkspace`  
**Build Folder:** `/Users/jasonl/Desktop/Claudes-Man&Man-build/`

---

## The Core Promise
Swipe on jobs → app learns what you want → recommendations get better over time.  
The Amber/Teal slider shifts between "who you are now" and "who you want to become."  
**This promise is currently broken.** Thompson learning resets every launch.

---

## Phase 0 — Foundation (CURRENT)
**Status:** In progress  
**Goal:** App builds, runs on device, shows real jobs

- [x] Fix duplicate Icon enum (build error)
- [x] Fix duplicate handleQuestionAnswer function (build error)  
- [x] Fix Core Data crash — removed invalid "Default" configuration
- [x] Convert 350+ print() calls to Logger/os_log
- [x] App icon — amber/teal gradient with M&M
- [x] JSearch API key wired (OpenWebNinja, env var in Xcode scheme)
- [ ] Verify real jobs appearing in deck after API key update

---

## Phase 1 — Make the Core Promise True
**Goal:** Swipe → learn → persist → next session is smarter  
**Estimated effort:** 1-2 sessions  
See: `phases/phase1_thompson_persistence.md`

- [ ] Wire ThompsonArm Core Data entity to OptimizedThompsonEngine
  - Load persisted alpha/beta on engine init
  - Save updated alpha/beta on every processInteraction() call
- [ ] Enable Greenhouse API (62 companies, free, already built)
- [ ] Enable Lever API (50 companies, free, already built)
- [ ] Add Thompson debug overlay (hidden: 5-tap on score → shows live alpha/beta)
- [ ] Verify end-to-end: swipe 20 jobs → close app → reopen → params match

---

## Phase 2 — Verify the Loop
**Goal:** Confirm the recommendation engine actually shifts based on swipes  
**Estimated effort:** 1 session  
See: `phases/phase2_loop_verification.md`

- [ ] Confirm user profile data (role, location, skills) flows into JSearch query
- [ ] After 20+ right swipes on tech jobs → confirm tech jobs rise in deck
- [ ] After 20+ left swipes on a role → confirm that role disappears
- [ ] Debug overlay shows alpha/beta drifting in correct direction

---

## Phase 3 — Startup Performance
**Goal:** First job card visible in < 1 second  
**Estimated effort:** 1 session  
See: `phases/phase3_performance.md`

- [ ] Move O*NET pre-load (3655ms) to background after deck appears
- [ ] Move O*NET cache pre-warm (2923ms) to background
- [ ] Lazy-load Thompson cache (only load arms for current profile blend)
- [ ] Target: deck visible < 1s, full data available < 3s

---

## Phase 4 — Job Source Diversity
**Goal:** Multiple job sources, resilient to single API failure  
**Estimated effort:** 1-2 sessions  
See: `phases/phase4_job_sources.md`

- [ ] Evaluate which additional sources to enable (Jobicy, RemoteOK, Adzuna)
- [ ] Get Adzuna keys (free tier available)
- [ ] Enable RSS feeds for niche sectors
- [ ] SmartSourceSelector routing by user profile (healthcare → USAJobs, remote → RemoteOK)
- [ ] Target: 3+ active sources at all times

---

## Phase 5 — AI Features
**Goal:** On-device AI that adds real value beyond matching  
**Estimated effort:** 2-3 sessions  
See: `phases/phase5_ai_features.md`

- [ ] Verify Apple Foundation Models available on iPhone 16 Pro Max
- [ ] Wire cover letter engine to job saves (swipe up → offer cover letter)
- [ ] Test resume upload → PDF parsing → profile population
- [ ] ML Insights dashboard showing swipe pattern analysis
- [ ] Thompson Explanation Engine ("Why this job?" surface in UI)

---

## Phase 6 — App Store Prep
**Goal:** Ready for TestFlight then App Store  
**Estimated effort:** 1-2 sessions

- [ ] Privacy manifest (PrivacyInfo.xcprivacy — required)
- [ ] App Store screenshots (6.7" and 6.1")
- [ ] Review all onboarding copy
- [ ] App Store listing copy
- [ ] TestFlight internal build
- [ ] Review Apple guidelines compliance

---

## Key Metrics to Track
| Metric | Current | Target |
|--------|---------|--------|
| Startup to first card | ~6.5s | < 1s |
| Thompson persistence | ❌ resets | ✅ survives launch |
| Active job sources | 1 (JSearch) | 3+ |
| Jobs per fetch | 50 | 50-150 |
| Thompson <10ms target | unknown | verified |

---

## Sacred Values (Never Change)
- Swipe right threshold: 100pt
- Swipe left threshold: -100pt  
- Swipe up threshold: -80pt
- Spring response: 0.6
- Spring damping: 0.8
- Card width ratio: 0.92
- Card height ratio: 0.85
- Amber hue: 45/360
- Teal hue: 174/360
