package com.vithey.content.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

@Schema(
    name = "UpdateCommentRequest",
    example = """
        {
          "text": "Great post! (edited)"
        }
        """
)
public record UpdateCommentRequest(
    @NotBlank
    @Schema(example = "Great post! (edited)", requiredMode = Schema.RequiredMode.REQUIRED)
    String text
) {
}
