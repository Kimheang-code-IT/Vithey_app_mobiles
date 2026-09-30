-- Precheck if migrate fails on uniqueness:
-- SELECT LOWER(university_email), COUNT(*) FROM student_verifications
-- GROUP BY LOWER(university_email) HAVING COUNT(*) > 1;

ALTER TABLE student_verifications DROP CONSTRAINT IF EXISTS student_verifications_user_id_fkey;
ALTER TABLE student_verifications
    ADD CONSTRAINT student_verifications_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE;

CREATE UNIQUE INDEX uq_student_verifications_university_email
    ON student_verifications (LOWER(university_email));
