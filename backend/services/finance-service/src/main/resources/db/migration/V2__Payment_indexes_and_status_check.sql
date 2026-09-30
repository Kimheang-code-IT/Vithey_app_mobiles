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
