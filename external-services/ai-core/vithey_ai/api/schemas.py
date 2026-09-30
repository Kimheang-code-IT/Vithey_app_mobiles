"""HTTP request models for the vithey-ai API."""

from typing import List, Optional

from pydantic import BaseModel, Field

from ..schemas import ExtractedActivity, RawPost, UserProfile


class ExtractRequest(BaseModel):
    content: str = Field(..., min_length=1, description="Raw post/activity text")
    source_id: str = Field(..., min_length=1, description="Unique id of the source post")
    source_type: str = Field(default="post", description="post | video | job | other")

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "content": "We built a recycling pickup app at RUPP using Flutter and Firebase.",
                    "source_id": "post_123",
                    "source_type": "post",
                }
            ]
        }
    }


class ExtractBatchRequest(BaseModel):
    posts: List[RawPost] = Field(..., min_length=1)
    on_error: str = Field(
        default="skip", description="'skip' failed posts or 'fail' fast"
    )


class GenerateCVRequest(BaseModel):
    """Provide exactly one of ``posts`` or ``activities``."""

    posts: Optional[List[RawPost]] = None
    activities: Optional[List[ExtractedActivity]] = None
    profile: Optional[UserProfile] = None
    target_role: str = ""
    job_description: str = ""
    language: str = Field(default="en", description="'en' or 'km'")
    on_error: str = Field(default="skip")

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "posts": [
                        {
                            "source_id": "post_1",
                            "content": "Built a smart campus app with Flutter + Firebase at RUPP.",
                        }
                    ],
                    "profile": {
                        "full_name": "Sok Dara",
                        "email": "dara@example.com",
                        "phone": "+855 12 345 678",
                        "location": "Phnom Penh",
                        "education": [
                            {
                                "degree": "BSc Computer Science",
                                "institution": "RUPP",
                                "period": "2022 ~ 2026",
                            }
                        ],
                    },
                    "target_role": "Software Engineer Intern",
                    "job_description": "Flutter mobile intern; Firebase experience a plus.",
                    "language": "en",
                }
            ]
        }
    }
