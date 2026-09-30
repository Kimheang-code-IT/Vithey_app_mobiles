CREATE TABLE posts (
    id UUID PRIMARY KEY,
    author_id UUID NOT NULL,
    type VARCHAR(32) NOT NULL,
    content TEXT,
    media_file_id UUID,
    job_title VARCHAR(180),
    job_description TEXT,
    job_requirement TEXT,
    job_deadline DATE,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    deleted_at TIMESTAMPTZ,
    CONSTRAINT chk_posts_type CHECK (type IN ('STANDARD','JOB'))
);

CREATE INDEX idx_posts_author_created ON posts (author_id, created_at DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_posts_created ON posts (created_at DESC) WHERE deleted_at IS NULL;

CREATE TABLE comments (
    id UUID PRIMARY KEY,
    post_id UUID NOT NULL REFERENCES posts (id) ON DELETE CASCADE,
    author_id UUID NOT NULL,
    text TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX idx_comments_post_created ON comments (post_id, created_at DESC);
CREATE INDEX idx_comments_author ON comments (author_id);

CREATE TABLE mentions (
    id UUID PRIMARY KEY,
    comment_id UUID NOT NULL REFERENCES comments (id) ON DELETE CASCADE,
    mentioned_user_id UUID NOT NULL
);

CREATE INDEX idx_mentions_comment ON mentions (comment_id);
CREATE INDEX idx_mentions_user ON mentions (mentioned_user_id);

CREATE TABLE reactions (
    id UUID PRIMARY KEY,
    post_id UUID NOT NULL REFERENCES posts (id) ON DELETE CASCADE,
    user_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    CONSTRAINT uq_reactions_post_user UNIQUE (post_id, user_id)
);

CREATE TABLE follows (
    id UUID PRIMARY KEY,
    follower_id UUID NOT NULL,
    following_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    CONSTRAINT uq_follows_pair UNIQUE (follower_id, following_id),
    CONSTRAINT chk_follows_no_self_follow CHECK (follower_id <> following_id)
);

CREATE INDEX idx_follows_following ON follows (following_id);
