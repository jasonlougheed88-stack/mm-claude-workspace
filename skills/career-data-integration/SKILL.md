---
name: career-data-integration
description: Integrates career exploration data from multiple job board APIs and matching algorithms to help users discover career opportunities aligned with their skills
allowed-tools:
  - Read
  - Grep
  - Glob
  - Edit
  - Write
  - WebFetch
  - WebSearch
---

# Career Data Integration Skill

Integrates career exploration data from multiple job board APIs and matching algorithms to help users discover career opportunities aligned with their skills.

## Core Capabilities

- **Job Feed Aggregation**: Fetch and normalize job postings from multiple APIs (Indeed, LinkedIn, Glassdoor, ZipRecruiter)
- **Skills Matching**: Match user skills against job requirements using advanced algorithms
- **Career Path Analysis**: Identify skill gaps and recommend learning paths
- **API Integration**: Handle rate limiting, caching, and error recovery across multiple job board APIs

## When to Use This Skill

Use this skill when:
- Integrating job board APIs into an application
- Building career exploration or job matching features
- Implementing skills-based recommendation systems
- Analyzing career data or job market trends
- Creating personalized job discovery experiences

## Key Features

### 1. Multi-Source Job Aggregation
- Fetches job postings from Indeed, LinkedIn, Glassdoor, ZipRecruiter APIs
- Normalizes data formats across different sources
- Handles API rate limiting and caching strategies
- Implements fallback mechanisms for API failures

### 2. Skills Taxonomy System
- Comprehensive skills classification (14 industry sectors)
- Hierarchical skill relationships (parent/child skills)
- Skill synonyms and aliases for matching
- Industry-specific skill weights and relevance

### 3. Intelligent Matching Algorithm
- Thompson Sampling for exploration vs exploitation
- Skill similarity scoring with configurable weights
- Experience level matching
- Location and salary range filtering
- Machine learning-based relevance ranking

### 4. Performance Optimized
- Aggressive caching to minimize API costs
- Batch processing for multiple job searches
- Response time < 10ms for cached results
- Token optimization for AI parsing

## API Reference

### Supported Job Board APIs

#### Indeed API
- Publisher ID and API key authentication
- Job search with location, keywords, salary filters
- Rate limit: 100 requests/day (free tier)
- Response format: JSON with standardized job schema

#### LinkedIn Jobs API
- OAuth 2.0 authentication
- Advanced search filters (company, experience level, remote)
- Rate limit: 500 requests/day
- Rich company and applicant data

#### Glassdoor API
- Partner key authentication
- Salary data and company reviews
- Rate limit: 1000 requests/day
- Employer branding information

#### ZipRecruiter API
- API key authentication
- Job posting and resume matching
- Rate limit: Varies by plan
- ATS integration support

### Skills Taxonomy Structure

```json
{
  "skill_id": "string",
  "name": "string",
  "category": "string (technical|soft|domain)",
  "industry_sector": "string (1 of 14 sectors)",
  "proficiency_levels": ["beginner", "intermediate", "advanced", "expert"],
  "related_skills": ["skill_id_1", "skill_id_2"],
  "parent_skill": "skill_id or null",
  "synonyms": ["alias1", "alias2"]
}
```

### Matching Algorithm Parameters

- `min_match_score`: Minimum similarity threshold (0.0-1.0)
- `skill_weights`: Custom weights for different skill categories
- `exploration_rate`: Thompson Sampling exploration parameter
- `location_radius`: Geographic search radius in miles
- `experience_range`: Min/max years of experience

## Implementation Guidance

### Job Feed Aggregation Workflow

1. **Configure API Credentials**: Set up authentication for each job board API
2. **Define Search Parameters**: Specify keywords, location, filters
3. **Fetch & Normalize**: Call aggregator to fetch from all sources
4. **Cache Results**: Store normalized results with TTL
5. **Return Unified Feed**: Provide standardized job card data

### Skills Matching Workflow

1. **Load Skills Taxonomy**: Initialize skills database
2. **Parse User Profile**: Extract skills from user data
3. **Fetch Job Requirements**: Get required skills from job postings
4. **Calculate Match Scores**: Run matching algorithm
5. **Rank & Filter**: Sort by relevance, apply thresholds
6. **Return Recommendations**: Provide matched jobs with scores

### Error Handling Best Practices

- Implement exponential backoff for rate limit errors
- Use circuit breaker pattern for failing APIs
- Provide graceful degradation (fewer sources if some fail)
- Log API errors for monitoring
- Cache fallback results for resilience

### Performance Optimization

- Cache API responses with appropriate TTL (1-24 hours)
- Batch multiple search queries when possible
- Use CDN for static skills taxonomy data
- Implement lazy loading for large result sets
- Monitor API costs and optimize request frequency

## Reference Files

- `references/api_reference.md`: Detailed API documentation for all job boards
- `references/skills_taxonomy.md`: Complete skills taxonomy with 14 industry sectors
- `scripts/job_feed_aggregator.py`: Python implementation of job aggregation
- `scripts/matching_algorithm.py`: Thompson Sampling-based matching algorithm

## Example Usage

### Aggregating Job Feeds

```python
from scripts.job_feed_aggregator import JobFeedAggregator

aggregator = JobFeedAggregator(
    indeed_api_key="your_key",
    linkedin_client_id="your_id",
    glassdoor_partner_id="your_id"
)

jobs = aggregator.fetch_jobs(
    keywords="software engineer",
    location="San Francisco, CA",
    radius=25,
    sources=["indeed", "linkedin", "glassdoor"]
)
```

### Matching Skills to Jobs

```python
from scripts.matching_algorithm import SkillsMatcher

matcher = SkillsMatcher(taxonomy_path="references/skills_taxonomy.md")

user_skills = ["Python", "Machine Learning", "API Design"]
job_requirements = ["Python", "TensorFlow", "REST APIs", "Cloud Computing"]

match_score = matcher.calculate_match(
    user_skills=user_skills,
    job_requirements=job_requirements,
    min_score=0.6
)

print(f"Match Score: {match_score.overall_score}")
print(f"Skill Gaps: {match_score.missing_skills}")
print(f"Recommendations: {match_score.learning_path}")
```

## Privacy & Security

- All user data processed on-device when possible
- API keys stored securely in Keychain/environment variables
- No personally identifiable information sent to job APIs without consent
- GDPR/CCPA compliant data handling
- Option to anonymize user profiles for matching

## Cost Optimization

- Aggressive caching reduces API calls by 80%+
- Smart rate limiting prevents quota overages
- Batch requests to minimize API costs
- Free tier prioritization where available
- Monitor and alert on cost thresholds

## Integration with V7 Architecture

This skill aligns with ManifestAndMatchV7 patterns:

- Uses Thompson Sampling for job recommendation (matches V7Thompson pattern)
- Implements on-device caching (privacy-first V7 approach)
- Provides standardized JobCard data model (V7Core.Job compatibility)
- Enforces <10ms response times (V7 performance baselines)
- Sector-neutral design (14 industries, not just tech)

## Future Enhancements

- Real-time job alerts via webhooks
- Resume parsing and auto-skill extraction
- Salary prediction models
- Career trajectory forecasting
- Interview preparation recommendations
