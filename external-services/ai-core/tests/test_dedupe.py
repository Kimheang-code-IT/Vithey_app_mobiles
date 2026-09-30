from fakes import activity_payload

from vithey_ai import ExtractedActivity
from vithey_ai.dedupe import merge_activities


def make(source_id, title, **overrides):
    return ExtractedActivity(**activity_payload(source_id=source_id, title=title, **overrides))


def test_unique_activities_unchanged():
    acts = [make("post_1", "App A"), make("post_2", "App B")]

    merged = merge_activities(acts)

    assert len(merged) == 2
    assert {a.title for a in merged} == {"App A", "App B"}


def test_duplicate_titles_merged_with_all_source_ids():
    acts = [
        make("post_1", "Recycling Pickup App", skills=["Flutter"]),
        make("post_2", "recycling pickup APP", skills=["Firebase"], tools=["Figma"]),
    ]

    merged = merge_activities(acts)

    assert len(merged) == 1
    m = merged[0]
    assert m.source_id == "post_1"
    assert set(m.additional_source_ids) == {"post_2"}
    assert sorted(m.skills) == ["Firebase", "Flutter"]
    assert m.tools == ["Flutter", "Firebase", "Figma"]


def test_merge_keeps_longest_summary_and_latest_date():
    acts = [
        make("post_1", "Same Title", summary="short", date="2024-01-01"),
        make(
            "post_2",
            "Same Title",
            summary="a considerably longer and more detailed summary",
            date="2024-05-01",
        ),
    ]

    merged = merge_activities(acts)

    m = merged[0]
    assert m.summary.startswith("a considerably longer")
    assert m.date == "2024-05-01"


def test_different_activity_types_not_merged():
    acts = [make("post_1", "Hackathon", activity_type="project"),
            make("post_2", "Hackathon", activity_type="achievement")]

    merged = merge_activities(acts)

    assert len(merged) == 2
