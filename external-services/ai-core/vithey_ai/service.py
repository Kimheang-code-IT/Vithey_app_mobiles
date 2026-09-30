from .config import Config
from .deepseek_client import DeepSeekClient
from .dedupe import merge_activities
from .errors import VitheyAIError
from .extraction import ExtractionService
from .generation import CVGenerationService
from .logging_conf import get_logger
from .normalize import validate_language
from .quality import score_cv
from .ratelimit import SlidingWindowRateLimiter
from .schemas import (
    CVQualityReport,
    ExtractionBatchResult,
    ExtractionFailure,
    ExtractedActivity,
    RawPost,
    StandardCV,
    UserProfile,
)

logger = get_logger(__name__)


class VitheyAI:
    """
    Main public entry point for the Vithey AI CV feature.
    Other devs should only use this class.

    Guarantees:
    - ``generate_cv`` / ``build_cv_from_raw_posts`` ALWAYS return a
      :class:`StandardCV` (fixed canonical sections, contact header, meta).
    - Duplicate posts about the same activity are merged, not duplicated.
    - Failed post extraction is logged and skipped (or raised with
      ``on_error="fail"``), never silently lost.
    - LLM calls are rate-limited and retried per config.
    """

    def __init__(
        self,
        api_key: str | None = None,
        config: Config | None = None,
        client: DeepSeekClient | None = None,
    ):
        """``client`` allows injecting a fake LLM client (tests/DI);
        by default a real DeepSeekClient is created."""
        self.config = config or Config()
        if api_key:
            self.config.DEEPSEEK_API_KEY = api_key

        if not self.config.DEEPSEEK_API_KEY:
            raise ValueError(
                "DEEPSEEK_API_KEY is required. Set it in .env or pass api_key."
            )

        self._client = client or DeepSeekClient(self.config)
        self._extractor = ExtractionService(self._client, self.config)
        self._generator = CVGenerationService(self._client, self.config)

    # ------------------------------------------------------------------
    # Single activity
    # ------------------------------------------------------------------

    def extract_activity(
        self,
        content: str,
        source_id: str,
        source_type: str = "post",
    ) -> ExtractedActivity:
        return self._extractor.extract(content, source_id, source_type)

    # ------------------------------------------------------------------
    # Batch extraction
    # ------------------------------------------------------------------

    @staticmethod
    def _coerce_post(post: RawPost | dict) -> RawPost:
        return post if isinstance(post, RawPost) else RawPost(**post)

    def extract_activities(
        self,
        posts: list[RawPost | dict],
        on_error: str = "skip",
    ) -> ExtractionBatchResult:
        """Extract many posts. Duplicates are merged; failures are reported.

        ``on_error``: ``"skip"`` (default) logs and continues; ``"fail"``
        re-raises the first error encountered.
        """
        if on_error not in {"skip", "fail"}:
            raise ValueError("on_error must be 'skip' or 'fail'.")
        if not posts:
            raise VitheyAIError("No posts provided.")

        coerced = [self._coerce_post(p) for p in posts]
        self._extractor.enforce_post_limit(len(coerced))

        result = ExtractionBatchResult()
        for post in coerced:
            try:
                activity = self.extract_activity(
                    content=post.content,
                    source_id=post.source_id,
                    source_type=post.source_type,
                )
                result.activities.append(activity)
            except VitheyAIError as e:
                logger.warning(
                    "Extraction failed for source_id=%s: %s", post.source_id, e
                )
                result.failures.append(
                    ExtractionFailure(source_id=post.source_id, error=str(e))
                )
                if on_error == "fail":
                    raise

        result.activities = merge_activities(result.activities)
        logger.info(
            "Batch extraction: %d activities kept, %d failures",
            result.ok_count,
            result.failure_count,
        )
        return result

    # ------------------------------------------------------------------
    # CV generation
    # ------------------------------------------------------------------

    @staticmethod
    def _coerce_profile(profile: UserProfile | dict | None) -> UserProfile | None:
        if profile is None or isinstance(profile, UserProfile):
            return profile
        return UserProfile(**profile)

    def generate_cv(
        self,
        activities: list[ExtractedActivity],
        profile: UserProfile | dict | None = None,
        target_role: str = "",
        job_description: str = "",
        language: str = "en",
    ) -> StandardCV:
        language = validate_language(language)
        activities = merge_activities(activities)
        cv = self._generator.generate(
            activities=activities,
            profile=self._coerce_profile(profile),
            target_role=target_role or "",
            job_description=job_description or "",
            language=language,
        )
        return cv

    def build_cv_from_raw_posts(
        self,
        posts: list[RawPost | dict],
        profile: UserProfile | dict | None = None,
        target_role: str = "",
        job_description: str = "",
        language: str = "en",
        on_error: str = "skip",
    ) -> StandardCV:
        language = validate_language(language)
        batch = self.extract_activities(posts, on_error=on_error)

        usable = [a for a in batch.activities]
        if not usable:
            raise VitheyAIError(
                "No valid activities could be extracted "
                f"({batch.failure_count} post(s) failed)."
            )
        if batch.failures:
            logger.warning(
                "%d post(s) were skipped during extraction; continuing with %d.",
                len(batch.failures),
                len(usable),
            )

        return self.generate_cv(
            activities=usable,
            profile=self._coerce_profile(profile),
            target_role=target_role,
            job_description=job_description,
            language=language,
        )

    # ------------------------------------------------------------------
    # Quality
    # ------------------------------------------------------------------

    def quality_report(self, cv: StandardCV) -> CVQualityReport:
        """Deterministic 0-100 completeness score + actionable issues."""
        return score_cv(cv)
