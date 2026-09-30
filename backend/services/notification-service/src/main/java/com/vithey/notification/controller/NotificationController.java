package com.vithey.notification.controller;

import com.vithey.notification.dto.response.MarkAllReadResponse;
import com.vithey.notification.dto.response.NotificationResponse;
import com.vithey.notification.dto.response.UnreadCountResponse;
import com.vithey.notification.security.CurrentUserProvider;
import com.vithey.notification.service.NotificationService;
import com.vithey.notification.util.ApiResponseWrapper;
import java.util.List;
import java.util.UUID;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/notifications")
public class NotificationController {

  private final NotificationService notificationService;
  private final CurrentUserProvider currentUserProvider;

  public NotificationController(
      NotificationService notificationService,
      CurrentUserProvider currentUserProvider
  ) {
    this.notificationService = notificationService;
    this.currentUserProvider = currentUserProvider;
  }

  @GetMapping
  ResponseEntity<ApiResponseWrapper<List<NotificationResponse>>> listNotifications(
      @RequestParam(defaultValue = "1") int page,
      @RequestParam(defaultValue = "20") int limit,
      @RequestParam(required = false) Boolean isRead
  ) {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(notificationService.listNotifications(userId, page, limit, isRead));
  }

  @GetMapping("/unread-count")
  ResponseEntity<ApiResponseWrapper<UnreadCountResponse>> unreadCount() {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(notificationService.unreadCount(userId)));
  }

  @PatchMapping("/read-all")
  ResponseEntity<ApiResponseWrapper<MarkAllReadResponse>> markAllRead() {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    long updated = notificationService.markAllRead(userId);
    return ResponseEntity.ok(ApiResponseWrapper.success(new MarkAllReadResponse(updated)));
  }

  @PatchMapping("/{notificationId}/read")
  ResponseEntity<ApiResponseWrapper<NotificationResponse>> markRead(@PathVariable UUID notificationId) {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(notificationService.markRead(notificationId, userId)));
  }

  @DeleteMapping("/{notificationId}")
  ResponseEntity<Void> delete(@PathVariable UUID notificationId) {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    notificationService.delete(notificationId, userId);
    return ResponseEntity.noContent().build();
  }
}
