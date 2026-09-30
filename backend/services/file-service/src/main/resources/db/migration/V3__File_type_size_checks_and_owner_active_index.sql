-- Align the DB check constraint with StoredFileType (AVATAR, CV, POSTER, VIDEO, CHAT_ATTACHMENT).
-- V1 shipped the legacy value list (CV, POST_MEDIA, PROFILE_PICTURE, CHAT_ATTACHMENT);
-- replace it instead of adding a duplicate-named constraint.

ALTER TABLE file_metadata
    DROP CONSTRAINT IF EXISTS chk_file_metadata_file_type;

ALTER TABLE file_metadata
    ADD CONSTRAINT chk_file_metadata_file_type
    CHECK (file_type IN ('AVATAR', 'CV', 'POSTER', 'VIDEO', 'CHAT_ATTACHMENT'));

ALTER TABLE file_metadata
    DROP CONSTRAINT IF EXISTS chk_file_metadata_size_positive;

ALTER TABLE file_metadata
    ADD CONSTRAINT chk_file_metadata_size_positive
    CHECK (size_bytes > 0);

-- V1 already creates this index in some environments; make it idempotent.
CREATE INDEX IF NOT EXISTS idx_file_metadata_owner_active
    ON file_metadata (owner_user_id)
    WHERE deleted_at IS NULL;
