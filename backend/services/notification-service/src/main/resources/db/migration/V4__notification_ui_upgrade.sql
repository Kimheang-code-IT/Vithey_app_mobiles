-- V4: Facebook-style UI upgrade (UPGRADE_FOR_UI.md)
-- Adds event metadata, actor snapshot, structured destination, dedupe key, read_at.

ALTER TABLE notifications
    ADD COLUMN IF NOT EXISTS event VARCHAR(64),
    ADD COLUMN IF NOT EXISTS actor_id UUID,
    ADD COLUMN IF NOT EXISTS actor_name VARCHAR(120),
    ADD COLUMN IF NOT EXISTS actor_avatar_url TEXT,
    ADD COLUMN IF NOT EXISTS destination JSONB,
    ADD COLUMN IF NOT EXISTS dedupe_key VARCHAR(180),
    ADD COLUMN IF NOT EXISTS read_at TIMESTAMPTZ;

-- Canonical API types (legacy internal names already migrated in V2)
ALTER TABLE notifications DROP CONSTRAINT IF EXISTS chk_notifications_type;
ALTER TABLE notifications
    ADD CONSTRAINT chk_notifications_type
    CHECK (type IN (
        'SYSTEM', 'MESSAGE', 'APPLICATION_UPDATE', 'PAYMENT_DUE', 'MENTION',
        'LIKE', 'COMMENT', 'FOLLOW', 'CHAT', 'CHAT_REQUEST', 'PAYMENT', 'JOB',
        'POST_SHARE', 'AI', 'STUDENT_VERIFICATION'
    ));

-- Idempotent event ingestion
CREATE UNIQUE INDEX IF NOT EXISTS ux_notifications_user_dedupe
    ON notifications (user_id, dedupe_key)
    WHERE dedupe_key IS NOT NULL;
