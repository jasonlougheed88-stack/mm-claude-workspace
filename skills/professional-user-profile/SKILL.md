---
name: professional-user-profile
description: Provides comprehensive guidance for creating, managing, and optimizing professional user profiles for job applications and career platforms, covering data structures, field definitions, ATS optimization, and industry best practices
allowed-tools:
  - Read
  - Write
  - Edit
---

# Professional User Profile Skill

## Overview
This skill provides comprehensive guidance for creating, managing, and optimizing professional user profiles for job applications and career platforms. It covers data structures, field definitions, ATS optimization, and best practices based on industry standards from LinkedIn, JSON Resume, and major applicant tracking systems.

## When to Use This Skill
- Building user profile data models for job applications
- Designing resume/CV data structures
- Creating candidate profile systems
- Implementing profile parsing and matching features
- Optimizing profiles for ATS (Applicant Tracking System) compatibility
- Developing career management platforms

## Core Profile Components

### 1. Basic Information (Required)
The foundation of any professional profile:

```json
{
  "basics": {
    "name": "Full Legal Name",
    "label": "Professional Title/Role",
    "image": "https://profile-photo-url.com/photo.jpg",
    "email": "professional@email.com",
    "phone": "(555) 123-4567",
    "url": "https://personal-website.com",
    "summary": "2-4 sentence professional summary highlighting key value proposition",
    "location": {
      "address": "Street address (optional for privacy)",
      "postalCode": "12345",
      "city": "City Name",
      "countryCode": "US",
      "region": "State/Province"
    }
  }
}
```

**Best Practices:**
- **Name:** Use full legal name for professional contexts; some systems allow preferred name separately
- **Label/Title:** Should be a clear, searchable job title (e.g., "Senior Software Engineer" not "Code Ninja")
- **Email:** Use professional email address; avoid nicknames or unprofessional domains
- **Phone:** Include country code for international applications; format consistently
- **Summary:** Write in first person, focus on value proposition, include keywords from target roles
- **Location:** Balance between specificity for local jobs and privacy concerns; city/state usually sufficient

### 2. Work Experience (Critical)
Most important section for established professionals:

```json
{
  "work": [
    {
      "name": "Company Name",
      "position": "Job Title",
      "url": "https://company.com",
      "startDate": "2020-01-15",
      "endDate": "2023-06-30",
      "summary": "Brief description of role and responsibilities",
      "highlights": [
        "Quantified achievement with specific metric (e.g., 'Increased sales by 40%')",
        "Leadership accomplishment (e.g., 'Led team of 5 developers')",
        "Technical implementation (e.g., 'Built microservices architecture')"
      ],
      "location": "City, State/Country",
      "employmentType": "Full-time | Part-time | Contract | Freelance",
      "isCurrentRole": true
    }
  ]
}
```

**Best Practices:**
- **Reverse chronological order:** Most recent first (required by most ATS)
- **Dates:** Use ISO 8601 format (YYYY-MM-DD) for consistency; month-year minimum
- **Current Role:** Mark clearly to prevent ATS confusion; use "Present" or leave endDate empty
- **Achievements over duties:** Focus on measurable outcomes, not just responsibilities
- **Action verbs:** Start bullets with strong verbs (Led, Built, Increased, Reduced, etc.)
- **Quantification:** Include numbers, percentages, dollar amounts whenever possible
- **Keywords:** Include industry-specific terms and technologies from job descriptions
- **Length:** 3-5 bullets per role optimal; more for current/recent roles

### 3. Education
Academic credentials and training:

```json
{
  "education": [
    {
      "institution": "University Name",
      "url": "https://university.edu",
      "area": "Major/Field of Study",
      "studyType": "Bachelor of Science | Master of Arts | PhD | Certificate",
      "startDate": "2015-09-01",
      "endDate": "2019-05-15",
      "score": "3.8 GPA | 4.0 scale",
      "courses": [
        "Relevant Course 1",
        "Relevant Course 2"
      ],
      "honors": [
        "Dean's List",
        "Magna Cum Laude"
      ]
    }
  ]
}
```

**Best Practices:**
- Include degree type, major, and institution at minimum
- GPA if 3.5+ or specifically requested
- Relevant coursework for recent graduates or career changers
- Honors and awards to distinguish yourself
- Omit high school if you have college degree
- For international: include equivalency if applying in different country

### 4. Skills (Essential for ATS)
Technical and soft skills for matching:

```json
{
  "skills": [
    {
      "name": "Skill Category (e.g., 'Web Development')",
      "level": "Beginner | Intermediate | Advanced | Expert | Master",
      "keywords": [
        "Specific skill 1",
        "Specific skill 2",
        "Specific skill 3"
      ],
      "yearsOfExperience": 5
    }
  ]
}
```

**Skills Taxonomy Structure:**
Organize skills hierarchically:

1. **Core Competencies** (Broad categories)
   - Technical Skills
   - Leadership & Management
   - Communication
   - Business/Domain Knowledge

2. **Skill Clusters** (Mid-level groupings)
   - Example: "Programming Languages", "Project Management Tools", "Data Analysis"

3. **Specific Skills** (Granular abilities)
   - Example: "Python", "Agile/Scrum", "SQL", "Public Speaking"

**Best Practices:**
- **Hard skills priority:** Technical abilities, software, certifications
- **Soft skills selective:** Only include if job description emphasizes them
- **Keywords matching:** Mirror language from target job descriptions
- **Proficiency levels:** Be honest; may be tested
- **Up-to-date:** Remove obsolete technologies
- **Categorization:** Group similar skills for better readability
- **ATS optimization:** Include both acronyms and full terms (e.g., "SEO (Search Engine Optimization)")

### 5. Certifications & Licenses
Professional credentials that validate expertise:

```json
{
  "certificates": [
    {
      "name": "Certification Name",
      "date": "2023-06-15",
      "issuer": "Issuing Organization",
      "url": "https://credential-verification-url.com",
      "expirationDate": "2026-06-15",
      "credentialId": "ABC123XYZ"
    }
  ]
}
```

**Best Practices:**
- Include verification URLs when available
- Note if certification is current or expired
- Prioritize industry-recognized certifications
- Include license numbers for regulated professions
- Professional certifications often carry more weight than completion certificates

### 6. Projects & Portfolio
Demonstrates applied skills and initiative:

```json
{
  "projects": [
    {
      "name": "Project Name",
      "description": "What the project does and why it matters",
      "highlights": [
        "Key achievement or feature",
        "Technical challenge solved"
      ],
      "keywords": [
        "Technology 1",
        "Technology 2"
      ],
      "startDate": "2022-01-01",
      "endDate": "2022-06-30",
      "url": "https://project-demo.com",
      "roles": [
        "Lead Developer",
        "Designer"
      ],
      "entity": "Company | Personal | Academic",
      "type": "Application | Website | Research | Open Source"
    }
  ]
}
```

**Best Practices:**
- Include live demos or GitHub links
- Explain business value, not just technical details
- Highlight your specific contributions in team projects
- Especially valuable for developers, designers, writers
- Can compensate for lack of formal experience

### 7. Additional Sections

#### Languages
```json
{
  "languages": [
    {
      "language": "English",
      "fluency": "Native | Fluent | Professional | Limited | Basic",
      "certifications": ["TOEFL 110/120"]
    }
  ]
}
```

#### Volunteer Experience
```json
{
  "volunteer": [
    {
      "organization": "Organization Name",
      "position": "Volunteer Role",
      "url": "https://organization.org",
      "startDate": "2020-01-01",
      "endDate": "2021-12-31",
      "summary": "Description of volunteer work",
      "highlights": [
        "Impact created",
        "Skills demonstrated"
      ]
    }
  ]
}
```

#### Awards & Honors
```json
{
  "awards": [
    {
      "title": "Award Name",
      "date": "2023-04-15",
      "awarder": "Awarding Organization",
      "summary": "Why award was received"
    }
  ]
}
```

#### Publications
```json
{
  "publications": [
    {
      "name": "Publication Title",
      "publisher": "Publisher Name",
      "releaseDate": "2022-09-01",
      "url": "https://publication-link.com",
      "summary": "Brief description of publication"
    }
  ]
}
```

#### Professional Profiles
```json
{
  "profiles": [
    {
      "network": "LinkedIn | GitHub | Twitter | Portfolio",
      "username": "username",
      "url": "https://linkedin.com/in/username"
    }
  ]
}
```

## ATS (Applicant Tracking System) Optimization

### Critical ATS Requirements

1. **File Format**
   - Preferred: `.docx` (MS Word)
   - Acceptable: PDF (but only if exported from Word, not scanned)
   - Avoid: Images, scanned PDFs, `.pages`, `.jpg`, `.png`

2. **Formatting Rules**
   - **Use:** Simple, clean formatting with standard fonts (Arial, Calibri, Times New Roman, Helvetica)
   - **Avoid:** Headers/footers (ATS may not read these), columns, tables, text boxes, graphics, images, WordArt, special characters

3. **Section Headings**
   Use standard, clear headings that ATS can recognize:
   - ✅ "Work Experience" or "Professional Experience"
   - ✅ "Education"
   - ✅ "Skills"
   - ✅ "Certifications"
   - ❌ "My Journey" (too creative)
   - ❌ "What I Bring to the Table" (confusing)

4. **Date Formatting**
   - Consistent format throughout: "Month YYYY" or "MM/YYYY"
   - Example: "January 2020 - Present" or "01/2020 - Present"
   - Include months, not just years
   - Avoid: "Jan '20" or inconsistent formats

5. **Keywords Strategy**
   - **Extract from job description:** Identify repeated terms, required skills, certifications
   - **Natural integration:** Weave keywords into content, not stuffed artificially
   - **Include variations:** Both acronym and full term (e.g., "ATS (Applicant Tracking System)")
   - **Industry terminology:** Use job-specific jargon appropriately
   - **Action verbs:** Led, Managed, Developed, Increased, Reduced, Implemented

6. **Contact Information Placement**
   - Place in main body of document, NOT in header/footer
   - Include: Name, Phone, Email, Location (City, State), LinkedIn URL
   - Top of first page, clearly visible

### Resume Parsing Process

Understanding how ATS reads resumes:

1. **Text Extraction:** ATS uses OCR (Optical Character Recognition) to convert resume to plain text
2. **Data Categorization:** Parsed text is organized into predefined fields (Name, Email, Skills, Experience, etc.)
3. **Keyword Matching:** System scans for keywords from job description
4. **Ranking:** Candidates scored based on keyword matches and relevance
5. **Human Review:** Top-ranked candidates forwarded to recruiters

**Common Parsing Issues:**
- Fancy fonts becoming garbled text
- Graphics/logos preventing text extraction
- Columns causing information to appear in wrong order
- Custom section headings not being recognized
- Skills buried in paragraphs instead of clearly listed

## LinkedIn Profile Structure

LinkedIn has become the de facto standard for professional profiles. Key sections:

### Required for "All-Star" Status
1. **Profile Photo** - Professional headshot (increases profile views 11x)
2. **Headline** - 120 characters to describe your professional identity
3. **About/Summary** - 2,600 character limit; use to tell your story
4. **Current Position** - With job description
5. **Two Past Positions** - With descriptions
6. **Education** - At least one entry
7. **Skills** - Minimum 3 skills (up to 50 total)
8. **50+ Connections**

### LinkedIn-Specific Best Practices
- **Headline:** Don't just list job title; include value proposition
- **About:** Write in first person, show personality, include call-to-action
- **Experience:** Focus on achievements and impact, use bullet points for readability
- **Skills:** Get endorsements; top 3 skills shown prominently
- **Recommendations:** Request from colleagues to add credibility
- **Activity:** Regular posting increases visibility
- **Custom URL:** Create readable vanity URL (linkedin.com/in/yourname)

## Privacy & Security Considerations

### What to Include vs. Exclude

**Include:**
- Professional email (create separate from personal if needed)
- City and state/region (specific address usually unnecessary)
- LinkedIn profile URL
- Professional phone number

**Exclude or Make Optional:**
- Full street address (privacy risk)
- Date of birth (age discrimination)
- Photo (in US resumes; required in some countries)
- Marital status, children (illegal to ask in many jurisdictions)
- Social Security Number (never include)
- References (provide separately when requested)

**Regional Variations:**
- **US:** No photo, no age, no marital status
- **Europe:** Photo often expected; GDPR protections apply
- **Asia:** More personal information often included
- **Middle East:** Photo usually required

## Data Validation Rules

### Field-Level Validation

```javascript
{
  "email": {
    "pattern": "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$",
    "required": true
  },
  "phone": {
    "pattern": "^[+]?[(]?[0-9]{1,4}[)]?[-\\s\\.]?[(]?[0-9]{1,4}[)]?[-\\s\\.]?[0-9]{1,9}$",
    "required": false
  },
  "dates": {
    "format": "YYYY-MM-DD",
    "validation": "startDate must be before endDate",
    "currentRole": "endDate can be null or 'Present'"
  },
  "url": {
    "pattern": "^https?://[\\w.-]+\\.[a-zA-Z]{2,}.*$",
    "required": false
  }
}
```

### Content Quality Checks

- **Spell check:** Typos severely damage credibility
- **Grammar:** Professional writing expected
- **Consistency:** Same tense, formatting throughout
- **Honesty:** Never falsify credentials or experience
- **Relevance:** Tailor to target role; remove irrelevant info after 10-15 years
- **Length:** 1 page for <5 years experience, 2 pages for >5 years; max 3 pages

## Implementation Guidelines for Developers

### Database Schema Considerations

1. **Flexible Structure:** Use JSON/JSONB columns for extensible data
2. **Version Control:** Track profile changes over time
3. **Privacy Levels:** Allow users to control what's public/private
4. **Multiple Formats:** Store data once, export to multiple formats
5. **Search Indexing:** Full-text search on key fields for matching

### API Design

```javascript
// Profile endpoints structure
GET    /api/profiles/:id          // Retrieve profile
POST   /api/profiles              // Create profile
PUT    /api/profiles/:id          // Update profile
PATCH  /api/profiles/:id          // Partial update
DELETE /api/profiles/:id          // Delete profile

// Export formats
GET    /api/profiles/:id/export?format=pdf|docx|json|linkedin

// Matching
POST   /api/profiles/:id/match    // Match profile against job description
{
  "jobDescription": "...",
  "returnScore": true,
  "returnSuggestions": true
}
```

### Skills Matching Algorithm

Basic approach to profile-job matching:

1. **Keyword Extraction:** Parse job description for required/preferred skills
2. **Skill Categorization:** Group skills by type (required, nice-to-have)
3. **Matching:** Compare profile skills against job requirements
4. **Scoring:** Calculate match percentage
5. **Recommendations:** Suggest missing skills or experience

```javascript
function calculateMatchScore(profile, jobDescription) {
  const requiredSkills = extractSkills(jobDescription, 'required');
  const profileSkills = profile.skills.flatMap(s => s.keywords);

  const matches = requiredSkills.filter(skill =>
    profileSkills.some(pSkill =>
      similarity(skill.toLowerCase(), pSkill.toLowerCase()) > 0.85
    )
  );

  return {
    score: (matches.length / requiredSkills.length) * 100,
    matchedSkills: matches,
    missingSkills: requiredSkills.filter(s => !matches.includes(s))
  };
}
```

## Best Practices Summary

### For Job Seekers
1. **Tailor each application** - One resume doesn't fit all
2. **Quantify achievements** - Numbers speak louder than words
3. **Keywords matter** - Mirror job description language
4. **Keep it current** - Update regularly, remove outdated info
5. **Proofread ruthlessly** - Typos kill applications
6. **Format simply** - ATS compatibility over visual flair
7. **Tell a story** - Connect experiences to show career progression

### For Platform Developers
1. **JSON Resume standard** - Consider for data structure
2. **ATS compatibility** - Design exports that parse correctly
3. **Skills taxonomy** - Implement hierarchical, searchable skills
4. **Privacy controls** - Let users decide what's visible
5. **Multiple exports** - Support PDF, DOCX, JSON, LinkedIn
6. **Version history** - Track changes, allow rollback
7. **AI assistance** - Help users improve content quality
8. **Matching intelligence** - Compare profiles against job descriptions

## Resources & References

### Industry Standards
- **JSON Resume:** https://jsonresume.org - Open standard for resume data
- **Schema.org Person:** https://schema.org/Person - Structured data for people
- **O*NET Online:** https://www.onetonline.org - Skills and occupations database
- **ESCO:** https://esco.ec.europa.eu - European skills taxonomy

### ATS Platforms (for compatibility testing)
- Workable
- Greenhouse
- Lever
- Taleo (Oracle)
- iCIMS
- SmartRecruiters
- BambooHR

### Professional Networks
- LinkedIn (primary professional network)
- GitHub (for developers)
- Behance (for designers)
- Medium (for writers)

## Conclusion

A well-structured professional profile is the foundation of effective job matching and career development. By following these standards and best practices, you can create profiles that:

- Parse correctly through ATS systems
- Present information clearly to human readers
- Match accurately against job requirements
- Protect user privacy while showcasing qualifications
- Support multiple export formats and use cases

Whether building a job application platform or helping users optimize their profiles, these guidelines provide a comprehensive framework for success.

---

**Skill Version:** 1.0
**Last Updated:** October 2025
**Maintained By:** Jason - Manifest & Match iOS App
