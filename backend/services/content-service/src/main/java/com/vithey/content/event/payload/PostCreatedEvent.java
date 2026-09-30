package com.vithey.content.event.payload;

import com.vithey.content.entity.PostType;
import java.time.OffsetDateTime;
import java.util.UUID;

public record PostCreatedEvent(
    UUID postId,
    UUID authorId,
    PostType type,
    OffsetDateTime createdAt
) {
}
