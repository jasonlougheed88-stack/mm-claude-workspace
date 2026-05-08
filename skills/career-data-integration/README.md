# Career Data Integration Skill

This Claude skill helps you integrate job board APIs and implement skills-based career matching systems.

## Quick Start

To use this skill in Claude Code:

```bash
/skill career-data-integration
```

Or invoke programmatically:

```python
from claude import Skill

skill = Skill("career-data-integration")
```

## What This Skill Does

This skill provides expert guidance on:

1. **Job Board API Integration**
   - Indeed, LinkedIn, Glassdoor, ZipRecruiter APIs
   - Authentication, rate limiting, error handling
   - Response normalization across multiple sources

2. **Skills Matching Algorithms**
   - Thompson Sampling for exploration/exploitation
   - Skill taxonomy and similarity scoring
   - Career path recommendations

3. **Performance Optimization**
   - Caching strategies (1-24 hour TTL)
   - Cost reduction (80%+ API cost savings)
   - Sub-10ms response times for cached results

## File Structure

```
.claudeskills/career-data-integration/
├── SKILL.md                          # Main skill definition
├── README.md                         # This file
├── references/
│   ├── api_reference.md             # Job board API documentation
│   └── skills_taxonomy.md           # Skills classification system
└── scripts/
    ├── job_feed_aggregator.py       # Multi-source job aggregation
    └── matching_algorithm.py        # Thompson Sampling matcher
```

## Example Use Cases

### 1. Building a Job Search Feature

Ask Claude:
> "Using the career-data-integration skill, help me implement job search that fetches from Indeed and LinkedIn APIs with proper caching."

### 2. Implementing Skills Matching

Ask Claude:
> "Using the career-data-integration skill, help me build a skills matcher that scores candidates against job requirements."

### 3. API Cost Optimization

Ask Claude:
> "Using the career-data-integration skill, help me reduce my job board API costs by implementing smart caching."

## Key Features

- **Multi-Source Aggregation**: Fetch from 4+ job boards simultaneously
- **Smart Caching**: Reduce API calls by 80%+ with TTL-based caching
- **Skill Taxonomy**: 14 industry sectors, 1000+ skills classified
- **Thompson Sampling**: Exploration vs exploitation for recommendations
- **Privacy-First**: On-device processing, secure credential storage

## Reference Data

### Supported APIs

| API | Free Tier | Rate Limit | Authentication |
|-----|-----------|------------|----------------|
| Indeed | 100/day | Daily | API Key + Publisher ID |
| LinkedIn | 500/day | 100/min | OAuth 2.0 |
| Glassdoor | 1000/day | Daily | Partner ID + Key |
| ZipRecruiter | Varies | Custom | API Key |

### Skills Categories

- Technical Skills (40% weight)
- Domain Knowledge (30% weight)
- Soft Skills (20% weight)
- Transferable Skills (10% weight)

### Industry Sectors (14 total)

1. Technology & Software
2. Healthcare & Medical
3. Finance & Banking
4. Education & Training
5. Manufacturing & Engineering
6. Retail & E-commerce
7. Hospitality & Tourism
8. Construction & Real Estate
9. Media & Entertainment
10. Transportation & Logistics
11. Legal & Compliance
12. Marketing & Advertising
13. Energy & Utilities
14. Agriculture & Food Services

## Integration Examples

### Job Feed Aggregation

```python
from scripts.job_feed_aggregator import JobFeedAggregator

aggregator = JobFeedAggregator(
    indeed_api_key="your_key",
    linkedin_access_token="your_token"
)

jobs = aggregator.fetch_jobs(
    keywords="software engineer",
    location="San Francisco, CA",
    sources=["indeed", "linkedin"]
)
```

### Skills Matching

```python
from scripts.matching_algorithm import SkillsMatcher

matcher = SkillsMatcher()

result = matcher.calculate_match(
    user_skills=["Python", "SQL", "Docker"],
    job_requirements=["Python", "PostgreSQL", "Kubernetes"],
    user_experience_level="mid"
)

print(f"Match: {result.overall_score:.0%}")
print(f"Gaps: {result.missing_skills}")
```

## Performance Baselines

- **Response Time**: <10ms (cached), <2s (API calls)
- **Cache Hit Rate**: >80% target
- **API Cost Reduction**: 80%+ vs no caching
- **Match Accuracy**: >85% relevance

## Privacy & Security

- API keys stored in environment variables/Keychain
- No PII sent to job APIs without consent
- On-device skill matching when possible
- GDPR/CCPA compliant data handling

## Cost Optimization

- **Caching**: 6-hour TTL reduces API calls by 80%+
- **Batch Processing**: Combine multiple searches
- **Free Tier Prioritization**: Use Indeed/LinkedIn free tiers
- **Smart Pagination**: Only fetch when needed

## Compatibility

Works with:
- ManifestAndMatchV7 architecture patterns
- Thompson Sampling job recommendation systems
- On-device caching (privacy-first)
- Swift/iOS job discovery apps
- Python/FastAPI backend services

## Future Enhancements

- Real-time job alerts via webhooks
- Resume parsing & auto-skill extraction
- Salary prediction models
- Career trajectory forecasting
- Interview prep recommendations

## Support

For issues or questions about this skill:
- Check `references/api_reference.md` for API docs
- Check `references/skills_taxonomy.md` for skills data
- Review example scripts in `scripts/` directory

## License

This skill is provided as-is for use with Claude Code.
