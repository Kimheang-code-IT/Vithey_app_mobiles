package com.vithey.gateway.filter;

import java.util.UUID;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

@Component
public class RequestIdGlobalFilter implements GlobalFilter, Ordered {

  public static final String REQUEST_ID_HEADER = "X-Request-ID";

  @Override
  public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
    String requestId = exchange.getRequest().getHeaders().getFirst(REQUEST_ID_HEADER);
    if (!StringUtils.hasText(requestId)) {
      requestId = UUID.randomUUID().toString();
    }
    String finalRequestId = requestId;

    ServerHttpRequest request = exchange.getRequest()
        .mutate()
        .headers(headers -> headers.set(REQUEST_ID_HEADER, finalRequestId))
        .build();

    exchange.getResponse().getHeaders().set(REQUEST_ID_HEADER, finalRequestId);
    return chain.filter(exchange.mutate().request(request).build());
  }

  @Override
  public int getOrder() {
    return Ordered.HIGHEST_PRECEDENCE;
  }
}
