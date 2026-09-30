package com.vithey.notification.service;

import com.vithey.notification.dto.response.NotificationResponse;
import com.vithey.notification.dto.response.UnreadCountResponse;
import com.vithey.notification.entity.Notification;
import com.vithey.notification.entity.NotificationType;
import com.vithey.notification.exception.ApiException;
import com.vithey.notification.exception.ErrorCode;
import com.vithey.notification.mapper.NotificationMapper;
import com.vithey.notification.repository.NotificationRepository;
import com.vithey.notification.util.ApiResponseWrapper;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class NotificationService {

  private static final int MAX_LIMIT = 50;

  private final NotificationRepository notificationRepository;
  private final NotificationMapper notificationMapper;
  private final FcmPushService fcmPushService;

  public NotificationService(
      NotificationRepository notificationRepository,
      NotificationMapper notificationMapper,
      FcmPushService fcmPushService
  ) {
    this.notificationRepository = notificationRepository;
    this.notificationMapper = notificationMapper;
    this.fcmPushService = fcmPushService;
  }

  @Transactional(readOnly = true)
  public ApiResponseWrapper<List<NotificationResponse>> listNotifications(
      UUID userId, int page, int limit, Boolean isRead
  ) {
    int safePage = Math.max(page, 1);
    int safeLimit = Math.min(Math.max(limit, 1), MAX_LIMIT);
    PageRequest pageable = PageRequest.of(safePage - 1, safeLimit);

    Page<Notification> notifications =
        notificationRepository.findByUserIdFilteringRead(userId, isRead, pageable);
    List<NotificationResponse> content = notifications.getContent().stream()
        .map(notificationMapper::toResponse)
        .toList();

    long unreadTotal = notificationRepository.countByUserIdAndReadFalse(userId);
    return ApiResponseWrapper.paginated(
        content,
        new ApiResponseWrapper.Meta(
            safePage, safeLimit, notifications.getTotalElements(), notifications.getTotalPages(), unreadTotal)
    );
  }

  @Transactional(readOnly = true)
  public UnreadCountResponse unreadCount(UUID userId) {
    return new UnreadCountResponse(notificationRepository.countByUserIdAndReadFalse(userId));
  }

  @Transactional
  public NotificationResponse markRead(UUID notificationId, UUID userId) {
    Notification notification = notificationRepository.findById(notificationId)
        .filter(value -> value.getUserId().equals(userId))
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND));
    if (!notification.isRead()) {
      notification.setRead(true);
      notification.setReadAt(OffsetDateTime.now(ZoneOffset.UTC));
      notification = notificationRepository.save(notification);
    }
    return notificationMapper.toResponse(notification);
  }

  @Transactional
  public long markAllRead(UUID userId) {
    return notificationRepository.markAllRead(userId, OffsetDateTime.now(ZoneOffset.UTC));
  }

  @Transactional
  public void delete(UUID notificationId, UUID userId) {
    Notification notification = notificationRepository.findById(notificationId)
        .filter(value -> value.getUserId().equals(userId))
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND));
    notificationRepository.delete(notification);
  }

  /**
   * Persists an event-driven notification (idempotent by dedupe key) and pushes FCM.
   * Returns {@code null} when skipped (self-action or duplicate dedupe key).
   */
  @Transactional
  public NotificationResponse createAndPush(
      UUID userId,
      NotificationType type,
      String event,
      String title,
      String body,
      UUID actorId,
      String actorName,
      String actorAvatarUrl,
      Map<String, Object> destination,
      String dedupeKey
  ) {
    if (userId == null) {
      return null;
    }
    if (dedupeKey != null && notificationRepository.existsByUserIdAndDedupeKey(userId, dedupeKey)) {
      return null;
    }

    OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
    Notification notification = new Notification();
    notification.setId(UUID.randomUUID());
    notification.setUserId(userId);
    notification.setType(type);
    notification.setEvent(event);
    notification.setTitle(title);
    notification.setBody(body);
    notification.setActorId(actorId);
    notification.setActorName(actorName);
    notification.setActorAvatarUrl(actorAvatarUrl);
    notification.setDestination(destination);
    notification.setDedupeKey(dedupeKey);
    notification.setReferenceId(destinationUuid(destination, "reference_id"));
    notification.setReferenceType(destinationString(destination, "reference_type"));
    notification.setRead(false);
    notification.setCreatedAt(now);

    Notification saved = notificationRepository.save(notification);
    NotificationResponse response = notificationMapper.toResponse(saved);
    fcmPushService.sendPush(userId, saved);
    return response;
  }

  private UUID destinationUuid(Map<String, Object> destination, String key) {
    String value = destinationString(destination, key);
    try {
      return value == null ? null : UUID.fromString(value);
    } catch (IllegalArgumentException exception) {
      return null;
    }
  }

  private String destinationString(Map<String, Object> destination, String key) {
    if (destination == null) {
      return null;
    }
    Object value = destination.get(key);
    return value == null ? null : value.toString();
  }
}
