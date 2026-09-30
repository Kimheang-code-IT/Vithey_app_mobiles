package com.vithey.gateway.exception;

import java.nio.charset.StandardCharsets;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

@Component
public class GatewayErrorHandler {

  public Mono<Void> writeError(ServerWebExchange exchange, HttpStatus status, String code, String message) {
    String body = """
        {"error":{"code":"%s","message":"%s","details":[]}}
        """.formatted(escape(code), escape(message)).trim();

    exchange.getResponse().setStatusCode(status);
    exchange.getResponse().getHeaders().setContentType(MediaType.APPLICATION_JSON);
    DataBuffer buffer = exchange.getResponse()
        .bufferFactory()
        .wrap(body.getBytes(StandardCharsets.UTF_8));
    return exchange.getResponse().writeWith(Mono.just(buffer));
  }

  private String escape(String value) {
    return value.replace("\\", "\\\\").replace("\"", "\\\"");
  }
}
