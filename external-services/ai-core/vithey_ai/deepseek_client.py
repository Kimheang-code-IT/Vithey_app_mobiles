"""DeepSeek client with retry/backoff and JSON-mode responses."""

import json
import time

from openai import OpenAI

from .config import Config
from .errors import AIClientError, AIResponseValidationError
from .logging_conf import get_logger
from .ratelimit import SlidingWindowRateLimiter

logger = get_logger(__name__)


class DeepSeekClient:
    def __init__(self, config: Config | None = None):
        self._config = config or Config()
        self.client = OpenAI(
            api_key=self._config.DEEPSEEK_API_KEY,
            base_url=self._config.DEEPSEEK_BASE_URL,
            timeout=self._config.TIMEOUT_SECONDS,
        )
        self.model = self._config.DEEPSEEK_MODEL
        self.temperature = self._config.TEMPERATURE
        self.rate_limiter = SlidingWindowRateLimiter(
            max_calls=(
                self._config.RATE_LIMIT_MAX_CALLS
                if self._config.RATE_LIMIT_ENABLED
                else 0
            ),
            window_seconds=self._config.RATE_LIMIT_WINDOW_SECONDS,
        )

    def ask_json(self, system_prompt: str, user_prompt: str) -> dict:
        """Send one chat completion and return parsed JSON.

        Transient API failures are retried up to ``MAX_RETRIES`` times with
        exponential backoff. Invalid JSON is never retried (deterministic).
        """
        last_error: Exception | None = None
        attempts = 1 + max(0, self._config.MAX_RETRIES)

        for attempt in range(attempts):
            try:
                self.rate_limiter.acquire()
                return self._call_once(system_prompt, user_prompt)
            except AIResponseValidationError:
                raise
            except AIClientError as e:
                last_error = e
                if attempt < attempts - 1:
                    delay = self._config.RETRY_BACKOFF_SECONDS * (2**attempt)
                    logger.warning(
                        "LLM call failed (attempt %d/%d): %s -- retrying in %.1fs",
                        attempt + 1,
                        attempts,
                        e,
                        delay,
                    )
                    time.sleep(delay)

        raise AIClientError(
            f"DeepSeek API call failed after {attempts} attempt(s): {last_error}"
        ) from last_error

    def _call_once(self, system_prompt: str, user_prompt: str) -> dict:
        message = None
        try:
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_prompt},
                ],
                response_format={"type": "json_object"},
                temperature=self.temperature,
                max_tokens=self._config.MAX_TOKENS,
            )
            message = response.choices[0].message
            content = message.content
            # Some OpenRouter models (e.g. GLM flash) occasionally leave
            # content empty while putting text in reasoning — recover JSON.
            if content is None or (isinstance(content, str) and not content.strip()):
                content = self._extract_json_text(message)
            if content is None or not str(content).strip():
                raise AIResponseValidationError("LLM returned empty content.")
            return json.loads(self._strip_json_fence(str(content)))
        except json.JSONDecodeError as e:
            recovered = self._extract_json_text(message) if message is not None else None
            if recovered:
                try:
                    return json.loads(self._strip_json_fence(recovered))
                except json.JSONDecodeError:
                    pass
            raise AIResponseValidationError("LLM returned invalid JSON.") from e
        except AIResponseValidationError:
            raise
        except Exception as e:
            raise AIClientError(f"LLM API call failed: {e}") from e

    @staticmethod
    def _strip_json_fence(text: str) -> str:
        cleaned = text.strip()
        if cleaned.startswith("```"):
            lines = cleaned.splitlines()
            if lines and lines[0].startswith("```"):
                lines = lines[1:]
            if lines and lines[-1].strip().startswith("```"):
                lines = lines[:-1]
            cleaned = "\n".join(lines).strip()
        start = cleaned.find("{")
        end = cleaned.rfind("}")
        if start >= 0 and end > start:
            return cleaned[start : end + 1]
        return cleaned

    @staticmethod
    def _extract_json_text(message) -> str | None:
        """Best-effort JSON recovery for reasoning-first OpenRouter replies."""
        dumped = message.model_dump() if hasattr(message, "model_dump") else {}
        for key in ("content", "reasoning"):
            value = dumped.get(key)
            if isinstance(value, str) and "{" in value:
                start = value.find("{")
                end = value.rfind("}")
                if start >= 0 and end > start:
                    return value[start : end + 1]
        details = dumped.get("reasoning_details") or []
        for item in details:
            if not isinstance(item, dict):
                continue
            text = item.get("text")
            if isinstance(text, str) and "{" in text:
                start = text.find("{")
                end = text.rfind("}")
                if start >= 0 and end > start:
                    return text[start : end + 1]
        return None
