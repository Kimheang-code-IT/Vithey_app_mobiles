package com.vithey.gateway.filter;

import com.vithey.gateway.exception.GatewayErrorHandler;
import com.vithey.gateway.security.AuthenticatedUser;
import com.vithey.gateway.security.JwtValidator;
import com.vithey.gateway.util.PublicPathMatcher;
import io.jsonwebtoken.JwtException;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

@Component
public class JwtAuthenticationGlobalFilter implements GlobalFilter, Ordered {

  private static final String BEARER_PREFIX = "Bearer ";

  private final PublicPathMatcher publicPathMatcher;
  private final JwtValidator jwtValidator;
  private final GatewayErrorHandler errorHandler;

  public JwtAuthenticationGlobalFilter(
      PublicPathMatcher publicPathMatcher,
      JwtValidator jwtValidator,
      GatewayErrorHandler errorHandler
  ) {
    this.publicPathMatcher = publicPathMatcher;
    this.jwtValidator = jwtValidator;
    this.errorHandler = errorHandler;
  }

  @Override
  public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
    String path = exchange.getRequest().getPath().pathWithinApplication().value();
    if (publicPathMatcher.isPublic(path) || !path.startsWith("/api/v1/")) {
      return chain.filter(exchange);
    }

    String authorization = exchange.getRequest().getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
    if (!StringUtils.hasText(authorization) || !authorization.startsWith(BEARER_PREFIX)) {
      return errorHandler.writeError(exchange, HttpStatus.UNAUTHORIZED, "UNAUTHORIZED", "Missing or invalid token");
    }

    try {
      AuthenticatedUser user = jwtValidator.validate(authorization.substring(BEARER_PREFIX.length()));
      ServerHttpRequest request = exchange.getRequest()
          .mutate()
          .headers(headers -> {
            headers.set("X-User-Id", user.userId());
            headers.set("X-User-Roles", String.join(",", user.roles()));
            if (StringUtils.hasText(user.email())) {
              headers.set("X-User-Email", user.email());
            }
          })
          .build();
      return chain.filter(exchange.mutate().request(request).build());
    } catch (JwtException | IllegalArgumentException exception) {
      return errorHandler.writeError(exchange, HttpStatus.UNAUTHORIZED, "UNAUTHORIZED", "Missing or invalid token");
    }
  }

  @Override
  public int getOrder() {
    return Ordered.HIGHEST_PRECEDENCE + 10;
  }
}
