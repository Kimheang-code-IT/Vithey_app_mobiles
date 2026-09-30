CREATE TABLE file_metadata (
    id UUID PRIMARY KEY,
    owner_user_id UUID NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_type VARCHAR(32) NOT NULL,
    mime_type VARCHAR(160) NOT NULL,
    size_bytes BIGINT NOT NULL,
    bucket VARCHAR(64) NOT NULL,
    object_key TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT chk_file_metadata_file_type CHECK (file_type IN ('CV','POST_MEDIA','PROFILE_PICTURE','CHAT_ATTACHMENT')),
    CONSTRAINT chk_file_metadata_size_positive CHECK (size_bytes > 0)
);

CREATE UNIQUE INDEX uq_file_metadata_object_key ON file_metadata (object_key);
CREATE INDEX idx_file_metadata_file_type ON file_metadata (file_type);
CREATE INDEX idx_file_metadata_owner_active ON file_metadata (owner_user_id) WHERE deleted_at IS NULL;