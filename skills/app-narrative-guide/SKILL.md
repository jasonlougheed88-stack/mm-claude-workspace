---
name: app-narrative-guide
description: Ensures every feature serves the core mission - helping people discover unexpected careers and confidently transition to fulfilling work
allowed-tools:
  - Read
  - Grep
  - Edit
---

## Purpose

Keeps all code, features, and design decisions aligned with the app's transformative mission: **revealing career possibilities users never knew existed by mapping transferable skills across industries**.

This isn't a job board. This is a career awakening platform.

## Sacred Mission Statement

> "Danifest & Destiny V7 answers the question nobody's asking but everyone's wondering: *What could I actually become based on who I really am?*
>
> We don't just show available jobs. We reveal hidden potential and provide realistic roadmaps to get there. This is about transformation, not just job switching."

## Activation Triggers

This skill activates when you're:
- Designing new features or UI flows
- Making product decisions about what to build
- Prioritizing features or bug fixes
- Writing user-facing text or messaging
- Evaluating whether code serves the user's transformation journey

## The Core User Problem We're Solving

### The Fundamental "Why"

**40 million professionals are employed but deeply unfulfilled** - trapped in careers that no longer excite them, believing they're "locked in" to their current field with no visibility into what else they could do.

### The Broken Promise of Existing Solutions

- **LinkedIn, Indeed, ZipRecruiter**: Show similar jobs in current field (accountant → accountant)
- **Career coaches**: Expensive ($150-300/hour), subjective advice
- **Online courses**: Overwhelming choice, no direction on which path is right for YOU
- **Networking apps**: Passive connections without discovery mechanism

**The Gap Nobody Fills**: Helping professionals discover what they could become by analyzing their hidden potential through skill transferability.

---

## The Three User Personas (Sacred Context)

### Persona 1: "The Stuck Professional" (Ages 28-45, PRIMARY)

**Who They Are**:
- Currently employed, making $60k-$150k+
- Skilled and experienced in their field
- Feel trapped: "If I leave, I start from zero"
- Growing anxiety that "this is their life now"

**What They Say**:
- "I'm good at what I do, but I don't want to do it anymore"
- "Everyone says I'm lucky, so I can't complain"
- "I don't know what else I could even do"
- "By now it's too late to change"

**What They Need**:
- Discovery of 3-5 specific career paths aligned with hidden skills
- Confidence that transition is achievable (not starting over)
- Realistic timelines and transition pathways
- Proof that people like them have succeeded

**Success Metric**: User takes first action toward exploration/transition within 30 days

**Real Example**: Marketing manager (unhappy with corporate politics) discovers they have all core skills for product management or UX research, with realistic 6-month transition path.

---

### Persona 2: "The Career Pivot" (Ages 25-35, SECONDARY)

**Who They Are**:
- Actively unhappy in current role
- Willing to invest time/money to learn new skills
- Fear of "wasting time" on wrong pivot
- Paralyzed by too many options

**What They Say**:
- "I want OUT but don't know which direction"
- "Will my resume make sense if I switch fields?"
- "I can't afford to go back to school for 4 years"
- "How do I know this is the right change?"

**What They Need**:
- Clear, concrete transition pathway with realistic timeline
- Specific skill gaps and how to fill them
- Validation that their pivot is realistic
- Job opportunities waiting at the end

**Success Metric**: 30% pursue opportunities aligned with alternative career within 90 days

**Real Example**: Teacher (burnt out, wanting tech) learns they can transition to instructional design, content strategy, or product management by leveraging communication and systems-thinking skills.

---

### Persona 3: "The Recent Graduate" (Ages 22-26, TERTIARY)

**Who They Are**:
- First job isn't what they expected
- Want to explore before committing to one path
- Worried about "gaps" on resume if they change
- Imposter syndrome in new role

**What They Say**:
- "My first job isn't what I imagined"
- "Is this failure if I change paths?"
- "I don't understand what I actually want yet"
- "There are too many options and I feel lost"

**What They Need**:
- Recognition that first job doesn't define career
- Understanding of which industries/roles match thinking style
- Permission to explore without judgment
- Confidence in making intentional second move

**Success Metric**: High satisfaction with career decisions; significantly lower job-switching regret

**Real Example**: Psychology grad in HR role discovers they'd excel in product management, user research, or organizational development based on people insights.

---

## The Revolutionary Core: Amber → Teal Dual-Profile System

### The Sacred Color System

**Amber (Match Profile)**: Your current self
- Your explicit skills and experience
- Your proven track record
- Safe, familiar career opportunities
- Represents "who you are today"

**Teal (Manifest Profile)**: Your potential self
- AI-discovered hidden talents
- Cross-domain career possibilities
- Growth trajectory visualization
- Represents "who you could become"

**The Gradient**: Visual journey from Amber through mixed tones to Teal - the transformation journey made visible

### Why This Matters for Code

Every UI component must reinforce this duality:
- Amber elements = current reality (warm, familiar, safe)
- Teal elements = future potential (cool, aspirational, exciting)
- Gradient transitions = the journey between them

**Code Implication**: Color choices aren't arbitrary - they communicate identity transformation.

---

## The Three Competitive Advantages (What Only We Do)

### 1. Cross-Domain Discovery Algorithm

**What It Does**:
- Analyzes skills at meta level (not keyword matching)
- Identifies transferable patterns employers never explicitly list
- Example: Firefighter's "crisis decision-making" = "incident management" (DevOps skill)

**User Value**: Discover 5-10 viable alternative careers they'd never consider

**Code Implication**:
- Thompson Sampling must prioritize skill transferability, not just title matching
- Job parsing must extract meta-skills, not just keywords
- Embeddings must capture semantic similarity across domains

```swift
// ❌ WRONG: Title-based matching
if user.currentTitle == "Teacher" {
    recommendJobs(titles: ["Teacher", "Tutor", "Instructor"])
}

// ✅ CORRECT: Skill-based cross-domain matching
let userMetaSkills = extractMetaSkills(user.experience)
// ["Communication", "Curriculum Design", "Student Assessment"] →
// ["UX Design", "Content Strategy", "Product Management"]

let crossDomainMatches = findCareersByMetaSkills(userMetaSkills)
```

---

### 2. Realistic Transition Pathways

**What It Does**:
- Not "you could be anything" (overwhelming)
- Not just "here's the job posting" (no guidance)
- But: "To transition from A to B, learn these 3 skills in this order, takes 6-12 months, here's market demand"

**User Value**: Confidence that transition is achievable with clear roadmap

**Code Implication**:
- Every career suggestion must include transition pathway
- Skill gaps must be identified and quantified
- Learning resources must be contextually relevant

```swift
// ✅ CORRECT: Transition pathway included
struct CareerSuggestion {
    let targetRole: String
    let matchScore: Double
    let currentSkills: [String]        // What they already have
    let missingSkills: [String]        // What they need to learn
    let transitionTimeline: String     // "6-12 months"
    let learningResources: [Course]    // How to fill gaps
    let marketDemand: Int              // Number of available jobs
    let successStories: [Story]        // Proof it's been done
}
```

---

### 3. AI-Powered Job Discovery from 25+ Sources

**What It Does**:
- Beyond the same LinkedIn listings everyone sees
- Includes: Greenhouse/Lever companies, Indeed, specialized boards
- Jobs matched at skill level (not job title level)

**User Value**: Find opportunities aligned with who they could become, not just who they are

**Code Implication**:
- Job sources must be diverse (14 sectors, not just tech)
- Bias detection enforced (no sector >30%)
- Jobs matched to Manifest Profile (potential), not just Match Profile (current)

```swift
// ✅ CORRECT: Match to potential, not just current
func recommendJobs(user: UserProfile) -> [Job] {
    let currentMatches = matchToCurrentSkills(user.matchProfile)  // Amber
    let potentialMatches = matchToManifestProfile(user.manifestProfile)  // Teal

    // Show BOTH - current opportunities AND growth opportunities
    return blend(
        current: currentMatches,
        potential: potentialMatches,
        ratio: 0.4  // 40% current, 60% potential
    )
}
```

---

## The Four-Act User Journey (Every Feature Must Serve This)

### Act I: "The Cage" (Problem Recognition)

**User State**: Realizes success has become a prison

**App's Role**: Create safe space to acknowledge unfulfillment

**Features That Serve This**:
- Profile creation that validates "it's okay to want more"
- Initial assessment that surfaces hidden dissatisfaction
- Community of others feeling same way

**Code Implication**: Onboarding shouldn't feel like "fix your resume" - it should feel like "explore who you could be"

---

### Act II: "The Revelation" (Discovery & Possibility)

**User State**: "Wait... I could be PERFECT for that? I never considered it."

**App's Role**: Generate and present unexpected career possibilities

**Features That Serve This**:
- AI generates Manifest Profile with 5-10 unexpected careers
- Clear explanation of WHY app thinks they'd excel
- Success stories of people who made similar transitions

**Code Implication**:
- Manifest Profile generation is THE critical moment
- Must feel magical, not random
- Must be backed by data, not fluff

```swift
// ✅ CORRECT: Revelation moment
struct ManifestProfileReveal: View {
    let unexpectedCareers: [CareerSuggestion]

    var body: some View {
        VStack {
            Text("Based on your hidden skills, here are careers you might not have considered:")
                .font(.title2)

            ForEach(unexpectedCareers) { career in
                CareerRevealCard(career: career)
                    .accessibilityLabel("Unexpected career possibility: \(career.targetRole)")
            }
        }
    }
}
```

---

### Act III: "The Climb" (Investment & Action)

**User State**: Moving from possibility to reality

**App's Role**: Guide first steps toward transition

**Features That Serve This**:
- Transition pathway with concrete next steps
- Learning resources aligned with skill gaps
- Job opportunities in target field
- Progress tracking and milestone celebration

**Code Implication**:
- Track user progress through transition
- Celebrate small wins (first course completed, first application sent)
- Provide encouragement during plateaus

```swift
// ✅ CORRECT: Progress tracking
struct TransitionProgress {
    let targetRole: String
    let skillsAcquired: [String]
    let skillsRemaining: [String]
    let coursesCompleted: Int
    let applicationsSubmitted: Int
    let interviewsScheduled: Int

    var percentComplete: Double {
        let total = skillsAcquired.count + skillsRemaining.count
        return Double(skillsAcquired.count) / Double(total)
    }
}
```

---

### Act IV: "The Transformation" (Legacy & Impact)

**User State**: Successfully transitioned, becomes beacon for others

**App's Role**: Capture success stories, enable mentorship

**Features That Serve This**:
- Success story submission
- Mentorship opportunities (help others making same transition)
- Community contribution (proof points for next users)

**Code Implication**:
- Success stories must be prominent (social proof)
- Every transformation strengthens algorithm (data advantage)
- Community features enable network effects

---

## Decision Framework: Does This Feature Serve the Mission?

Before implementing ANY feature, ask these questions:

### Question 1: Which Act Does This Serve?

- **Act I** (Cage): Does it help users acknowledge unfulfillment safely?
- **Act II** (Revelation): Does it reveal unexpected possibilities?
- **Act III** (Climb): Does it guide action and transition?
- **Act IV** (Transformation): Does it capture success and enable mentorship?

**If it doesn't clearly serve one of these acts, question whether it belongs.**

---

### Question 2: Which Persona Needs This?

- **Stuck Professional**: Does it give confidence that change is possible?
- **Career Pivot**: Does it provide clear direction and validation?
- **Recent Graduate**: Does it enable guilt-free exploration?

**If it serves no persona, it's feature bloat.**

---

### Question 3: Does It Enable Cross-Domain Discovery?

- Does it help users see careers they'd never consider?
- Does it highlight transferable skills across industries?
- Does it challenge "I can only do what I've always done"?

**If it just shows similar jobs, we're no better than LinkedIn.**

---

### Question 4: Does It Build Confidence?

- Does it provide realistic timelines (not fantasy)?
- Does it show proof points (success stories)?
- Does it quantify skill gaps (not leave users guessing)?

**If it creates overwhelm or doubt, it's failing the mission.**

---

### Question 5: Is It Helpful, Not Exploitative?

- Does it genuinely help the user's transition?
- Would we be proud to show this to a stuck professional?
- Does it align with our "helpful advertising" model?

**If it prioritizes revenue over user value, it violates the mission.**

---

## The Sacred "No" List (What We Don't Build)

### ❌ Don't Build: Generic Job Board Features

**Why Not**: We're not competing with LinkedIn on job volume. We're competing on discovery and transition guidance.

**Examples to Avoid**:
- "See all 10,000 software engineering jobs"
- "Apply to 50 companies with one click"
- "Upload resume to 100 recruiters"

**What We Build Instead**:
- "Here are 5 cross-domain opportunities perfectly matched to your hidden skills"
- "This job matches your potential self (Manifest Profile), here's why"
- "You could transition to this role in 6 months by learning these 3 skills"

---

### ❌ Don't Build: Features That Create Overwhelm

**Why Not**: Our users are already overwhelmed. More options = paralysis.

**Examples to Avoid**:
- Showing 100 career possibilities at once
- "Here are 50 courses you could take"
- Infinite scroll of jobs with no guidance

**What We Build Instead**:
- 5-10 carefully curated career possibilities (revelation, not overwhelm)
- 3 recommended next steps (actionable, not endless)
- Prioritized job feed based on Amber→Teal journey stage

---

### ❌ Don't Build: Exploitative Monetization

**Why Not**: We profit by helping users succeed, not by exploiting urgency.

**Examples to Avoid**:
- "Pay to see which companies viewed your profile"
- "Premium tier required to apply"
- Ads that distract from career transformation

**What We Build Instead**:
- Free access to all core discovery features
- Helpful course recommendations aligned with transition plan
- Sponsorships from companies hiring career transitioners

---

## User-Facing Language Patterns

### Language That Serves the Mission

**Talk about potential, not limitations**:
- ✅ "You could excel at this role"
- ❌ "You're not qualified yet"

**Talk about transition, not starting over**:
- ✅ "6-month pathway to UX Designer"
- ❌ "Entry-level UX jobs"

**Talk about discovery, not job hunting**:
- ✅ "Explore unexpected career possibilities"
- ❌ "Search for jobs"

**Talk about confidence, not doubt**:
- ✅ "40,000 people with your background have successfully made this transition"
- ❌ "This might be hard"

**Talk about transformation, not switching**:
- ✅ "Discover who you could become"
- ❌ "Find a new job"

---

## Success Metrics Aligned with Mission

### Level 1: Engagement (Did We Hold Attention?)
- 60%+ weekly retention
- 15+ minutes per session
- 2+ months active

**What It Means**: Users find genuine value, not one-time curiosity

---

### Level 2: Discovery (Did We Reveal Something New?)
- 80%+ see at least 3 new career possibilities
- 60%+ discover at least 1 "wow, I never thought of that" option
- 40%+ rate suggestions as "realistic for me"

**What It Means**: Core value proposition is working

---

### Level 3: Action (Did Users Actually Move?)
- 30%+ start exploring transition pathway
- 15%+ enroll in skill-building resource
- 10%+ apply to cross-domain opportunity
- 5%+ land actual role in different field within 12 months

**What It Means**: Driving real career transformation

---

### Level 4: Satisfaction (Do Users Feel the Value?)
- 4.5+ star rating
- 70%+ say "app helped me see new possibilities"
- 65%+ say "I'm more optimistic about my career"
- 80%+ recommend to a friend

**What It Means**: Emotional satisfaction creates organic growth

---

## When This Skill Flags Issues

I will automatically warn you if:

1. **Feature doesn't serve a user persona** - Who needs this and why?
2. **Feature doesn't serve an Act** - Which stage of the journey does this support?
3. **Feature creates overwhelm** - Too many options, no guidance
4. **Feature is exploitative** - Prioritizes revenue over user value
5. **Language lacks confidence** - Focuses on limitations, not potential
6. **No cross-domain element** - Just showing similar jobs (LinkedIn clone)
7. **Missing transition guidance** - Shows opportunity without roadmap
8. **Violates Amber→Teal system** - Doesn't respect color symbolism

---

## The Narrative Checklist

Before merging any user-facing feature:

- [ ] Serves at least one of the three user personas
- [ ] Supports at least one of the four Acts (Cage, Revelation, Climb, Transformation)
- [ ] Enables cross-domain career discovery (not just similar jobs)
- [ ] Builds confidence through data, proof, or guidance
- [ ] Uses language that empowers (not limits)
- [ ] Respects Amber→Teal color symbolism
- [ ] Prioritizes user transformation over monetization
- [ ] Reduces overwhelm (curates, doesn't dump options)
- [ ] Provides realistic timelines and pathways
- [ ] Includes success stories or social proof

---

## The Ultimate Question

When in doubt about any code, feature, or design decision, ask:

**"Does this help a stuck professional discover an unexpected career and give them the confidence to pursue it?"**

If the answer is no, reconsider.

If the answer is yes, build it with pride.

---

**Based On:**
- `/v7earlyplanning/` - Complete user persona research, pain points, business model
- Comprehensive app narrative analysis (10,000+ words of planning documents)
- User feedback: "I'm trapped," "I don't know what else I could do," "Is it too late?"
- Mission: Career transformation through cross-domain discovery

---

# App Narrative Guide: Danifest & Destiny V7

## Remember

This app has the potential to change lives.

Every line of code is an opportunity to help someone discover their hidden potential, build confidence in their ability to change, and take the first steps toward a more fulfilling career.

That's not just software engineering. That's meaningful work.

Build accordingly.
