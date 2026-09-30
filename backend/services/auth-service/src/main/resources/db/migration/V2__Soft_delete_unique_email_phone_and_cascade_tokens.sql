-- Precheck (run manually if migration fails):
-- SELECT LOWER(email), COUNT(*) FROM users WHERE deleted_at IS NULL GROUP BY LOWER(email) HAVING COUNT(*) > 1;
-- SELECT phone, COUNT(*) FROM users WHERE deleted_at IS NULL GROUP BY phone HAVING COUNT(*) > 1;

-- Replace plain UNIQUE with active-row partial unique indexes (soft-delete safe re-registration)
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_email_key;
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_phone_key;

CREATE UNIQUE INDEX uq_users_email_active
    ON users (LOWER(email))
    WHERE deleted_at IS NULL;

CREATE UNIQUE INDEX uq_users_phone_active
    ON users (phone)
    WHERE deleted_at IS NULL;

-- Cascade disposable auth tokens when a user row is hard-deleted
ALTER TABLE refresh_tokens DROP CONSTRAINT IF EXISTS refresh_tokens_user_id_fkey;
ALTER TABLE refresh_tokens
    ADD CONSTRAINT refresh_tokens_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE;

ALTER TABLE password_reset_tokens DROP CONSTRAINT IF EXISTS password_reset_tokens_user_id_fkey;
ALTER TABLE password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE;

ALTER TABLE email_verification_tokens DROP CONSTRAINT IF EXISTS email_verification_tokens_user_id_fkey;
ALTER TABLE email_verification_tokens
    ADD CONSTRAINT email_verification_tokens_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE;
