package com.vithey.content.dto.response;

import java.util.UUID;

public record ProfileResponse(
    UUID userId,
    String fullName,
    String avatarUrl
) {
}
