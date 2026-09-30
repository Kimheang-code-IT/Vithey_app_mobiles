package com.vithey.career.event.payload;

import com.vithey.career.entity.ApplicationStatus;
import java.time.OffsetDateTime;
import java.util.UUID;

public record JobApplicationStatusChangedEvent(
    UUID applicationId,
    UUID jobPostId,
    UUID applicantId,
    ApplicationStatus previousStatus,
    ApplicationStatus newStatus,
    UUID updatedBy,
    OffsetDateTime updatedAt
) {
}
