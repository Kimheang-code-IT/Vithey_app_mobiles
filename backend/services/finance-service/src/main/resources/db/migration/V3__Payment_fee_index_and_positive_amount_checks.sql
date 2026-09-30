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
