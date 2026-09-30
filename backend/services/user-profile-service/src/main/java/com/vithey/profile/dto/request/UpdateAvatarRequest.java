package com.vithey.profile.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import java.util.UUID;

@Schema(name = "UpdateAvatarRequest", example = """
    {
      "avatar_file_id": "1ae1e48f-2a5a-4b91-af42-ecf3cc0acf54"
    }
    """)
public record UpdateAvatarRequest(
    @Schema(
        description = "File id returned by file-service upload",
        example = "1ae1e48f-2a5a-4b91-af42-ecf3cc0acf54",
        requiredMode = Schema.RequiredMode.REQUIRED
    )
    @NotNull UUID avatarFileId
) {
}
