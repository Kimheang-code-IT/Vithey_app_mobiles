package com.vithey.chat.dto.realtime;

import java.time.OffsetDateTime;
import java.util.UUID;

public record StompPresencePayload(
    String type,
    UUID userId,
    String status,
    OffsetDateTime lastSeenAt
) {

  public static final String FRAME_TYPE = "PRESENCE";

  public static StompPresencePayload online(UUID userId) {
    return new StompPresencePayload(FRAME_TYPE, userId, "ONLINE", OffsetDateTime.now());
  }

  public static StompPresencePayload offline(UUID userId, OffsetDateTime lastSeenAt) {
    return new StompPresencePayload(FRAME_TYPE, userId, "OFFLINE", lastSeenAt);
  }
}
