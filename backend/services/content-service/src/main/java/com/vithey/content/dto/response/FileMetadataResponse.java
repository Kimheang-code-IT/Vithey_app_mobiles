package com.vithey.content.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.UUID;

public record FileMetadataResponse(
    UUID fileId,
    @JsonProperty("type") String fileType,
    String url
) {
}
