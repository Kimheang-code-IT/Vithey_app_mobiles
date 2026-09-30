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
