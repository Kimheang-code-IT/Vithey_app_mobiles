"""Tests for the DeepSeek HTTP client wrapper (retry/backoff/rate limit)."""

import pytest

from vithey_ai.config import Config
from vithey_ai.deepseek_client import DeepSeekClient
from vithey_ai.errors import AIClientError


def make_client(**overrides) -> DeepSeekClient:
    config = Config()
    config.DEEPSEEK_API_KEY = "test-key"
    for key, value in overrides.items():
        setattr(config, key, value)
    return DeepSeekClient(config)


def fake_create_factory(fail_times: int):
    """Return a fake chat.completions.create that fails N times then succeeds."""
    state = {"calls": 0}

    def fake_create(**kwargs):
        state["calls"] += 1
        if state["calls"] <= fail_times:
            raise ConnectionError("transient network blip")

        class Msg:
            content = '{"ok": true}'

        class Choice:
            message = Msg()

        class Response:
            choices = [Choice()]

        return Response()

    return fake_create, state


def test_retry_succeeds_after_transient_failures(monkeypatch):
    client = make_client(MAX_RETRIES=2, RETRY_BACKOFF_SECONDS=0)
    monkeypatch.setattr("time.sleep", lambda s: None)
    fake_create, state = fake_create_factory(fail_times=2)
    monkeypatch.setattr(
        client.client.chat.completions, "create", fake_create
    )

    result = client.ask_json("system", "user")

    assert result == {"ok": True}
    assert state["calls"] == 3


def test_retry_exhaustion_raises_client_error(monkeypatch):
    client = make_client(MAX_RETRIES=1, RETRY_BACKOFF_SECONDS=0)
    monkeypatch.setattr("time.sleep", lambda s: None)
    fake_create, state = fake_create_factory(fail_times=99)
    monkeypatch.setattr(
        client.client.chat.completions, "create", fake_create
    )

    with pytest.raises(AIClientError):
        client.ask_json("system", "user")

    assert state["calls"] == 2  # 1 try + 1 retry


def test_rate_limiter_blocks_flood():
    client = make_client(RATE_LIMIT_MAX_CALLS=2, RATE_LIMIT_WINDOW_SECONDS=60)

    client.rate_limiter.acquire(now=0.0)
    client.rate_limiter.acquire(now=0.1)

    from vithey_ai.errors import RateLimitError

    with pytest.raises(RateLimitError):
        client.rate_limiter.acquire(now=0.2)


def test_invalid_json_not_retried(monkeypatch):
    client = make_client(MAX_RETRIES=3, RETRY_BACKOFF_SECONDS=0)
    monkeypatch.setattr("time.sleep", lambda s: None)

    def fake_create(**kwargs):
        class Msg:
            content = "{not json"

        class Choice:
            message = Msg()

        class Response:
            choices = [Choice()]

        return Response()

    monkeypatch.setattr(client.client.chat.completions, "create", fake_create)

    from vithey_ai.errors import AIResponseValidationError

    with pytest.raises(AIResponseValidationError):
        client.ask_json("system", "user")
