package com.vithey.career.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.UUID;

public record FileMetadataResponse(
    UUID fileId,
    String fileName,
    @JsonProperty("type") String fileType,
    String url
) {
}
