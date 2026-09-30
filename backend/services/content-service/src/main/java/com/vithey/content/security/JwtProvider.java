package com.vithey.content.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;
import javax.crypto.SecretKey;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class JwtProvider {

  private final SecretKey secretKey;

  public JwtProvider(@Value("${vithey.jwt.secret}") String secret) {
    this.secretKey = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
  }

  public CurrentUser parseAccessToken(String token) {
    Claims claims = Jwts.parser()
        .verifyWith(secretKey)
        .build()
        .parseSignedClaims(token)
        .getPayload();

    List<String> roles = claims.get("roles", List.class);
    return new CurrentUser(
        UUID.fromString(claims.getSubject()),
        claims.get("email", String.class),
        roles == null ? List.of() : roles
    );
  }

  public CurrentUser fromGatewayHeaders(String userId, String email, String rolesHeader) {
    List<String> roles = rolesHeader == null || rolesHeader.isBlank()
        ? List.of("USER")
        : Arrays.stream(rolesHeader.split(",")).map(String::trim).filter(value -> !value.isBlank()).toList();
    return new CurrentUser(UUID.fromString(userId), email, roles);
  }
}
