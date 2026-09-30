"""Deterministic normalizer: raw LLM output -> StandardCV.

This module is the guarantee that *every* CV returned by vithey-ai follows
the standard structure, no matter how sloppy the model's JSON is:

- tolerates missing keys, extra keys, wrong types, string-instead-of-list;
- maps stray section headings ("Work History", "My Projects", ...) onto the
  canonical buckets;
- merges UserProfile into contact header + education (profile always wins);
- drops evidence entries that do not reference a known source_id;
- fills an empty summary with a fact-based template (no hallucination);
- never raises on odd payloads -- worst case you get a valid, mostly-empty,
  standard CV.
"""

from datetime import datetime, timezone
from typing import Any, List, Optional

from .config import Config
from .errors import UnsupportedLanguageError
from .logging_conf import get_logger
from .schemas import (
    AchievementItem,
    CertificationItem,
    ContactInfo,
    CVMeta,
    EducationItem,
    ExperienceItem,
    ExtractedActivity,
    LanguageItem,
    ProjectItem,
    SkillGroup,
    StandardCV,
    UserProfile,
    VolunteerItem,
)

logger = get_logger(__name__)

# Canonical bucket for any heading the model might invent.
_HEADING_MAP = {
    "experience": "experience",
    "work experience": "experience",
    "work": "experience",
    "employment": "experience",
    "work history": "experience",
    "internships": "experience",
    "internship": "experience",
    "education": "education",
    "academic background": "education",
    "projects": "projects",
    "project": "projects",
    "personal projects": "projects",
    "skills": "skills",
    "technical skills": "skills",
    "certifications": "certifications",
    "certificates": "certifications",
    "languages": "languages",
    "achievements": "achievements",
    "awards": "achievements",
    "awards & achievements": "achievements",
    "volunteer": "volunteer",
    "volunteer work": "volunteer",
    "volunteering": "volunteer",
}


# ---------------------------------------------------------------------------
# Small coercion helpers (never raise)
# ---------------------------------------------------------------------------


def _as_dict(value: Any) -> dict:
    return value if isinstance(value, dict) else {}


def _as_list(value: Any) -> list:
    if value is None:
        return []
    if isinstance(value, list):
        return value
    return [value]


def _clean(value: Any) -> Optional[str]:
    """Coerce to a stripped non-empty string or None."""
    if value is None:
        return None
    if isinstance(value, (int, float)):
        return str(value)
    if not isinstance(value, str):
        return None
    v = value.strip()
    return v or None


def _str_list(value: Any) -> List[str]:
    out: List[str] = []
    seen = set()
    for item in _as_list(value):
        s = _clean(item)
        if s and s.lower() not in seen:
            seen.add(s.lower())
            out.append(s)
    return out


def _filter_evidence(value: Any, allowed: set) -> List[str]:
    return [s for s in _str_list(value) if s in allowed]


def _fallback_bullets(*values: Any, max_words: int = 25) -> List[str]:
    bullets = []
    for v in values:
        s = _clean(v)
        if not s:
            continue
        words = s.split()
        bullets.append(" ".join(words[:max_words]))
    return bullets


# Keyword fallbacks: any heading CONTAINING these maps onto the bucket.
_HEADING_KEYWORDS = [
    ("experience", ("experience", "employment", "work history", "career", "internship", "where i worked", "professional background")),
    ("education", ("education", "academic")),
    ("projects", ("project",)),
    ("skills", ("skill",)),
    ("certifications", ("certificat",)),
    ("languages", ("language",)),
    ("achievements", ("achiev", "award", "honor")),
    ("volunteer", ("volunteer", "community service")),
]


def _map_heading(heading: str) -> Optional[str]:
    h = heading.strip().lower()
    if h in _HEADING_MAP:
        return _HEADING_MAP[h]
    for target, keywords in _HEADING_KEYWORDS:
        if any(kw in h for kw in keywords):
            return target
    return None


def _date_sort_key(date_str: Optional[str]) -> str:
    """Best-effort descending sort key from partial dates ('2024-06', '2024')."""
    if not date_str:
        return ""
    head = date_str.strip()[:10]
    digits = "".join(ch for ch in head[:4] if ch.isdigit())
    return digits if len(digits) == 4 else ""


# ---------------------------------------------------------------------------
# Item builders
# ---------------------------------------------------------------------------


def _build_experience(raw: Any, allowed_evidence: set) -> Optional[ExperienceItem]:
    d = _as_dict(raw)
    title = _clean(d.get("title") or d.get("role") or d.get("name"))
    if not title:
        return None
    bullets = _str_list(d.get("bullets")) or _fallback_bullets(
        d.get("bullet"), d.get("summary"), d.get("description")
    )
    return ExperienceItem(
        title=title,
        organization=_clean(d.get("organization") or d.get("company")),
        location=_clean(d.get("location")),
        period=_clean(d.get("period")),
        start_date=_clean(d.get("start_date")),
        end_date=_clean(d.get("end_date")),
        bullets=bullets,
        evidence=_filter_evidence(d.get("evidence"), allowed_evidence),
    )


def _build_education(raw: Any, allowed_evidence: set) -> Optional[EducationItem]:
    d = _as_dict(raw)
    degree = _clean(d.get("degree") or d.get("title"))
    if not degree:
        return None
    return EducationItem(
        degree=degree,
        institution=_clean(d.get("institution") or d.get("school")),
        field_of_study=_clean(d.get("field_of_study") or d.get("field")),
        period=_clean(d.get("period")),
        details=_clean(d.get("details")),
        evidence=_filter_evidence(d.get("evidence"), allowed_evidence),
    )


def _build_project(raw: Any, allowed_evidence: set) -> Optional[ProjectItem]:
    d = _as_dict(raw)
    name = _clean(d.get("name") or d.get("title"))
    if not name:
        return None
    bullets = _str_list(d.get("bullets")) or _fallback_bullets(
        d.get("bullet"), d.get("description")
    )
    return ProjectItem(
        name=name,
        role=_clean(d.get("role")),
        period=_clean(d.get("period")),
        summary=_clean(d.get("summary")),
        tech_stack=_str_list(d.get("tech_stack") or d.get("tools")),
        bullets=bullets,
        link=_clean(d.get("link")),
        evidence=_filter_evidence(d.get("evidence"), allowed_evidence),
    )


def _build_skill_groups(raw_skills: Any, profile: Optional[UserProfile]) -> List[SkillGroup]:
    groups: List[SkillGroup] = []

    def add_group(category: str, skills: Any) -> None:
        cleaned = _str_list(skills)
        if cleaned:
            groups.append(SkillGroup(category=category or "General", skills=cleaned))

    for raw in _as_list(raw_skills):
        if isinstance(raw, dict):
            add_group(
                _clean(raw.get("category")) or "General",
                raw.get("skills"),
            )
        else:
            add_group("General", [raw])

    # Profile-declared skills land in a dedicated group so they are never lost.
    if profile is not None and profile.skills:
        existing = {s.lower() for g in groups for s in g.skills}
        extra = [s for s in _str_list(profile.skills) if s.lower() not in existing]
        if extra:
            groups.append(SkillGroup(category="Additional", skills=extra))
    return groups


def _build_certification(raw: Any, allowed_evidence: set) -> Optional[CertificationItem]:
    d = _as_dict(raw)
    name = _clean(d.get("name") or d.get("title"))
    if not name:
        return None
    return CertificationItem(
        name=name,
        issuer=_clean(d.get("issuer")),
        date=_clean(d.get("date")),
        evidence=_filter_evidence(d.get("evidence"), allowed_evidence),
    )


def _build_language(raw: Any) -> Optional[LanguageItem]:
    if isinstance(raw, str):
        return LanguageItem(name=raw) if raw.strip() else None
    d = _as_dict(raw)
    name = _clean(d.get("name"))
    if not name:
        return None
    return LanguageItem(name=name, proficiency=_clean(d.get("proficiency")))


def _build_achievement(raw: Any, allowed_evidence: set) -> Optional[AchievementItem]:
    d = _as_dict(raw)
    title = _clean(d.get("title") or d.get("name"))
    if not title:
        return None
    return AchievementItem(
        title=title,
        description=_clean(d.get("description") or d.get("bullet")),
        date=_clean(d.get("date")),
        evidence=_filter_evidence(d.get("evidence"), allowed_evidence),
    )


def _build_volunteer(raw: Any, allowed_evidence: set) -> Optional[VolunteerItem]:
    d = _as_dict(raw)
    title = _clean(d.get("title") or d.get("role") or d.get("name"))
    if not title:
        return None
    return VolunteerItem(
        title=title,
        organization=_clean(d.get("organization")),
        description=_clean(d.get("description") or d.get("bullet")),
        date=_clean(d.get("date")),
        evidence=_filter_evidence(d.get("evidence"), allowed_evidence),
    )


_BUILDERS = {
    "experience": _build_experience,
    "projects": _build_project,
    "certifications": _build_certification,
    "achievements": _build_achievement,
    "volunteer": _build_volunteer,
}


# ---------------------------------------------------------------------------
# Contact / summary / legacy handling
# ---------------------------------------------------------------------------


def _merge_contact(raw_contact: Any, profile: Optional[UserProfile]) -> ContactInfo:
    ai = _as_dict(raw_contact)

    def pick(field: str) -> Optional[str]:
        # Profile wins over anything the model produced.
        if profile is not None:
            pval = _clean(getattr(profile, field, None))
            if pval:
                return pval
        return _clean(ai.get(field))

    headline = pick("headline")
    if not headline and profile is not None:
        headline = _clean(profile.headline)
    return ContactInfo(
        full_name=pick("full_name"),
        headline=headline,
        email=pick("email"),
        phone=pick("phone"),
        location=pick("location"),
        linkedin=pick("linkedin"),
        github=pick("github"),
        website=pick("website"),
    )


def _profile_education(profile: Optional[UserProfile], allowed_evidence: set) -> List[EducationItem]:
    """Profile-provided education is authoritative -- keep as-is (its own
    evidence, usually none)."""
    if profile is None:
        return []
    out = []
    for edu in profile.education:
        if isinstance(edu, EducationItem):
            out.append(edu.model_copy())
        elif isinstance(edu, dict):
            built = _build_education(edu, set())
            if built:
                out.append(built)
    return out


def _legacy_sections(data: dict, allowed_evidence: set) -> dict:
    """Convert a legacy ``{"sections": [{"heading", "items"}]}`` payload into
    the standard buckets."""
    buckets: dict = {}
    for section in _as_list(data.get("sections")):
        sd = _as_dict(section)
        heading = (_clean(sd.get("heading")) or "").lower()
        target = _map_heading(heading)
        if not target:
            logger.info("Dropping unknown legacy CV section heading '%s'", heading)
            continue
        buckets.setdefault(target, []).extend(_as_list(sd.get("items")))
    return buckets


def _fallback_summary(activities: List[ExtractedActivity], language: str) -> str:
    templates = {
        "en": {
            "intro": "Candidate with verified activity across",
            "projects": "hands-on projects",
            "experience": "work experience",
            "achievements": "achievements",
            "skills_prefix": "Key skills:",
            "tail": "All claims are traceable to verified posts.",
        },
        "km": {
            "intro": "បេក្ខជនមានសកម្មភាពផ្ទៀងផ្ទាត់គ្របដណ្ដប់",
            "projects": "គម្រោងដោយខ្លួនឯង",
            "experience": "បទពិសោធន៍ការងារ",
            "achievements": "ស្នាដៃ",
            "skills_prefix": "ជំនាញសំខាន់ៗ:",
            "tail": "រាល់ព័ត៌មានអាចតាមដានបានពីប្រភេទសកម្មភាពពិត។",
        },
    }
    t = templates.get(language, templates["en"])

    counts = {
        "projects": sum(1 for a in activities if a.activity_type == "project"),
        "experience": sum(
            1 for a in activities if a.activity_type in {"work", "internship"}
        ),
        "achievements": sum(1 for a in activities if a.activity_type == "achievement"),
    }
    parts = [
        label
        for flag, label in (
            (counts["projects"], t["projects"]),
            (counts["experience"], t["experience"]),
            (counts["achievements"], t["achievements"]),
        )
        if flag
    ]
    summary = t["intro"]
    if parts:
        summary += " " + ", ".join(parts) + "."
    top_skills: List[str] = []
    for a in activities:
        top_skills.extend(a.skills[:2])
    top_skills = list(dict.fromkeys(top_skills))[:8]
    if top_skills:
        summary += f" {t['skills_prefix']} {', '.join(top_skills)}."
    summary += " " + t["tail"]
    return summary


# ---------------------------------------------------------------------------
# Public entry point
# ---------------------------------------------------------------------------


def normalize_cv(
    data: Any,
    activities: List[ExtractedActivity],
    profile: Optional[UserProfile],
    target_role: str,
    job_description: str,
    language: str,
    model_name: str,
) -> StandardCV:
    """Turn raw LLM JSON into a guaranteed-standard :class:`StandardCV`."""
    data = _as_dict(data)
    allowed_evidence = {sid for a in activities for sid in a.all_source_ids}

    # Legacy shape support: fold {"sections": [...]} into standard buckets.
    if "sections" in data and "experience" not in data:
        legacy = _legacy_sections(data, allowed_evidence)
        merged = {k: v for k, v in data.items() if k != "sections"}
        for key, items in legacy.items():
            merged.setdefault(key, items)
        data = merged

    cv = StandardCV()

    # --- contact ------------------------------------------------------------
    cv.contact = _merge_contact(data.get("contact"), profile)

    # --- summary --------------------------------------------------------------
    summary = _clean(data.get("summary")) or ""
    cv.summary = summary if len(summary.split()) >= 5 else _fallback_summary(
        activities, language
    )

    # --- canonical sections -----------------------------------------------------
    cv.experience = [
        item
        for item in (_build_experience(r, allowed_evidence) for r in _as_list(data.get("experience")))
        if item
    ]
    cv.projects = [
        item
        for item in (_build_project(r, allowed_evidence) for r in _as_list(data.get("projects")))
        if item
    ]
    cv.certifications = [
        item
        for item in (
            _build_certification(r, allowed_evidence) for r in _as_list(data.get("certifications"))
        )
        if item
    ]
    cv.achievements = [
        item
        for item in (
            _build_achievement(r, allowed_evidence) for r in _as_list(data.get("achievements"))
        )
        if item
    ]
    cv.volunteer = [
        item
        for item in (_build_volunteer(r, allowed_evidence) for r in _as_list(data.get("volunteer")))
        if item
    ]

    cv.education = _profile_education(profile, allowed_evidence)
    ai_education = [
        item
        for item in (_build_education(r, allowed_evidence) for r in _as_list(data.get("education")))
        if item
    ]
    seen_degrees = {e.degree.lower() for e in cv.education}
    cv.education.extend(e for e in ai_education if e.degree.lower() not in seen_degrees)

    cv.skills = _build_skill_groups(data.get("skills"), profile)
    cv.languages = [
        item
        for item in (_build_language(r) for r in _as_list(data.get("languages")))
        if item
    ]

    # --- ordering (most recent first where dates exist) ---------------------------
    cv.experience.sort(key=lambda e: _date_sort_key(e.start_date or e.period), reverse=True)
    cv.projects.sort(key=lambda p: _date_sort_key(p.period), reverse=True)

    # --- metadata ---------------------------------------------------------------
    cv.meta = CVMeta(
        language=language,
        target_role=_clean(target_role),
        job_tailored=bool((job_description or "").strip()),
        generated_at=datetime.now(timezone.utc).isoformat(),
        model=model_name,
        activity_count=len(activities),
    )

    logger.info(
        "CV normalized: %d experience, %d education, %d projects, %d skill groups "
        "(language=%s, tailored=%s)",
        len(cv.experience),
        len(cv.education),
        len(cv.projects),
        len(cv.skills),
        language,
        cv.meta.job_tailored,
    )
    return cv


def validate_language(language: str) -> str:
    lang = (language or "en").strip().lower()
    if lang not in Config.ALLOWED_LANGUAGES:
        raise UnsupportedLanguageError(
            f"Unsupported language '{language}'. Allowed: {sorted(Config.ALLOWED_LANGUAGES)}"
        )
    return lang
