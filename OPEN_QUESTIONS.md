# Open Questions — Manifest & Match
**Product decisions that need Jason's answer before I can build that piece.**
**When I hit a blocker that requires a product call, I add it here instead of guessing.**

---

## Answered

- **App structure:** Use existing V7 app as the guide. Keep the working skeleton.
- **Tab 1 name:** Tracker
- **Question cards:** Need-based pull, not scheduled. Details decided when we build that functionality.
- **Design specifics:** Decided when we reach that part of the build.

---

## Open

### Q4: Should ads appear in the Discover deck or somewhere else?
**Current plan:** 1 ad every 10 job cards in the Discover deck.
**Alternative:** Ads in a separate "Sponsored" section, or only in Manifest tab.
**Why it matters:** Ads in the main job deck is the highest-revenue placement but most disruptive. Elsewhere is less disruptive but earns less.
**Default if not answered:** Ads in Discover deck at 1:10 ratio as planned.

### Q6: Is there an authentication system planned?
**Current:** No auth. All data is local.
**Why it matters:** If Sign in with Apple is planned, that changes the Profile tab significantly.
**Default if not answered:** No auth in this build. Profile is local settings only.

### Q7: Does onboarding change at all from V7?
**Current V7 onboarding:** 7 steps — intro, role selection, location, skills, work values, career goals, first jobs preview.
**Default if not answered:** Keep V7's 7-step structure.

### Q8: Is there anything about the app you don't want ads near?
**Current plan:** Ads inject into the Discover job deck only.
**Default if not answered:** Discover deck only. No ads in job details, onboarding, Tracker, Profile, or Manifest.

### Q9: Any apps that feel like what you want this to feel like visually?
**Default if not answered:** Match V7's current visual language.
