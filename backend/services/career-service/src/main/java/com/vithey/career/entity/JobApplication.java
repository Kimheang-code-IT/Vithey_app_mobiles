package com.vithey.career.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "job_applications")
@Getter
@Setter
public class JobApplication {

  @Id
  private UUID id;

  @Column(name = "job_post_id", nullable = false)
  private UUID jobPostId;

  @Column(name = "applicant_id", nullable = false)
  private UUID applicantId;

  @Column(name = "cv_file_id", nullable = false)
  private UUID cvFileId;

  @Column(name = "cover_note", columnDefinition = "TEXT")
  private String coverNote;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, length = 32)
  private ApplicationStatus status;

  @Column(name = "applied_at", nullable = false)
  private OffsetDateTime appliedAt;

  @Column(name = "updated_at", nullable = false)
  private OffsetDateTime updatedAt;

  @Column(name = "review_started_at")
  private OffsetDateTime reviewStartedAt;

  @Column(name = "decided_at")
  private OffsetDateTime decidedAt;

  @Column(name = "reviewer_note", columnDefinition = "TEXT")
  private String reviewerNote;

  @Column(name = "idempotency_key", length = 128)
  private String idempotencyKey;
}
