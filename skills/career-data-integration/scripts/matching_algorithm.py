#!/usr/bin/env python3
"""
Skills Matching Algorithm
Thompson Sampling-based job-to-candidate matching with skill similarity scoring.
"""

import numpy as np
from typing import List, Dict, Optional, Tuple
from dataclasses import dataclass
import json


@dataclass
class SkillMatch:
    """Result of skill matching calculation."""
    overall_score: float
    matched_skills: List[str]
    missing_skills: List[str]
    partial_matches: List[Tuple[str, str, float]]
    skill_gap_count: int
    learning_path: List[str]


class SkillsMatcher:
    """Thompson Sampling-based skills matching algorithm."""

    def __init__(self, taxonomy_path: Optional[str] = None):
        """
        Initialize matcher with skills taxonomy.

        Args:
            taxonomy_path: Path to skills taxonomy JSON file
        """
        self.taxonomy = self._load_taxonomy(taxonomy_path) if taxonomy_path else {}
        self.skill_weights = {
            "technical": 0.40,
            "domain": 0.30,
            "soft": 0.20,
            "transferable": 0.10
        }
        self.experience_multipliers = {
            "entry": 0.8,
            "mid": 1.0,
            "senior": 1.2,
            "expert": 1.5
        }

        # Thompson Sampling parameters
        self.alpha = np.ones(100)  # Success counts
        self.beta = np.ones(100)   # Failure counts

    def calculate_match(
        self,
        user_skills: List[str],
        job_requirements: List[str],
        user_experience_level: str = "mid",
        min_score: float = 0.6,
        exploration_rate: float = 0.1
    ) -> SkillMatch:
        """
        Calculate match score between user skills and job requirements.

        Args:
            user_skills: List of user's skills
            job_requirements: List of required job skills
            user_experience_level: User's experience level
            min_score: Minimum match threshold
            exploration_rate: Thompson Sampling exploration parameter

        Returns:
            SkillMatch object with detailed matching results
        """
        matched_skills = []
        partial_matches = []
        missing_skills = []

        # Normalize skill names
        user_skills_lower = [s.lower() for s in user_skills]
        job_requirements_lower = [s.lower() for s in job_requirements]

        total_score = 0.0
        max_possible_score = len(job_requirements)

        for job_skill in job_requirements:
            best_match_score = 0.0
            best_match_user_skill = None

            # Find best matching user skill
            for user_skill in user_skills:
                similarity = self._calculate_skill_similarity(user_skill, job_skill)

                if similarity > best_match_score:
                    best_match_score = similarity
                    best_match_user_skill = user_skill

            # Apply experience multiplier
            experience_multiplier = self.experience_multipliers.get(
                user_experience_level.lower(), 1.0
            )
            adjusted_score = best_match_score * experience_multiplier

            # Thompson Sampling: exploration vs exploitation
            if np.random.random() < exploration_rate:
                # Explore: sample from Beta distribution
                theta = np.random.beta(self.alpha[hash(job_skill) % 100],
                                     self.beta[hash(job_skill) % 100])
                adjusted_score *= theta

            total_score += adjusted_score

            # Categorize matches
            if best_match_score >= 0.95:
                matched_skills.append(job_skill)
            elif best_match_score >= 0.5:
                partial_matches.append((user_skill, job_skill, best_match_score))
            else:
                missing_skills.append(job_skill)

        # Calculate overall match percentage
        overall_score = (total_score / max_possible_score) if max_possible_score > 0 else 0.0

        # Generate learning path for missing skills
        learning_path = self._generate_learning_path(
            user_skills, missing_skills, partial_matches
        )

        return SkillMatch(
            overall_score=overall_score,
            matched_skills=matched_skills,
            missing_skills=missing_skills,
            partial_matches=partial_matches,
            skill_gap_count=len(missing_skills),
            learning_path=learning_path
        )

    def _calculate_skill_similarity(self, user_skill: str, job_skill: str) -> float:
        """
        Calculate similarity score between two skills.

        Returns:
            Similarity score from 0.0 to 1.0
        """
        user_skill_lower = user_skill.lower()
        job_skill_lower = job_skill.lower()

        # Exact match
        if user_skill_lower == job_skill_lower:
            return 1.0

        # Check synonyms
        if self._are_synonyms(user_skill_lower, job_skill_lower):
            return 0.95

        # Check parent-child relationship
        if self._is_parent_skill(user_skill_lower, job_skill_lower):
            return 0.80
        if self._is_child_skill(user_skill_lower, job_skill_lower):
            return 0.70

        # Check related skills
        if self._are_related(user_skill_lower, job_skill_lower):
            return 0.60

        # Partial string matching
        if user_skill_lower in job_skill_lower or job_skill_lower in user_skill_lower:
            return 0.50

        # Check same category
        if self._same_category(user_skill_lower, job_skill_lower):
            return 0.40

        # No match
        return 0.0

    def _are_synonyms(self, skill1: str, skill2: str) -> bool:
        """Check if two skills are synonyms."""
        synonyms_map = {
            "javascript": ["js", "ecmascript", "es6"],
            "python": ["python3", "py"],
            "machine learning": ["ml", "ai/ml"],
            "project management": ["pm"],
            "customer service": ["customer support", "client relations"],
        }

        for primary, synonyms in synonyms_map.items():
            if (skill1 == primary and skill2 in synonyms) or \
               (skill2 == primary and skill1 in synonyms):
                return True

        return False

    def _is_parent_skill(self, user_skill: str, job_skill: str) -> bool:
        """Check if user skill is a parent of job skill."""
        parent_child = {
            "programming": ["python", "javascript", "java", "c++"],
            "web development": ["frontend", "backend", "full stack"],
            "cloud computing": ["aws", "azure", "gcp"],
            "data science": ["machine learning", "data analysis", "statistics"],
        }

        for parent, children in parent_child.items():
            if user_skill == parent and job_skill in children:
                return True

        return False

    def _is_child_skill(self, user_skill: str, job_skill: str) -> bool:
        """Check if user skill is a child of job skill."""
        return self._is_parent_skill(job_skill, user_skill)

    def _are_related(self, skill1: str, skill2: str) -> bool:
        """Check if two skills are related."""
        related_groups = [
            ["python", "django", "flask", "fastapi"],
            ["javascript", "react", "vue", "angular", "node.js"],
            ["aws", "docker", "kubernetes", "terraform"],
            ["sql", "postgresql", "mysql", "mongodb"],
        ]

        for group in related_groups:
            if skill1 in group and skill2 in group:
                return True

        return False

    def _same_category(self, skill1: str, skill2: str) -> bool:
        """Check if two skills belong to the same category."""
        # Simplified - in production, use taxonomy
        technical_skills = ["python", "java", "sql", "aws", "docker"]
        soft_skills = ["communication", "leadership", "teamwork"]

        if (skill1 in technical_skills and skill2 in technical_skills) or \
           (skill1 in soft_skills and skill2 in soft_skills):
            return True

        return False

    def _generate_learning_path(
        self,
        user_skills: List[str],
        missing_skills: List[str],
        partial_matches: List[Tuple[str, str, float]]
    ) -> List[str]:
        """
        Generate recommended learning path to bridge skill gaps.

        Args:
            user_skills: Current user skills
            missing_skills: Skills user lacks
            partial_matches: Skills user partially knows

        Returns:
            Prioritized list of skills to learn
        """
        learning_path = []

        # Prioritize partial matches (easier to upgrade)
        for user_skill, job_skill, score in sorted(partial_matches, key=lambda x: -x[2]):
            if job_skill not in learning_path:
                learning_path.append(f"Upgrade: {job_skill} (from {user_skill})")

        # Add missing skills that are related to existing skills
        for missing_skill in missing_skills:
            for user_skill in user_skills:
                if self._are_related(user_skill.lower(), missing_skill.lower()):
                    learning_path.append(f"Learn: {missing_skill} (related to {user_skill})")
                    break
            else:
                learning_path.append(f"Learn: {missing_skill} (new skill)")

        return learning_path

    def update_thompson_sampling(self, skill_index: int, success: bool):
        """
        Update Thompson Sampling parameters based on match outcome.

        Args:
            skill_index: Index of the skill
            success: Whether the match was successful
        """
        idx = skill_index % 100
        if success:
            self.alpha[idx] += 1
        else:
            self.beta[idx] += 1

    def _load_taxonomy(self, path: str) -> Dict:
        """Load skills taxonomy from file."""
        try:
            with open(path, 'r') as f:
                return json.load(f)
        except Exception as e:
            print(f"Error loading taxonomy: {e}")
            return {}


# Example usage
if __name__ == "__main__":
    matcher = SkillsMatcher()

    user_skills = [
        "Python",
        "JavaScript",
        "SQL",
        "Docker",
        "Git",
        "Communication",
        "Project Management"
    ]

    job_requirements = [
        "Python",
        "Django",
        "PostgreSQL",
        "Docker",
        "Kubernetes",
        "AWS",
        "Team Leadership"
    ]

    result = matcher.calculate_match(
        user_skills=user_skills,
        job_requirements=job_requirements,
        user_experience_level="mid",
        min_score=0.6
    )

    print(f"Overall Match Score: {result.overall_score:.2%}")
    print(f"\nMatched Skills ({len(result.matched_skills)}):")
    for skill in result.matched_skills:
        print(f"  ✓ {skill}")

    print(f"\nPartial Matches ({len(result.partial_matches)}):")
    for user_skill, job_skill, score in result.partial_matches:
        print(f"  ~ {job_skill} (have: {user_skill}, {score:.0%} match)")

    print(f"\nMissing Skills ({len(result.missing_skills)}):")
    for skill in result.missing_skills:
        print(f"  ✗ {skill}")

    print(f"\nRecommended Learning Path:")
    for i, step in enumerate(result.learning_path, 1):
        print(f"  {i}. {step}")
