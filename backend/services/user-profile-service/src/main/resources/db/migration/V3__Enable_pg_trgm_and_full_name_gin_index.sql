-- Requires CREATE privilege on extension (local Docker postgres user is fine;
-- managed Postgres may need a one-time DBA grant for pg_trgm).
CREATE EXTENSION IF NOT EXISTS pg_trgm;

DROP INDEX IF EXISTS idx_profiles_full_name;

CREATE INDEX IF NOT EXISTS idx_profiles_full_name_trgm
    ON profiles
    USING GIN (LOWER(full_name) gin_trgm_ops);
