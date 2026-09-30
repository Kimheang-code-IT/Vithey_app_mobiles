package com.vithey.career.event.payload;

import com.vithey.career.entity.ApplicationStatus;
import java.time.OffsetDateTime;
import java.util.UUID;

public record JobApplicationSubmittedEvent(
    UUID applicationId,
    UUID jobPostId,
    UUID applicantId,
    UUID cvFileId,
    ApplicationStatus status,
    OffsetDateTime appliedAt
) {
}
