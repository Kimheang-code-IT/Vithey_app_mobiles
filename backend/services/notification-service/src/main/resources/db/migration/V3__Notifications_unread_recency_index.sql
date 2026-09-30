CREATE INDEX idx_notifications_user_read_created
    ON notifications (user_id, is_read, created_at DESC);

DROP INDEX IF EXISTS idx_notifications_user_read;
