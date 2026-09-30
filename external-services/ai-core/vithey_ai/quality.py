"""Deterministic CV quality scoring.

The report tells the app how complete a generated CV is and which fields the
user should fill in. Pure function -- no LLM involved, so it is cheap to run
on every read.
"""

from .schemas import CVQualityReport, QualityIssue, StandardCV

# Weights per dimension (total 100).
_WEIGHTS = {
    "contact_name": 10,
    "contact_channels": 15,
    "summary": 20,
    "experience": 20,
    "projects": 10,
    "education": 10,
    "skills": 10,
    "evidence": 5,
}

_MIN_SUMMARY_WORDS = 12


def score_cv(cv: StandardCV) -> CVQualityReport:
    issues: list = []
    points: dict = {key: 0 for key in _WEIGHTS}

    # --- contact -------------------------------------------------------------
    if cv.contact.full_name:
        points["contact_name"] = _WEIGHTS["contact_name"]
    else:
        issues.append(
            QualityIssue(
                code="MISSING_NAME",
                message="Add your full name so employers know who the CV belongs to.",
                field="contact.full_name",
            )
        )

    channels = sum(
        bool(v) for v in (cv.contact.email, cv.contact.phone)
    )
    if channels >= 2:
        points["contact_channels"] = _WEIGHTS["contact_channels"]
    elif channels == 1:
        points["contact_channels"] = _WEIGHTS["contact_channels"] // 2
        issues.append(
            QualityIssue(
                code="PARTIAL_CONTACT",
                message="Add both an email and a phone number for recruiter reach.",
                field="contact",
            )
        )
    else:
        issues.append(
            QualityIssue(
                code="MISSING_CONTACT",
                message="No email or phone on the CV -- add at least one.",
                field="contact",
            )
        )

    # --- summary ----------------------------------------------------------------
    word_count = len(cv.summary.split())
    if word_count >= _MIN_SUMMARY_WORDS:
        points["summary"] = _WEIGHTS["summary"]
    elif word_count > 0:
        points["summary"] = _WEIGHTS["summary"] // 2
        issues.append(
            QualityIssue(
                code="SHORT_SUMMARY",
                message="Professional summary is too short -- aim for 2-3 sentences.",
                field="summary",
            )
        )
    else:
        issues.append(
            QualityIssue(
                code="MISSING_SUMMARY",
                message="The CV has no professional summary.",
                field="summary",
            )
        )

    # --- sections -----------------------------------------------------------------
    def _section_points(name: str, count: int, min_count: int):
        if count >= min_count:
            return _WEIGHTS[name]
        if count > 0:
            return _WEIGHTS[name] // 2
        return 0

    points["experience"] = _section_points("experience", len(cv.experience), 1)
    points["projects"] = _section_points("projects", len(cv.projects), 1)
    points["education"] = _section_points("education", len(cv.education), 1)

    skill_count = sum(len(g.skills) for g in cv.skills)
    if skill_count >= 5:
        points["skills"] = _WEIGHTS["skills"]
    elif skill_count > 0:
        points["skills"] = _WEIGHTS["skills"] // 2
    if not skill_count:
        issues.append(
            QualityIssue(
                code="NO_SKILLS",
                message="No skills listed -- skills are the first thing recruiters scan.",
                field="skills",
            )
        )
    if not cv.experience and not cv.projects:
        issues.append(
            QualityIssue(
                code="EMPTY_HISTORY",
                message="No work experience or projects yet -- post more activity or add them manually.",
                field="experience",
            )
        )
    if not cv.education:
        issues.append(
            QualityIssue(
                code="NO_EDUCATION",
                message="No education entries -- add your studies for a standard CV.",
                field="education",
            )
        )

    # --- evidence trail ---------------------------------------------------------------
    evidence_items = (
        len(cv.experience)
        + len(cv.projects)
        + len(cv.certifications)
        + len(cv.achievements)
        + len(cv.volunteer)
    )
    with_evidence = sum(
        bool(item.evidence)
        for items in (cv.experience, cv.projects, cv.certifications, cv.achievements, cv.volunteer)
        for item in items
    )
    if evidence_items == 0:
        points["evidence"] = _WEIGHTS["evidence"] // 2
    elif with_evidence == evidence_items:
        points["evidence"] = _WEIGHTS["evidence"]
    elif with_evidence > 0:
        points["evidence"] = _WEIGHTS["evidence"] // 2

    score = min(100, sum(points.values()))
    grade = (
        "excellent" if score >= 85
        else "good" if score >= 65
        else "fair" if score >= 40
        else "weak"
    )
    return CVQualityReport(score=score, grade=grade, issues=issues)
