package com.vithey.chat.dto.response;

import java.util.UUID;

public record ParticipantSummaryResponse(
    UUID userId,
    String fullName,
    String avatarUrl
) {
}
