package com.vithey.notification.event.payload;

import java.time.OffsetDateTime;
import java.util.UUID;

public record ReactionAddedEvent(UUID reactionId, UUID postId, UUID userId, OffsetDateTime createdAt) {
}
