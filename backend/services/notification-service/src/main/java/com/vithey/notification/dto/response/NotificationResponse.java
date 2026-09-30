package com.vithey.notification.dto.response;

import java.time.OffsetDateTime;
import java.util.Map;
import java.util.UUID;

/**
 * Rich inbox row for the Flutter Notification Center.
 * {@code notification_id} is kept as a backward-compatible alias of {@code id}.
 */
public record NotificationResponse(
    UUID id,
    UUID notificationId,
    String type,
    String event,
    String title,
    String body,
    boolean isRead,
    OffsetDateTime createdAt,
    OffsetDateTime readAt,
    UUID referenceId,
    String referenceType,
    ActorDto actor,
    Map<String, Object> destination,
    String dedupeKey
) {

  public record ActorDto(
      UUID id,
      String fullName,
      String avatarUrl
  ) {
  }
}
