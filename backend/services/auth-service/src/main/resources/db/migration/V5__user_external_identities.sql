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
