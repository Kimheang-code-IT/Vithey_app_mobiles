package com.vithey.gateway.config;

import java.net.InetSocketAddress;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.cloud.gateway.filter.ratelimit.KeyResolver;
import org.springframework.cloud.gateway.filter.ratelimit.RedisRateLimiter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.util.StringUtils;
import reactor.core.publisher.Mono;

@Configuration
@EnableConfigurationProperties(VitheyGatewayProperties.class)
public class RedisRateLimiterConfig {

  @Bean
  RedisRateLimiter redisRateLimiter(VitheyGatewayProperties properties) {
    VitheyGatewayProperties.RateLimit rateLimit = properties.getRateLimit();
    return new RedisRateLimiter(
        rateLimit.getReplenishRate(),
        rateLimit.getBurstCapacity(),
        rateLimit.getRequestedTokens()
    );
  }

  @Bean
  KeyResolver rateLimitKeyResolver() {
    return exchange -> {
      String userId = exchange.getRequest().getHeaders().getFirst("X-User-Id");
      if (StringUtils.hasText(userId)) {
        return Mono.just("user:" + userId);
      }

      return Mono.just("ip:" + resolveClientIp(exchange.getRequest()));
    };
  }

  private String resolveClientIp(ServerHttpRequest request) {
    String forwardedFor = request.getHeaders().getFirst("X-Forwarded-For");
    if (StringUtils.hasText(forwardedFor)) {
      return forwardedFor.split(",")[0].trim();
    }

    InetSocketAddress remoteAddress = request.getRemoteAddress();
    return remoteAddress == null ? "unknown" : remoteAddress.getAddress().getHostAddress();
  }
}
