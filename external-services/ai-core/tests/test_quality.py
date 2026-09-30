from vithey_ai.quality import score_cv
from vithey_ai.schemas import (
    ContactInfo,
    EducationItem,
    ExperienceItem,
    ProjectItem,
    SkillGroup,
    StandardCV,
    UserProfile,
)

SUMMARY = (
    "Software engineering student with two shipped mobile projects, strong "
    "Flutter and Firebase skills, and a passion for clean code."
)


def make_cv(**overrides) -> StandardCV:
    cv = StandardCV(
        contact=ContactInfo(
            full_name="Sok Dara",
            email="dara@example.com",
            phone="+855 12 345 678",
        ),
        summary=SUMMARY,
        experience=[
            ExperienceItem(title="Intern", organization="ACLEDA", evidence=["post_1"])
        ],
        education=[EducationItem(degree="BSc Computer Science", institution="RUPP")],
        projects=[ProjectItem(name="Recycling App", evidence=["post_1"])],
        skills=[SkillGroup(category="Technical", skills=["Flutter", "Firebase", "Git"])],
    )
    for key, value in overrides.items():
        setattr(cv, key, value)
    return cv


def test_complete_cv_scores_high():
    report = score_cv(make_cv())

    assert report.score >= 85
    assert report.grade == "excellent"
    assert report.issues == []


def test_missing_contact_and_summary_drop_score():
    cv = make_cv()
    cv.contact = ContactInfo()
    cv.summary = ""

    report = score_cv(cv)

    codes = {i.code for i in report.issues}
    assert {"MISSING_NAME", "MISSING_CONTACT"} <= codes
    assert report.grade in {"good", "fair"}


def test_empty_history_flags_weak():
    cv = StandardCV(contact=ContactInfo(full_name="X"), summary=SUMMARY)

    report = score_cv(cv)

    codes = {i.code for i in report.issues}
    assert "EMPTY_HISTORY" in codes
    assert "NO_SKILLS" in codes
    assert report.grade == "weak"


def test_partial_contact_gives_half_points():
    cv = make_cv()
    cv.contact = ContactInfo(full_name="Sok Dara", email="dara@example.com")

    report = score_cv(cv)

    assert any(i.code == "PARTIAL_CONTACT" for i in report.issues)
