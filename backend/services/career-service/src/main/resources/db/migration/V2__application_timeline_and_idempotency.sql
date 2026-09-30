ALTER TABLE job_applications
    ADD COLUMN review_started_at TIMESTAMPTZ,
    ADD COLUMN decided_at TIMESTAMPTZ,
    ADD COLUMN reviewer_note TEXT,
    ADD COLUMN idempotency_key VARCHAR(128);

CREATE UNIQUE INDEX uq_job_applications_applicant_idempotency
    ON job_applications (applicant_id, idempotency_key)
    WHERE idempotency_key IS NOT NULL;
