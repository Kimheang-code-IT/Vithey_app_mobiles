package com.vithey.profile.dto.response;

import java.util.UUID;

public record UserSearchResultResponse(
    UUID userId,
    String fullName,
    String avatarUrl,
    String university,
    String major,
    String headline
) {
}