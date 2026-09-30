DROP INDEX IF EXISTS idx_posts_created;

CREATE INDEX IF NOT EXISTS idx_posts_author_created_active
    ON posts (author_id, created_at DESC)
    WHERE deleted_at IS NULL;

DROP INDEX IF EXISTS idx_posts_author_created;

ALTER TABLE posts DROP CONSTRAINT IF EXISTS chk_posts_type;
ALTER TABLE posts
    ADD CONSTRAINT chk_posts_type
    CHECK (type IN ('VIDEO', 'POSTER', 'JOB', 'STANDARD'));

CREATE INDEX IF NOT EXISTS idx_follows_follower_created
    ON follows (follower_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_follows_following_created
    ON follows (following_id, created_at DESC);

DROP INDEX IF EXISTS idx_follows_follower;
DROP INDEX IF EXISTS idx_follows_following;

DROP INDEX IF EXISTS idx_comments_author;
DROP INDEX IF EXISTS idx_reactions_post;
DROP INDEX IF EXISTS idx_mentions_comment;
DROP INDEX IF EXISTS idx_mentions_user;
