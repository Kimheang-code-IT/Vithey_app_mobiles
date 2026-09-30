"""Thread-safe sliding-window rate limiter for LLM calls."""

import threading
import time
from collections import deque

from .errors import RateLimitError


class SlidingWindowRateLimiter:
    """Allows at most ``max_calls`` calls per ``window_seconds``.

    ``max_calls <= 0`` disables limiting entirely.
    """

    def __init__(self, max_calls: int, window_seconds: float):
        self.max_calls = max_calls
        self.window_seconds = window_seconds
        self._calls: deque[float] = deque()
        self._lock = threading.Lock()

    @property
    def enabled(self) -> bool:
        return self.max_calls > 0

    def acquire(self, *, now: float | None = None) -> None:
        """Register one call or raise :class:`RateLimitError`."""
        if not self.enabled:
            return

        current = time.monotonic() if now is None else now
        with self._lock:
            while self._calls and current - self._calls[0] >= self.window_seconds:
                self._calls.popleft()

            if len(self._calls) >= self.max_calls:
                retry_after = round(self.window_seconds - (current - self._calls[0]), 2)
                raise RateLimitError(
                    f"Rate limit exceeded: max {self.max_calls} calls per "
                    f"{self.window_seconds:g}s. Retry in ~{retry_after}s."
                )

            self._calls.append(current)

    def reset(self) -> None:
        with self._lock:
            self._calls.clear()
