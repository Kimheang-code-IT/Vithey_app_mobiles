package com.vithey.auth.security;

import static org.assertj.core.api.Assertions.assertThat;

import com.vithey.auth.entity.Role;
import com.vithey.auth.entity.User;
import java.time.Duration;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class JwtProviderTest {

  @Test
  void createAndParseAccessTokenIncludesRequiredClaims() {
    JwtProvider jwtProvider = new JwtProvider(
        "test-secret-with-at-least-256-bits-for-jjwt",
        Duration.ofMinutes(15)
    );

    User user = new User();
    user.setId(UUID.randomUUID());
    user.setEmail("student@aub.edu.kh");
    user.setRole(Role.STUDENT);

    CurrentUser currentUser = jwtProvider.parseAccessToken(jwtProvider.createAccessToken(user));

    assertThat(currentUser.userId()).isEqualTo(user.getId());
    assertThat(currentUser.email()).isEqualTo(user.getEmail());
    assertThat(currentUser.roles()).containsExactly(Role.STUDENT.name());
    assertThat(jwtProvider.accessTokenExpiresInSeconds()).isEqualTo(900);
  }
}
