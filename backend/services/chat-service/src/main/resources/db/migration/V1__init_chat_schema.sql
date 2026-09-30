CREATE TABLE conversations (
    id UUID PRIMARY KEY,
    status VARCHAR(32) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    CONSTRAINT chk_conversations_status CHECK (status IN ('ACTIVE','ARCHIVED','CLOSED'))
);

CREATE TABLE conversation_participants (
    conversation_id UUID NOT NULL REFERENCES conversations (id) ON DELETE CASCADE,
    user_id UUID NOT NULL,
    role VARCHAR(32) NOT NULL,
    joined_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (conversation_id, user_id),
    CONSTRAINT chk_conversation_participants_role CHECK (role IN ('MEMBER','ADMIN'))
);

CREATE INDEX idx_conversation_participants_user ON conversation_participants (user_id);

CREATE TABLE messages (
    id UUID PRIMARY KEY,
    conversation_id UUID NOT NULL REFERENCES conversations (id) ON DELETE CASCADE,
    sender_id UUID NOT NULL,
    text TEXT NOT NULL,
    status VARCHAR(32) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    CONSTRAINT chk_messages_status CHECK (status IN ('SENT','DELIVERED','READ','DELETED'))
);

CREATE INDEX idx_messages_conversation_created ON messages (conversation_id, created_at DESC);
CREATE INDEX idx_messages_sender ON messages (sender_id);

CREATE TABLE blocks (
    blocker_id UUID NOT NULL,
    blocked_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (blocker_id, blocked_id),
    CONSTRAINT chk_blocks_no_self_block CHECK (blocker_id <> blocked_id)
);

CREATE INDEX idx_blocks_blocked ON blocks (blocked_id);

CREATE TABLE user_reports (
    id UUID PRIMARY KEY,
    reporter_id UUID NOT NULL,
    reported_id UUID NOT NULL,
    reason TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    CONSTRAINT chk_user_reports_no_self_report CHECK (reporter_id <> reported_id)
);

CREATE INDEX idx_user_reports_reporter ON user_reports (reporter_id);
CREATE INDEX idx_user_reports_reported ON user_reports (reported_id);
