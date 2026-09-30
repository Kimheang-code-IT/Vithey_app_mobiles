package com.vithey.notification.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.vithey.notification.dto.response.NotificationResponse;
import com.vithey.notification.entity.Notification;
import com.vithey.notification.entity.NotificationType;
import com.vithey.notification.exception.ApiException;
import com.vithey.notification.exception.ErrorCode;
import com.vithey.notification.mapper.NotificationMapper;
import com.vithey.notification.repository.NotificationRepository;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

@ExtendWith(MockitoExtension.class)
class NotificationServiceTest {

  @Mock
  private NotificationRepository notificationRepository;

  @Mock
  private NotificationMapper notificationMapper;

  @Mock
  private FcmPushService fcmPushService;

  @InjectMocks
  private NotificationService notificationService;

  @Test
  void markRead_rejectsForeignNotification() {
    UUID ownerId = UUID.randomUUID();
    UUID otherUserId = UUID.randomUUID();
    UUID notificationId = UUID.randomUUID();

    Notification notification = new Notification();
    notification.setId(notificationId);
    notification.setUserId(ownerId);
    when(notificationRepository.findById(notificationId)).thenReturn(Optional.of(notification));

    ApiException exception = assertThrows(
        ApiException.class,
        () -> notificationService.markRead(notificationId, otherUserId)
    );

    assertEquals(ErrorCode.NOT_FOUND, exception.getErrorCode());
    verify(notificationRepository, never()).save(any());
  }

  @Test
  void delete_rejectsForeignNotification() {
    UUID ownerId = UUID.randomUUID();
    UUID otherUserId = UUID.randomUUID();
    UUID notificationId = UUID.randomUUID();

    Notification notification = new Notification();
    notification.setId(notificationId);
    notification.setUserId(ownerId);
    when(notificationRepository.findById(notificationId)).thenReturn(Optional.of(notification));

    ApiException exception = assertThrows(
        ApiException.class,
        () -> notificationService.delete(notificationId, otherUserId)
    );

    assertEquals(ErrorCode.NOT_FOUND, exception.getErrorCode());
    verify(notificationRepository, never()).delete(any(Notification.class));
  }

  @Test
  void delete_allowsOwner() {
    UUID ownerId = UUID.randomUUID();
    UUID notificationId = UUID.randomUUID();

    Notification notification = new Notification();
    notification.setId(notificationId);
    notification.setUserId(ownerId);
    when(notificationRepository.findById(notificationId)).thenReturn(Optional.of(notification));

    notificationService.delete(notificationId, ownerId);

    verify(notificationRepository).delete(notification);
  }

  @Test
  void listNotifications_passesReadFilterAndCapsLimit() {
    UUID userId = UUID.randomUUID();
    Page<Notification> page = Page.empty();
    when(notificationRepository.findByUserIdFilteringRead(eq(userId), eq(false), any(Pageable.class)))
        .thenReturn(page);
    when(notificationRepository.countByUserIdAndReadFalse(userId)).thenReturn(7L);

    notificationService.listNotifications(userId, 1, 500, false);

    ArgumentCaptor<Pageable> pageableCaptor = ArgumentCaptor.forClass(Pageable.class);
    verify(notificationRepository).findByUserIdFilteringRead(eq(userId), eq(false), pageableCaptor.capture());
    assertEquals(50, pageableCaptor.getValue().getPageSize());
  }

  @Test
  void markRead_isIdempotentAndSetsReadAt() {
    UUID userId = UUID.randomUUID();
    UUID notificationId = UUID.randomUUID();
    Notification notification = new Notification();
    notification.setId(notificationId);
    notification.setUserId(userId);
    notification.setRead(false);
    when(notificationRepository.findById(notificationId)).thenReturn(Optional.of(notification));
    when(notificationRepository.save(notification)).thenReturn(notification);
    when(notificationMapper.toResponse(notification)).thenReturn(
        new NotificationResponse(notificationId, notificationId, "LIKE", "reaction.added",
            "New like", "Someone liked your post.", true, null, null, null, null, null, null, null));

    NotificationResponse response = notificationService.markRead(notificationId, userId);

    assertTrue(response.isRead());
    assertNotNull(notification.getReadAt());
  }

  @Test
  void createAndPush_skipsDuplicateDedupeKey() {
    UUID userId = UUID.randomUUID();
    when(notificationRepository.existsByUserIdAndDedupeKey(userId, "reaction.added:r-1")).thenReturn(true);

    NotificationResponse result = notificationService.createAndPush(
        userId, NotificationType.LIKE, "reaction.added", "New like", "body",
        UUID.randomUUID(), null, null, Map.of("reference_type", "POST"), "reaction.added:r-1");

    assertNull(result);
    verify(notificationRepository, never()).save(any());
  }

  @Test
  void createAndPush_persistsDestinationAndDedupeKey() {
    UUID userId = UUID.randomUUID();
    UUID postId = UUID.randomUUID();
    Notification saved = new Notification();
    saved.setId(UUID.randomUUID());
    saved.setUserId(userId);
    when(notificationRepository.existsByUserIdAndDedupeKey(eq(userId), any())).thenReturn(false);
    when(notificationRepository.save(any(Notification.class))).thenReturn(saved);
    when(notificationMapper.toResponse(saved)).thenReturn(
        new NotificationResponse(saved.getId(), saved.getId(), "LIKE", "reaction.added",
            "New like", "body", false, null, null, null, null, null, null, null));

    notificationService.createAndPush(
        userId, NotificationType.LIKE, "reaction.added", "New like", "body",
        null, null, null, Map.of("reference_type", "POST", "reference_id", postId.toString(), "post_id", postId.toString()),
        "reaction.added:r-1");

    ArgumentCaptor<Notification> captor = ArgumentCaptor.forClass(Notification.class);
    verify(notificationRepository).save(captor.capture());
    Notification persisted = captor.getValue();
    assertEquals("reaction.added", persisted.getEvent());
    assertEquals("reaction.added:r-1", persisted.getDedupeKey());
    assertEquals(postId, persisted.getReferenceId());
    assertEquals("POST", persisted.getReferenceType());
    assertFalse(persisted.isRead());
  }
}
