import pytest
from fakes import MockDeepSeekClient, activity_payload, standard_cv_response

from vithey_ai import ExtractedActivity, RawPost, StandardCV, UserProfile, VitheyAI
from vithey_ai.config import Config
from vithey_ai.errors import AIClientError, InputLimitError


def make_ai(client):
    config = Config()
    config.DEEPSEEK_MODEL = "test-model"
    return (
        VitheyAI(api_key="test-key", config=config, client=client),
        client,
    )


def test_build_cv_from_posts_skips_failures():
    """One post fails extraction -> logged+skipped, CV still generated."""
    ai, client = make_ai(
        MockDeepSeekClient(
            responses=[
                activity_payload(source_id="post_1", title="App One"),
                standard_cv_response(),
            ]
        )
    )

    cv = ai.build_cv_from_raw_posts(
        posts=[
            {"source_id": "post_1", "content": "Built app one."},
            {"source_id": "post_bad", "content": ""},  # empty -> fails inside extract
        ],
        target_role="Intern",
        language="en",
    )

    assert isinstance(cv, StandardCV)
    assert cv.meta.activity_count == 1


def test_build_cv_on_error_fail_raises():
    ai, _ = make_ai(MockDeepSeekClient())

    with pytest.raises(Exception):
        ai.build_cv_from_raw_posts(
            posts=[{"source_id": "post_1", "content": ""}],
            on_error="fail",
        )


def test_build_cv_all_posts_failing_raises():
    ai, _ = make_ai(MockDeepSeekClient(errors=[AIClientError("down"), AIClientError("down")]))

    with pytest.raises(Exception) as excinfo:
        ai.build_cv_from_raw_posts(
            posts=[{"source_id": "p1", "content": "x"}],
            on_error="skip",
        )
    assert "No valid activities" in str(excinfo.value)


def test_build_cv_enforces_post_cap(monkeypatch):
    config = Config()
    config.DEEPSEEK_MODEL = "test-model"
    config.MAX_POSTS_PER_BUILD = 2
    ai = VitheyAI(
        api_key="k",
        config=config,
        client=MockDeepSeekClient(responses=[activity_payload()]),
    )

    with pytest.raises(InputLimitError):
        ai.extract_activities([{"source_id": f"p{i}", "content": "x"} for i in range(3)])


def test_build_cv_merges_duplicate_posts():
    """Same project posted twice -> one merged activity in the prompt."""
    ai, client = make_ai(
        MockDeepSeekClient(
            responses=[
                activity_payload(source_id="post_1", title="Recycling Pickup App"),
                activity_payload(source_id="post_2", title="Recycling Pickup App"),
                standard_cv_response(),
            ]
        )
    )

    cv = ai.build_cv_from_raw_posts(
        posts=[
            {"source_id": "post_1", "content": "Built the recycling app."},
            {"source_id": "post_2", "content": "Built the recycling app."},
        ],
        language="en",
    )

    assert cv.meta.activity_count == 1
    _, user_prompt = client.calls[-1]
    assert "additional_source_ids" in user_prompt


def test_generate_cv_accepts_profile_dict_and_reports_quality():
    ai, client = make_ai(
        MockDeepSeekClient(responses=[standard_cv_response()])
    )
    activities = [ExtractedActivity(**activity_payload())]

    cv = ai.generate_cv(
        activities=activities,
        profile={"full_name": "Sok Dara", "email": "dara@example.com"},
        language="en",
    )
    report = ai.quality_report(cv)

    assert cv.contact.full_name == "Sok Dara"
    assert 0 <= report.score <= 100
    assert report.grade in {"excellent", "good", "fair", "weak"}


def test_unsupported_language_rejected():
    ai, _ = make_ai(MockDeepSeekClient())

    from vithey_ai.errors import UnsupportedLanguageError

    with pytest.raises(UnsupportedLanguageError):
        ai.generate_cv(
            activities=[ExtractedActivity(**activity_payload())],
            language="fr",
        )


def test_extract_activities_batch_result_shape():
    ai, client = make_ai(
        MockDeepSeekClient(
            responses=[
                activity_payload(source_id="post_1", title="A"),
                activity_payload(source_id="post_2", title="B"),
            ]
        )
    )

    result = ai.extract_activities(
        [
            RawPost(source_id="post_1", content="one"),
            RawPost(source_id="post_2", content="two"),
            RawPost(source_id="post_3", content=""),  # fails
        ]
    )

    assert result.ok_count == 2
    assert result.failure_count == 1
    assert result.failures[0].source_id == "post_3"
    # Titles differ -> no merging
    assert len(result.activities) == 2
