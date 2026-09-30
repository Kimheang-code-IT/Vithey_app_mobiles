"""Chat session persistence + stub replies for Flutter /api/v1/ai/**."""

from __future__ import annotations

import uuid
from datetime import datetime, timezone
from typing import Any

from .chat_registry import ChatRequestRegistry
from .chat_stubs import normalize_topic, stub_reply
from .db import Database


def _now() -> datetime:
    return datetime.now(timezone.utc)


def _title_from_message(message: str) -> str:
    text = " ".join(message.strip().split())
    if not text:
        return "New Chat"
    return text if len(text) <= 40 else text[:39] + "…"


class ChatService:
    def __init__(self, db: Database | None, registry: ChatRequestRegistry | None = None):
        self._db = db
        self.registry = registry or ChatRequestRegistry()
        # Fallback store when DATABASE_URL is missing (local unit tests).
        self._mem_sessions: dict[uuid.UUID, dict[str, Any]] = {}
        self._mem_messages: dict[uuid.UUID, list[dict[str, Any]]] = {}

    def chat(
        self,
        user_id: uuid.UUID,
        message: str,
        topic: str | None = None,
        session_id: uuid.UUID | None = None,
    ) -> dict[str, Any]:
        request_id = self.registry.register(user_id)
        try:
            prepared = self._prepare_turn(user_id, message, topic, session_id)
            reply = stub_reply(prepared["topic"], message)
            assistant_id = self._complete_turn(prepared, reply)
            return {
                "session_id": str(prepared["session_id"]),
                "reply": reply,
                "topic": prepared["topic"],
                "message_id": str(assistant_id),
                "request_id": str(request_id),
            }
        finally:
            self.registry.mark_done(request_id)

    def regenerate(self, user_id: uuid.UUID, message_id: uuid.UUID) -> dict[str, Any]:
        msg = self._get_message(message_id)
        if msg is None:
            raise LookupError("Message not found")
        session = self._get_session(msg["session_id"])
        if session is None or session["user_id"] != user_id:
            raise LookupError("Message not found")
        if msg["role"].upper() not in {"ASSISTANT", "assistant"}:
            raise ValueError("Only assistant messages can be regenerated")

        user_msg = self._previous_user_message(msg["session_id"], message_id)
        if user_msg is None:
            raise ValueError("No user message to regenerate from")

        reply = stub_reply(session["topic"], user_msg["content"])
        self._update_message_content(message_id, reply)
        self._touch_session(session["id"])
        return {
            "session_id": str(session["id"]),
            "reply": reply,
            "topic": session["topic"],
            "message_id": str(message_id),
            "request_id": None,
        }

    def cancel(self, user_id: uuid.UUID, request_id: uuid.UUID) -> None:
        entry = self.registry.find(request_id)
        if entry is None or entry.user_id != user_id:
            raise LookupError("Unknown chat request")
        self.registry.cancel(request_id, user_id)

    def list_sessions(
        self, user_id: uuid.UUID, page: int, limit: int
    ) -> tuple[list[dict[str, Any]], int]:
        page = max(page, 1)
        limit = min(max(limit, 1), 100)
        offset = (page - 1) * limit
        if self._db is None:
            sessions = [
                s for s in self._mem_sessions.values() if s["user_id"] == user_id
            ]
            sessions.sort(key=lambda s: s["updated_at"], reverse=True)
            total = len(sessions)
            slice_ = sessions[offset : offset + limit]
            return [self._session_dto(s) for s in slice_], total

        with self._db.connection() as conn:
            total = conn.execute(
                "SELECT COUNT(*) AS c FROM ai_chat_sessions WHERE user_id = %s",
                (user_id,),
            ).fetchone()["c"]
            rows = conn.execute(
                """
                SELECT * FROM ai_chat_sessions
                WHERE user_id = %s
                ORDER BY updated_at DESC
                LIMIT %s OFFSET %s
                """,
                (user_id, limit, offset),
            ).fetchall()
            return [self._session_dto(dict(r), conn=conn) for r in rows], int(total)

    def list_messages(
        self, user_id: uuid.UUID, session_id: uuid.UUID, page: int, limit: int
    ) -> tuple[list[dict[str, Any]], int]:
        session = self._require_session(user_id, session_id)
        page = max(page, 1)
        limit = min(max(limit, 1), 100)
        offset = (page - 1) * limit
        if self._db is None:
            msgs = list(self._mem_messages.get(session_id, []))
            total = len(msgs)
            slice_ = msgs[offset : offset + limit]
            return [self._message_dto(m) for m in slice_], total

        with self._db.connection() as conn:
            total = conn.execute(
                "SELECT COUNT(*) AS c FROM ai_chat_messages WHERE session_id = %s",
                (session_id,),
            ).fetchone()["c"]
            rows = conn.execute(
                """
                SELECT * FROM ai_chat_messages
                WHERE session_id = %s
                ORDER BY created_at ASC
                LIMIT %s OFFSET %s
                """,
                (session_id, limit, offset),
            ).fetchall()
            _ = session
            return [self._message_dto(dict(r)) for r in rows], int(total)

    def delete_session(self, user_id: uuid.UUID, session_id: uuid.UUID) -> None:
        self._require_session(user_id, session_id)
        if self._db is None:
            self._mem_sessions.pop(session_id, None)
            self._mem_messages.pop(session_id, None)
            return
        with self._db.connection() as conn:
            conn.execute("DELETE FROM ai_chat_sessions WHERE id = %s", (session_id,))

    def prepare_stream_turn(
        self,
        user_id: uuid.UUID,
        message: str,
        topic: str | None,
        session_id: uuid.UUID | None,
    ) -> dict[str, Any]:
        return self._prepare_turn(user_id, message, topic, session_id)

    def complete_stream_turn(self, prepared: dict[str, Any], reply: str) -> uuid.UUID:
        return self._complete_turn(prepared, reply)

    def _prepare_turn(
        self,
        user_id: uuid.UUID,
        message: str,
        topic: str | None,
        session_id: uuid.UUID | None,
    ) -> dict[str, Any]:
        topic_norm = normalize_topic(topic)
        session = self._resolve_session(user_id, session_id, topic_norm, message)
        user_message_id = uuid.uuid4()
        now = _now()
        self._insert_message(session["id"], user_message_id, "USER", message.strip(), now)
        self._touch_session(session["id"], now)
        return {
            "session_id": session["id"],
            "topic": topic_norm,
            "user_message_id": user_message_id,
        }

    def _complete_turn(self, prepared: dict[str, Any], reply: str) -> uuid.UUID:
        assistant_id = uuid.uuid4()
        now = _now()
        self._insert_message(
            prepared["session_id"], assistant_id, "ASSISTANT", reply, now
        )
        self._touch_session(prepared["session_id"], now)
        return assistant_id

    def _resolve_session(
        self,
        user_id: uuid.UUID,
        session_id: uuid.UUID | None,
        topic: str,
        message: str,
    ) -> dict[str, Any]:
        if session_id is not None:
            session = self._require_session(user_id, session_id)
            return session
        new_id = uuid.uuid4()
        now = _now()
        session = {
            "id": new_id,
            "user_id": user_id,
            "topic": topic,
            "title": _title_from_message(message),
            "created_at": now,
            "updated_at": now,
        }
        if self._db is None:
            self._mem_sessions[new_id] = session
            self._mem_messages[new_id] = []
            return session
        with self._db.connection() as conn:
            conn.execute(
                """
                INSERT INTO ai_chat_sessions (id, user_id, topic, title, created_at, updated_at)
                VALUES (%s, %s, %s, %s, %s, %s)
                """,
                (
                    new_id,
                    user_id,
                    topic,
                    session["title"],
                    now,
                    now,
                ),
            )
        return session

    def _require_session(self, user_id: uuid.UUID, session_id: uuid.UUID) -> dict[str, Any]:
        session = self._get_session(session_id)
        if session is None or session["user_id"] != user_id:
            raise LookupError("Session not found")
        return session

    def _get_session(self, session_id: uuid.UUID) -> dict[str, Any] | None:
        if self._db is None:
            return self._mem_sessions.get(session_id)
        with self._db.connection() as conn:
            row = conn.execute(
                "SELECT * FROM ai_chat_sessions WHERE id = %s", (session_id,)
            ).fetchone()
            return dict(row) if row else None

    def _get_message(self, message_id: uuid.UUID) -> dict[str, Any] | None:
        if self._db is None:
            for msgs in self._mem_messages.values():
                for msg in msgs:
                    if msg["id"] == message_id:
                        return msg
            return None
        with self._db.connection() as conn:
            row = conn.execute(
                "SELECT * FROM ai_chat_messages WHERE id = %s", (message_id,)
            ).fetchone()
            return dict(row) if row else None

    def _previous_user_message(
        self, session_id: uuid.UUID, assistant_message_id: uuid.UUID
    ) -> dict[str, Any] | None:
        """Last USER message before the given assistant message (by list order)."""
        if self._db is None:
            msgs = list(self._mem_messages.get(session_id, []))
        else:
            with self._db.connection() as conn:
                rows = conn.execute(
                    """
                    SELECT * FROM ai_chat_messages
                    WHERE session_id = %s
                    ORDER BY created_at ASC, id ASC
                    """,
                    (session_id,),
                ).fetchall()
                msgs = [dict(r) for r in rows]

        previous: dict[str, Any] | None = None
        for msg in msgs:
            if msg["id"] == assistant_message_id:
                return previous
            if str(msg["role"]).upper() == "USER":
                previous = msg
        return None

    def _insert_message(
        self,
        session_id: uuid.UUID,
        message_id: uuid.UUID,
        role: str,
        content: str,
        created_at: datetime,
    ) -> None:
        if self._db is None:
            self._mem_messages.setdefault(session_id, []).append(
                {
                    "id": message_id,
                    "session_id": session_id,
                    "role": role,
                    "content": content,
                    "created_at": created_at,
                }
            )
            return
        with self._db.connection() as conn:
            conn.execute(
                """
                INSERT INTO ai_chat_messages (id, session_id, role, content, created_at)
                VALUES (%s, %s, %s, %s, %s)
                """,
                (message_id, session_id, role, content, created_at),
            )

    def _update_message_content(self, message_id: uuid.UUID, content: str) -> None:
        if self._db is None:
            msg = self._get_message(message_id)
            if msg:
                msg["content"] = content
            return
        with self._db.connection() as conn:
            conn.execute(
                "UPDATE ai_chat_messages SET content = %s WHERE id = %s",
                (content, message_id),
            )

    def _touch_session(
        self, session_id: uuid.UUID, when: datetime | None = None
    ) -> None:
        when = when or _now()
        if self._db is None:
            session = self._mem_sessions.get(session_id)
            if session:
                session["updated_at"] = when
            return
        with self._db.connection() as conn:
            conn.execute(
                "UPDATE ai_chat_sessions SET updated_at = %s WHERE id = %s",
                (when, session_id),
            )

    def _session_dto(
        self, session: dict[str, Any], conn=None
    ) -> dict[str, Any]:
        preview = self._preview(session["id"], conn=conn)
        return {
            "id": str(session["id"]),
            "topic": session["topic"],
            "title": session["title"],
            "preview": preview,
            "created_at": _iso(session["created_at"]),
            "updated_at": _iso(session["updated_at"]),
        }

    def _preview(self, session_id: uuid.UUID, conn=None) -> str:
        if self._db is None:
            msgs = self._mem_messages.get(session_id, [])
            if not msgs:
                return ""
            return msgs[-1]["content"][:160]
        if conn is not None:
            row = conn.execute(
                """
                SELECT content FROM ai_chat_messages
                WHERE session_id = %s
                ORDER BY created_at DESC LIMIT 1
                """,
                (session_id,),
            ).fetchone()
            return (row["content"][:160] if row else "") or ""
        with self._db.connection() as c:
            return self._preview(session_id, conn=c)

    def _message_dto(self, msg: dict[str, Any]) -> dict[str, Any]:
        role = msg["role"]
        role_out = "USER" if str(role).upper() == "USER" else "ASSISTANT"
        return {
            "id": str(msg["id"]),
            "role": role_out,
            "content": msg["content"],
            "status": "complete",
            "created_at": _iso(msg["created_at"]),
        }


def _iso(value: Any) -> str:
    if isinstance(value, datetime):
        if value.tzinfo is None:
            value = value.replace(tzinfo=timezone.utc)
        return value.isoformat()
    return str(value)


def chunk_reply(reply: str, max_len: int = 24) -> list[str]:
    if not reply:
        return []
    return [reply[i : i + max_len] for i in range(0, len(reply), max_len)]
