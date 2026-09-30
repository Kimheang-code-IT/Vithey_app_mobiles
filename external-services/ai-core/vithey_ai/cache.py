"""Optional in-memory cache for extraction results (bounded, FIFO eviction)."""

import hashlib
from collections import OrderedDict


class InMemoryCache:
    def __init__(self, max_size: int = 512):
        self.max_size = max(1, max_size)
        self._store: OrderedDict[str, object] = OrderedDict()

    def get(self, key: str):
        return self._store.get(key)

    def set(self, key: str, value) -> None:
        if key in self._store:
            self._store.move_to_end(key)
        self._store[key] = value
        while len(self._store) > self.max_size:
            self._store.popitem(last=False)

    def make_key(self, content: str, source_type: str = "post") -> str:
        """Content-based key: identical text reuses the extraction even if the
        source_id differs."""
        raw = f"{source_type}:{content}"
        return hashlib.sha256(raw.encode("utf-8")).hexdigest()
