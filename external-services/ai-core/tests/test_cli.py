import json

import pytest

import main
from vithey_ai.config import Config
from vithey_ai.schemas import (
    CVQualityReport,
    ExtractedActivity,
    RawPost,
    StandardCV,
    UserProfile,
)


class FakeVitheyAI:
    """Fake facade so CLI tests never hit the network."""

    calls = []

    def __init__(self, api_key=None):
        self.api_key = api_key

    def extract_activity(self, content, source_id, source_type="post"):
        return ExtractedActivity(
            activity_type="project",
            title="Recycling Pickup App",
            summary=content,
            source_id=source_id,
        )

    def quality_report(self, cv):
        return CVQualityReport(score=80, grade="good")

    def generate_cv(self, activities, profile=None, target_role="", job_description="", language="en"):
        return StandardCV(summary="Generated summary")

    def build_cv_from_raw_posts(
        self,
        posts,
        profile=None,
        target_role="",
        job_description="",
        language="en",
        on_error="skip",
    ):
        FakeVitheyAI.calls.append(
            {
                "posts": posts,
                "profile": profile,
                "target_role": target_role,
                "job_description": job_description,
                "language": language,
                "on_error": on_error,
            }
        )
        return StandardCV(summary="Generated summary")


@pytest.fixture(autouse=True)
def use_fake_facade(monkeypatch):
    monkeypatch.setattr(main, "VitheyAI", FakeVitheyAI)


def test_extract_outputs_json(capsys):
    rc = main.main(["extract", "--content", "hello world", "--source-id", "post_1"])

    assert rc == 0
    data = json.loads(capsys.readouterr().out)
    assert data["source_id"] == "post_1"
    assert data["title"] == "Recycling Pickup App"


def test_generate_from_activities(tmp_path, capsys):
    activities_file = tmp_path / "activities.json"
    activities_file.write_text(
        json.dumps(
            [
                {
                    "activity_type": "project",
                    "title": "Recycling Pickup App",
                    "summary": "Built a recycling pickup app.",
                    "source_id": "post_1",
                }
            ]
        ),
        encoding="utf-8",
    )

    rc = main.main(
        [
            "generate",
            "--activities",
            str(activities_file),
            "--target-role",
            "Software Engineer Intern",
            "--with-quality",
        ]
    )

    assert rc == 0
    data = json.loads(capsys.readouterr().out)
    assert data["cv"]["summary"] == "Generated summary"
    assert data["quality"]["score"] == 80


def test_generate_from_raw_posts(tmp_path, capsys):
    posts_file = tmp_path / "posts.json"
    posts_file.write_text(
        json.dumps([{"source_id": "post_1", "content": "Built a smart campus app."}]),
        encoding="utf-8",
    )

    rc = main.main(["generate", "--posts", str(posts_file), "--language", "en"])

    assert rc == 0
    data = json.loads(capsys.readouterr().out)
    assert data["cv"]["summary"] == "Generated summary"


def test_generate_with_profile_and_job(tmp_path, capsys):
    posts_file = tmp_path / "posts.json"
    posts_file.write_text(
        json.dumps([{"source_id": "post_1", "content": "Built a smart campus app."}]),
        encoding="utf-8",
    )
    profile_file = tmp_path / "profile.json"
    profile_file.write_text(
        json.dumps({"full_name": "Sok Dara", "email": "dara@example.com"}),
        encoding="utf-8",
    )
    job_file = tmp_path / "job.txt"
    job_file.write_text("Flutter intern role.", encoding="utf-8")

    FakeVitheyAI.calls.clear()
    rc = main.main(
        [
            "generate",
            "--posts",
            str(posts_file),
            "--profile",
            str(profile_file),
            "--job-file",
            str(job_file),
            "--on-error",
            "fail",
        ]
    )

    assert rc == 0
    out = json.loads(capsys.readouterr().out)
    assert out["cv"]["summary"] == "Generated summary"

    call = FakeVitheyAI.calls[0]
    assert isinstance(call["posts"][0], RawPost)
    assert isinstance(call["profile"], UserProfile)
    assert call["profile"].full_name == "Sok Dara"
    assert call["job_description"] == "Flutter intern role."
    assert call["on_error"] == "fail"


def test_invalid_json_file_is_reported(capsys, tmp_path):
    bad_file = tmp_path / "bad.json"
    bad_file.write_text("{not valid json", encoding="utf-8")

    rc = main.main(["generate", "--activities", str(bad_file)])

    assert rc == 1
    assert "invalid JSON" in capsys.readouterr().err


def test_missing_activities_file_is_reported(capsys, tmp_path):
    rc = main.main(["generate", "--activities", str(tmp_path / "nope.json")])

    assert rc == 1
    assert "file not found" in capsys.readouterr().err


def test_missing_api_key_returns_error(capsys, monkeypatch):
    from vithey_ai import VitheyAI as RealVitheyAI

    monkeypatch.setattr(Config, "DEEPSEEK_API_KEY", "")
    monkeypatch.setattr(main, "VitheyAI", RealVitheyAI)

    rc = main.main(["extract", "--content", "x", "--source-id", "post_1"])

    assert rc == 1
    assert "DEEPSEEK_API_KEY" in capsys.readouterr().err
