import pytest
from fakes import MockDeepSeekClient, activity_payload, standard_cv_response

from vithey_ai import ExtractedActivity, StandardCV, UserProfile
from vithey_ai.config import Config
from vithey_ai.errors import AIResponseValidationError, EmptyInputError
from vithey_ai.generation import CVGenerationService


def make_activity(source_id="post_1", title="Recycling Pickup App"):
    return ExtractedActivity(**activity_payload(source_id=source_id, title=title))


def make_service(client):
    config = Config()
    config.DEEPSEEK_MODEL = "test-model"
    return CVGenerationService(client, config)


def test_generate_returns_standard_cv():
    client = MockDeepSeekClient(responses=[standard_cv_response()])
    service = make_service(client)

    cv = service.generate(activities=[make_activity()], language="en")

    assert isinstance(cv, StandardCV)
    # Canonical sections always present, in order:
    assert list(cv.section_lists().keys()) == [
        "Work Experience",
        "Education",
        "Projects",
        "Skills",
        "Certifications",
        "Languages",
        "Achievements",
        "Volunteer Work",
    ]
    assert cv.projects[0].name == "Recycling Pickup App"
    assert cv.meta.activity_count == 1
    assert cv.meta.language == "en"


def test_generate_requires_activities():
    service = make_service(MockDeepSeekClient())

    with pytest.raises(EmptyInputError):
        service.generate(activities=[])


def test_generate_prompt_includes_profile_job_language():
    client = MockDeepSeekClient(responses=[standard_cv_response()])
    service = make_service(client)
    profile = UserProfile(
        full_name="Sok Dara",
        email="dara@example.com",
        education=[{"degree": "BSc CS", "institution": "RUPP"}],
    )
    activity = make_activity(source_id="post_99", title="Smart Campus App")

    service.generate(
        activities=[activity],
        profile=profile,
        target_role="Mobile Intern",
        job_description="Flutter + Firebase internship.",
        language="km",
    )

    _, user_prompt = client.calls[0]
    assert "post_99" in user_prompt
    assert "Smart Campus App" in user_prompt
    assert "Sok Dara" in user_prompt
    assert "dara@example.com" in user_prompt
    assert "Mobile Intern" in user_prompt
    assert "Flutter + Firebase internship." in user_prompt
    assert "km" in user_prompt


def test_generate_marks_meta_as_tailored():
    client = MockDeepSeekClient(
        responses=[standard_cv_response(), standard_cv_response()]
    )
    service = make_service(client)

    cv_plain = service.generate(activities=[make_activity()])
    cv_tailored = service.generate(
        activities=[make_activity()], job_description="Looking for a Flutter dev."
    )

    assert cv_plain.meta.job_tailored is False
    assert cv_tailored.meta.job_tailored is True


def test_generate_invalid_json_raises():
    client = MockDeepSeekClient(
        errors=[AIResponseValidationError("DeepSeek returned invalid JSON.")]
    )
    service = make_service(client)

    with pytest.raises(AIResponseValidationError):
        service.generate(activities=[make_activity()])


def test_generate_survives_garbage_llm_output():
    """Even nonsense from the model must produce a VALID StandardCV."""
    client = MockDeepSeekClient(responses=[{"whatever": {"deeply": ["odd"]}}])
    service = make_service(client)

    cv = service.generate(activities=[make_activity()])

    assert isinstance(cv, StandardCV)
    assert cv.summary  # fallback summary kicked in
    assert cv.projects == []
