package com.vithey.notification.event.payload;

import java.time.OffsetDateTime;
import java.util.UUID;

public record CommentAddedEvent(UUID commentId, UUID postId, UUID authorId, String text, OffsetDateTime createdAt) {
}
