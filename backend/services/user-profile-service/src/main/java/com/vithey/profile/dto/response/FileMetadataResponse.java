package com.vithey.profile.dto.response;

import java.util.UUID;

public record FileMetadataResponse(
    UUID fileId,
    String url,
    String type,
    UUID ownerUserId
) {
}
