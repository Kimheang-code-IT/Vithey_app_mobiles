-- Precheck if migrate fails on uniqueness:
-- SELECT cv_file_id, COUNT(*) FROM user_cvs GROUP BY cv_file_id HAVING COUNT(*) > 1;
-- Orphan apps (would fail FK):
-- SELECT ja.id FROM job_applications ja
-- LEFT JOIN user_cvs uc ON uc.cv_file_id = ja.cv_file_id
-- WHERE uc.cv_file_id IS NULL;

CREATE UNIQUE INDEX uq_user_cvs_cv_file_id
    ON user_cvs (cv_file_id);

ALTER TABLE job_applications
    ADD CONSTRAINT fk_job_applications_cv_file
    FOREIGN KEY (cv_file_id) REFERENCES user_cvs (cv_file_id);
