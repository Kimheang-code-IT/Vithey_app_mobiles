package com.vithey.content.event.payload;

import java.time.OffsetDateTime;
import java.util.UUID;

public record FollowCreatedEvent(
    UUID followId,
    UUID followerId,
    UUID followingId,
    OffsetDateTime createdAt
) {
}
