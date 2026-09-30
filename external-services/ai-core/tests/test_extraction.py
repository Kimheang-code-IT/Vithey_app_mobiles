import pytest
from fakes import MockDeepSeekClient, activity_payload

from vithey_ai import ExtractedActivity
from vithey_ai.config import Config
from vithey_ai.errors import AIResponseValidationError, EmptyInputError
from vithey_ai.extraction import ExtractionService


def make_service(client, **config_overrides):
    config = Config()
    for key, value in config_overrides.items():
        setattr(config, key, value)
    return ExtractionService(client, config)


def test_extract_returns_activity():
    client = MockDeepSeekClient(responses=[activity_payload(source_id="wrong_id")])
    service = make_service(client)

    activity = service.extract(
        content="We built a recycling pickup app at RUPP.",
        source_id="post_123",
    )

    assert isinstance(activity, ExtractedActivity)
    assert activity.title == "Recycling Pickup App"
    assert activity.source_id == "post_123"  # forced
    assert activity.tools == ["Flutter", "Firebase"]


def test_extract_sends_content_and_source_id():
    client = MockDeepSeekClient(
        responses=[activity_payload(source_id="post_1", title="T", summary="S")]
    )
    service = make_service(client)

    service.extract(content="Hello world", source_id="post_1")

    system_prompt, user_prompt = client.calls[0]
    assert "Hello world" in user_prompt
    assert "post_1" in user_prompt
    assert "extracts structured information" in system_prompt


def test_extract_truncates_oversized_content():
    client = MockDeepSeekClient(
        responses=[activity_payload(title="T", summary="S")]
    )
    service = make_service(client, MAX_CONTENT_CHARS=10)

    service.extract(content="x" * 500, source_id="post_1")

    _, user_prompt = client.calls[0]
    assert "truncated" in user_prompt
    assert len([c for c in user_prompt if c == "x"]) <= 10


def test_extract_empty_content_raises():
    service = make_service(MockDeepSeekClient())

    with pytest.raises(EmptyInputError):
        service.extract(content="   ", source_id="post_1")


def test_extract_invalid_json_raises():
    client = MockDeepSeekClient(
        errors=[AIResponseValidationError("DeepSeek returned invalid JSON.")]
    )
    service = make_service(client)

    with pytest.raises(AIResponseValidationError):
        service.extract(content="x", source_id="post_1")


def test_extract_missing_required_fields_raises():
    # Missing title/summary -> schema validation failure
    client = MockDeepSeekClient(responses=[{"activity_type": "project"}])
    service = make_service(client)

    with pytest.raises(AIResponseValidationError):
        service.extract(content="x", source_id="post_1")


def test_identical_content_hits_cache():
    payload = activity_payload()
    client = MockDeepSeekClient(responses=[payload])  # only one queued response
    service = make_service(client)

    first = service.extract(content="same text", source_id="post_A")
    second = service.extract(content="same text", source_id="post_B")

    assert len(client.calls) == 1  # second call served from cache
    assert second.source_id == "post_B"
    assert first.title == second.title


def test_cache_disabled_makes_two_calls():
    payload = activity_payload()
    client = MockDeepSeekClient(responses=[payload, payload])
    service = make_service(client, CACHE_ENABLED=False)

    service.extract(content="same text", source_id="post_A")
    service.extract(content="same text", source_id="post_B")

    assert len(client.calls) == 2


def test_enforce_post_limit():
    service = make_service(MockDeepSeekClient(), MAX_POSTS_PER_BUILD=2)

    service.enforce_post_limit(2)  # ok

    from vithey_ai.errors import InputLimitError

    with pytest.raises(InputLimitError):
        service.enforce_post_limit(3)
