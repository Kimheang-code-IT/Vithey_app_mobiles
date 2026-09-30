package com.vithey.chat.security;

import java.util.Map;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.http.server.ServletServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.server.HandshakeInterceptor;

@Component
public class JwtHandshakeInterceptor implements HandshakeInterceptor {

  private final JwtProvider jwtProvider;

  public JwtHandshakeInterceptor(JwtProvider jwtProvider) {
    this.jwtProvider = jwtProvider;
  }

  @Override
  public boolean beforeHandshake(
      ServerHttpRequest request,
      ServerHttpResponse response,
      WebSocketHandler wsHandler,
      Map<String, Object> attributes
  ) {
    if (!(request instanceof ServletServerHttpRequest servletRequest)) {
      return false;
    }

    String authorization = servletRequest.getServletRequest().getHeader("Authorization");
    if (StringUtils.hasText(authorization) && authorization.startsWith("Bearer ")) {
      CurrentUser currentUser = jwtProvider.parseAccessToken(authorization.substring(7));
      attributes.put("currentUser", currentUser);
      return true;
    }

    String token = servletRequest.getServletRequest().getParameter("token");
    if (StringUtils.hasText(token)) {
      CurrentUser currentUser = jwtProvider.parseAccessToken(token);
      attributes.put("currentUser", currentUser);
      return true;
    }

    String gatewayUserId = servletRequest.getServletRequest().getHeader("X-User-Id");
    if (StringUtils.hasText(gatewayUserId)) {
      CurrentUser currentUser = jwtProvider.fromGatewayHeaders(
          gatewayUserId,
          servletRequest.getServletRequest().getHeader("X-User-Email"),
          servletRequest.getServletRequest().getHeader("X-User-Roles")
      );
      attributes.put("currentUser", currentUser);
      return true;
    }

    return false;
  }

  @Override
  public void afterHandshake(
      ServerHttpRequest request,
      ServerHttpResponse response,
      WebSocketHandler wsHandler,
      Exception exception
  ) {
  }
}
