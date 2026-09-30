package com.vithey.content.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import java.time.OffsetDateTime;
import java.util.UUID;

@Schema(name = "CommentResponse")
public record CommentResponse(
    @Schema(example = "c0ffee00-0000-4000-8000-000000000001") UUID commentId,
    @Schema(example = "a1b2c3d4-e5f6-7890-abcd-ef1234567890") UUID postId,
    AuthorSummaryResponse author,
    @Schema(example = "Great post!") String text,
    @Schema(example = "2026-07-28T02:05:00Z") OffsetDateTime createdAt
) {
}
