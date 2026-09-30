package com.vithey.career.repository;

import com.vithey.career.entity.JobApplication;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface JobApplicationRepository extends JpaRepository<JobApplication, UUID> {

  boolean existsByJobPostIdAndApplicantId(UUID jobPostId, UUID applicantId);

  Page<JobApplication> findByApplicantIdOrderByAppliedAtDesc(UUID applicantId, Pageable pageable);

  Page<JobApplication> findByJobPostIdOrderByAppliedAtDesc(UUID jobPostId, Pageable pageable);

  Optional<JobApplication> findByApplicantIdAndIdempotencyKey(UUID applicantId, String idempotencyKey);

  Page<JobApplication> findByJobPostIdAndApplicantIdOrderByAppliedAtDesc(
      UUID jobPostId,
      UUID applicantId,
      Pageable pageable
  );
}
