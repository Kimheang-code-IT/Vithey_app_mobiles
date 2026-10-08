package com.vithey.gateway.filter;

import java.util.List;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

/**
 * Strips any client-supplied identity headers before authentication.
 *
 * <p>Downstream services trust {@code X-User-Id} / {@code X-User-Roles} /
 * {@code X-User-Email}. This filter runs before {@code
 * JwtAuthenticationGlobalFilter} so a caller can never inject an identity via
 * forged headers; the JWT filter then sets the trusted values from the token.
 */
@Component
public class UserHeaderForwardFilter implements GlobalFilter, Ordered {

  private static final List<String> UNTRUSTED_USER_HEADERS = List.of(
      "X-User-Id",
      "X-User-Roles",
      "X-User-Email"
  );

  @Override
  public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
    ServerHttpRequest sanitized = exchange.getRequest()
        .mutate()
        .headers(headers -> UNTRUSTED_USER_HEADERS.forEach(headers::remove))
        .build();
    return chain.filter(exchange.mutate().request(sanitized).build());
  }

  @Override
  public int getOrder() {
    // Before the JWT filter (HIGHEST_PRECEDENCE + 10) so forged headers are
    // removed before trusted values are applied.
    return Ordered.HIGHEST_PRECEDENCE + 5;
  }
}
