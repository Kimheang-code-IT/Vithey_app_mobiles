CREATE INDEX IF NOT EXISTS idx_reactions_post
    ON reactions (post_id);

CREATE INDEX IF NOT EXISTS idx_mentions_comment
    ON mentions (comment_id);
