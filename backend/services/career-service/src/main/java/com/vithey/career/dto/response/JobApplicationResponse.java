package com.vithey.career.dto.response;

import com.vithey.career.entity.ApplicationStatus;
import java.time.OffsetDateTime;
import java.util.UUID;

public record JobApplicationResponse(
    UUID applicationId,
    UUID jobPostId,
    String jobTitle,
    String organization,
    ApplicantSummaryResponse applicant,
    UUID cvFileId,
    String cvFileName,
    ApplicationStatus status,
    String coverNote,
    OffsetDateTime appliedAt,
    OffsetDateTime reviewStartedAt,
    OffsetDateTime decidedAt,
    String reviewerNote
) {
}
