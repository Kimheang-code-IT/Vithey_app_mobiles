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
