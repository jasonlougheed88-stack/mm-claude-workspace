# Open Questions — Manifest & Match
**Product decisions that need Jason's answer before I can build that piece.**
**When I hit a blocker that requires a product call, I add it here instead of guessing.**

Format: question → why it's blocking → what I'll do if not answered (default assumption)

---

## Navigation & Structure

### Q1: Tab names — keep or rename?
**Current names:** Discover / History / Profile / Manifest
**Why it matters:** Tab labels are the first thing users read. "Manifest" is abstract and product-specific. "Discover" is clean. No wrong answer — just need a decision before I write the tab enum.
**Default if not answered:** Keep current names exactly.

### Q2: Does the Manifest tab get a new name now that it includes Courses?
**Current:** "Manifest" — career building hub, skills gap, career path, courses
**Option:** Rename to "Grow" / "Build" / "Learn" / keep "Manifest"
**Why it matters:** Courses + career path + skills gap together might feel like a different concept than "Manifest."
**Default if not answered:** Keep "Manifest."

---

## Deck Screen (Tab 0)

### Q3: Amber/Teal slider — where does it live on the screen?
**Current:** Slider is visible on DeckScreen, controls the exploration/exploitation blend.
**Why it matters:** It's a prominent UI element that needs intentional placement. Currently sits below the card stack.
**Default if not answered:** Keep current position (below card stack).

### Q4: Should ads appear in the Discover deck or somewhere else?
**Current plan:** 1 ad every 10 job cards in the Discover deck.
**Alternative:** Ads in a separate "Sponsored" section, or only in Manifest tab.
**Why it matters:** Ads in the main job deck is the highest-revenue placement but most disruptive. Elsewhere is less disruptive but earns less.
**Default if not answered:** Ads in Discover deck at 1:10 ratio as planned.

---

## Manifest Tab (Tab 3)

### Q5: Where exactly do courses live in the Manifest tab?
**Current V7:** ManifestTabView has sub-navigation destinations including `.courses`. It's a list inside the Manifest tab.
**Options:** (A) Same — a section inside Manifest tab alongside skills gap and career path. (B) Prominent featured row at the top of Manifest. (C) Its own full-screen inside Manifest.
**Why it matters:** Revenue depends partly on course visibility. Buried = fewer clicks.
**Default if not answered:** Prominent featured section at top of Manifest tab, above skills gap.

---

## Profile Tab (Tab 2)

### Q6: Is there an authentication system planned?
**Current:** No auth. All data is local. "Change Password" is a stub that says "Managed via Apple ID."
**Why it matters:** If Sign in with Apple is planned, that changes the Profile tab significantly — it becomes the account hub. If not, Profile stays purely local settings.
**Default if not answered:** No auth in this build. Profile is local settings only.

---

## Onboarding

### Q7: Does onboarding change at all from V7?
**Current V7 onboarding:** 7 steps — intro, role selection, location, skills, work values, career goals, first jobs preview.
**Why it matters:** Onboarding is the first thing every user sees. V7's 7 steps is reasonable but we could simplify or reorder. Also: where does the ATT consent prompt fit — during onboarding or after?
**Default if not answered:** Keep V7's 7-step structure. ATT prompt after final onboarding step.

---

## Revenue

### Q8: Is there anything about the app you don't want ads near?
**Current plan:** Ads inject into the Discover job deck only.
**Why it matters:** Some contexts feel wrong for ads (e.g., while reading job details, during onboarding). Just want to confirm deck-only is correct before wiring.
**Default if not answered:** Discover deck only. No ads in job details, onboarding, History, Profile, or Manifest.

---

## Visual Feel

### Q9: Any apps that feel like what you want this to feel like?
**Why it matters:** "Use the existing structure" tells me the architecture. It doesn't tell me if you want it to feel more polished/minimal (LinkedIn), more playful (Duolingo-ish), more professional/serious (Blind). This affects color weight, animation style, card design.
**Default if not answered:** Match V7's current visual language — clean, professional, Amber/Teal as the color system, iOS-native feel.

---

## How to use this file

- Jason reviews periodically and adds answers inline below each question
- When a question is answered, I move it to DECISIONS.md and delete it from here
- New questions get added here as they come up during build
- If a question is blocking the current phase, it gets noted in BUILD_SEQUENCE.md too
