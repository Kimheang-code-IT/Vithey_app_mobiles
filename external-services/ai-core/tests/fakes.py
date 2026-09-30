"""Shared test doubles for the Vithey AI core test suite."""


class MockDeepSeekClient:
    """Fake DeepSeek client returning canned JSON responses.

    Queue responses with ``responses=[...]`` (each entry is a dict returned
    by ``ask_json``) or force failures with ``errors=[...]``.
    """

    def __init__(self, responses=None, errors=None):
        self.responses = list(responses or [])
        self.errors = list(errors or [])
        self.calls = []

    def ask_json(self, system_prompt, user_prompt):
        self.calls.append((system_prompt, user_prompt))
        if self.errors:
            raise self.errors.pop(0)
        if not self.responses:
            raise AssertionError(
                "MockDeepSeekClient.ask_json called with no responses queued."
            )
        return self.responses.pop(0)


def activity_payload(source_id="post_1", title="Recycling Pickup App", **overrides):
    """A valid raw extraction payload."""
    data = {
        "activity_type": "project",
        "title": title,
        "role": "Developer",
        "summary": "Built a recycling pickup app at RUPP using Flutter and Firebase.",
        "tools": ["Flutter", "Firebase"],
        "skills": ["Mobile Development"],
        "outcome": "Launched to 100 users",
        "date": "2024-06-01",
        "source_id": source_id,
    }
    data.update(overrides)
    return data


def standard_cv_response(source_id="post_1"):
    """A valid STANDARD CV JSON payload as the generation prompt requests."""
    return {
        "contact": {"full_name": None, "email": None},
        "summary": "Software engineering student with hands-on mobile development "
        "experience building and launching real apps.",
        "experience": [],
        "education": [],
        "projects": [
            {
                "name": "Recycling Pickup App",
                "period": "2024-06",
                "tech_stack": ["Flutter", "Firebase"],
                "bullets": ["Built and launched a campus recycling app to 100 users."],
                "evidence": [source_id],
            }
        ],
        "skills": [
            {"category": "Technical", "skills": ["Flutter", "Firebase"]},
            {"category": "Soft skills", "skills": ["Teamwork"]},
        ],
        "certifications": [],
        "languages": [{"name": "Khmer", "proficiency": "Native"}],
        "achievements": [],
        "volunteer": [],
    }
