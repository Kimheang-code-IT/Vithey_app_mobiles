"""Shared singletons for the HTTP layer."""

from fastapi import Request

from ..config import Config
from ..service import VitheyAI


def build_ai(config: Config | None = None) -> VitheyAI:
    return VitheyAI(config=config)


def get_ai(request: Request) -> VitheyAI:
    """FastAPI dependency returning the app-scoped VitheyAI instance."""
    return request.app.state.ai
