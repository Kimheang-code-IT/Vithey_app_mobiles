"""Tests for the FastAPI wrapper (envelope, endpoints, rate limiting)."""

import pytest

fastapi = pytest.importorskip("fastapi")
from fastapi.testclient import TestClient  # noqa: E402

from fakes import activity_payload, standard_cv_response  # noqa: E402

from vithey_ai.api.app import create_app  # noqa: E402
from vithey_ai.config import Config  # noqa: E402
from vithey_ai.errors import UnsupportedLanguageError  # noqa: E402
from vithey_ai.schemas import (  # noqa: E402
    CVQualityReport,
    ExtractedActivity,
    ExtractionBatchResult,
    StandardCV,
)


class FakeFacade:
    def __init__(self):
        self.rate_limit_after = None

    def extract_activity(self, content, source_id, source_type="post"):
        return ExtractedActivity(**activity_payload(source_id=source_id))

    def extract_activities(self, posts, on_error="skip"):
        return ExtractionBatchResult(
            activities=[
                ExtractedActivity(**activity_payload(source_id=p["source_id"]))
                for p in posts
            ]
        )

    def generate_cv(self, activities, profile=None, target_role="", job_description="", language="en"):
        if language == "fr":
            raise UnsupportedLanguageError("Unsupported language 'fr'.")
        cv = StandardCV.model_validate(standard_cv_response())
        cv.contact.full_name = "Sok Dara"
        return cv

    def build_cv_from_raw_posts(self, posts, **kwargs):
        if kwargs.get("language") == "fr":
            raise UnsupportedLanguageError("Unsupported language 'fr'.")
        cv = StandardCV.model_validate(standard_cv_response())
        cv.contact.full_name = "Sok Dara"
        return cv

    def quality_report(self, cv):
        return CVQualityReport(score=90, grade="excellent")


@pytest.fixture()
def client(monkeypatch):
    monkeypatch.setattr(Config, "DEEPSEEK_API_KEY", "test-key", raising=False)
    app = create_app(ai=FakeFacade())
    return TestClient(app)


def test_health_envelope(client):
    resp = client.get("/health")

    assert resp.status_code == 200
    body = resp.json()
    assert body["success"] is True
    assert body["data"]["status"] == "healthy"
    assert body["data"]["service"] == "vithey-ai"
    assert body["meta"]["service"] == "vithey-ai"
    assert resp.headers["X-Request-ID"]


def test_extract_endpoint_envelope(client):
    resp = client.post(
        "/api/v1/activities/extract",
        json={"content": "Built a recycling app.", "source_id": "post_123"},
    )

    assert resp.status_code == 200
    body = resp.json()
    assert body["success"] is True
    assert body["data"]["activity"]["source_id"] == "post_123"


def test_extract_batch_endpoint(client):
    resp = client.post(
        "/api/v1/activities/extract-batch",
        json={
            "posts": [
                {"source_id": "p1", "content": "one"},
                {"source_id": "p2", "content": "two"},
            ]
        },
    )

    assert resp.status_code == 200
    data = resp.json()["data"]
    assert data["ok_count"] == 2


def test_generate_cv_returns_cv_and_quality(client):
    resp = client.post(
        "/api/v1/cv/generate",
        json={
            "posts": [{"source_id": "post_1", "content": "Built a smart campus app."}],
            "profile": {"full_name": "Sok Dara"},
            "target_role": "Mobile Intern",
            "language": "en",
        },
    )

    assert resp.status_code == 200
    data = resp.json()["data"]
    assert data["cv"]["contact"]["full_name"] == "Sok Dara"
    assert data["cv"]["meta"]["language"] == "en"
    assert data["quality"]["score"] == 90
    # Standard CV always carries the canonical sections.
    for key in (
        "experience",
        "education",
        "projects",
        "skills",
        "certifications",
        "languages",
        "achievements",
        "volunteer",
    ):
        assert key in data["cv"]


def test_generate_cv_rejects_both_posts_and_activities(client):
    resp = client.post(
        "/api/v1/cv/generate",
        json={
            "posts": [{"source_id": "p1", "content": "x"}],
            "activities": [],
        },
    )

    assert resp.status_code == 400
    body = resp.json()
    assert body["success"] is False
    assert body["error"]["code"] == "INVALID_INPUT"


def test_generate_cv_maps_unsupported_language(client):
    resp = client.post(
        "/api/v1/cv/generate",
        json={"posts": [{"source_id": "p1", "content": "x"}], "language": "fr"},
    )

    assert resp.status_code == 400
    assert resp.json()["error"]["code"] == "UNSUPPORTED_LANGUAGE"


def test_generate_cv_requires_posts_or_activities(client):
    resp = client.post("/api/v1/cv/generate", json={})

    assert resp.status_code == 400


def test_per_client_rate_limiting(monkeypatch):
    config = Config()
    config.DEEPSEEK_API_KEY = "test-key"
    config.API_RATE_LIMIT_PER_MINUTE = 2
    app = create_app(config=config, ai=FakeFacade())
    limited_client = TestClient(app)

    ok_codes = []
    for _ in range(3):
        resp = limited_client.post(
            "/api/v1/activities/extract",
            json={"content": "hi", "source_id": "p"},
        )
        ok_codes.append(resp.status_code)

    assert ok_codes[:2] == [200, 200]
    assert ok_codes[2] == 429
    body = limited_client.post(
        "/api/v1/activities/extract", json={"content": "hi", "source_id": "p"}
    ).json()
    assert body["error"]["code"] == "RATE_LIMIT_EXCEEDED"


def test_body_size_limit(monkeypatch):
    config = Config()
    config.DEEPSEEK_API_KEY = "test-key"
    config.API_MAX_BODY_BYTES = 10
    app = create_app(config=config, ai=FakeFacade())
    tiny_client = TestClient(app)

    resp = tiny_client.request(
        "POST",
        "/api/v1/activities/extract",
        content=b"x" * 100,
        headers={"Content-Type": "application/json"},
    )

    assert resp.status_code == 413
    assert resp.json()["error"]["code"] == "REQUEST_TOO_LARGE"
