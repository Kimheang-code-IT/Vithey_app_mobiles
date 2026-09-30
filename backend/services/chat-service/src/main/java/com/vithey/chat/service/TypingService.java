package com.vithey.chat.service;

import com.vithey.chat.config.ChatProperties;
import com.vithey.chat.dto.realtime.StompTypingPayload;
import java.time.Duration;
import java.util.UUID;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

@Service
public class TypingService {

  private static final String KEY_PREFIX = "chat:typing:";

  private final StringRedisTemplate redisTemplate;
  private final ChatProperties chatProperties;
  private final ConversationAccessService accessService;
  private final RealtimeMessageService realtimeMessageService;

  public TypingService(
      StringRedisTemplate redisTemplate,
      ChatProperties chatProperties,
      ConversationAccessService accessService,
      RealtimeMessageService realtimeMessageService
  ) {
    this.redisTemplate = redisTemplate;
    this.chatProperties = chatProperties;
    this.accessService = accessService;
    this.realtimeMessageService = realtimeMessageService;
  }

  public void handleTyping(UUID conversationId, UUID userId, boolean isTyping) {
    accessService.requireParticipantConversation(conversationId, userId);
    String key = key(conversationId, userId);

    if (isTyping) {
      redisTemplate.opsForValue().set(key, "1", Duration.ofSeconds(chatProperties.typingTtlSeconds()));
    } else {
      redisTemplate.delete(key);
    }

    UUID recipientId = accessService.findOtherParticipantId(conversationId, userId);
    realtimeMessageService.deliverTyping(
        recipientId,
        StompTypingPayload.from(conversationId, userId, isTyping)
    );
  }

  public boolean isTyping(UUID conversationId, UUID userId) {
    return Boolean.TRUE.equals(redisTemplate.hasKey(key(conversationId, userId)));
  }

  private String key(UUID conversationId, UUID userId) {
    return KEY_PREFIX + conversationId + ":" + userId;
  }
}
