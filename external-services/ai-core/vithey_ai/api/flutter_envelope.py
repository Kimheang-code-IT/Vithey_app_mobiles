"""Flutter/Java-compatible response envelope: {data, meta, error}."""

from __future__ import annotations

from typing import Any

from fastapi.responses import JSONResponse


def ok(data: Any = None, meta: dict | None = None, status_code: int = 200) -> JSONResponse:
    body: dict[str, Any] = {"data": data, "meta": meta, "error": None}
    return JSONResponse(status_code=status_code, content=body)


def fail(
    status_code: int,
    code: str,
    message: str,
    details: Any = None,
) -> JSONResponse:
    return JSONResponse(
        status_code=status_code,
        content={
            "data": None,
            "meta": None,
            "error": {"code": code, "message": message, "details": details},
        },
    )


def page_meta(page: int, limit: int, total: int) -> dict[str, Any]:
    total_pages = max(1, (total + limit - 1) // limit) if total > 0 else 0
    return {
        "page": page,
        "limit": limit,
        "total": total,
        "total_pages": total_pages,
    }
