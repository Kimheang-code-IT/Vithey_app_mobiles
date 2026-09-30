package com.vithey.auth.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.vithey.auth.entity.PasswordResetToken;
import com.vithey.auth.entity.User;
import com.vithey.auth.mail.AuthMailSender;
import com.vithey.auth.repository.PasswordResetTokenRepository;
import com.vithey.auth.repository.UserRepository;
import com.vithey.auth.util.TokenHash;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

@ExtendWith(MockitoExtension.class)
class PasswordResetServiceTest {

  @Mock
  private UserRepository userRepository;
  @Mock
  private PasswordResetTokenRepository passwordResetTokenRepository;
  @Mock
  private PasswordEncoder passwordEncoder;
  @Mock
  private AuthMailSender authMailSender;

  private PasswordResetService passwordResetService;

  @BeforeEach
  void setUp() {
    passwordResetService = new PasswordResetService(
        userRepository,
        passwordResetTokenRepository,
        passwordEncoder,
        authMailSender
    );
  }

  @Test
  void startResetSendsRawTokenByMailAndStoresHashOnly() {
    User user = new User();
    user.setId(UUID.randomUUID());
    user.setEmail("student@aub.edu.kh");
    user.setActive(true);

    when(userRepository.findByEmailIgnoreCaseAndDeletedAtIsNull("student@aub.edu.kh"))
        .thenReturn(Optional.of(user));
    when(passwordResetTokenRepository.save(any(PasswordResetToken.class)))
        .thenAnswer(invocation -> invocation.getArgument(0));

    passwordResetService.startReset("student@aub.edu.kh");

    ArgumentCaptor<PasswordResetToken> tokenCaptor = ArgumentCaptor.forClass(PasswordResetToken.class);
    ArgumentCaptor<String> rawTokenCaptor = ArgumentCaptor.forClass(String.class);
    verify(passwordResetTokenRepository).save(tokenCaptor.capture());
    verify(authMailSender).sendPasswordReset(eq("student@aub.edu.kh"), rawTokenCaptor.capture());

    String rawToken = rawTokenCaptor.getValue();
    assertThat(rawToken).isNotBlank();
    assertThat(tokenCaptor.getValue().getTokenHash()).isEqualTo(TokenHash.sha256(rawToken));
  }

  @Test
  void startResetDoesNothingWhenUserMissing() {
    when(userRepository.findByEmailIgnoreCaseAndDeletedAtIsNull("missing@aub.edu.kh"))
        .thenReturn(Optional.empty());

    passwordResetService.startReset("missing@aub.edu.kh");

    verify(passwordResetTokenRepository, never()).save(any());
    verify(authMailSender, never()).sendPasswordReset(any(), any());
  }
}
