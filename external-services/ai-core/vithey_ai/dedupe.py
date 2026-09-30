"""Merge duplicate activities extracted from different posts.

Two activities are considered the same when their normalized title and
activity_type match (e.g. the user posted about one project three times).
Merged activities keep every source_id so evidence stays intact.
"""

from typing import List

from .logging_conf import get_logger
from .schemas import ExtractedActivity

logger = get_logger(__name__)


def _norm(value) -> str:
    return "".join(ch.lower() for ch in (value or "") if ch.isalnum())


def _dedupe_preserve_order(values: List[str]) -> List[str]:
    seen = set()
    out = []
    for v in values:
        key = v.lower()
        if key not in seen:
            seen.add(key)
            out.append(v)
    return out


def _later_date(a: str | None, b: str | None) -> str | None:
    """Pick the lexicographically-later partial ISO date ('2024' < '2024-06')."""
    if not a:
        return b
    if not b:
        return a
    return max(a, b)


def _longer(a: str | None, b: str | None) -> str | None:
    if not a:
        return b
    if not b:
        return a
    return a if len(a) >= len(b) else b


def merge_activities(activities: List[ExtractedActivity]) -> List[ExtractedActivity]:
    merged: "dict[tuple[str, str], ExtractedActivity]" = {}
    order: list = []

    for activity in activities:
        key = (_norm(activity.title), _norm(activity.activity_type))
        if key not in merged:
            copy = activity.model_copy(deep=True)
            merged[key] = copy
            order.append(key)
            continue

        target = merged[key]
        target.additional_source_ids = _dedupe_preserve_order(
            [target.source_id, *target.additional_source_ids, activity.source_id,
             *activity.additional_source_ids]
        )
        # Drop source_id from additional list to avoid duplication.
        target.additional_source_ids = [
            sid for sid in target.additional_source_ids if sid != target.source_id
        ]
        target.summary = _longer(target.summary, activity.summary)
        target.outcome = _longer(target.outcome, activity.outcome)
        target.role = target.role or activity.role
        target.date = _later_date(target.date, activity.date)
        target.tools = _dedupe_preserve_order(target.tools + activity.tools)
        target.skills = _dedupe_preserve_order(target.skills + activity.skills)

    duplicates = len(activities) - len(order)
    if duplicates:
        logger.info("Merged %d duplicate activit(y/ies) into existing entries", duplicates)
    return [merged[key] for key in order]
