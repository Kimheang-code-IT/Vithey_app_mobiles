CREATE TABLE user_cvs (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    cv_file_id UUID NOT NULL UNIQUE,
    file_name VARCHAR(255) NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX idx_user_cvs_user_id ON user_cvs (user_id);

CREATE TABLE job_applications (
    id UUID PRIMARY KEY,
    job_post_id UUID NOT NULL,
    applicant_id UUID NOT NULL,
    cv_file_id UUID NOT NULL,
    cover_note TEXT,
    status VARCHAR(32) NOT NULL,
    applied_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    CONSTRAINT uq_job_applications_post_applicant UNIQUE (job_post_id, applicant_id),
    CONSTRAINT chk_job_applications_status CHECK (status IN ('PENDING','UNDER_REVIEW','ACCEPTED','REJECTED','WITHDRAWN','REVIEWED')),
    CONSTRAINT fk_job_applications_cv_file FOREIGN KEY (cv_file_id) REFERENCES user_cvs (cv_file_id)
);

CREATE INDEX idx_job_applications_applicant ON job_applications (applicant_id);
CREATE INDEX idx_job_applications_status ON job_applications (status);
CREATE INDEX idx_job_applications_job_post ON job_applications (job_post_id);
