package com.vithey.chat.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "vithey.chat")
public record ChatProperties(
    int presenceTtlSeconds,
    int typingTtlSeconds,
    int recentMessagesLimit
) {

  public ChatProperties() {
    this(90, 5, 50);
  }
}
