package com.vithey.notification.service;

import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.AndroidConfig;
import com.google.firebase.messaging.AndroidNotification;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.vithey.notification.entity.Notification;
import com.vithey.notification.entity.NotificationType;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class FcmPushService {

  private static final Logger log = LoggerFactory.getLogger(FcmPushService.class);

  private final DeviceTokenService deviceTokenService;

  public FcmPushService(DeviceTokenService deviceTokenService) {
    this.deviceTokenService = deviceTokenService;
  }

  public void sendPush(UUID userId, Notification notification) {
    if (FirebaseApp.getApps().isEmpty()) {
      log.debug("Firebase not configured; skipping push for user {}", userId);
      return;
    }

    List<String> tokens = deviceTokenService.findTokensForUser(userId);
    if (tokens.isEmpty()) {
      return;
    }

    Map<String, String> data = buildDataPayload(notification);
    String title = notification.getTitle();
    String body = notification.getBody();
    AndroidConfig androidConfig = AndroidConfig.builder()
        .setPriority(AndroidConfig.Priority.HIGH)
        .setNotification(AndroidNotification.builder()
            .setChannelId(channelFor(notification.getType()))
            .build())
        .build();

    for (String token : tokens) {
      try {
        Message message = Message.builder()
            .setToken(token)
            .setNotification(com.google.firebase.messaging.Notification.builder()
                .setTitle(title).setBody(body).build())
            .setAndroidConfig(androidConfig)
            .putAllData(data)
            .build();
        FirebaseMessaging.getInstance().send(message);
      } catch (Exception exception) {
        log.warn("FCM push failed for user {} token {}", userId, token, exception);
      }
    }
  }

  /** All values must be strings — FCM data-payload requirement. */
  private Map<String, String> buildDataPayload(Notification notification) {
    Map<String, String> data = new HashMap<>();
    data.put("notification_id", string(notification.getId()));
    data.put("type", notification.getType() == null ? "" : notification.getType().name());
    data.put("event", string(notification.getEvent()));
    data.put("title", string(notification.getTitle()));
    data.put("body", string(notification.getBody()));
    data.put("actor_id", string(notification.getActorId()));
    data.put("actor_name", string(notification.getActorName()));
    data.put("reference_type", string(notification.getReferenceType()));
    data.put("reference_id", string(notification.getReferenceId()));
    data.put("dedupe_key", string(notification.getDedupeKey()));

    Map<String, Object> destination = notification.getDestination();
    data.put("post_id", destinationString(destination, "post_id"));
    data.put("comment_id", destinationString(destination, "comment_id"));
    data.put("user_id", destinationString(destination, "user_id"));
    data.put("conversation_id", destinationString(destination, "conversation_id"));
    data.put("job_post_id", destinationString(destination, "job_post_id"));
    data.put("application_id", destinationString(destination, "application_id"));
    data.put("payment_id", destinationString(destination, "payment_id"));
    data.put("ai_thread_id", destinationString(destination, "ai_thread_id"));
    return data;
  }

  private String string(UUID value) {
    return value == null ? "" : value.toString();
  }

  private String string(String value) {
    return value == null ? "" : value;
  }

  private String destinationString(Map<String, Object> destination, String key) {
    if (destination == null) {
      return "";
    }
    Object value = destination.get(key);
    return value == null ? "" : value.toString();
  }

  private String channelFor(NotificationType type) {
    return switch (type) {
      case CHAT, CHAT_REQUEST -> "chat";
      case LIKE, COMMENT, MENTION, FOLLOW -> "social";
      case JOB -> "jobs";
      case PAYMENT -> "payments";
      case SYSTEM, STUDENT_VERIFICATION -> "system";
      default -> "system";
    };
  }
}
