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
