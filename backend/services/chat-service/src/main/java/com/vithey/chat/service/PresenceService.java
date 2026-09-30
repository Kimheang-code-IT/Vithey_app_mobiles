package com.vithey.chat.service;

import com.vithey.chat.config.ChatProperties;
import com.vithey.chat.dto.realtime.StompPresencePayload;
import com.vithey.chat.repository.ConversationParticipantRepository;
import java.time.Duration;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.UUID;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

@Service
public class PresenceService {

  private static final String KEY_PREFIX = "chat:presence:";

  private final StringRedisTemplate redisTemplate;
  private final ChatProperties chatProperties;
  private final RealtimeMessageService realtimeMessageService;
  private final ConversationParticipantRepository participantRepository;

  public PresenceService(
      StringRedisTemplate redisTemplate,
      ChatProperties chatProperties,
      RealtimeMessageService realtimeMessageService,
      ConversationParticipantRepository participantRepository
  ) {
    this.redisTemplate = redisTemplate;
    this.chatProperties = chatProperties;
    this.realtimeMessageService = realtimeMessageService;
    this.participantRepository = participantRepository;
  }

  public void markOnline(UUID userId) {
    redisTemplate.opsForValue().set(
        key(userId),
        "ONLINE",
        Duration.ofSeconds(chatProperties.presenceTtlSeconds())
    );
    broadcastPresence(userId, true);
  }

  public void refreshHeartbeat(UUID userId) {
    if (Boolean.TRUE.equals(redisTemplate.hasKey(key(userId)))) {
      redisTemplate.expire(key(userId), Duration.ofSeconds(chatProperties.presenceTtlSeconds()));
    } else {
      markOnline(userId);
    }
  }

  public void markOffline(UUID userId) {
    redisTemplate.delete(key(userId));
    broadcastPresence(userId, false);
  }

  public boolean isOnline(UUID userId) {
    return Boolean.TRUE.equals(redisTemplate.hasKey(key(userId)));
  }

  public PresenceSnapshot snapshot(UUID userId) {
    return new PresenceSnapshot(userId, isOnline(userId) ? "ONLINE" : "OFFLINE");
  }

  private void broadcastPresence(UUID userId, boolean online) {
    OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
    StompPresencePayload payload = online
        ? StompPresencePayload.online(userId)
        : StompPresencePayload.offline(userId, now);

    participantRepository.findPartnerUserIds(userId).forEach(partnerId ->
        realtimeMessageService.deliverPresence(partnerId, payload)
    );
  }

  private String key(UUID userId) {
    return KEY_PREFIX + userId;
  }

  public record PresenceSnapshot(UUID userId, String status) {
  }
}
