from datetime import datetime, timezone

from fastapi import APIRouter, Depends, Request

from ..config import Config
from ..errors import (
    AIClientError,
    AIResponseValidationError,
    EmptyInputError,
    InputLimitError,
    RateLimitError,
    UnsupportedLanguageError,
    VitheyAIError,
)
from ..schemas import ExtractedActivity, StandardCV
from .deps import get_ai
from .envelope import error, success
from .schemas import ExtractBatchRequest, ExtractRequest, GenerateCVRequest

router = APIRouter(prefix="/api/v1", tags=["vithey-ai"])
health_router = APIRouter(tags=["health"])


@router.post(
    "/activities/extract",
    summary="Extract one structured activity from raw post text",
)
def extract_activity(body: ExtractRequest, request: Request, ai=Depends(get_ai)):
    try:
        activity = ai.extract_activity(
            content=body.content,
            source_id=body.source_id,
            source_type=body.source_type,
        )
    except VitheyAIError as e:
        return _map_error(request, e)
    return success(request, {"activity": activity.model_dump()})


@router.post(
    "/activities/extract-batch",
    summary="Extract many posts at once (dedupes repeated activities)",
)
def extract_activities(body: ExtractBatchRequest, request: Request, ai=Depends(get_ai)):
    try:
        result = ai.extract_activities(
            [p.model_dump() for p in body.posts], on_error=body.on_error
        )
    except VitheyAIError as e:
        return _map_error(request, e)
    return success(
        request,
        {
            "activities": [a.model_dump() for a in result.activities],
            "failures": [f.model_dump() for f in result.failures],
            "ok_count": result.ok_count,
            "failure_count": result.failure_count,
        },
    )


@router.post(
    "/cv/generate",
    summary="Generate a standard CV from activities or raw posts",
    response_description="A standard CV plus its quality report.",
)
def generate_cv(body: GenerateCVRequest, request: Request, ai=Depends(get_ai)):
    provided = [
        name
        for name, value in (("posts", body.posts), ("activities", body.activities))
        if value is not None
    ]
    if len(provided) != 1:
        return error(
            request,
            400,
            "INVALID_INPUT",
            "Provide exactly one of 'posts' or 'activities'.",
            {"provided": provided},
        )
    try:
        if body.posts:
            cv = ai.build_cv_from_raw_posts(
                posts=[p.model_dump() for p in body.posts],
                profile=(body.profile.model_dump() if body.profile else None),
                target_role=body.target_role,
                job_description=body.job_description,
                language=body.language,
                on_error=body.on_error,
            )
        else:
            activities = [ExtractedActivity(**a.model_dump()) for a in body.activities]
            cv = ai.generate_cv(
                activities=activities,
                profile=(body.profile.model_dump() if body.profile else None),
                target_role=body.target_role,
                job_description=body.job_description,
                language=body.language,
            )
        quality = ai.quality_report(cv)
    except VitheyAIError as e:
        return _map_error(request, e)

    data = {
        "cv": cv.model_dump(),
        "quality": quality.model_dump(),
    }
    return success(request, data)


@health_router.get("/health", summary="Liveness + configuration check")
def health(request: Request):
    config: Config = Config()
    llm_configured = bool(config.DEEPSEEK_API_KEY)
    payload = {
        "status": "healthy" if llm_configured else "degraded",
        "service": "vithey-ai",
        "version": Config.VERSION,
        "checks": {"llm": "healthy" if llm_configured else "unconfigured"},
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }
    return success(request, payload)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

_ERROR_MAP = [
    (RateLimitError, 429, "AI_RATE_LIMITED"),
    (InputLimitError, 413, "INPUT_TOO_LARGE"),
    (EmptyInputError, 400, "EMPTY_INPUT"),
    (UnsupportedLanguageError, 400, "UNSUPPORTED_LANGUAGE"),
    (AIResponseValidationError, 502, "AI_INVALID_RESPONSE"),
    (AIClientError, 502, "UPSTREAM_AI_ERROR"),
]


def _map_error(request: Request, exc: VitheyAIError):
    for exc_type, status_code, code in _ERROR_MAP:
        if isinstance(exc, exc_type):
            return error(request, status_code, code, str(exc))
    if isinstance(exc, VitheyAIError):
        return error(request, 400, "VITHEY_AI_ERROR", str(exc))
    raise exc
