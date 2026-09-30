"""FastAPI application factory for the vithey-ai HTTP service.

Run with:
    uvicorn vithey_ai.api.app:create_app --factory --port 8100
or via the CLI:
    python main.py serve
"""

from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from ..chat_service import ChatService
from ..config import Config
from ..cv_app_service import CvAppService
from ..db import build_database
from ..logging_conf import get_logger
from .deps import build_ai
from .flutter_envelope import fail
from .flutter_routes import flutter_router
from .middleware import (
    BodySizeLimitMiddleware,
    PerClientRateLimitMiddleware,
    RequestContextMiddleware,
)
from .routes import health_router, router

logger = get_logger(__name__)


def create_app(config: Config | None = None, ai=None) -> FastAPI:
    """Build the app. Pass ``ai`` to inject a fake VitheyAI (tests)."""
    config = config or Config()
    app = FastAPI(
        title="Vithey AI Core",
        description=(
            "CV generation and Flutter AI chat for the Vithey superapp."
        ),
        version=Config.VERSION,
    )

    app.state.config = config

    if ai is not None:
        app.state.ai = ai
    else:
        try:
            app.state.ai = build_ai(config)
        except ValueError as exc:
            logger.warning("CV engine disabled: %s", exc)
            app.state.ai = None

    db = build_database(config)
    app.state.db = db
    app.state.chat_service = ChatService(db)
    app.state.cv_app_service = CvAppService(app.state.ai, config, db)

    # Middleware (order matters: outermost first).
    app.add_middleware(RequestContextMiddleware)
    app.add_middleware(
        PerClientRateLimitMiddleware,
        requests_per_minute=config.API_RATE_LIMIT_PER_MINUTE,
    )
    app.add_middleware(
        BodySizeLimitMiddleware, max_bytes=config.API_MAX_BODY_BYTES
    )
    app.add_middleware(
        CORSMiddleware,
        allow_origins=config.API_CORS_ORIGINS or ["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
        expose_headers=["X-Request-ID", "X-Process-Time-Ms", "X-RateLimit-Remaining"],
    )

    @app.exception_handler(HTTPException)
    async def http_exception_handler(request: Request, exc: HTTPException):
        # Flutter routes expect {data, meta, error}; keep legacy engine routes unchanged.
        if request.url.path.startswith("/api/v1/ai/"):
            detail = exc.detail
            message = detail if isinstance(detail, str) else str(detail)
            code = "UNAUTHORIZED" if exc.status_code == 401 else "HTTP_ERROR"
            return fail(exc.status_code, code, message)
        return JSONResponse(
            status_code=exc.status_code,
            content={"detail": exc.detail},
        )

    app.include_router(health_router)
    app.include_router(router)
    app.include_router(flutter_router)
    logger.info(
        "vithey-ai HTTP app created (version %s, chat_mode=%s)",
        Config.VERSION,
        config.AI_CHAT_MODE,
    )
    return app
