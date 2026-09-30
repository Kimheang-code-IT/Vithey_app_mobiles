package com.vithey.gateway.security;

import static org.assertj.core.api.Assertions.assertThat;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;
import java.util.List;
import org.junit.jupiter.api.Test;

class JwtValidatorTest {

  private static final String SECRET = "test-secret-with-at-least-256-bits-for-jjwt";

  @Test
  void validateReturnsSubjectEmailAndRoles() {
    String token = Jwts.builder()
        .subject("user-123")
        .claim("email", "student@aub.edu.kh")
        .claim("roles", List.of("STUDENT"))
        .issuedAt(Date.from(Instant.now()))
        .expiration(Date.from(Instant.now().plusSeconds(900)))
        .signWith(Keys.hmacShaKeyFor(SECRET.getBytes(StandardCharsets.UTF_8)))
        .compact();

    AuthenticatedUser user = new JwtValidator(SECRET).validate(token);

    assertThat(user.userId()).isEqualTo("user-123");
    assertThat(user.email()).isEqualTo("student@aub.edu.kh");
    assertThat(user.roles()).containsExactly("STUDENT");
  }
}
