from pydantic import ValidationError

from .cache import InMemoryCache
from .config import Config
from .deepseek_client import DeepSeekClient
from .errors import AIResponseValidationError, EmptyInputError, InputLimitError
from .logging_conf import get_logger
from .prompts import EXTRACTION_SYSTEM_PROMPT
from .schemas import ExtractedActivity

logger = get_logger(__name__)


class ExtractionService:
    def __init__(self, client: DeepSeekClient, config: Config | None = None):
        self.client = client
        self.config = config or Config()
        self.cache = (
            InMemoryCache(max_size=self.config.CACHE_MAX_SIZE)
            if self.config.CACHE_ENABLED
            else None
        )

    def extract(
        self, content: str, source_id: str, source_type: str = "post"
    ) -> ExtractedActivity:
        if not content or not content.strip():
            raise EmptyInputError("Post content is empty.")

        truncated = False
        max_chars = self.config.MAX_CONTENT_CHARS
        if len(content) > max_chars:
            content = content[:max_chars]
            truncated = True

        cache_key = (
            self.cache.make_key(content, source_type) if self.cache else None
        )
        if cache_key and self.cache:
            cached = self.cache.get(cache_key)
            if isinstance(cached, dict):
                logger.info("Extraction cache hit for source_id=%s", source_id)
                return ExtractedActivity(**cached, source_id=source_id)

        note = "\n(Note: post was truncated to fit limits.)" if truncated else ""
        user_prompt = f"Post content:\n{content}\n\nSource ID: {source_id}{note}"
        data = self.client.ask_json(EXTRACTION_SYSTEM_PROMPT, user_prompt)
        data["source_id"] = source_id  # force correct source_id

        try:
            activity = ExtractedActivity(**data)
        except ValidationError as e:
            raise AIResponseValidationError(
                f"AI response failed schema validation: {e}"
            ) from e

        if cache_key and self.cache:
            payload = activity.model_dump(exclude={"source_id", "additional_source_ids"})
            self.cache.set(cache_key, payload)

        return activity

    def enforce_post_limit(self, count: int) -> None:
        limit = self.config.MAX_POSTS_PER_BUILD
        if count > limit:
            raise InputLimitError(
                f"Too many posts ({count}). Maximum allowed per build is {limit}."
            )
