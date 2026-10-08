"""LLM-backed chatbot wiring (no network)."""

import uuid

from vithey_ai.chat_llm import CHAT_SYSTEM_PROMPT, LLMChat
from vithey_ai.chat_service import ChatService


class FakeClient:
    def __init__(self, reply="hello", error=None):
        self.reply_text = reply
        self.error = error
        self.calls = []

    def ask_text(self, system_prompt, user_prompt):
        self.calls.append((system_prompt, user_prompt))
        if self.error:
            raise self.error
        return self.reply_text


def test_llm_chat_uses_system_prompt():
    fake = FakeClient("hi there")
    out = LLMChat(fake).reply("CV", "How do I write a CV?")
    assert out == "hi there"
    assert fake.calls[0][0] == CHAT_SYSTEM_PROMPT
    assert "How do I write a CV?" in fake.calls[0][1]


def test_chat_service_uses_llm_reply():
    svc = ChatService(None, llm_reply=lambda topic, msg: f"LLM:{msg}")
    assert svc.generate_reply("CV", "hello") == "LLM:hello"


def test_chat_service_persists_llm_reply():
    svc = ChatService(None, llm_reply=lambda topic, msg: "answer")
    data = svc.chat(uuid.uuid4(), "hi", "CV", None)
    assert data["reply"] == "answer"


def test_chat_service_falls_back_to_stub_on_error():
    def boom(topic, msg):
        raise RuntimeError("llm down")

    svc = ChatService(None, llm_reply=boom)
    assert "CV tips" in svc.generate_reply("CV", "hello")
