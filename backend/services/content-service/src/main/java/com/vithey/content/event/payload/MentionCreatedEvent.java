package com.vithey.content.event.payload;

import java.util.UUID;

public record MentionCreatedEvent(
    UUID mentionId,
    UUID commentId,
    UUID mentionedUserId,
    UUID postId
) {
}
