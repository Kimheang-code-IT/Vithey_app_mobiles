package com.vithey.chat.service;

import com.vithey.chat.config.ChatProperties;
import java.time.Duration;
import java.util.List;
import java.util.UUID;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

@Service
public class MessageCacheService {

  private static final String KEY_PREFIX = "chat:recent:";
  private static final Duration CACHE_TTL = Duration.ofHours(24);

  private final StringRedisTemplate redisTemplate;
  private final ChatProperties chatProperties;

  public MessageCacheService(StringRedisTemplate redisTemplate, ChatProperties chatProperties) {
    this.redisTemplate = redisTemplate;
    this.chatProperties = chatProperties;
  }

  public void appendMessageId(UUID conversationId, UUID messageId) {
    String key = key(conversationId);
    redisTemplate.opsForList().leftPush(key, messageId.toString());
    redisTemplate.opsForList().trim(key, 0, chatProperties.recentMessagesLimit() - 1L);
    redisTemplate.expire(key, CACHE_TTL);
  }

  public List<UUID> recentMessageIds(UUID conversationId) {
    return redisTemplate.opsForList().range(key(conversationId), 0, -1).stream()
        .map(UUID::fromString)
        .toList();
  }

  private String key(UUID conversationId) {
    return KEY_PREFIX + conversationId;
  }
}
