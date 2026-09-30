package com.vithey.file.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.vithey.file.entity.StoredFileType;
import io.swagger.v3.oas.annotations.media.Schema;
import java.time.OffsetDateTime;
import java.util.UUID;

@Schema(name = "FileMetadataResponse", example = """
    {
      "file_id": "1ae1e48f-2a5a-4b91-af42-ecf3cc0acf54",
      "file_name": "avatar.png",
      "type": "AVATAR",
      "mime_type": "image/png",
      "size_bytes": 24576,
      "url": "http://localhost:19000/avatars/user-id/file-id/avatar.png?X-Amz-Algorithm=...",
      "created_at": "2026-07-27T15:00:00Z"
    }
    """)
public record FileMetadataResponse(
    @Schema(example = "1ae1e48f-2a5a-4b91-af42-ecf3cc0acf54") UUID fileId,
    @Schema(example = "avatar.png") String fileName,
    @JsonProperty("type")
    @Schema(name = "type", example = "AVATAR") StoredFileType fileType,
    @Schema(example = "image/png") String mimeType,
    @Schema(example = "24576") long sizeBytes,
    @Schema(example = "http://localhost:19000/avatars/.../avatar.png?X-Amz-Algorithm=...") String url,
    @Schema(example = "2026-07-27T15:00:00Z") OffsetDateTime createdAt
) {
}
