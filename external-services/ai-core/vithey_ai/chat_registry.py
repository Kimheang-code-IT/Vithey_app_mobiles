"""In-memory cancel registry for streaming chat requests."""

from __future__ import annotations

import threading
import uuid
from dataclasses import dataclass, field


@dataclass
class _Entry:
    user_id: uuid.UUID
    cancelled: bool = False
    done: bool = False


class ChatRequestRegistry:
    def __init__(self) -> None:
        self._lock = threading.Lock()
        self._entries: dict[uuid.UUID, _Entry] = {}

    def register(self, user_id: uuid.UUID) -> uuid.UUID:
        request_id = uuid.uuid4()
        with self._lock:
            self._entries[request_id] = _Entry(user_id=user_id)
        return request_id

    def cancel(self, request_id: uuid.UUID, user_id: uuid.UUID) -> bool:
        with self._lock:
            entry = self._entries.get(request_id)
            if entry is None or entry.user_id != user_id:
                return False
            entry.cancelled = True
            return True

    def is_cancelled(self, request_id: uuid.UUID) -> bool:
        with self._lock:
            entry = self._entries.get(request_id)
            return bool(entry and entry.cancelled)

    def mark_done(self, request_id: uuid.UUID) -> None:
        with self._lock:
            entry = self._entries.get(request_id)
            if entry:
                entry.done = True

    def find(self, request_id: uuid.UUID) -> _Entry | None:
        with self._lock:
            return self._entries.get(request_id)
