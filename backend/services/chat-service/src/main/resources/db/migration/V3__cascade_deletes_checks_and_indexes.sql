-- V3 (consolidated): cascade deletes, widened status/role checks, list indexes.
-- Supersedes the three conflicting V3 scripts that previously shared this version.

-- 1) Cascade deletes from conversations to participants and messages
ALTER TABLE conversation_participants DROP CONSTRAINT IF EXISTS conversation_participants_conversation_id_fkey;
ALTER TABLE conversation_participants
    ADD CONSTRAINT conversation_participants_conversation_id_fkey
    FOREIGN KEY (conversation_id) REFERENCES conversations (id) ON DELETE CASCADE;

ALTER TABLE messages DROP CONSTRAINT IF EXISTS messages_conversation_id_fkey;
ALTER TABLE messages
    ADD CONSTRAINT messages_conversation_id_fkey
    FOREIGN KEY (conversation_id) REFERENCES conversations (id) ON DELETE CASCADE;

-- 2) Widen status checks to cover the full request lifecycle
ALTER TABLE conversations DROP CONSTRAINT IF EXISTS chk_conversations_status;
ALTER TABLE conversations
    ADD CONSTRAINT chk_conversations_status
    CHECK (status IN ('PENDING', 'ACTIVE', 'BLOCKED', 'DECLINED', 'ARCHIVED', 'CLOSED'));

ALTER TABLE conversation_participants DROP CONSTRAINT IF EXISTS chk_conversation_participants_role;
ALTER TABLE conversation_participants
    ADD CONSTRAINT chk_conversation_participants_role
    CHECK (role IN ('REQUESTER', 'RECIPIENT', 'MEMBER', 'ADMIN'));

-- 3) Self-action guards (no blocking / reporting yourself)
ALTER TABLE blocks DROP CONSTRAINT IF EXISTS chk_blocks_no_self_block;
ALTER TABLE blocks
    ADD CONSTRAINT chk_blocks_no_self_block
    CHECK (blocker_id <> blocked_id);

ALTER TABLE user_reports DROP CONSTRAINT IF EXISTS chk_user_reports_no_self_report;
ALTER TABLE user_reports
    ADD CONSTRAINT chk_user_reports_no_self_report
    CHECK (reporter_id <> reported_id);

-- 4) Indexes for the conversation list; message status check kept in line with V1
CREATE INDEX IF NOT EXISTS idx_conversations_updated_at
    ON conversations (updated_at DESC);

CREATE INDEX IF NOT EXISTS idx_conversations_status
    ON conversations (status);

ALTER TABLE messages DROP CONSTRAINT IF EXISTS chk_messages_status;
ALTER TABLE messages
    ADD CONSTRAINT chk_messages_status
    CHECK (status IN ('SENT', 'DELIVERED', 'READ', 'DELETED'));

-- idx_messages_sender / idx_user_reports_reporter / idx_user_reports_reported
-- already exist from V1 and remain; idx_blocks_blocker never existed (V1 uses
-- idx_blocks_blocked + the composite PK for blocker lookups).
