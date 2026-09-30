package com.vithey.career.dto.response;

import java.util.UUID;

/**
 * Response for {@code GET /api/v1/job-applications/{applicationId}/cv-preview}.
 * Fields are serialized snake_case by the global SNAKE_CASE naming strategy.
 */
public record CvPreviewResponse(
    UUID applicationId,
    UUID cvFileId,
    String cvFileName,
    String downloadUrl
) {
}
