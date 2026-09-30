package com.vithey.notification.event.payload;

import java.time.OffsetDateTime;
import java.util.UUID;

public record JobApplicationSubmittedEvent(
    UUID applicationId,
    UUID jobPostId,
    UUID applicantId,
    UUID cvFileId,
    String status,
    OffsetDateTime appliedAt
) {
}
