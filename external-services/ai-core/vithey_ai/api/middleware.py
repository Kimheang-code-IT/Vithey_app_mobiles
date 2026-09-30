import time
import uuid

from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware, RequestResponseEndpoint
from starlette.responses import Response

from .envelope import error

from collections import defaultdict, deque


class RequestContextMiddleware(BaseHTTPMiddleware):
    """Attaches a request id + start time; echoes X-Request-ID back."""

    async def dispatch(self, request: Request, call_next: RequestResponseEndpoint) -> Response:
        request_id = request.headers.get("X-Request-ID") or str(uuid.uuid4())
        request.state.request_id = request_id
        request.state.start_time = time.perf_counter()
        response = await call_next(request)
        response.headers["X-Request-ID"] = request_id
        elapsed_ms = (time.perf_counter() - request.state.start_time) * 1000
        response.headers["X-Process-Time-Ms"] = f"{elapsed_ms:.1f}"
        return response


class BodySizeLimitMiddleware(BaseHTTPMiddleware):
    """Rejects oversized request bodies with a 413 envelope."""

    def __init__(self, app, max_bytes: int):
        super().__init__(app)
        self.max_bytes = max_bytes

    async def dispatch(self, request: Request, call_next: RequestResponseEndpoint) -> Response:
        content_length = request.headers.get("content-length")
        if content_length and content_length.isdigit() and int(content_length) > self.max_bytes:
            return error(
                request,
                413,
                "REQUEST_TOO_LARGE",
                f"Request body exceeds the {self.max_bytes} byte limit.",
            )
        return await call_next(request)


class PerClientRateLimitMiddleware(BaseHTTPMiddleware):
    """Simple in-memory per-client-IP limiter (per process)."""

    def __init__(self, app, requests_per_minute: int):
        super().__init__(app)
        self.requests_per_minute = max(0, requests_per_minute)
        self._hits: dict = defaultdict(deque)

    async def dispatch(self, request: Request, call_next: RequestResponseEndpoint) -> Response:
        if self.requests_per_minute <= 0 or request.url.path == "/health":
            return await call_next(request)

        client_ip = request.client.host if request.client else "unknown"
        now = time.monotonic()
        window = self._hits[client_ip]
        while window and now - window[0] >= 60:
            window.popleft()

        remaining = self.requests_per_minute - len(window)
        if remaining <= 0:
            retry_after = round(60 - (now - window[0]), 2)
            resp = error(
                request,
                429,
                "RATE_LIMIT_EXCEEDED",
                f"Too many requests. Max {self.requests_per_minute}/minute per client.",
                {"retry_after_seconds": retry_after},
            )
            resp.headers["Retry-After"] = str(max(1, int(retry_after) + 1))
            return resp

        window.append(now)
        response = await call_next(request)
        response.headers["X-RateLimit-Limit"] = str(self.requests_per_minute)
        response.headers["X-RateLimit-Remaining"] = str(remaining - 1)
        return response
