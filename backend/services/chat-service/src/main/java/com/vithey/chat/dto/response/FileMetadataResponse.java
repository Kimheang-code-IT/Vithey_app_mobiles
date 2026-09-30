package com.vithey.chat.dto.response;

import java.util.UUID;

public record FileMetadataResponse(
    UUID fileId,
    String fileName,
    String type,
    String mimeType,
    long sizeBytes,
    String url,
    UUID ownerUserId
) {
}
