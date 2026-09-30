package com.vithey.content.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import java.util.UUID;

@Schema(name = "AuthorSummaryResponse")
public record AuthorSummaryResponse(
    @Schema(example = "f984000a-38f4-46e5-a047-019d20a66ce0") UUID userId,
    @Schema(example = "Jane Doe") String fullName,
    @Schema(example = "http://localhost:19000/vithey/avatar.png") String avatarUrl
) {
}
