"""LLM-backed chatbot replies for the Vithey assistant."""

from __future__ import annotations

from .deepseek_client import DeepSeekClient

CHAT_SYSTEM_PROMPT = (
    "You are Vithey, a concise, friendly assistant for Cambodian university "
    "students. Help with CVs, jobs, interview prep, student life and personal "
    "finance. Reply in the same language the user writes in (English or Khmer). "
    "Use short markdown. Never invent personal data, fee amounts, or account "
    "details; point the user to the relevant in-app screen instead."
)


class LLMChat:
    """Wraps :class:`DeepSeekClient` with the Vithey assistant system prompt."""

    def __init__(self, client: DeepSeekClient):
        self._client = client

    def reply(self, topic: str | None, message: str) -> str:
        user_prompt = f"Topic: {topic or 'GENERAL'}\nUser: {message}"
        return self._client.ask_text(CHAT_SYSTEM_PROMPT, user_prompt)
