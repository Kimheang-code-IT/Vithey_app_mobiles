package com.vithey.content.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(name = "ReactionSummaryResponse")
public record ReactionSummaryResponse(
    @Schema(example = "3") long reactionCount,
    @Schema(example = "true") boolean userReacted
) {
}
