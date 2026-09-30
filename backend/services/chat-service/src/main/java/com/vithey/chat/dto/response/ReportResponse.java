package com.vithey.chat.dto.response;

import java.time.OffsetDateTime;
import java.util.UUID;

public record ReportResponse(
    UUID reportId,
    UUID reportedId,
    String reason,
    OffsetDateTime createdAt
) {
}
