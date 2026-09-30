package com.vithey.notification.event.payload;

import java.time.OffsetDateTime;
import java.util.UUID;

public record FollowCreatedEvent(UUID followId, UUID followerId, UUID followingId, OffsetDateTime createdAt) {
}
