-- ============================================================================
-- Vithey - complete database schema (all service databases)
-- ----------------------------------------------------------------------------
-- Generated from the Flyway migrations in
--   backend/services/*/src/main/resources/db/migration
-- plus the ai_core schema (ai_db, which ai_core also creates at runtime).
--
-- HOW TO USE (psql as a superuser):
--   psql -U postgres -f vithey_schema.sql
--
-- NOTES:
--   * For FRESH databases only. Do not also run per-service Flyway against
--     the same database - pick one mechanism.
--   * \connect is a psql meta-command. With a GUI client, run each
--     "-- Database: xxx" section against that database.
--   * Requires PostgreSQL 14+; the pg_trgm extension is created for user_db.
--   * career_db historically has two V3 migration files; both are included.
-- ============================================================================

-- ============================================================================
-- 0. Create databases (run once; fails if they already exist)
-- ============================================================================
CREATE DATABASE auth_db;
CREATE DATABASE user_db;
CREATE DATABASE file_db;
CREATE DATABASE content_db;
CREATE DATABASE career_db;
CREATE DATABASE finance_db;
CREATE DATABASE chat_db;
CREATE DATABASE notification_db;
CREATE DATABASE ai_db;
CREATE DATABASE map_db;


-- ============================================================================
-- Database: auth_db  (auth-service)
-- ============================================================================
\connect auth_db

-- source: V1__init_auth_schema.sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(32) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(160) NOT NULL,
  role VARCHAR(32) NOT NULL CHECK (role IN ('USER', 'STUDENT', 'COMPANY', 'ADMIN')),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  is_student_verified BOOLEAN NOT NULL DEFAULT FALSE,
  is_email_verified BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  deleted_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX idx_users_email_active ON users (lower(email)) WHERE deleted_at IS NULL;
CREATE UNIQUE INDEX idx_users_phone_active ON users (phone) WHERE deleted_at IS NULL;

CREATE TABLE refresh_tokens (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash VARCHAR(255) NOT NULL UNIQUE,
  expires_at TIMESTAMPTZ NOT NULL,
  revoked_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE password_reset_tokens (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash VARCHAR(255) NOT NULL UNIQUE,
  expires_at TIMESTAMPTZ NOT NULL,
  used_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE email_verification_tokens (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash VARCHAR(255) NOT NULL UNIQUE,
  expires_at TIMESTAMPTZ NOT NULL,
  used_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE student_verifications (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  student_id VARCHAR(64) NOT NULL,
  university_email VARCHAR(255) NOT NULL,
  status VARCHAR(32) NOT NULL CHECK (status IN ('PENDING', 'VERIFIED', 'REJECTED')),
  verified_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_expires_at ON refresh_tokens(expires_at);
CREATE INDEX idx_password_reset_tokens_user_id ON password_reset_tokens(user_id);
CREATE INDEX idx_password_reset_tokens_expires_at ON password_reset_tokens(expires_at);
CREATE INDEX idx_email_verification_tokens_user_id ON email_verification_tokens(user_id);
CREATE INDEX idx_email_verification_tokens_expires_at ON email_verification_tokens(expires_at);
CREATE INDEX idx_student_verifications_status ON student_verifications(status);
CREATE UNIQUE INDEX idx_student_verifications_university_email ON student_verifications (lower(university_email));

-- source: V2__Soft_delete_unique_email_phone_and_cascade_tokens.sql
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

-- source: V3__Drop_unused_token_and_student_verification_indexes.sql
-- Repos only look up tokens by token_hash (UNIQUE). Status has no admin filter yet.
-- Keep student_verifications.user_id UNIQUE (serves findByUserId).

DROP INDEX IF EXISTS idx_refresh_tokens_user_id;
DROP INDEX IF EXISTS idx_refresh_tokens_expires_at;
DROP INDEX IF EXISTS idx_password_reset_tokens_user_id;
DROP INDEX IF EXISTS idx_password_reset_tokens_expires_at;
DROP INDEX IF EXISTS idx_email_verification_tokens_user_id;
DROP INDEX IF EXISTS idx_email_verification_tokens_expires_at;
DROP INDEX IF EXISTS idx_student_verifications_status;

-- source: V4__Student_verification_cascade_and_university_email_unique.sql
-- Precheck if migrate fails on uniqueness:
-- SELECT LOWER(university_email), COUNT(*) FROM student_verifications
-- GROUP BY LOWER(university_email) HAVING COUNT(*) > 1;

ALTER TABLE student_verifications DROP CONSTRAINT IF EXISTS student_verifications_user_id_fkey;
ALTER TABLE student_verifications
    ADD CONSTRAINT student_verifications_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE;

CREATE UNIQUE INDEX uq_student_verifications_university_email
    ON student_verifications (LOWER(university_email));

-- source: V5__user_external_identities.sql
-- Provider-neutral external identity linkage (Google sign-in, Apple, ...).
--
-- A Vithey account may be linked to one or more external identity providers.
-- The provider subject is the stable, provider-issued identifier (Google `sub`),
-- never the email address, because an account email can change over time.

CREATE TABLE user_external_identities (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  provider VARCHAR(32) NOT NULL,
  provider_subject VARCHAR(255) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  CONSTRAINT uq_user_external_identities_provider_subject UNIQUE (provider, provider_subject)
);

CREATE INDEX idx_user_external_identities_user_id
    ON user_external_identities (user_id);

-- Accounts created through a trusted external provider (for example Google)
-- do not supply a phone number. Registration still requires a phone, and the
-- existing partial unique index (idx_users_phone_active) keeps non-null phones
-- unique while allowing multiple NULLs.
ALTER TABLE users ALTER COLUMN phone DROP NOT NULL;

-- ============================================================================
-- Database: user_db  (user-profile-service)
-- ============================================================================
\connect user_db

-- source: V1__init_profile_schema.sql
CREATE TABLE profiles (
    user_id UUID PRIMARY KEY,
    full_name VARCHAR(160) NOT NULL,
    bio TEXT,
    avatar_file_id UUID,
    avatar_url TEXT,
    telegram_link TEXT,
    facebook_link TEXT,
    university VARCHAR(160),
    major VARCHAR(160),
    graduation_year INTEGER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_profiles_graduation_year CHECK (graduation_year IS NULL OR graduation_year BETWEEN 1950 AND 2100)
);

CREATE TABLE user_settings (
    user_id UUID PRIMARY KEY,
    language VARCHAR(8) NOT NULL DEFAULT 'en',
    theme VARCHAR(16) NOT NULL DEFAULT 'system',
    notification_prefs JSONB NOT NULL DEFAULT '{}'::jsonb,
    privacy_prefs JSONB NOT NULL DEFAULT '{}'::jsonb,
    fcm_token TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_user_settings_language CHECK (language IN ('en','km')),
    CONSTRAINT chk_user_settings_theme CHECK (theme IN ('light','dark','system'))
);

CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX idx_profiles_full_name_trgm ON profiles USING GIN (full_name gin_trgm_ops);

-- source: V2__profile_extended_fields.sql
ALTER TABLE profiles
    ADD COLUMN location VARCHAR(160),
    ADD COLUMN date_of_birth DATE,
    ADD COLUMN workplace VARCHAR(160),
    ADD COLUMN portfolio_url TEXT,
    ADD COLUMN phone VARCHAR(32),
    ADD COLUMN email VARCHAR(160),
    ADD COLUMN skills JSONB NOT NULL DEFAULT '[]'::jsonb,
    ADD COLUMN education JSONB NOT NULL DEFAULT '[]'::jsonb,
    ADD COLUMN field_visibility JSONB NOT NULL DEFAULT '{}'::jsonb;

-- source: V3__Enable_pg_trgm_and_full_name_gin_index.sql
-- Requires CREATE privilege on extension (local Docker postgres user is fine;
-- managed Postgres may need a one-time DBA grant for pg_trgm).
CREATE EXTENSION IF NOT EXISTS pg_trgm;

DROP INDEX IF EXISTS idx_profiles_full_name;

CREATE INDEX IF NOT EXISTS idx_profiles_full_name_trgm
    ON profiles
    USING GIN (LOWER(full_name) gin_trgm_ops);

-- ============================================================================
-- Database: file_db  (file-service)
-- ============================================================================
\connect file_db

-- source: V1__init_file_schema.sql
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

-- source: V2__Drop_unused_file_metadata_indexes.sql
DROP INDEX IF EXISTS idx_file_metadata_owner_user_id;
DROP INDEX IF EXISTS idx_file_metadata_file_type;
DROP INDEX IF EXISTS idx_file_metadata_active;

-- source: V3__File_type_size_checks_and_owner_active_index.sql
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

-- ============================================================================
-- Database: content_db  (content-service)
-- ============================================================================
\connect content_db

-- source: V1__init_content_schema.sql
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

-- source: V2__Content_indexes_checks_and_drop_dead.sql
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

-- source: V3__Restore_reaction_and_mention_indexes.sql
CREATE INDEX IF NOT EXISTS idx_reactions_post
    ON reactions (post_id);

CREATE INDEX IF NOT EXISTS idx_mentions_comment
    ON mentions (comment_id);

-- source: V4__Cascade_deletes_and_no_self_follow.sql
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

-- source: V5__Posts_created_active_partial_index.sql
-- Global active feed ordering (replaces V1 idx_posts_created, with soft-delete filter)
CREATE INDEX idx_posts_created_active
    ON posts (created_at DESC)
    WHERE deleted_at IS NULL;

-- ============================================================================
-- Database: career_db  (career-service)
-- ============================================================================
\connect career_db

-- source: V1__init_career_schema.sql
CREATE TABLE user_cvs (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    cv_file_id UUID NOT NULL UNIQUE,
    file_name VARCHAR(255) NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX idx_user_cvs_user_id ON user_cvs (user_id);

CREATE TABLE job_applications (
    id UUID PRIMARY KEY,
    job_post_id UUID NOT NULL,
    applicant_id UUID NOT NULL,
    cv_file_id UUID NOT NULL,
    cover_note TEXT,
    status VARCHAR(32) NOT NULL,
    applied_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    CONSTRAINT uq_job_applications_post_applicant UNIQUE (job_post_id, applicant_id),
    CONSTRAINT chk_job_applications_status CHECK (status IN ('PENDING','UNDER_REVIEW','ACCEPTED','REJECTED','WITHDRAWN','REVIEWED')),
    CONSTRAINT fk_job_applications_cv_file FOREIGN KEY (cv_file_id) REFERENCES user_cvs (cv_file_id)
);

CREATE INDEX idx_job_applications_applicant ON job_applications (applicant_id);
CREATE INDEX idx_job_applications_status ON job_applications (status);
CREATE INDEX idx_job_applications_job_post ON job_applications (job_post_id);

-- source: V2__application_timeline_and_idempotency.sql
ALTER TABLE job_applications
    ADD COLUMN review_started_at TIMESTAMPTZ,
    ADD COLUMN decided_at TIMESTAMPTZ,
    ADD COLUMN reviewer_note TEXT,
    ADD COLUMN idempotency_key VARCHAR(128);

CREATE UNIQUE INDEX uq_job_applications_applicant_idempotency
    ON job_applications (applicant_id, idempotency_key)
    WHERE idempotency_key IS NOT NULL;

-- source: V3__Job_application_composite_indexes_and_status_check.sql
CREATE INDEX IF NOT EXISTS idx_job_applications_applicant_applied
    ON job_applications (applicant_id, applied_at DESC);

CREATE INDEX IF NOT EXISTS idx_job_applications_post_applied
    ON job_applications (job_post_id, applied_at DESC);

DROP INDEX IF EXISTS idx_job_applications_status;
DROP INDEX IF EXISTS idx_job_applications_applicant;
DROP INDEX IF EXISTS idx_job_applications_job_post;

ALTER TABLE job_applications DROP CONSTRAINT IF EXISTS chk_job_applications_status;
ALTER TABLE job_applications
    ADD CONSTRAINT chk_job_applications_status
    CHECK (status IN ('PENDING', 'REVIEWED', 'ACCEPTED', 'REJECTED', 'UNDER_REVIEW', 'WITHDRAWN'));

-- source: V3__User_cv_file_unique_and_application_fk.sql
-- Precheck if migrate fails on uniqueness:
-- SELECT cv_file_id, COUNT(*) FROM user_cvs GROUP BY cv_file_id HAVING COUNT(*) > 1;
-- Orphan apps (would fail FK):
-- SELECT ja.id FROM job_applications ja
-- LEFT JOIN user_cvs uc ON uc.cv_file_id = ja.cv_file_id
-- WHERE uc.cv_file_id IS NULL;

CREATE UNIQUE INDEX uq_user_cvs_cv_file_id
    ON user_cvs (cv_file_id);

-- NOTE: career_db has two historical V3 files (see the two source blocks above);
-- V1 already created this FK, so guard it to keep this consolidated file runnable.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_job_applications_cv_file'
    ) THEN
        ALTER TABLE job_applications
            ADD CONSTRAINT fk_job_applications_cv_file
            FOREIGN KEY (cv_file_id) REFERENCES user_cvs (cv_file_id);
    END IF;
END $$;

-- ============================================================================
-- Database: finance_db  (finance-service)
-- ============================================================================
\connect finance_db

-- source: V1__init_finance_schema.sql
CREATE TABLE student_finance_accounts (
    user_id UUID PRIMARY KEY,
    student_id VARCHAR(64) NOT NULL,
    linked_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE fee_categories (
    id UUID PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE fees (
    id UUID PRIMARY KEY,
    category_id UUID NOT NULL REFERENCES fee_categories (id),
    name VARCHAR(180) NOT NULL,
    amount NUMERIC(14, 2) NOT NULL,
    currency VARCHAR(8) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    CONSTRAINT chk_fees_amount_positive CHECK (amount > 0)
);
CREATE INDEX idx_fees_category_id ON fees (category_id);

CREATE TABLE payments (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    fee_id UUID NOT NULL REFERENCES fees (id),
    amount NUMERIC(14, 2) NOT NULL,
    currency VARCHAR(8) NOT NULL,
    status VARCHAR(32) NOT NULL,
    due_date DATE,
    paid_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    CONSTRAINT chk_payments_amount_positive CHECK (amount > 0),
    CONSTRAINT chk_payments_status CHECK (status IN ('PENDING','PAID','OVERDUE','CANCELLED'))
);

CREATE INDEX idx_payments_user ON payments (user_id);
CREATE INDEX idx_payments_status_due ON payments (status, due_date);
CREATE INDEX idx_payments_fee_id ON payments (fee_id);

INSERT INTO fee_categories (id, name, description, created_at) VALUES
    ('11111111-1111-1111-1111-111111111101', 'Tuition', 'Semester tuition fees', TIMESTAMPTZ '2026-01-01 00:00:00+00'),
    ('11111111-1111-1111-1111-111111111102', 'Services', 'Campus service fees', TIMESTAMPTZ '2026-01-01 00:00:00+00');

INSERT INTO fees (id, category_id, name, amount, currency, created_at) VALUES
    ('22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', 'Tuition Semester 1', 1500000.00, 'KHR', TIMESTAMPTZ '2026-01-01 00:00:00+00'),
    ('22222222-2222-2222-2222-222222222202', '11111111-1111-1111-1111-111111111101', 'Tuition Semester 2', 1500000.00, 'KHR', TIMESTAMPTZ '2026-01-01 00:00:00+00'),
    ('22222222-2222-2222-2222-222222222203', '11111111-1111-1111-1111-111111111102', 'Library Membership', 25000.00, 'KHR', TIMESTAMPTZ '2026-01-01 00:00:00+00');

-- source: V2__Payment_indexes_and_status_check.sql
CREATE INDEX IF NOT EXISTS idx_payments_user_due_created
    ON payments (user_id, due_date ASC, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_payments_unpaid_due_date
    ON payments (due_date)
    WHERE status <> 'PAID';

DROP INDEX IF EXISTS idx_payments_user;
DROP INDEX IF EXISTS idx_payments_status;
DROP INDEX IF EXISTS idx_payments_due_date;

ALTER TABLE payments DROP CONSTRAINT IF EXISTS chk_payments_status;
ALTER TABLE payments
    ADD CONSTRAINT chk_payments_status
    CHECK (status IN ('UNPAID', 'PAID', 'OVERDUE', 'PENDING', 'CANCELLED'));

CREATE INDEX IF NOT EXISTS idx_fees_category_id
    ON fees (category_id);

-- source: V3__Payment_fee_index_and_positive_amount_checks.sql
CREATE INDEX IF NOT EXISTS idx_payments_fee_id
    ON payments (fee_id);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'chk_fees_amount_positive'
    ) THEN
        ALTER TABLE fees
            ADD CONSTRAINT chk_fees_amount_positive
            CHECK (amount > 0);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'chk_payments_amount_positive'
    ) THEN
        ALTER TABLE payments
            ADD CONSTRAINT chk_payments_amount_positive
            CHECK (amount > 0);
    END IF;
END $$;

-- source: V4__payment_transactions.sql
CREATE TABLE payment_transactions (
    id UUID PRIMARY KEY,
    payment_id UUID NOT NULL REFERENCES payments (id),
    user_id UUID NOT NULL,
    merchant_reference VARCHAR(120) NOT NULL,
    amount NUMERIC(14, 2) NOT NULL,
    currency VARCHAR(8) NOT NULL,
    provider_name VARCHAR(40) NOT NULL,
    provider_payment_id VARCHAR(80),
    provider_reference VARCHAR(80),
    status VARCHAR(32) NOT NULL,
    failure_code VARCHAR(64),
    failure_message VARCHAR(255),
    payment_method VARCHAR(32),
    scenario VARCHAR(32),
    idempotency_key VARCHAR(120),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    completed_at TIMESTAMPTZ,
    CONSTRAINT chk_payment_transactions_amount_positive CHECK (amount > 0),
    CONSTRAINT chk_payment_transactions_status
        CHECK (status IN ('PENDING', 'PROCESSING', 'SUCCESS', 'FAILED', 'CANCELLED'))
);

CREATE INDEX idx_payment_transactions_payment ON payment_transactions (payment_id);
CREATE INDEX idx_payment_transactions_user ON payment_transactions (user_id);

CREATE UNIQUE INDEX uq_payment_transactions_idempotency
    ON payment_transactions (idempotency_key)
    WHERE idempotency_key IS NOT NULL;

-- ============================================================================
-- Database: chat_db  (chat-service)
-- ============================================================================
\connect chat_db

-- source: V1__init_chat_schema.sql
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

-- source: V2__message_media_and_reply.sql
ALTER TABLE messages
    ADD COLUMN message_type VARCHAR(16) NOT NULL DEFAULT 'TEXT',
    ADD COLUMN file_id UUID,
    ADD COLUMN reply_to_message_id UUID REFERENCES messages (id),
    ADD COLUMN client_message_id VARCHAR(64),
    ADD COLUMN deleted_at TIMESTAMPTZ;

ALTER TABLE messages ALTER COLUMN text DROP NOT NULL;

CREATE UNIQUE INDEX uq_messages_client_id
    ON messages (conversation_id, sender_id, client_message_id)
    WHERE client_message_id IS NOT NULL;

-- source: V3__cascade_deletes_checks_and_indexes.sql
-- V3 (consolidated): cascade deletes, widened status/role checks, list indexes.
-- Supersedes the three conflicting V3 scripts that previously shared this version.

-- 1) Cascade deletes from conversations to participants and messages
ALTER TABLE conversation_participants DROP CONSTRAINT IF EXISTS conversation_participants_conversation_id_fkey;
ALTER TABLE conversation_participants
    ADD CONSTRAINT conversation_participants_conversation_id_fkey
    FOREIGN KEY (conversation_id) REFERENCES conversations (id) ON DELETE CASCADE;

ALTER TABLE messages DROP CONSTRAINT IF EXISTS messages_conversation_id_fkey;
ALTER TABLE messages
    ADD CONSTRAINT messages_conversation_id_fkey
    FOREIGN KEY (conversation_id) REFERENCES conversations (id) ON DELETE CASCADE;

-- 2) Widen status checks to cover the full request lifecycle
ALTER TABLE conversations DROP CONSTRAINT IF EXISTS chk_conversations_status;
ALTER TABLE conversations
    ADD CONSTRAINT chk_conversations_status
    CHECK (status IN ('PENDING', 'ACTIVE', 'BLOCKED', 'DECLINED', 'ARCHIVED', 'CLOSED'));

ALTER TABLE conversation_participants DROP CONSTRAINT IF EXISTS chk_conversation_participants_role;
ALTER TABLE conversation_participants
    ADD CONSTRAINT chk_conversation_participants_role
    CHECK (role IN ('REQUESTER', 'RECIPIENT', 'MEMBER', 'ADMIN'));

-- 3) Self-action guards (no blocking / reporting yourself)
ALTER TABLE blocks DROP CONSTRAINT IF EXISTS chk_blocks_no_self_block;
ALTER TABLE blocks
    ADD CONSTRAINT chk_blocks_no_self_block
    CHECK (blocker_id <> blocked_id);

ALTER TABLE user_reports DROP CONSTRAINT IF EXISTS chk_user_reports_no_self_report;
ALTER TABLE user_reports
    ADD CONSTRAINT chk_user_reports_no_self_report
    CHECK (reporter_id <> reported_id);

-- 4) Indexes for the conversation list; message status check kept in line with V1
CREATE INDEX IF NOT EXISTS idx_conversations_updated_at
    ON conversations (updated_at DESC);

CREATE INDEX IF NOT EXISTS idx_conversations_status
    ON conversations (status);

ALTER TABLE messages DROP CONSTRAINT IF EXISTS chk_messages_status;
ALTER TABLE messages
    ADD CONSTRAINT chk_messages_status
    CHECK (status IN ('SENT', 'DELIVERED', 'READ', 'DELETED'));

-- idx_messages_sender / idx_user_reports_reporter / idx_user_reports_reported
-- already exist from V1 and remain; idx_blocks_blocker never existed (V1 uses
-- idx_blocks_blocked + the composite PK for blocker lookups).

-- ============================================================================
-- Database: notification_db  (notification-service)
-- ============================================================================
\connect notification_db

-- source: V1__init_notification_schema.sql
CREATE TABLE notifications (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    type VARCHAR(32) NOT NULL,
    title VARCHAR(180) NOT NULL,
    body TEXT NOT NULL,
    reference_id UUID,
    reference_type VARCHAR(64),
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL,
    CONSTRAINT chk_notifications_type CHECK (type IN ('SYSTEM','MESSAGE','APPLICATION_UPDATE','PAYMENT_DUE','MENTION'))
);

CREATE INDEX idx_notifications_user_created ON notifications (user_id, created_at DESC);
CREATE INDEX idx_notifications_user_unread ON notifications (user_id, created_at DESC) WHERE is_read = FALSE;

CREATE TABLE device_tokens (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    fcm_token TEXT NOT NULL,
    platform VARCHAR(16) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    CONSTRAINT uq_device_tokens_fcm_token UNIQUE (fcm_token),
    CONSTRAINT chk_device_tokens_platform CHECK (platform IN ('IOS','ANDROID'))
);

CREATE INDEX idx_device_tokens_user ON device_tokens (user_id);

-- source: V2__Notification_type_and_platform_checks.sql
ALTER TABLE notifications DROP CONSTRAINT IF EXISTS chk_notifications_type;
ALTER TABLE notifications
    ADD CONSTRAINT chk_notifications_type
    CHECK (type IN (
        'SYSTEM', 'MESSAGE', 'APPLICATION_UPDATE', 'PAYMENT_DUE', 'MENTION',
        'LIKE', 'COMMENT', 'FOLLOW', 'CHAT', 'CHAT_REQUEST', 'PAYMENT', 'JOB'
    ));

ALTER TABLE device_tokens DROP CONSTRAINT IF EXISTS chk_device_tokens_platform;
ALTER TABLE device_tokens
    ADD CONSTRAINT chk_device_tokens_platform
    CHECK (platform IN ('ANDROID', 'IOS'));

-- source: V3__Notifications_unread_recency_index.sql
CREATE INDEX idx_notifications_user_read_created
    ON notifications (user_id, is_read, created_at DESC);

DROP INDEX IF EXISTS idx_notifications_user_read;

-- source: V4__notification_ui_upgrade.sql
-- V4: Facebook-style UI upgrade (UPGRADE_FOR_UI.md)
-- Adds event metadata, actor snapshot, structured destination, dedupe key, read_at.

ALTER TABLE notifications
    ADD COLUMN IF NOT EXISTS event VARCHAR(64),
    ADD COLUMN IF NOT EXISTS actor_id UUID,
    ADD COLUMN IF NOT EXISTS actor_name VARCHAR(120),
    ADD COLUMN IF NOT EXISTS actor_avatar_url TEXT,
    ADD COLUMN IF NOT EXISTS destination JSONB,
    ADD COLUMN IF NOT EXISTS dedupe_key VARCHAR(180),
    ADD COLUMN IF NOT EXISTS read_at TIMESTAMPTZ;

-- Canonical API types (legacy internal names already migrated in V2)
ALTER TABLE notifications DROP CONSTRAINT IF EXISTS chk_notifications_type;
ALTER TABLE notifications
    ADD CONSTRAINT chk_notifications_type
    CHECK (type IN (
        'SYSTEM', 'MESSAGE', 'APPLICATION_UPDATE', 'PAYMENT_DUE', 'MENTION',
        'LIKE', 'COMMENT', 'FOLLOW', 'CHAT', 'CHAT_REQUEST', 'PAYMENT', 'JOB',
        'POST_SHARE', 'AI', 'STUDENT_VERIFICATION'
    ));

-- Idempotent event ingestion
CREATE UNIQUE INDEX IF NOT EXISTS ux_notifications_user_dedupe
    ON notifications (user_id, dedupe_key)
    WHERE dedupe_key IS NOT NULL;

-- ============================================================================
-- Database: map_db  (map-service)
-- ============================================================================
\connect map_db

-- source: V1__init_map_schema.sql
-- map_service initial schema (map_db)

CREATE TABLE place_favorites (
    id              UUID PRIMARY KEY,
    user_id         UUID NOT NULL,
    google_place_id VARCHAR(255) NOT NULL,
    name            VARCHAR(255) NOT NULL,
    address         VARCHAR(512),
    latitude        DOUBLE PRECISION NOT NULL,
    longitude       DOUBLE PRECISION NOT NULL,
    category        VARCHAR(64),
    photo_url       VARCHAR(1024),
    created_at      TIMESTAMPTZ NOT NULL,
    updated_at      TIMESTAMPTZ NOT NULL,
    CONSTRAINT uq_place_favorites_user_place UNIQUE (user_id, google_place_id)
);

CREATE INDEX idx_place_favorites_user_created
    ON place_favorites (user_id, created_at DESC);

CREATE TABLE place_search_history (
    id         UUID PRIMARY KEY,
    user_id    UUID NOT NULL,
    query      VARCHAR(100),
    category   VARCHAR(64),
    latitude   DOUBLE PRECISION NOT NULL,
    longitude  DOUBLE PRECISION NOT NULL,
    radius_m   INT NOT NULL DEFAULT 1500,
    created_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX idx_place_search_history_user_created
    ON place_search_history (user_id, created_at DESC);

-- ============================================================================
-- Database: ai_db  (ai_core; also auto-created by ai_core at runtime)
-- ============================================================================
\connect ai_db

-- source: ai_core/vithey_ai/db.py (_SCHEMA_SQL)
CREATE TABLE IF NOT EXISTS ai_chat_sessions (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    topic VARCHAR(32) NOT NULL,
    title VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ai_chat_messages (
    id UUID PRIMARY KEY,
    session_id UUID NOT NULL REFERENCES ai_chat_sessions (id) ON DELETE CASCADE,
    role VARCHAR(16) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ai_cv_interactions (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    section VARCHAR(64) NOT NULL,
    original_text TEXT NOT NULL,
    suggested_text TEXT NOT NULL,
    cv_file_id UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_chat_sessions_user_updated
    ON ai_chat_sessions (user_id, updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_ai_chat_messages_session_created
    ON ai_chat_messages (session_id, created_at);

