import pytest

from vithey_ai.errors import RateLimitError
from vithey_ai.ratelimit import SlidingWindowRateLimiter


def test_allows_calls_within_limit():
    limiter = SlidingWindowRateLimiter(max_calls=3, window_seconds=60)

    for _ in range(3):
        limiter.acquire(now=0.0)


def test_blocks_calls_over_limit():
    limiter = SlidingWindowRateLimiter(max_calls=2, window_seconds=60)
    limiter.acquire(now=0.0)
    limiter.acquire(now=1.0)

    with pytest.raises(RateLimitError):
        limiter.acquire(now=2.0)


def test_window_slides():
    limiter = SlidingWindowRateLimiter(max_calls=2, window_seconds=10)
    limiter.acquire(now=0.0)
    limiter.acquire(now=1.0)

    with pytest.raises(RateLimitError):
        limiter.acquire(now=5.0)

    # Both earlier calls have aged out of the window.
    limiter.acquire(now=15.0)  # no raise


def test_disabled_limiter_never_blocks():
    limiter = SlidingWindowRateLimiter(max_calls=0, window_seconds=60)

    for i in range(1000):
        limiter.acquire(now=float(i))


def test_reset_clears_history():
    limiter = SlidingWindowRateLimiter(max_calls=1, window_seconds=60)
    limiter.acquire(now=0.0)

    with pytest.raises(RateLimitError):
        limiter.acquire(now=1.0)

    limiter.reset()
    limiter.acquire(now=2.0)  # no raise
