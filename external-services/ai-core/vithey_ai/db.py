"""Postgres helpers for ai_db (reuse Java Flyway tables)."""

from __future__ import annotations

from contextlib import contextmanager
from typing import Iterator

import psycopg
from psycopg.rows import dict_row

from .config import Config
from .logging_conf import get_logger

logger = get_logger(__name__)

_SCHEMA_SQL = """
CREATE TABLE IF NOT EXISTS ai_chat_sessions (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    topic VARCHAR(32) NOT NULL,
    title VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ai_chat_messages (
    id UUID PRIMARY KEY,
    session_id UUID NOT NULL REFERENCES ai_chat_sessions (id) ON DELETE CASCADE,
    role VARCHAR(16) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ai_cv_interactions (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    section VARCHAR(64) NOT NULL,
    original_text TEXT NOT NULL,
    suggested_text TEXT NOT NULL,
    cv_file_id UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_chat_sessions_user_updated
    ON ai_chat_sessions (user_id, updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_ai_chat_messages_session_created
    ON ai_chat_messages (session_id, created_at);
"""


class Database:
    def __init__(self, dsn: str):
        self._dsn = dsn

    @contextmanager
    def connection(self) -> Iterator[psycopg.Connection]:
        conn = psycopg.connect(self._dsn, row_factory=dict_row)
        try:
            yield conn
            conn.commit()
        except Exception:
            conn.rollback()
            raise
        finally:
            conn.close()

    def ensure_schema(self) -> None:
        statements = [s.strip() for s in _SCHEMA_SQL.split(";") if s.strip()]
        with self.connection() as conn:
            for statement in statements:
                conn.execute(statement)
        logger.info("ai_db schema ensured")


def build_database(config: Config | None = None) -> Database | None:
    config = config or Config()
    dsn = config.DATABASE_URL
    if not dsn:
        logger.warning("DATABASE_URL unset — chat/CV suggest persistence disabled")
        return None
    db = Database(dsn)
    try:
        db.ensure_schema()
    except Exception as exc:
        logger.error("Failed to init ai_db: %s", exc)
        raise
    return db
