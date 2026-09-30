ALTER TABLE comments DROP CONSTRAINT IF EXISTS comments_post_id_fkey;
ALTER TABLE comments
    ADD CONSTRAINT comments_post_id_fkey
    FOREIGN KEY (post_id) REFERENCES posts (id) ON DELETE CASCADE;

ALTER TABLE mentions DROP CONSTRAINT IF EXISTS mentions_comment_id_fkey;
ALTER TABLE mentions
    ADD CONSTRAINT mentions_comment_id_fkey
    FOREIGN KEY (comment_id) REFERENCES comments (id) ON DELETE CASCADE;

ALTER TABLE reactions DROP CONSTRAINT IF EXISTS reactions_post_id_fkey;
ALTER TABLE reactions
    ADD CONSTRAINT reactions_post_id_fkey
    FOREIGN KEY (post_id) REFERENCES posts (id) ON DELETE CASCADE;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'chk_follows_no_self_follow'
    ) THEN
        ALTER TABLE follows
            ADD CONSTRAINT chk_follows_no_self_follow
            CHECK (follower_id <> following_id);
    END IF;
END $$;
