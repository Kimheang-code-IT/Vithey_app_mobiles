package com.vithey.auth.security;

import com.vithey.auth.entity.User;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.Instant;
import java.util.Date;
import java.util.List;
import java.util.UUID;
import javax.crypto.SecretKey;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class JwtProvider {

  private final SecretKey secretKey;
  private final Duration accessTokenTtl;

  public JwtProvider(
      @Value("${vithey.jwt.secret}") String secret,
      @Value("${vithey.jwt.access-token-ttl}") Duration accessTokenTtl
  ) {
    this.secretKey = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    this.accessTokenTtl = accessTokenTtl;
  }

  public String createAccessToken(User user) {
    Instant now = Instant.now();
    Instant expiresAt = now.plus(accessTokenTtl);

    return Jwts.builder()
        .subject(user.getId().toString())
        .claim("email", user.getEmail())
        .claim("roles", List.of(user.getRole().name()))
        .issuedAt(Date.from(now))
        .expiration(Date.from(expiresAt))
        .signWith(secretKey)
        .compact();
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

  public long accessTokenExpiresInSeconds() {
    return accessTokenTtl.toSeconds();
  }
}
