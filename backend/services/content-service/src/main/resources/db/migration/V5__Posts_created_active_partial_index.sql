-- Global active feed ordering (replaces V1 idx_posts_created, with soft-delete filter)
CREATE INDEX idx_posts_created_active
    ON posts (created_at DESC)
    WHERE deleted_at IS NULL;
