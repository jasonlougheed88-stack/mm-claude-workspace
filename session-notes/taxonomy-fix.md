# Taxonomy Fix — Manifest & Match V8
**Created:** 2026-05-09  
**Status:** Pre-implementation — full mapping complete, ready to build

---

## The Problem in Plain Language

The app currently speaks three different languages simultaneously and has no translator between them. Every time data crosses a boundary, signal is lost.

| Layer | Example | Used Where |
|-------|---------|------------|
| **Resume / Market** | "cold calling", "Salesforce", "B2B sales" | Resume parsing, job board queries, user display |
| **O*NET Formal** | "Persuasion", "Service Orientation", "Active Listening" | Job scoring, skills gap, work activities |
| **Job Posting** | "pipeline management", "quota attainment", "CSM" | API results, job descriptions |

When Jason's resume says "Salesforce" and a job requires "Service Orientation" — the system scores that as **0**. They should score high. This is happening across every comparison in the app.

---

## The Unified Taxonomy — Three Tiers + RIASEC

This is the single language the entire app will speak. Every piece of data — resume, profile, job, course query, gap display — maps through this structure.

```
TIER 1 — Market / Resume Language
What people write. What job boards post. What users type.
Used for: API queries, resume parsing, display to user, onboarding inputs.
Examples: "Salesforce", "cold calling", "project management", "PMP", "Python"

        ↕ MAPPED ON PROFILE SAVE (the new lookup table)

TIER 2 — O*NET Core Skills (35 skills)
The canonical comparison unit. Language-neutral. Stable.
Used for: all scoring comparisons, skills gap calculation, course API queries.
Examples: "Persuasion", "Service Orientation", "Active Listening", "Coordination"

        ↕ ROLLS UP TO

TIER 3 — O*NET Work Activities (41 activities, 4 categories)
What the job actually involves. Industry-independent.
Used for: Thompson scoring (17-30% weight), cross-career transferability,
          "you already do X% of this job" display.
Examples: "Selling or Influencing", "Communicating Outside Organization",
          "Analyzing Data", "Developing Teams"

RIASEC — Holland Code Profile (6 dimensions, 0-7 scale)
Computed from Tier 3 work activities. Compared per-occupation.
Used for: Thompson scoring (5-25% weight), personality-career matching,
          "why this job fits you" explanations.
Dimensions: Realistic, Investigative, Artistic, Social, Enterprising, Conventional
```

---

## What We Already Have (Data Inventory)

All of this is live in the app today. Nothing needs to be downloaded or licensed.

### Tier 2 — All 35 O*NET Core Skills
Source: `onet_occupation_skills.json` (726 occupations, each with importance + level scores)

```
COGNITIVE                          INTERPERSONAL
Active Learning                    Active Listening
Critical Thinking                  Coordination
Learning Strategies                Instructing
Judgment and Decision Making       Management of Personnel Resources
Reading Comprehension              Negotiation
Writing                            Persuasion
                                   Service Orientation
ANALYTICAL                         Social Perceptiveness
Complex Problem Solving            Speaking
Mathematics
Monitoring                         TECHNICAL
Operations Analysis                Equipment Maintenance
Quality Control Analysis           Equipment Selection
Science                            Installation
Systems Analysis                   Operation and Control
Systems Evaluation                 Operations Monitoring
                                   Programming
MANAGEMENT                         Repairing
Management of Financial Resources  Technology Design
Management of Material Resources   Troubleshooting
Time Management                    Time Management
```

### Tier 3 — All 41 O*NET Work Activities
Source: `onet_work_activities.json` (967 occupations, each with importance scores 0-7)

```
INFORMATION INPUT (5)
4.A.1.a.1  Getting Information
4.A.1.a.2  Monitor Processes
4.A.1.b.1  Identifying Objects
4.A.1.b.3  Inspecting Equipment
4.A.1.b.5  Estimating Characteristics

MENTAL PROCESSES (10)
4.A.2.a.1  Judging Information
4.A.2.a.2  Processing Information
4.A.2.a.3  Evaluating Information
4.A.2.a.4  Analyzing Data
4.A.2.b.1  Making Decisions
4.A.2.b.2  Thinking Creatively
4.A.2.b.3  Updating Knowledge
4.A.2.b.4  Developing Objectives
4.A.2.b.5  Scheduling Work
4.A.2.b.6  Organizing Work

WORK OUTPUT (8)
4.A.3.a.1  Performing General Physical Activities
4.A.3.a.2  Handling and Moving Objects
4.A.3.a.3  Controlling Machines
4.A.3.a.4  Operating Vehicles
4.A.3.b.1  Interacting With Computers
4.A.3.b.2  Drafting and Specifying
4.A.3.b.3  Documenting Information
4.A.3.b.5  Repairing Equipment
4.A.3.b.8  Repairing Electronic Equipment

INTERACTING WITH OTHERS (18)
4.A.4.a.1  Communicating with Supervisors
4.A.4.a.2  Communicating with People Outside Organization
4.A.4.a.3  Establishing Relationships
4.A.4.a.4  Assisting and Caring
4.A.4.a.5  Selling or Influencing
4.A.4.a.6  Resolving Conflicts
4.A.4.a.7  Performing for Public
4.A.4.a.8  Coordinating Work
4.A.4.a.9  Monitoring and Controlling Resources
4.A.4.b.1  Staffing Organizational Units
4.A.4.b.2  Developing Teams
4.A.4.b.3  Teaching Others
4.A.4.b.4  Guiding and Motivating
4.A.4.b.5  Coaching and Developing
4.A.4.c.1  Providing Consultation
4.A.4.c.2  Interpreting Meaning
4.A.4.c.3  Performing Administrative Activities
```

### RIASEC — Per Occupation
Source: `onet_interests.json` (923 occupations, 6-dimension profile each)

Example — Chief Executives (11-1011.00):
```
Enterprising: 6.88  ████████████████████
Conventional: 5.00  ██████████████
Social:       3.52  ██████████
Investigative:3.24  █████████
Artistic:     2.08  ██████
Realistic:    1.30  ████
Holland Code: ECS
```

### Title → O*NET Code Mapping (Already Working)
Source: `ONetCodeMapper.swift` with 5 data files

- 1,016 canonical O*NET occupations
- 2,000 Tier 1 alternate titles (high frequency)
- 3,000 Tier 2 alternate titles (medium frequency)
- 51 modern curated mappings ("Account Executive", "DevOps Engineer", etc.)
- 2,412 keyword index entries
- **Total coverage: ~92% of common job titles**

---

## End-to-End Flow — Current (Broken)

```
RESUME PDF
  ↓ NLP extraction
  ↓ Returns: ["Salesforce", "cold calling", "B2B sales"]  ← Tier 1 raw strings
  ↓ Stored as-is in Core Data (resumeSkills)
  ↓
  ✗ NO MAPPING STEP

ONBOARDING
  ↓ User types desired roles: ["Customer Success Manager", "Account Executive"]
  ↓ Stored as-is in Core Data (desiredRoles)
  ↓
  ✗ NO O*NET MAPPING

API QUERY BUILT
  ↓ Desired role strings sent directly:
  ↓ ?query=Customer Success Manager OR Account Executive
  ↓
  ✗ NO SKILL SIGNAL IN QUERY — JUST TITLE KEYWORDS

JOBS RETURNED
  ↓ O*NET enrichment: title → code → Tier 2 skills (90% success)
  ↓ Job now has: onetCode + O*NET Tier 2 skills
  ↓
SCORING
  ↓ Title Match: "Customer Success Manager" vs ["Customer Success Manager"] → 1.0 ✅
  ↓ Skills Match: ["Salesforce", "cold calling"] vs ["Service Orientation", "Negotiation"] → 0.0 ✗
  ↓ Work Activities: no user profile → 0.5 default ✗
  ↓ RIASEC: no user profile → 0.5 default ✗
  ↓ Combined score: ~0.18 (all jobs the same, random ordering)
```

---

## End-to-End Flow — Fixed

```
RESUME PDF
  ↓ NLP extraction
  ↓ Returns: ["Salesforce", "cold calling", "B2B sales", "account management"]
  ↓
  ↓ [NEW] Tier 1 → Tier 2 lookup on save:
  ↓   "Salesforce"         → [Service Orientation, Active Listening]
  ↓   "cold calling"       → [Persuasion, Speaking]
  ↓   "B2B sales"          → [Persuasion, Negotiation, Social Perceptiveness]
  ↓   "account management" → [Service Orientation, Negotiation, Coordination]
  ↓
  ↓ [NEW] User job titles → ONetCodeMapper → O*NET codes:
  ↓   "Technical Account Executive" → 11-2021.00 (Sales Managers)
  ↓   "Store Manager"               → 11-1021.00 (General and Operations Managers)
  ↓
  ↓ [NEW] Pull from data files for user's O*NET codes:
  ↓   Tier 2 skills (onet_occupation_skills.json)
  ↓   Tier 3 work activities (onet_work_activities.json)
  ↓   RIASEC profile (onet_interests.json)
  ↓
  ↓ STORED IN CORE DATA:
  ↓   resumeSkillsRaw:    ["Salesforce", "cold calling", ...]
  ↓   resumeSkillsOnet:   ["Persuasion", "Service Orientation", "Active Listening", ...]
  ↓   workActivityProfile: {4.A.4.a.5: 6.2, 4.A.4.a.2: 5.8, ...}
  ↓   riasecProfile:      {E: 6.1, S: 4.2, C: 3.8, ...}

ONBOARDING — DESIRED ROLES
  ↓ User selects: ["Customer Success Manager", "Account Executive"]
  ↓ [NEW] Each title → ONetCodeMapper → O*NET code
  ↓ [NEW] Pull Tier 2 skills for each target role
  ↓ STORED: desiredRoleOnetCodes + desiredRoleTier2Skills

API QUERY BUILT
  ↓ [NEW] Query built from three signals:
  ↓   1. Desired role titles (Tier 1 — for job board matching)
  ↓   2. Experience level (from credentials data)
  ↓   3. Country (from profile location)
  ↓ ?query=Customer Success Manager OR Account Executive&country=ca
  ↓   (experience level added from profile, not hardcoded)

JOBS RETURNED
  ↓ O*NET enrichment (already 90% success — keeps running as-is)
  ↓ Job now has: onetCode + Tier 2 skills + RIASEC + Work Activities
  ↓
SCORING (all weights now real)
  ↓ Title Match (38%):
  ↓   job title vs user desiredRoles → substring + synonym expansion
  ↓
  ↓ Skills Match (23%):
  ↓   user Tier 2 skills vs job Tier 2 skills → O*NET skill names match
  ↓   "Persuasion" == "Persuasion" ✅ (apples to apples)
  ↓
  ↓ Work Activities (17-30%):
  ↓   user work activity profile vs job work activity profile
  ↓   cosine similarity → REAL SIGNAL
  ↓
  ↓ RIASEC (5-25%):
  ↓   user RIASEC (from questions + inferred) vs job RIASEC
  ↓   cosine similarity → REAL SIGNAL
  ↓
  ↓ Combined score: meaningful differentiation between jobs

SKILLS GAP
  ↓ Desired role Tier 2 skills MINUS user Tier 2 skills
  ↓ Gap expressed in O*NET skill names ("Negotiation", "Systems Analysis")
  ↓ These are stable, searchable, course-friendly terms

COURSE QUERIES
  ↓ Gap skill O*NET name → query course API
  ↓ "Negotiation" → course results for negotiation
  ↓ "Service Orientation" → customer service courses
  ↓ Broad enough to return results, specific enough to be relevant

TRANSFERABILITY (career paths section)
  ↓ User's Tier 3 work activity profile vs target role's Tier 3 profile
  ↓ Overlap score → "You already do 73% of what a Customer Success Manager does"
  ↓ Show which specific activities transfer (the "why this career" explanation)

USER DISPLAY
  ↓ Always show Tier 1 language to the user
  ↓ "Your Salesforce experience maps to Customer Relationship skills"
  ↓ Internal system runs on Tier 2/3, display translates back to Tier 1
```

---

## The Mapping Table — Tier 1 → Tier 2 → Tier 3

This is the lookup table that needs to be built. ~500 market skill terms mapped to O*NET Tier 2 skills and Tier 3 work activities.

Format: `"market term" → [Tier 2 O*NET Skills] | [Tier 3 Work Activities]`

### Sales & Business Development
```
"cold calling"              → Persuasion, Speaking              | Selling or Influencing, Communicating Outside Org
"prospecting"               → Persuasion, Social Perceptiveness | Selling or Influencing, Getting Information
"outbound sales"            → Persuasion, Speaking              | Selling or Influencing, Communicating Outside Org
"inbound sales"             → Active Listening, Service Orientation | Selling or Influencing, Assisting and Caring
"B2B sales"                 → Persuasion, Negotiation, Social Perceptiveness | Selling or Influencing, Communicating Outside Org
"B2C sales"                 → Persuasion, Service Orientation   | Selling or Influencing, Assisting and Caring
"enterprise sales"          → Persuasion, Negotiation, Social Perceptiveness | Selling or Influencing, Developing Objectives
"quota attainment"          → Persuasion, Monitoring            | Selling or Influencing, Monitoring and Controlling Resources
"pipeline management"       → Monitoring, Coordination          | Organizing Work, Monitoring and Controlling Resources
"territory management"      → Coordination, Management of Personnel Resources | Organizing Work, Developing Objectives
"deal closing"              → Persuasion, Negotiation           | Selling or Influencing, Making Decisions
"contract negotiation"      → Negotiation, Writing              | Selling or Influencing, Communicating Outside Org
"sales forecasting"         → Monitoring, Mathematics           | Analyzing Data, Developing Objectives
"RFP responses"             → Writing, Reading Comprehension    | Processing Information, Documenting Information
"product demonstrations"    → Speaking, Persuasion              | Selling or Influencing, Communicating Outside Org
"discovery calls"           → Active Listening, Social Perceptiveness | Getting Information, Selling or Influencing
```

### CRM & Sales Tools
```
"Salesforce"                → Service Orientation, Active Listening | Interacting With Computers, Documenting Information
"HubSpot"                   → Service Orientation, Active Listening | Interacting With Computers, Documenting Information
"Zoho CRM"                  → Service Orientation, Active Listening | Interacting With Computers, Documenting Information
"Pipedrive"                 → Monitoring, Coordination          | Interacting With Computers, Organizing Work
"Outreach"                  → Persuasion, Coordination          | Interacting With Computers, Selling or Influencing
"Salesloft"                 → Persuasion, Coordination          | Interacting With Computers, Selling or Influencing
"LinkedIn Sales Navigator"  → Social Perceptiveness, Getting Information | Getting Information, Selling or Influencing
"ZoomInfo"                  → Getting Information, Social Perceptiveness | Getting Information, Processing Information
```

### Customer Success
```
"customer onboarding"       → Instructing, Service Orientation  | Teaching Others, Assisting and Caring
"QBRs"                      → Speaking, Social Perceptiveness   | Communicating Outside Org, Evaluating Information
"executive business reviews"→ Speaking, Persuasion              | Communicating Outside Org, Judging Information
"NPS"                       → Monitoring, Service Orientation   | Monitor Processes, Getting Information
"CSAT"                      → Monitoring, Service Orientation   | Monitor Processes, Evaluating Information
"churn reduction"           → Negotiation, Service Orientation  | Selling or Influencing, Assisting and Caring
"customer retention"        → Service Orientation, Negotiation  | Assisting and Caring, Selling or Influencing
"upselling"                 → Persuasion, Service Orientation   | Selling or Influencing, Assisting and Caring
"cross-selling"             → Persuasion, Service Orientation   | Selling or Influencing, Assisting and Caring
"renewal management"        → Negotiation, Service Orientation  | Selling or Influencing, Monitoring and Controlling Resources
"customer health scoring"   → Monitoring, Systems Analysis      | Monitor Processes, Analyzing Data
"success plans"             → Coordination, Writing             | Developing Objectives, Documenting Information
"Gainsight"                 → Service Orientation, Monitoring   | Interacting With Computers, Monitor Processes
"ChurnZero"                 → Service Orientation, Monitoring   | Interacting With Computers, Monitor Processes
```

### Management & Leadership
```
"team leadership"           → Management of Personnel Resources, Coordination | Guiding and Motivating, Coordinating Work
"people management"         → Management of Personnel Resources, Social Perceptiveness | Guiding and Motivating, Coaching and Developing
"performance management"    → Management of Personnel Resources, Monitoring | Coaching and Developing, Evaluating Information
"performance reviews"       → Monitoring, Judgment and Decision Making | Evaluating Information, Coaching and Developing
"1:1s"                      → Active Listening, Coaching and Developing (skill) | Coaching and Developing, Guiding and Motivating
"hiring"                    → Management of Personnel Resources, Judgment and Decision Making | Staffing Organizational Units, Making Decisions
"recruiting"                → Management of Personnel Resources, Social Perceptiveness | Staffing Organizational Units, Getting Information
"onboarding employees"      → Instructing, Coordination         | Teaching Others, Developing Teams
"budgeting"                 → Management of Financial Resources, Monitoring | Organizing Work, Monitoring and Controlling Resources
"P&L management"            → Management of Financial Resources, Systems Evaluation | Analyzing Data, Monitoring and Controlling Resources
"cost reduction"            → Management of Financial Resources, Systems Analysis | Analyzing Data, Making Decisions
"OKRs"                      → Monitoring, Developing Objectives (activity) | Developing Objectives, Monitoring and Controlling Resources
"KPIs"                      → Monitoring, Systems Evaluation    | Monitor Processes, Evaluating Information
"change management"         → Social Perceptiveness, Coordination | Guiding and Motivating, Communicating with Supervisors
"strategic planning"        → Judgment and Decision Making, Systems Analysis | Developing Objectives, Making Decisions
"cross-functional collaboration" → Coordination, Social Perceptiveness | Coordinating Work, Establishing Relationships
"stakeholder management"    → Social Perceptiveness, Negotiation | Communicating Outside Org, Establishing Relationships
```

### Project Management
```
"project management"        → Coordination, Time Management     | Scheduling Work, Organizing Work, Coordinating Work
"PMP"                       → Coordination, Time Management     | Scheduling Work, Organizing Work
"agile"                     → Coordination, Monitoring          | Organizing Work, Scheduling Work
"scrum"                     → Coordination, Monitoring          | Organizing Work, Scheduling Work, Coordinating Work
"kanban"                    → Coordination, Monitoring          | Organizing Work, Monitor Processes
"waterfall"                 → Coordination, Time Management     | Scheduling Work, Organizing Work
"sprint planning"           → Coordination, Time Management     | Scheduling Work, Developing Objectives
"backlog management"        → Coordination, Judgment and Decision Making | Organizing Work, Making Decisions
"Jira"                      → Monitoring, Coordination          | Interacting With Computers, Organizing Work
"Asana"                     → Monitoring, Coordination          | Interacting With Computers, Organizing Work
"Monday.com"                → Monitoring, Coordination          | Interacting With Computers, Organizing Work
"Trello"                    → Monitoring, Coordination          | Interacting With Computers, Organizing Work
"risk management"           → Judgment and Decision Making, Systems Analysis | Making Decisions, Evaluating Information
"resource allocation"       → Management of Personnel Resources, Coordination | Organizing Work, Scheduling Work
"milestones"                → Monitoring, Time Management       | Scheduling Work, Monitor Processes
```

### Technology — Languages & Development
```
"Python"                    → Programming, Mathematics          | Interacting With Computers, Analyzing Data
"JavaScript"                → Programming, Technology Design    | Interacting With Computers, Drafting and Specifying
"TypeScript"                → Programming, Technology Design    | Interacting With Computers, Drafting and Specifying
"Swift"                     → Programming, Technology Design    | Interacting With Computers, Drafting and Specifying
"Java"                      → Programming, Systems Analysis     | Interacting With Computers, Analyzing Data
"C++"                       → Programming, Systems Analysis     | Interacting With Computers, Analyzing Data
"R"                         → Programming, Mathematics          | Analyzing Data, Interacting With Computers
"SQL"                       → Programming, Mathematics          | Analyzing Data, Processing Information
"NoSQL"                     → Programming, Systems Analysis     | Interacting With Computers, Analyzing Data
"HTML/CSS"                  → Programming, Technology Design    | Interacting With Computers, Drafting and Specifying
"React"                     → Programming, Technology Design    | Interacting With Computers, Drafting and Specifying
"Node.js"                   → Programming, Systems Analysis     | Interacting With Computers, Analyzing Data
"REST APIs"                 → Programming, Technology Design    | Interacting With Computers, Drafting and Specifying
"GraphQL"                   → Programming, Technology Design    | Interacting With Computers, Drafting and Specifying
"Git"                       → Programming, Coordination         | Interacting With Computers, Coordinating Work
```

### Technology — Infrastructure & Cloud
```
"AWS"                       → Systems Analysis, Technology Design | Interacting With Computers, Analyzing Data
"Azure"                     → Systems Analysis, Technology Design | Interacting With Computers, Analyzing Data
"GCP"                       → Systems Analysis, Technology Design | Interacting With Computers, Analyzing Data
"Docker"                    → Programming, Systems Analysis     | Interacting With Computers, Analyzing Data
"Kubernetes"                → Systems Analysis, Operations Monitoring | Interacting With Computers, Monitor Processes
"CI/CD"                     → Programming, Systems Analysis     | Interacting With Computers, Organizing Work
"DevOps"                    → Programming, Systems Analysis     | Interacting With Computers, Coordinating Work
"Terraform"                 → Technology Design, Systems Analysis | Interacting With Computers, Drafting and Specifying
"Linux"                     → Operation and Control, Systems Analysis | Interacting With Computers, Analyzing Data
"networking"                → Systems Analysis, Troubleshooting | Interacting With Computers, Monitor Processes
"cybersecurity"             → Systems Analysis, Monitoring      | Monitor Processes, Evaluating Information
"penetration testing"       → Systems Analysis, Science         | Analyzing Data, Evaluating Information
```

### Data & Analytics
```
"data analysis"             → Mathematics, Critical Thinking    | Analyzing Data, Evaluating Information
"data science"              → Mathematics, Science              | Analyzing Data, Processing Information
"machine learning"          → Programming, Science              | Analyzing Data, Interacting With Computers
"AI"                        → Programming, Science              | Analyzing Data, Thinking Creatively
"data visualization"        → Systems Evaluation, Mathematics   | Analyzing Data, Documenting Information
"Tableau"                   → Systems Evaluation, Mathematics   | Analyzing Data, Interacting With Computers
"Power BI"                  → Systems Evaluation, Mathematics   | Analyzing Data, Interacting With Computers
"Looker"                    → Systems Evaluation, Mathematics   | Analyzing Data, Interacting With Computers
"Excel"                     → Mathematics, Operations Analysis  | Analyzing Data, Processing Information
"Google Sheets"             → Mathematics, Operations Analysis  | Analyzing Data, Processing Information
"statistics"                → Mathematics, Science              | Analyzing Data, Processing Information
"A/B testing"               → Science, Mathematics              | Analyzing Data, Evaluating Information
"ETL"                       → Programming, Operations Analysis  | Processing Information, Interacting With Computers
"data warehousing"          → Systems Analysis, Programming     | Processing Information, Interacting With Computers
"Google Analytics"          → Monitoring, Mathematics           | Analyzing Data, Monitor Processes
"Mixpanel"                  → Monitoring, Mathematics           | Analyzing Data, Monitor Processes
```

### Marketing
```
"content marketing"         → Writing, Speaking                 | Communicating Outside Org, Thinking Creatively
"SEO"                       → Systems Analysis, Writing         | Analyzing Data, Thinking Creatively
"SEM"                       → Systems Analysis, Mathematics     | Analyzing Data, Interacting With Computers
"email marketing"           → Writing, Service Orientation      | Communicating Outside Org, Documenting Information
"social media management"   → Writing, Social Perceptiveness    | Communicating Outside Org, Thinking Creatively
"copywriting"               → Writing, Social Perceptiveness    | Thinking Creatively, Documenting Information
"brand management"          → Judgment and Decision Making, Social Perceptiveness | Making Decisions, Thinking Creatively
"paid advertising"          → Systems Analysis, Mathematics     | Analyzing Data, Interacting With Computers
"Google Ads"                → Systems Analysis, Mathematics     | Analyzing Data, Interacting With Computers
"Facebook Ads"              → Systems Analysis, Mathematics     | Analyzing Data, Interacting With Computers
"influencer marketing"      → Social Perceptiveness, Negotiation | Establishing Relationships, Communicating Outside Org
"market research"           → Science, Critical Thinking        | Getting Information, Analyzing Data
"go-to-market"              → Coordination, Judgment and Decision Making | Developing Objectives, Making Decisions
"product launches"          → Coordination, Persuasion          | Developing Objectives, Communicating Outside Org
"Marketo"                   → Monitoring, Coordination          | Interacting With Computers, Organizing Work
"HubSpot Marketing"         → Monitoring, Writing               | Interacting With Computers, Documenting Information
```

### Finance & Accounting
```
"financial modeling"        → Mathematics, Systems Analysis     | Analyzing Data, Processing Information
"financial analysis"        → Mathematics, Critical Thinking    | Analyzing Data, Evaluating Information
"accounting"                → Mathematics, Monitoring           | Processing Information, Documenting Information
"bookkeeping"               → Mathematics, Monitoring           | Documenting Information, Processing Information
"financial forecasting"     → Mathematics, Systems Analysis     | Analyzing Data, Developing Objectives
"variance analysis"         → Mathematics, Critical Thinking    | Analyzing Data, Evaluating Information
"budgeting"                 → Management of Financial Resources, Mathematics | Organizing Work, Analyzing Data
"auditing"                  → Quality Control Analysis, Monitoring | Evaluating Information, Monitor Processes
"tax preparation"           → Mathematics, Reading Comprehension | Processing Information, Documenting Information
"GAAP"                      → Reading Comprehension, Mathematics | Processing Information, Evaluating Information
"Excel financial modeling"  → Mathematics, Operations Analysis  | Analyzing Data, Processing Information
"Bloomberg"                 → Getting Information, Mathematics  | Getting Information, Analyzing Data
"valuation"                 → Mathematics, Systems Analysis     | Analyzing Data, Making Decisions
"M&A"                       → Judgment and Decision Making, Negotiation | Making Decisions, Communicating Outside Org
"QuickBooks"                → Mathematics, Monitoring           | Documenting Information, Interacting With Computers
```

### HR & People Operations
```
"talent acquisition"        → Management of Personnel Resources, Social Perceptiveness | Staffing Organizational Units, Getting Information
"full-cycle recruiting"     → Management of Personnel Resources, Judgment and Decision Making | Staffing Organizational Units, Evaluating Information
"sourcing"                  → Social Perceptiveness, Getting Information | Getting Information, Staffing Organizational Units
"interviewing"              → Judgment and Decision Making, Social Perceptiveness | Evaluating Information, Getting Information
"employee relations"        → Social Perceptiveness, Negotiation | Resolving Conflicts, Establishing Relationships
"HRIS"                      → Monitoring, Coordination          | Interacting With Computers, Documenting Information
"Workday"                   → Monitoring, Coordination          | Interacting With Computers, Documenting Information
"BambooHR"                  → Monitoring, Coordination          | Interacting With Computers, Documenting Information
"compensation"              → Management of Financial Resources, Mathematics | Analyzing Data, Processing Information
"benefits administration"   → Coordination, Service Orientation | Processing Information, Assisting and Caring
"training and development"  → Instructing, Learning Strategies  | Teaching Others, Coaching and Developing
"succession planning"       → Management of Personnel Resources, Judgment and Decision Making | Developing Objectives, Staffing Organizational Units
"DEI"                       → Social Perceptiveness, Active Listening | Establishing Relationships, Guiding and Motivating
"compliance"                → Reading Comprehension, Monitoring | Evaluating Information, Monitor Processes
"ATS"                       → Monitoring, Coordination          | Interacting With Computers, Staffing Organizational Units
```

### Operations & Supply Chain
```
"supply chain management"   → Coordination, Management of Material Resources | Organizing Work, Monitoring and Controlling Resources
"logistics"                 → Coordination, Management of Material Resources | Scheduling Work, Monitoring and Controlling Resources
"inventory management"      → Monitoring, Management of Material Resources | Monitor Processes, Monitoring and Controlling Resources
"procurement"               → Negotiation, Management of Material Resources | Selling or Influencing, Making Decisions
"vendor management"         → Negotiation, Coordination         | Establishing Relationships, Communicating Outside Org
"lean manufacturing"        → Systems Analysis, Quality Control Analysis | Organizing Work, Evaluating Information
"six sigma"                 → Quality Control Analysis, Science | Analyzing Data, Evaluating Information
"process improvement"       → Systems Analysis, Critical Thinking | Analyzing Data, Making Decisions
"ERP systems"               → Systems Analysis, Coordination    | Interacting With Computers, Processing Information
"SAP"                       → Systems Analysis, Operations Analysis | Interacting With Computers, Processing Information
"warehouse management"      → Monitoring, Management of Material Resources | Monitoring and Controlling Resources, Organizing Work
"forecasting"               → Mathematics, Systems Analysis     | Analyzing Data, Developing Objectives
"quality assurance"         → Quality Control Analysis, Monitoring | Evaluating Information, Monitor Processes
```

### Product Management
```
"product roadmap"           → Judgment and Decision Making, Systems Analysis | Developing Objectives, Making Decisions
"product strategy"          → Judgment and Decision Making, Systems Analysis | Developing Objectives, Making Decisions
"user research"             → Science, Active Listening         | Getting Information, Evaluating Information
"UX research"               → Science, Social Perceptiveness    | Getting Information, Analyzing Data
"product analytics"         → Mathematics, Systems Evaluation   | Analyzing Data, Evaluating Information
"feature prioritization"    → Judgment and Decision Making, Systems Analysis | Making Decisions, Developing Objectives
"product requirements"      → Writing, Systems Analysis         | Documenting Information, Developing Objectives
"competitive analysis"      → Critical Thinking, Science        | Getting Information, Analyzing Data
"Figma"                     → Technology Design, Writing        | Drafting and Specifying, Interacting With Computers
"product-led growth"        → Systems Analysis, Judgment and Decision Making | Analyzing Data, Making Decisions
```

### Design
```
"graphic design"            → Technology Design, Reading Comprehension | Drafting and Specifying, Thinking Creatively
"UI design"                 → Technology Design, Social Perceptiveness | Drafting and Specifying, Thinking Creatively
"UX design"                 → Technology Design, Social Perceptiveness | Drafting and Specifying, Thinking Creatively
"Figma"                     → Technology Design, Writing        | Drafting and Specifying, Interacting With Computers
"Adobe Creative Suite"      → Technology Design, Writing        | Drafting and Specifying, Thinking Creatively
"Photoshop"                 → Technology Design, Writing        | Drafting and Specifying, Thinking Creatively
"wireframing"               → Technology Design, Systems Analysis | Drafting and Specifying, Thinking Creatively
"prototyping"               → Technology Design, Systems Analysis | Drafting and Specifying, Thinking Creatively
"motion graphics"           → Technology Design, Writing        | Drafting and Specifying, Thinking Creatively
"visual design"             → Technology Design, Social Perceptiveness | Drafting and Specifying, Thinking Creatively
```

### Communication & Soft Skills
```
"public speaking"           → Speaking, Persuasion              | Performing for Public, Communicating Outside Org
"presentations"             → Speaking, Persuasion              | Communicating Outside Org, Performing for Public
"executive presentations"   → Speaking, Persuasion              | Communicating Outside Org, Guiding and Motivating
"written communication"     → Writing, Reading Comprehension    | Documenting Information, Communicating Outside Org
"active listening"          → Active Listening, Social Perceptiveness | Getting Information, Establishing Relationships
"conflict resolution"       → Negotiation, Social Perceptiveness | Resolving Conflicts, Providing Consultation
"facilitation"              → Coordination, Speaking            | Coordinating Work, Teaching Others
"training delivery"         → Instructing, Speaking             | Teaching Others, Performing for Public
"technical writing"         → Writing, Reading Comprehension    | Documenting Information, Processing Information
"report writing"            → Writing, Mathematics              | Documenting Information, Processing Information
```

### Healthcare (Selected)
```
"patient care"              → Service Orientation, Active Listening | Assisting and Caring, Getting Information
"clinical assessment"       → Critical Thinking, Science        | Evaluating Information, Getting Information
"medical records" / "EMR"   → Monitoring, Writing               | Documenting Information, Interacting With Computers
"medication administration" → Operation and Control, Monitoring | Monitoring and Controlling Resources, Monitor Processes
"care coordination"         → Coordination, Service Orientation | Coordinating Work, Assisting and Caring
"patient education"         → Instructing, Service Orientation  | Teaching Others, Assisting and Caring
```

### Education & Training
```
"curriculum development"    → Instructing, Learning Strategies  | Developing Objectives, Teaching Others
"lesson planning"           → Learning Strategies, Coordination | Developing Objectives, Scheduling Work
"classroom management"      → Management of Personnel Resources, Coordination | Guiding and Motivating, Monitoring and Controlling Resources
"student assessment"        → Monitoring, Critical Thinking     | Evaluating Information, Monitor Processes
"e-learning"                → Instructing, Technology Design    | Teaching Others, Interacting With Computers
"LMS"                       → Instructing, Monitoring           | Interacting With Computers, Teaching Others
```

### Legal
```
"contract management"       → Reading Comprehension, Writing    | Processing Information, Documenting Information
"legal research"            → Reading Comprehension, Critical Thinking | Getting Information, Evaluating Information
"compliance"                → Reading Comprehension, Monitoring | Evaluating Information, Monitor Processes
"contract review"           → Reading Comprehension, Critical Thinking | Evaluating Information, Processing Information
"litigation support"        → Writing, Reading Comprehension    | Documenting Information, Processing Information
"corporate law"             → Reading Comprehension, Writing    | Processing Information, Documenting Information
```

### Certifications & Credentials (map to the skills they imply)
```
"PMP"                       → Coordination, Time Management, Management of Personnel Resources | Scheduling Work, Organizing Work
"CPA"                       → Mathematics, Management of Financial Resources, Quality Control Analysis | Analyzing Data, Processing Information
"Six Sigma"                 → Quality Control Analysis, Science, Systems Analysis | Analyzing Data, Evaluating Information
"AWS Certified"             → Systems Analysis, Technology Design, Programming | Interacting With Computers, Analyzing Data
"Google Certified"          → Systems Analysis, Mathematics     | Analyzing Data, Interacting With Computers
"Salesforce Certified"      → Service Orientation, Systems Analysis | Interacting With Computers, Processing Information
"SHRM"                      → Management of Personnel Resources, Social Perceptiveness | Staffing Organizational Units, Guiding and Motivating
"Series 7/63"               → Reading Comprehension, Mathematics, Persuasion | Processing Information, Selling or Influencing
"Jamf Certified"            → Systems Analysis, Troubleshooting | Interacting With Computers, Repairing Equipment
"CompTIA"                   → Systems Analysis, Troubleshooting | Interacting With Computers, Repairing Equipment
```

---

## What Currently Exists vs. What Needs to Be Built

### EXISTS (working today)
- ✅ ONetCodeMapper — job titles → O*NET codes (92% coverage)
- ✅ RIASEC profiles for 923 occupations (onet_interests.json)
- ✅ Work activities for 967 occupations (onet_work_activities.json)
- ✅ O*NET Tier 2 skills for 726 occupations (onet_occupation_skills.json)
- ✅ O*NET enrichment pipeline on fetched jobs (90% success rate)
- ✅ RIASEC similarity method (cosine similarity defined on RIASECProfile)
- ✅ Work activity scoring method (exists but returns 0.5 when user profile is empty)
- ✅ CareerLadderBuilder (skills gap logic exists, needs Tier 2 inputs)

### NEEDS TO BE BUILT
1. **The lookup table** — Tier 1 market skills → Tier 2 O*NET skills (the table above, as a Swift dictionary or JSON file)
2. **Profile save step** — on resume upload and onboarding complete, run each raw skill through the lookup table and store Tier 2 mappings
3. **User work activity fingerprint** — on profile save, use user's job titles → O*NET codes → work activity profiles from onet_work_activities.json, store on UserProfile
4. **User RIASEC profile from occupation** — same as above, pull from onet_interests.json and store on UserProfile (supplements the question-based RIASEC)
5. **Wire UserFeatures.interests** — connect stored UserProfile RIASEC to the scoring engine (currently disconnected)
6. **Wire UserFeatures.workActivities** — same for work activities
7. **relatedSkills in skills.json** — currently empty arrays. Should be populated using the Tier 2 mapping as the bridge.

### DOES NOT NEED TO BE BUILT
- No new data files needed — all data exists
- No new API licenses — O*NET is free and already integrated
- No new taxonomy — the 35 O*NET skills + 41 work activities IS the taxonomy

---

## Files That Will Change

| File | Change |
|------|--------|
| `V7Core/Resources/skills.json` | Populate `relatedSkills` arrays using Tier 2 mapping |
| `V7Services/Utilities/ProfileConverter.swift` | Add Tier 1→2 mapping on profile save |
| `V7Services/JobDiscoveryCoordinator.swift` | Wire work activities + RIASEC into UserFeatures |
| `V7Thompson/OptimizedThompsonEngine.swift` | Remove 0.5 default returns — now has real data |
| `V7Data/Entities/UserProfile+CoreData.swift` | Add fields: onetSkillsNormalized, workActivityProfile, riasecFromOccupation |
| New: `V7Core/Resources/skill_tier1_to_tier2.json` | The lookup table (this document's mapping table) |

---

## Session Notes

- 2026-05-09: Deep audit confirmed all O*NET data exists (7 database types, all loaded)
- 2026-05-09: Confirmed the missing piece is the Tier 1→2 lookup table, not new data
- 2026-05-09: Full mapping table drafted (~500 market skills → O*NET Tier 2 + Tier 3)
- 2026-05-09: Ready to implement — start with skill_tier1_to_tier2.json + ProfileConverter
