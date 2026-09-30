"""Flutter /api/v1/ai/** contract smoke (in-memory, no Postgres)."""

import uuid

import pytest

fastapi = pytest.importorskip("fastapi")
from fastapi.testclient import TestClient  # noqa: E402

from fakes import standard_cv_response  # noqa: E402

from vithey_ai.api.app import create_app  # noqa: E402
from vithey_ai.config import Config  # noqa: E402
from vithey_ai.schemas import CVQualityReport, StandardCV  # noqa: E402


class FakeFacade:
    def build_cv_from_raw_posts(self, posts, **kwargs):
        cv = StandardCV.model_validate(standard_cv_response())
        cv.contact.full_name = "Sok Dara"
        return cv

    def quality_report(self, cv):
        return CVQualityReport(score=90, grade="excellent")


@pytest.fixture()
def client(monkeypatch):
    monkeypatch.setattr(Config, "DEEPSEEK_API_KEY", "test-key", raising=False)
    monkeypatch.setattr(Config, "DATABASE_URL", "", raising=False)
    app = create_app(ai=FakeFacade())
    return TestClient(app)


def test_chat_and_sessions(client):
    user = str(uuid.uuid4())
    headers = {"X-User-Id": user}
    resp = client.post(
        "/api/v1/ai/chat",
        headers=headers,
        json={"message": "How do I write a CV?", "topic": "CV"},
    )
    assert resp.status_code == 200
    body = resp.json()
    assert body["error"] is None
    assert body["data"]["reply"]
    session_id = body["data"]["session_id"]
    message_id = body["data"]["message_id"]

    sessions = client.get("/api/v1/ai/sessions", headers=headers)
    assert sessions.status_code == 200
    assert sessions.json()["data"]

    regen = client.post(
        f"/api/v1/ai/messages/{message_id}/regenerate",
        headers=headers,
    )
    assert regen.status_code == 200, regen.text
    assert regen.json()["data"]["reply"]

    msgs = client.get(
        f"/api/v1/ai/sessions/{session_id}/messages",
        headers=headers,
    )
    assert msgs.status_code == 200
    assert len(msgs.json()["data"]) >= 2


def test_cv_suggest(client):
    resp = client.post(
        "/api/v1/ai/cv/suggest",
        headers={"X-User-Id": str(uuid.uuid4())},
        json={"section": "summary", "original_text": "I build apps."},
    )
    assert resp.status_code == 200
    assert resp.json()["data"]["suggested_text"]


def test_chat_requires_auth(client):
    resp = client.post("/api/v1/ai/chat", json={"message": "hi"})
    assert resp.status_code == 401
    assert resp.json()["error"]["code"] == "UNAUTHORIZED"
