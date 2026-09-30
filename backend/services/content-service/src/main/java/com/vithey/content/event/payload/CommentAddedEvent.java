package com.vithey.content.event.payload;

import java.time.OffsetDateTime;
import java.util.UUID;

public record CommentAddedEvent(
    UUID commentId,
    UUID postId,
    UUID authorId,
    String text,
    OffsetDateTime createdAt
) {
}
