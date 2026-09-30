"""Pydantic data models for the Vithey AI core.

The generated CV always follows one standard structure (``StandardCV``):
contact header -> professional summary -> canonical sections in a fixed
order (experience, education, projects, skills, certifications, languages,
achievements, volunteer). Missing sections are rendered as empty lists, so
the output shape is deterministic and safe for the app to render or export.
"""

from typing import List, Optional

from pydantic import BaseModel, Field, field_validator

# ---------------------------------------------------------------------------
# Inputs
# ---------------------------------------------------------------------------


class RawPost(BaseModel):
    source_id: str = Field(..., min_length=1, description="Unique id of the source post")
    source_type: str = Field(default="post", description="post | video | job | other")
    content: str = Field(
        default="",
        description="Raw post/activity text (empty posts fail during extraction)",
    )

    @field_validator("source_id", "source_type", "content")
    @classmethod
    def _strip(cls, v: str) -> str:
        return v.strip()


class UserProfile(BaseModel):
    """Known facts about the user. These always win over anything the LLM
    produces for the contact header and education section."""

    full_name: Optional[str] = None
    headline: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    location: Optional[str] = None
    linkedin: Optional[str] = None
    github: Optional[str] = None
    website: Optional[str] = None
    skills: List[str] = Field(default_factory=list, description="Extra user-claimed skills")
    education: List["EducationItem"] = Field(default_factory=list)


class ExtractedActivity(BaseModel):
    activity_type: str = Field(
        default="other",
        description="project | knowledge_share | achievement | volunteer | work | other",
    )
    title: str
    role: Optional[str] = None
    summary: str
    tools: List[str] = Field(default_factory=list)
    skills: List[str] = Field(default_factory=list)
    outcome: Optional[str] = None
    date: Optional[str] = Field(default=None, description="YYYY-MM-DD when known")
    source_id: str
    additional_source_ids: List[str] = Field(default_factory=list)

    @field_validator("title", "summary")
    @classmethod
    def _require_text(cls, v: str) -> str:
        v = v.strip()
        if not v:
            raise ValueError("must not be empty")
        return v

    @property
    def all_source_ids(self) -> List[str]:
        ids = [self.source_id]
        ids.extend(sid for sid in self.additional_source_ids if sid != self.source_id)
        return ids


# ---------------------------------------------------------------------------
# Standard CV building blocks
# ---------------------------------------------------------------------------


class ContactInfo(BaseModel):
    full_name: Optional[str] = None
    headline: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    location: Optional[str] = None
    linkedin: Optional[str] = None
    github: Optional[str] = None
    website: Optional[str] = None


class EvidenceMixin(BaseModel):
    evidence: List[str] = Field(
        default_factory=list,
        description="source_ids from the user's posts backing this entry",
    )


class ExperienceItem(EvidenceMixin):
    title: str
    organization: Optional[str] = None
    location: Optional[str] = None
    period: Optional[str] = Field(default=None, description='e.g. "2024-01 ~ 2024-06"')
    start_date: Optional[str] = None
    end_date: Optional[str] = None
    bullets: List[str] = Field(default_factory=list)


class EducationItem(EvidenceMixin):
    degree: str
    institution: Optional[str] = None
    field_of_study: Optional[str] = None
    period: Optional[str] = None
    details: Optional[str] = Field(default=None, description="GPA, honours, coursework")


class ProjectItem(EvidenceMixin):
    name: str
    role: Optional[str] = None
    period: Optional[str] = None
    summary: Optional[str] = None
    tech_stack: List[str] = Field(default_factory=list)
    bullets: List[str] = Field(default_factory=list)
    link: Optional[str] = None


class SkillGroup(BaseModel):
    category: str = Field(default="General", description='e.g. "Technical", "Languages", "Soft skills"')
    skills: List[str] = Field(default_factory=list)


class CertificationItem(EvidenceMixin):
    name: str
    issuer: Optional[str] = None
    date: Optional[str] = None


class LanguageItem(BaseModel):
    name: str
    proficiency: Optional[str] = Field(
        default=None, description='e.g. "Native", "Professional", "Conversational"'
    )


class AchievementItem(EvidenceMixin):
    title: str
    description: Optional[str] = None
    date: Optional[str] = None


class VolunteerItem(EvidenceMixin):
    title: str
    organization: Optional[str] = None
    description: Optional[str] = None
    date: Optional[str] = None


class CVMeta(BaseModel):
    language: str = "en"
    target_role: Optional[str] = None
    job_tailored: bool = False
    generated_at: Optional[str] = Field(default=None, description="ISO8601 UTC")
    model: Optional[str] = None
    activity_count: int = 0

    @field_validator("language")
    @classmethod
    def _lower(cls, v: str) -> str:
        return (v or "en").strip().lower()


# ---------------------------------------------------------------------------
# The standard CV
# ---------------------------------------------------------------------------


class StandardCV(BaseModel):
    """One canonical CV shape. Sections are always present (possibly empty),
    always in this order -- renderers and PDF exporters can rely on it."""

    contact: ContactInfo = Field(default_factory=ContactInfo)
    summary: str = ""
    experience: List[ExperienceItem] = Field(default_factory=list)
    education: List[EducationItem] = Field(default_factory=list)
    projects: List[ProjectItem] = Field(default_factory=list)
    skills: List[SkillGroup] = Field(default_factory=list)
    certifications: List[CertificationItem] = Field(default_factory=list)
    languages: List[LanguageItem] = Field(default_factory=list)
    achievements: List[AchievementItem] = Field(default_factory=list)
    volunteer: List[VolunteerItem] = Field(default_factory=list)
    meta: CVMeta = Field(default_factory=CVMeta)

    def section_lists(self) -> dict:
        """Map section display names to their entries, in standard order."""
        return {
            "Work Experience": self.experience,
            "Education": self.education,
            "Projects": self.projects,
            "Skills": self.skills,
            "Certifications": self.certifications,
            "Languages": self.languages,
            "Achievements": self.achievements,
            "Volunteer Work": self.volunteer,
        }


# ---------------------------------------------------------------------------
# Quality report
# ---------------------------------------------------------------------------


class QualityIssue(BaseModel):
    code: str = Field(..., description="machine-readable issue code")
    message: str
    field: Optional[str] = None


class CVQualityReport(BaseModel):
    score: int = Field(..., ge=0, le=100, description="Completeness/quality 0-100")
    grade: str = Field(..., description='"excellent" | "good" | "fair" | "weak"')
    issues: List[QualityIssue] = Field(default_factory=list)


# ---------------------------------------------------------------------------
# Batch extraction results
# ---------------------------------------------------------------------------


class ExtractionFailure(BaseModel):
    source_id: str = Field(..., description="Post that could not be extracted")
    error: str
    recoverable: bool = True


class ExtractionBatchResult(BaseModel):
    activities: List[ExtractedActivity] = Field(default_factory=list)
    failures: List[ExtractionFailure] = Field(default_factory=list)

    @property
    def ok_count(self) -> int:
        return len(self.activities)

    @property
    def failure_count(self) -> int:
        return len(self.failures)


# Rebuild forward references (UserProfile <-> EducationItem)
UserProfile.model_rebuild()
