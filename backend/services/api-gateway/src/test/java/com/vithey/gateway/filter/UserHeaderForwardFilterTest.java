package com.vithey.gateway.filter;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.concurrent.atomic.AtomicReference;
import org.junit.jupiter.api.Test;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.http.HttpHeaders;
import org.springframework.mock.http.server.reactive.MockServerHttpRequest;
import org.springframework.mock.web.server.MockServerWebExchange;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

class UserHeaderForwardFilterTest {

  @Test
  void stripsForgedIdentityHeadersButKeepsAuthorization() {
    UserHeaderForwardFilter filter = new UserHeaderForwardFilter();
    MockServerWebExchange exchange = MockServerWebExchange.from(
        MockServerHttpRequest.get("/api/v1/users/me")
            .header("X-User-Id", "forged-id")
            .header("X-User-Roles", "ADMIN")
            .header("X-User-Email", "attacker@example.com")
            .header(HttpHeaders.AUTHORIZATION, "Bearer signed-token"));

    AtomicReference<ServerWebExchange> captured = new AtomicReference<>();
    GatewayFilterChain chain = ex -> {
      captured.set(ex);
      return Mono.empty();
    };

    filter.filter(exchange, chain).block();

    HttpHeaders headers = captured.get().getRequest().getHeaders();
    assertThat(headers.keySet()).doesNotContain("X-User-Id", "X-User-Roles", "X-User-Email");
    assertThat(headers.getFirst(HttpHeaders.AUTHORIZATION)).isEqualTo("Bearer signed-token");
  }

  @Test
  void runsBeforeTheJwtAuthenticationFilter() {
    assertThat(new UserHeaderForwardFilter().getOrder())
        .isLessThan(new JwtAuthenticationGlobalFilterReadOrder().jwtFilterOrder());
  }

  /** Keeps the ordering expectation explicit without building the full filter. */
  private static final class JwtAuthenticationGlobalFilterReadOrder {
    int jwtFilterOrder() {
      return org.springframework.core.Ordered.HIGHEST_PRECEDENCE + 10;
    }
  }
}
