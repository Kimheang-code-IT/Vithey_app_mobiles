"""Demo stub chatbot replies (ported from Java TopicStubReplies)."""

from __future__ import annotations

TOPICS = ("CV", "JOB", "INTERVIEW", "STUDENT", "FINANCE")


def normalize_topic(raw: str | None) -> str:
    if not raw:
        return "STUDENT"
    value = raw.strip().upper()
    aliases = {
        "CV_HELP": "CV",
        "MOCK_INTERVIEW": "INTERVIEW",
        "FINANCE_QA": "FINANCE",
        "MEDIA": "STUDENT",
    }
    value = aliases.get(value, value)
    return value if value in TOPICS else "STUDENT"


def stub_reply(topic: str | None, user_message: str) -> str:
    safe = normalize_topic(topic)
    hint = _truncate(user_message, 120)
    if safe == "CV":
        return f"""## CV tips (demo stub)

Here are quick Vithey demo tips for your question:
> {hint}

1. Lead with a **2–3 line summary** tied to the role you want.
2. Turn posts/projects into **bullet results** (what you built + tools + outcome).
3. Keep skills honest — match the job post language.
4. Use **Auto-Create CV** in the app to draft from your profile and posts.

_Demo mode: Vithey AI replies are stubs. CV generate uses DeepSeek via ai_core._
"""
    if safe == "JOB":
        return f"""## Job apply tips (demo stub)

About: _{hint}_

- Read the job post skills and mirror the strongest matches on your CV.
- Pick 2–3 projects that prove those skills.
- Write a short note: why this role + what you can ship in 30 days.

_Demo stub — peer chat and career APIs are live; this assistant is not calling an LLM._
"""
    if safe == "INTERVIEW":
        return f"""## Interview prep (demo stub)

Question focus: _{hint}_

Practice out loud:
1. **Tell me about yourself** (60–90s, role-targeted).
2. One project story: problem → action → result.
3. One question for them about the team or stack.

_Demo stub reply._
"""
    if safe == "FINANCE":
        return f"""## Student finance (demo stub)

You asked: _{hint}_

For live fee/payment data, open the **Finance** screens in Vithey (finance-service).
This assistant cannot move money — it only gives general study tips in demo mode.

_Demo stub — no RAG / no GDCE._
"""
    return f"""## Student help (demo stub)

You said: _{hint}_

Vithey can help with feed, jobs, peer chat, map, and Auto-Create CV.
Ask a more specific topic (CV / JOB / INTERVIEW / FINANCE) for tailored stub tips.

_Demo mode: stub replies only._
"""


def stub_cv_suggest(section: str, original_text: str) -> str:
    return f"""## Improved {section} (demo stub)

{original_text.strip()}

_Tip: tighten verbs, quantify outcomes, and keep this section under 4 lines._
"""


def _truncate(message: str, max_len: int) -> str:
    if not message or not message.strip():
        return "(no message)"
    normalized = " ".join(message.strip().split())
    if len(normalized) <= max_len:
        return normalized
    return normalized[: max_len - 1].rstrip() + "…"
