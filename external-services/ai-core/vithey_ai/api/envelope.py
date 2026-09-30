"""Standard response envelope for the vithey-ai HTTP API."""

import time
import uuid
from datetime import datetime, timezone

from fastapi import Request
from fastapi.responses import JSONResponse

SERVICE_NAME = "vithey-ai"


def build_meta(request_id: str) -> dict:
    return {
        "request_id": request_id,
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "service": SERVICE_NAME,
    }


def success(request: Request, data: dict, status_code: int = 200) -> JSONResponse:
    request_id = getattr(request.state, "request_id", str(uuid.uuid4()))
    return JSONResponse(
        status_code=status_code,
        content={"success": True, "data": data, "meta": build_meta(request_id)},
        headers={"X-Request-ID": request_id},
    )


def error(
    request: Request,
    status_code: int,
    code: str,
    message: str,
    details: dict | None = None,
) -> JSONResponse:
    request_id = getattr(request.state, "request_id", str(uuid.uuid4()))
    return JSONResponse(
        status_code=status_code,
        content={
            "success": False,
            "error": {"code": code, "message": message, "details": details or {}},
            "meta": build_meta(request_id),
        },
        headers={"X-Request-ID": request_id},
    )
