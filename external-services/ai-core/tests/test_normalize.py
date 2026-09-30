"""Tests for the deterministic normalizer: LLM dict -> StandardCV."""

from fakes import activity_payload

from vithey_ai import ExtractedActivity, UserProfile
from vithey_ai.normalize import normalize_cv


def make_activities():
    return [ExtractedActivity(**activity_payload(source_id="post_1"))]


def test_standard_shape_is_always_complete():
    cv = normalize_cv({}, make_activities(), None, "", "", "en", "m")

    assert cv.contact is not None
    assert cv.summary  # fallback summary
    for section in (
        cv.experience,
        cv.education,
        cv.projects,
        cv.skills,
        cv.certifications,
        cv.languages,
        cv.achievements,
        cv.volunteer,
    ):
        assert isinstance(section, list)


def test_profile_contact_wins_over_llm():
    profile = UserProfile(full_name="Sok Dara", email="dara@example.com")
    data = {"contact": {"full_name": "WRONG NAME", "email": "ai@fake.com"}}

    cv = normalize_cv(data, make_activities(), profile, "", "", "en", "m")

    assert cv.contact.full_name == "Sok Dara"
    assert cv.contact.email == "dara@example.com"


def test_unknown_headings_are_dropped_in_legacy_shape():
    legacy = {
        "summary": "A solid summary worth keeping.",
        "sections": [
            {
                "heading": "Projects",
                "items": [{"title": "Recycling Pickup App", "bullet": "Built it."}],
            },
            {"heading": "Random Nonsense", "items": [{"title": "X"}]},
        ],
    }

    cv = normalize_cv(legacy, make_activities(), None, "", "", "en", "m")

    assert cv.projects[0].name == "Recycling Pickup App"
    assert cv.projects[0].bullets == ["Built it."]
    assert len(cv.projects) == 1


def test_unusual_but_reasonable_headings_are_understood():
    legacy = {
        "summary": "Summary that is long enough to survive the fallback check.",
        "sections": [
            {"heading": "My Cool Projects", "items": [{"title": "App X"}]},
            {"heading": "Where I Worked", "items": [{"title": "Intern", "bullet": "did stuff"}]},
            {"heading": "Certificates Earned", "items": [{"name": "AWS CCP"}]},
        ],
    }

    cv = normalize_cv(legacy, make_activities(), None, "", "", "en", "m")

    assert [p.name for p in cv.projects] == ["App X"]
    assert [e.title for e in cv.experience] == ["Intern"]
    assert [c.name for c in cv.certifications] == ["AWS CCP"]


def test_evidence_filtered_to_known_source_ids():
    data = {
        "summary": "Experienced builder with shipped projects.",
        "projects": [
            {
                "name": "App",
                "bullets": ["Built it."],
                "evidence": ["post_1", "hacked_id"],
            }
        ],
    }

    cv = normalize_cv(data, make_activities(), None, "", "", "en", "m")

    assert cv.projects[0].evidence == ["post_1"]


def test_string_coerced_into_bullets():
    data = {
        "summary": "Summary here that has enough words to survive normalization.",
        "experience": [
            {"title": "Intern", "bullet": "Did the work every single day"}
        ],
    }

    cv = normalize_cv(data, make_activities(), None, "", "", "en", "m")

    assert cv.experience[0].bullets == ["Did the work every single day"]


def test_fallback_summary_when_model_gives_none():
    cv = normalize_cv({"summary": ""}, make_activities(), None, "", "", "en", "m")

    assert "hands-on projects" in cv.summary.lower() or "projects" in cv.summary.lower()
    assert "Mobile Development" in cv.summary


def test_profile_skills_added_as_additional_group():
    profile = UserProfile(skills=["Public Speaking"])
    data = {
        "summary": "Summary with plenty of words to pass the length check.",
        "skills": [{"category": "Technical", "skills": ["Flutter"]}],
    }

    cv = normalize_cv(data, make_activities(), profile, "", "", "en", "m")

    categories = {g.category: g.skills for g in cv.skills}
    assert categories["Technical"] == ["Flutter"]
    assert "Public Speaking" in categories["Additional"]


def test_languages_section_is_populated():
    data = {
        "summary": "Summary long enough to bypass the deterministic fallback path.",
        "languages": [
            {"name": "Khmer", "proficiency": "Native"},
            {"name": "English", "proficiency": "Professional"},
            {"name": "", "proficiency": None},  # dropped
        ],
    }

    cv = normalize_cv(data, make_activities(), None, "", "", "en", "m")

    assert [(l.name, l.proficiency) for l in cv.languages] == [
        ("Khmer", "Native"),
        ("English", "Professional"),
    ]


def test_meta_records_tailoring_and_counts():
    cv = normalize_cv(
        {}, make_activities(), None, "Backend Intern", "Go + Postgres role", "km", "deepseek-x"
    )

    assert cv.meta.target_role == "Backend Intern"
    assert cv.meta.job_tailored is True
    assert cv.meta.language == "km"
    assert cv.meta.model == "deepseek-x"
    assert cv.meta.activity_count == 1


def test_experience_sorted_most_recent_first():
    acts = make_activities()
    data = {
        "summary": "Summary long enough to bypass the fallback path entirely.",
        "experience": [
            {"title": "Old Job", "start_date": "2022-01-01"},
            {"title": "New Job", "start_date": "2024-06-01"},
        ],
    }

    cv = normalize_cv(data, acts, None, "", "", "en", "m")

    assert cv.experience[0].title == "New Job"
    assert cv.experience[1].title == "Old Job"
