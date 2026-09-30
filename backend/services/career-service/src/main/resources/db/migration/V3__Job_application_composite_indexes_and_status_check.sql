CREATE INDEX IF NOT EXISTS idx_job_applications_applicant_applied
    ON job_applications (applicant_id, applied_at DESC);

CREATE INDEX IF NOT EXISTS idx_job_applications_post_applied
    ON job_applications (job_post_id, applied_at DESC);

DROP INDEX IF EXISTS idx_job_applications_status;
DROP INDEX IF EXISTS idx_job_applications_applicant;
DROP INDEX IF EXISTS idx_job_applications_job_post;

ALTER TABLE job_applications DROP CONSTRAINT IF EXISTS chk_job_applications_status;
ALTER TABLE job_applications
    ADD CONSTRAINT chk_job_applications_status
    CHECK (status IN ('PENDING', 'REVIEWED', 'ACCEPTED', 'REJECTED', 'UNDER_REVIEW', 'WITHDRAWN'));
