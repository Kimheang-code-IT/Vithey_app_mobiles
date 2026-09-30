package com.vithey.content.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import java.util.List;
import java.util.UUID;

@Schema(
    name = "CreateCommentRequest",
    example = """
        {
          "text": "Great post!",
          "mention_user_ids": ["018a4379-a9e0-4391-8285-c231aeea577c"]
        }
        """
)
public record CreateCommentRequest(
    @NotBlank
    @Schema(example = "Great post!", requiredMode = Schema.RequiredMode.REQUIRED)
    String text,
    @Schema(example = "[\"018a4379-a9e0-4391-8285-c231aeea577c\"]")
    List<UUID> mentionUserIds
) {
}
