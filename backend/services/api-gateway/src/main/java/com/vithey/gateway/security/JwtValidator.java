package com.vithey.gateway.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.util.List;
import javax.crypto.SecretKey;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class JwtValidator {

  private final SecretKey secretKey;

  public JwtValidator(@Value("${vithey.jwt.secret}") String secret) {
    this.secretKey = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
  }

  public AuthenticatedUser validate(String token) {
    Claims claims = Jwts.parser()
        .verifyWith(secretKey)
        .build()
        .parseSignedClaims(token)
        .getPayload();

    Object rolesClaim = claims.get("roles");
    List<String> roles = rolesClaim instanceof List<?> values
        ? values.stream().map(String::valueOf).toList()
        : List.of();

    return new AuthenticatedUser(
        claims.getSubject(),
        claims.get("email", String.class),
        roles
    );
  }
}
