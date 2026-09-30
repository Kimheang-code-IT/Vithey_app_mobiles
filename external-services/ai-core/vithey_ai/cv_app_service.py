"""Flutter CV generate/suggest — aggregation + AiCvDraft mapping."""

from __future__ import annotations

import uuid
from typing import Any

import httpx

from .chat_stubs import stub_cv_suggest
from .config import Config
from .db import Database
from .logging_conf import get_logger
from .service import VitheyAI

logger = get_logger(__name__)


class CvAppService:
    def __init__(
        self,
        ai: VitheyAI,
        config: Config,
        db: Database | None = None,
    ):
        self._ai = ai
        self._config = config
        self._db = db

    def generate(
        self,
        user_id: uuid.UUID,
        authorization: str | None,
        target_role: str | None = None,
        language: str | None = None,
        template_id: str | None = None,
    ) -> dict[str, Any]:
        profile = self._fetch_profile(user_id, authorization)
        posts = self._fetch_posts(user_id, authorization)
        full_name = str(profile.get("full_name") or "").strip()
        if not full_name:
            full_name = ""

        if not posts:
            return incomplete_draft(
                full_name,
                "Add a few posts about your projects or activities, then try Auto-Create CV again.",
                template_id,
            )

        if self._ai is None:
            return incomplete_draft(
                full_name,
                "AI could not finish your CV right now. Try again, or fill sections manually.",
                template_id,
            )

        try:
            cv = self._ai.build_cv_from_raw_posts(
                posts=posts,
                profile=profile or None,
                target_role=target_role or "",
                language=language or "en",
                on_error="skip",
            )
            quality = self._ai.quality_report(cv)
            draft = to_draft(
                cv.model_dump() if hasattr(cv, "model_dump") else dict(cv),
                template_id,
                getattr(quality, "score", None),
                getattr(quality, "grade", None),
            )
            if not draft.get("full_name") and full_name:
                draft["full_name"] = full_name
            return draft
        except Exception as exc:
            logger.warning("CV generate failed for %s: %s", user_id, exc)
            return incomplete_draft(
                full_name,
                "AI could not finish your CV right now. Try again, or fill sections manually.",
                template_id,
            )

    def suggest(
        self,
        user_id: uuid.UUID,
        section: str,
        original_text: str,
        cv_file_id: str | None = None,
    ) -> dict[str, Any]:
        suggested = stub_cv_suggest(section, original_text)
        interaction_id = uuid.uuid4()
        if self._db is not None:
            with self._db.connection() as conn:
                conn.execute(
                    """
                    INSERT INTO ai_cv_interactions
                        (id, user_id, section, original_text, suggested_text, cv_file_id)
                    VALUES (%s, %s, %s, %s, %s, %s)
                    """,
                    (
                        interaction_id,
                        user_id,
                        section,
                        original_text,
                        suggested,
                        uuid.UUID(cv_file_id) if cv_file_id else None,
                    ),
                )
        return {
            "suggested_text": suggested,
            "interaction_id": str(interaction_id),
        }

    def _fetch_profile(
        self, user_id: uuid.UUID, authorization: str | None
    ) -> dict[str, Any]:
        base = self._config.USER_PROFILE_BASE_URL.rstrip("/")
        url = f"{base}/api/v1/users/{user_id}"
        try:
            with httpx.Client(timeout=5.0) as client:
                resp = client.get(url, headers=_headers(authorization, user_id))
                if resp.status_code >= 400:
                    return {}
                data = resp.json().get("data") or {}
                profile: dict[str, Any] = {}
                if data.get("full_name"):
                    profile["full_name"] = data["full_name"]
                if data.get("email"):
                    profile["email"] = data["email"]
                if data.get("phone"):
                    profile["phone"] = data["phone"]
                skills = []
                for skill in data.get("skills") or []:
                    if isinstance(skill, dict) and skill.get("name"):
                        skills.append(skill["name"])
                    elif isinstance(skill, str):
                        skills.append(skill)
                profile["skills"] = skills
                education = []
                uni = data.get("university") or ""
                major = data.get("major") or ""
                if uni or major:
                    education.append(
                        {
                            "institution": uni,
                            "degree": major,
                            "period": str(data.get("graduation_year") or ""),
                        }
                    )
                profile["education"] = education
                return profile
        except Exception as exc:
            logger.warning("Profile fetch failed: %s", exc)
            return {}

    def _fetch_posts(
        self, user_id: uuid.UUID, authorization: str | None
    ) -> list[dict[str, Any]]:
        base = self._config.CONTENT_BASE_URL.rstrip("/")
        limit = max(1, min(self._config.AI_CV_MAX_POSTS, 50))
        url = f"{base}/api/v1/users/{user_id}/posts?page=1&limit={limit}"
        try:
            with httpx.Client(timeout=5.0) as client:
                resp = client.get(url, headers=_headers(authorization, user_id))
                if resp.status_code >= 400:
                    return []
                data = resp.json().get("data")
                if not isinstance(data, list):
                    return []
                posts = []
                for post in data:
                    content = (post.get("content") or "").strip()
                    if not content:
                        continue
                    pid = post.get("post_id") or post.get("id") or str(uuid.uuid4())
                    posts.append(
                        {
                            "source_id": str(pid),
                            "source_type": "post",
                            "content": content,
                        }
                    )
                return posts
        except Exception as exc:
            logger.warning("Posts fetch failed: %s", exc)
            return []


def _headers(authorization: str | None, user_id: uuid.UUID) -> dict[str, str]:
    headers = {"X-User-Id": str(user_id), "Accept": "application/json"}
    if authorization:
        headers["Authorization"] = authorization
    return headers


def incomplete_draft(
    full_name: str, message: str, template_id: str | None
) -> dict[str, Any]:
    return {
        "full_name": full_name or "",
        "summary": "",
        "skills": [],
        "education": [],
        "experience": [],
        "projects": [],
        "contact": "",
        "template_id": template_id,
        "incomplete_profile": True,
        "incomplete_message": message,
        "quality_score": None,
        "quality_grade": None,
    }


def to_draft(
    cv: dict[str, Any],
    template_id: str | None,
    quality_score: int | None,
    quality_grade: str | None,
) -> dict[str, Any]:
    contact = cv.get("contact") or {}
    full_name = (contact.get("full_name") or "").strip()
    contact_parts = []
    for key in ("email", "phone", "linkedin", "github", "website"):
        value = contact.get(key)
        if value:
            contact_parts.append(str(value).strip())

    skills: list[str] = []
    for group in cv.get("skills") or []:
        if isinstance(group, str):
            skills.append(group)
            continue
        category = (group.get("category") or "").strip()
        items = [str(i).strip() for i in (group.get("items") or []) if str(i).strip()]
        if not items:
            continue
        if category:
            skills.append(f"{category}: {', '.join(items)}")
        else:
            skills.extend(items)

    education = []
    for item in cv.get("education") or []:
        line = _join(
            item.get("degree"), item.get("institution"), item.get("period")
        )
        if line:
            education.append(line)

    experience = []
    for item in cv.get("experience") or []:
        line = _join(
            item.get("title"),
            item.get("organization"),
            item.get("period"),
            item.get("summary"),
        )
        if line:
            experience.append(line)

    projects = []
    for item in cv.get("projects") or []:
        line = _join(item.get("name"), item.get("summary"), item.get("role"))
        if line:
            projects.append(line)

    return {
        "full_name": full_name,
        "summary": (cv.get("summary") or "").strip(),
        "skills": skills,
        "education": education,
        "experience": experience,
        "projects": projects,
        "contact": " | ".join(contact_parts),
        "template_id": template_id,
        "incomplete_profile": False,
        "incomplete_message": None,
        "quality_score": quality_score,
        "quality_grade": quality_grade,
    }


def _join(*parts: Any) -> str:
    values = [str(p).strip() for p in parts if p and str(p).strip()]
    return " — ".join(values)
