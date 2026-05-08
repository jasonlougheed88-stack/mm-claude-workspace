#!/usr/bin/env python3
"""
Job Feed Aggregator
Fetches and normalizes job postings from multiple job board APIs.
"""

import requests
import time
from typing import List, Dict, Optional
from datetime import datetime, timedelta
import hashlib
import json


class JobFeedAggregator:
    """Aggregates job feeds from multiple sources with caching and rate limiting."""

    def __init__(
        self,
        indeed_api_key: Optional[str] = None,
        indeed_publisher_id: Optional[str] = None,
        linkedin_access_token: Optional[str] = None,
        glassdoor_partner_id: Optional[str] = None,
        glassdoor_partner_key: Optional[str] = None,
        ziprecruiter_api_key: Optional[str] = None,
        cache_ttl_hours: int = 6
    ):
        """Initialize aggregator with API credentials."""
        self.indeed_api_key = indeed_api_key
        self.indeed_publisher_id = indeed_publisher_id
        self.linkedin_access_token = linkedin_access_token
        self.glassdoor_partner_id = glassdoor_partner_id
        self.glassdoor_partner_key = glassdoor_partner_key
        self.ziprecruiter_api_key = ziprecruiter_api_key
        self.cache_ttl_hours = cache_ttl_hours
        self.cache = {}

    def fetch_jobs(
        self,
        keywords: str,
        location: str,
        radius: int = 25,
        sources: List[str] = ["indeed", "linkedin", "glassdoor", "ziprecruiter"],
        limit: int = 25
    ) -> List[Dict]:
        """
        Fetch jobs from multiple sources and normalize results.

        Args:
            keywords: Job search keywords
            location: Geographic location
            radius: Search radius in miles
            sources: List of sources to query
            limit: Max results per source

        Returns:
            List of normalized job dictionaries
        """
        cache_key = self._generate_cache_key(keywords, location, radius, sources)

        # Check cache
        if cache_key in self.cache:
            cached_data, timestamp = self.cache[cache_key]
            if datetime.now() - timestamp < timedelta(hours=self.cache_ttl_hours):
                return cached_data

        all_jobs = []

        if "indeed" in sources and self.indeed_api_key:
            indeed_jobs = self._fetch_indeed(keywords, location, radius, limit)
            all_jobs.extend(indeed_jobs)

        if "linkedin" in sources and self.linkedin_access_token:
            linkedin_jobs = self._fetch_linkedin(keywords, location, radius, limit)
            all_jobs.extend(linkedin_jobs)

        if "glassdoor" in sources and self.glassdoor_partner_id:
            glassdoor_jobs = self._fetch_glassdoor(keywords, location, radius, limit)
            all_jobs.extend(glassdoor_jobs)

        if "ziprecruiter" in sources and self.ziprecruiter_api_key:
            ziprecruiter_jobs = self._fetch_ziprecruiter(keywords, location, radius, limit)
            all_jobs.extend(ziprecruiter_jobs)

        # Deduplicate based on company + title
        unique_jobs = self._deduplicate_jobs(all_jobs)

        # Cache results
        self.cache[cache_key] = (unique_jobs, datetime.now())

        return unique_jobs

    def _fetch_indeed(self, keywords: str, location: str, radius: int, limit: int) -> List[Dict]:
        """Fetch jobs from Indeed API."""
        try:
            url = "https://api.indeed.com/ads/apisearch"
            params = {
                "publisher": self.indeed_publisher_id,
                "q": keywords,
                "l": location,
                "radius": radius,
                "limit": min(limit, 25),
                "format": "json",
                "v": "2"
            }

            response = requests.get(url, params=params, timeout=10)
            response.raise_for_status()
            data = response.json()

            return [self._normalize_indeed_job(job) for job in data.get("results", [])]
        except Exception as e:
            print(f"Indeed API error: {e}")
            return []

    def _fetch_linkedin(self, keywords: str, location: str, radius: int, limit: int) -> List[Dict]:
        """Fetch jobs from LinkedIn API."""
        try:
            url = "https://api.linkedin.com/v2/jobs"
            headers = {
                "Authorization": f"Bearer {self.linkedin_access_token}",
                "LinkedIn-Version": "202401"
            }
            params = {
                "keywords": keywords,
                "location": location,
                "distance": radius,
                "count": min(limit, 50)
            }

            response = requests.get(url, headers=headers, params=params, timeout=10)
            response.raise_for_status()
            data = response.json()

            return [self._normalize_linkedin_job(job) for job in data.get("elements", [])]
        except Exception as e:
            print(f"LinkedIn API error: {e}")
            return []

    def _fetch_glassdoor(self, keywords: str, location: str, radius: int, limit: int) -> List[Dict]:
        """Fetch jobs from Glassdoor API."""
        try:
            url = "https://api.glassdoor.com/api/api.htm"
            params = {
                "t.p": self.glassdoor_partner_id,
                "t.k": self.glassdoor_partner_key,
                "action": "jobs-prog",
                "q": keywords,
                "l": location,
                "radius": radius,
                "format": "json",
                "v": "1",
                "pageSize": min(limit, 20)
            }

            response = requests.get(url, params=params, timeout=10)
            response.raise_for_status()
            data = response.json()

            jobs = data.get("response", {}).get("jobListings", [])
            return [self._normalize_glassdoor_job(job) for job in jobs]
        except Exception as e:
            print(f"Glassdoor API error: {e}")
            return []

    def _fetch_ziprecruiter(self, keywords: str, location: str, radius: int, limit: int) -> List[Dict]:
        """Fetch jobs from ZipRecruiter API."""
        try:
            url = "https://api.ziprecruiter.com/jobs/v1"
            params = {
                "api_key": self.ziprecruiter_api_key,
                "search": keywords,
                "location": location,
                "radius_miles": radius,
                "jobs_per_page": min(limit, 100),
                "page": 1
            }

            response = requests.get(url, params=params, timeout=10)
            response.raise_for_status()
            data = response.json()

            return [self._normalize_ziprecruiter_job(job) for job in data.get("jobs", [])]
        except Exception as e:
            print(f"ZipRecruiter API error: {e}")
            return []

    def _normalize_indeed_job(self, job: Dict) -> Dict:
        """Normalize Indeed job to standard schema."""
        return {
            "id": f"indeed_{job.get('jobkey', '')}",
            "source": "indeed",
            "title": job.get("jobtitle", ""),
            "company": {
                "name": job.get("company", ""),
                "url": None
            },
            "location": {
                "city": job.get("city", ""),
                "state": job.get("state", ""),
                "country": job.get("country", "US"),
                "remote": "remote" in job.get("jobtitle", "").lower()
            },
            "description": job.get("snippet", ""),
            "snippet": job.get("snippet", "")[:200],
            "salary": self._parse_salary(job.get("salary")),
            "employment_type": None,
            "experience_level": None,
            "posted_date": job.get("date", ""),
            "expires_date": None,
            "apply_url": job.get("url", ""),
            "required_skills": [],
            "preferred_skills": []
        }

    def _normalize_linkedin_job(self, job: Dict) -> Dict:
        """Normalize LinkedIn job to standard schema."""
        company = job.get("company", {})
        return {
            "id": f"linkedin_{job.get('id', '')}",
            "source": "linkedin",
            "title": job.get("title", ""),
            "company": {
                "name": company.get("name", ""),
                "url": f"https://www.linkedin.com/company/{company.get('universalName', '')}"
            },
            "location": {
                "city": None,
                "state": None,
                "country": None,
                "remote": job.get("workplaceType") == "REMOTE"
            },
            "description": job.get("description", ""),
            "snippet": job.get("description", "")[:200],
            "salary": job.get("salary"),
            "employment_type": job.get("employmentType", "").lower().replace("_", "-"),
            "experience_level": job.get("experienceLevel", "").lower().replace("_", "-"),
            "posted_date": datetime.fromtimestamp(job.get("postedDate", 0) / 1000).isoformat(),
            "expires_date": datetime.fromtimestamp(job.get("expiresDate", 0) / 1000).isoformat() if job.get("expiresDate") else None,
            "apply_url": job.get("applyUrl", ""),
            "required_skills": [],
            "preferred_skills": []
        }

    def _normalize_glassdoor_job(self, job: Dict) -> Dict:
        """Normalize Glassdoor job to standard schema."""
        return {
            "id": f"glassdoor_{job.get('jobId', '')}",
            "source": "glassdoor",
            "title": job.get("jobTitle", ""),
            "company": {
                "name": job.get("employer", ""),
                "url": None
            },
            "location": {
                "city": None,
                "state": None,
                "country": None,
                "remote": False
            },
            "description": job.get("jobDescription", ""),
            "snippet": job.get("jobDescription", "")[:200],
            "salary": self._parse_salary(job.get("salary")),
            "employment_type": job.get("jobType", "").lower(),
            "experience_level": None,
            "posted_date": job.get("postedDate", ""),
            "expires_date": None,
            "apply_url": job.get("jobUrl", ""),
            "required_skills": [],
            "preferred_skills": []
        }

    def _normalize_ziprecruiter_job(self, job: Dict) -> Dict:
        """Normalize ZipRecruiter job to standard schema."""
        hiring_company = job.get("hiring_company", {})
        return {
            "id": f"ziprecruiter_{job.get('id', '')}",
            "source": "ziprecruiter",
            "title": job.get("job_title", ""),
            "company": {
                "name": hiring_company.get("name", ""),
                "url": hiring_company.get("url")
            },
            "location": {
                "city": None,
                "state": None,
                "country": None,
                "remote": False
            },
            "description": job.get("snippet", ""),
            "snippet": job.get("snippet", "")[:200],
            "salary": self._parse_salary(job.get("salary")),
            "employment_type": job.get("employment_type", "").lower(),
            "experience_level": None,
            "posted_date": job.get("posted_time", ""),
            "expires_date": None,
            "apply_url": job.get("url", ""),
            "required_skills": [],
            "preferred_skills": []
        }

    def _parse_salary(self, salary_str: Optional[str]) -> Optional[Dict]:
        """Parse salary string into structured format."""
        if not salary_str:
            return None

        # Simple parsing - can be enhanced
        return {
            "min": None,
            "max": None,
            "currency": "USD",
            "raw": salary_str
        }

    def _deduplicate_jobs(self, jobs: List[Dict]) -> List[Dict]:
        """Remove duplicate jobs based on title + company."""
        seen = set()
        unique_jobs = []

        for job in jobs:
            key = f"{job['title'].lower()}_{job['company']['name'].lower()}"
            if key not in seen:
                seen.add(key)
                unique_jobs.append(job)

        return unique_jobs

    def _generate_cache_key(self, keywords: str, location: str, radius: int, sources: List[str]) -> str:
        """Generate cache key from search parameters."""
        key_data = f"{keywords}_{location}_{radius}_{'_'.join(sorted(sources))}"
        return hashlib.md5(key_data.encode()).hexdigest()


# Example usage
if __name__ == "__main__":
    aggregator = JobFeedAggregator(
        indeed_api_key="your_key",
        indeed_publisher_id="your_id"
    )

    jobs = aggregator.fetch_jobs(
        keywords="software engineer",
        location="San Francisco, CA",
        radius=25,
        sources=["indeed"]
    )

    print(f"Found {len(jobs)} jobs")
    for job in jobs[:5]:
        print(f"- {job['title']} at {job['company']['name']}")
