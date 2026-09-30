import json

from .config import Config
from .deepseek_client import DeepSeekClient
from .logging_conf import get_logger
from .normalize import normalize_cv
from .prompts import CV_GENERATION_SYSTEM_PROMPT
from .schemas import ExtractedActivity, StandardCV, UserProfile

logger = get_logger(__name__)


class CVGenerationService:
    def __init__(self, client: DeepSeekClient, config: Config | None = None):
        self.client = client
        self.config = config or Config()

    def generate(
        self,
        activities: list[ExtractedActivity],
        profile: UserProfile | None = None,
        target_role: str = "",
        job_description: str = "",
        language: str = "en",
    ) -> StandardCV:
        if not activities:
            from .errors import EmptyInputError

            raise EmptyInputError("No activities provided for CV generation.")

        activities_json = json.dumps(
            [a.model_dump() for a in activities], ensure_ascii=False
        )
        profile_json = (
            json.dumps(profile.model_dump(), ensure_ascii=False)
            if profile is not None
            else "Not provided"
        )

        user_prompt = (
            f"Verified activities (extracted from the user's own posts):\n"
            f"{activities_json}\n\n"
            f"Profile data (authoritative for contact/education; may be partial):\n"
            f"{profile_json}\n\n"
            f"Target role: {target_role.strip() or 'Not specified'}\n"
            f"Job description to tailor towards: "
            f"{job_description.strip() or 'Not provided'}\n"
            f"Output language: {language}"
        )

        data = self.client.ask_json(CV_GENERATION_SYSTEM_PROMPT, user_prompt)

        cv = normalize_cv(
            data=data,
            activities=activities,
            profile=profile,
            target_role=target_role,
            job_description=job_description,
            language=language,
            model_name=self.config.DEEPSEEK_MODEL,
        )
        logger.info(
            "Generated standard CV: score inputs %d experience / %d projects / "
            "%d education entries",
            len(cv.experience),
            len(cv.projects),
            len(cv.education),
        )
        return cv
