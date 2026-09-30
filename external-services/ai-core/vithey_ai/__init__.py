"""Vithey AI core package.

Public surface (import these from the rest of the app):
- VitheyAI               : main facade
- RawPost                : raw post input model
- UserProfile            : user profile input (contact/education)
- ExtractedActivity      : structured activity model
- StandardCV             : generated CV (standard, canonical structure)
- CVQualityReport        : deterministic quality score + issues
- ExtractionBatchResult  : batch extraction outcome

Everything else in this package is internal and should not be imported
by the rest of the application.
"""

from .schemas import (
    ContactInfo,
    CVQualityReport,
    EducationItem,
    ExperienceItem,
    ExtractionBatchResult,
    ExtractionFailure,
    ExtractedActivity,
    ProjectItem,
    RawPost,
    SkillGroup,
    StandardCV,
    UserProfile,
)
from .service import VitheyAI

__all__ = [
    "VitheyAI",
    "RawPost",
    "UserProfile",
    "ExtractedActivity",
    "StandardCV",
    "CVQualityReport",
    "ExtractionBatchResult",
    "ExtractionFailure",
    "ContactInfo",
    "ExperienceItem",
    "EducationItem",
    "ProjectItem",
    "SkillGroup",
]

__version__ = "0.2.0"
