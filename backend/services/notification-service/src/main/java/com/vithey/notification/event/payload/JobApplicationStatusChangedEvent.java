package com.vithey.notification.event.payload;

import java.time.OffsetDateTime;
import java.util.UUID;

public record JobApplicationStatusChangedEvent(
    UUID applicationId,
    UUID jobPostId,
    UUID applicantId,
    String previousStatus,
    String newStatus,
    UUID updatedBy,
    OffsetDateTime updatedAt
) {
}
