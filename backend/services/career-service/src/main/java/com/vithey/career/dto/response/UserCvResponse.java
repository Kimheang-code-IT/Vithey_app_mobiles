package com.vithey.career.dto.response;

import java.time.OffsetDateTime;
import java.util.UUID;

public record UserCvResponse(
    UUID userId,
    UUID cvFileId,
    String fileName,
    OffsetDateTime updatedAt
) {
}
