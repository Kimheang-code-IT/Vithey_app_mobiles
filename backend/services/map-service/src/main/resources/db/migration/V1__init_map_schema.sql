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
