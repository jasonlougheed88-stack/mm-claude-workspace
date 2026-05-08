# Phase 5 — AI Features

## Apple Foundation Models (On-Device)
iPhone 16 Pro Max supports Apple Intelligence.
`FoundationModelsDetector` in V7Services checks availability at runtime.
All AI runs on-device — no API calls, no cost, private.

## Cover Letter Engine
- `CoverLetterEngine.swift` — exists, needs wiring
- Trigger: user swipes up (saves job) → sheet appears offering cover letter
- Input: job data + user profile from Core Data
- Output: tailored cover letter draft

## Resume Upload
- `ResumeUploadStepView.swift` — in onboarding step
- `ResumeExtractor.swift` — PDF parsing
- `AICareerProfileBuilder.swift` — maps extracted data to UserProfile Core Data entity
- Needs end-to-end test: upload real PDF → verify profile fields populated

## Thompson Explanation Engine
- `ThompsonExplanationEngine.swift` — exists
- Surface as "Why this job?" button on each card
- Shows: which skills matched, which profile (amber/teal) it appeals to, confidence score

## ML Insights Dashboard
- `MLInsightsDashboard.swift` — exists
- Shows swipe patterns, skill gaps, role distribution
- Wire to Analytics tab
