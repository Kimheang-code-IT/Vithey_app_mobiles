package com.vithey.map.dto.response;

import java.time.Instant;

/** One recent search row (max 20 per user). */
public record PlaceHistoryResponse(
    String query,
    String category,
    double latitude,
    double longitude,
    int radiusM,
    Instant createdAt
) {
}
