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
