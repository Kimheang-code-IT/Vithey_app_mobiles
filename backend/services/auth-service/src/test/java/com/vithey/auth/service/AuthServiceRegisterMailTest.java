package com.vithey.auth.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.vithey.auth.dto.request.RegisterRequest;
import com.vithey.auth.dto.response.TokenResponse;
import com.vithey.auth.entity.EmailVerificationToken;
import com.vithey.auth.entity.Role;
import com.vithey.auth.entity.User;
import com.vithey.auth.event.publisher.UserRegisteredEventPublisher;
import com.vithey.auth.mail.AuthMailSender;
import com.vithey.auth.mapper.UserMapper;
import com.vithey.auth.repository.EmailVerificationTokenRepository;
import com.vithey.auth.repository.UserRepository;
import com.vithey.auth.util.TokenHash;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

@ExtendWith(MockitoExtension.class)
class AuthServiceRegisterMailTest {

  @Mock
  private UserRepository userRepository;
  @Mock
  private EmailVerificationTokenRepository emailVerificationTokenRepository;
  @Mock
  private PasswordEncoder passwordEncoder;
  @Mock
  private TokenService tokenService;
  @Mock
  private UserMapper userMapper;
  @Mock
  private UserRegisteredEventPublisher userRegisteredEventPublisher;
  @Mock
  private AuthMailSender authMailSender;

  private AuthService authService;

  @BeforeEach
  void setUp() {
    authService = new AuthService(
        userRepository,
        emailVerificationTokenRepository,
        passwordEncoder,
        tokenService,
        userMapper,
        userRegisteredEventPublisher,
        authMailSender
    );
  }

  @Test
  void registerSendsEmailVerificationToken() {
    RegisterRequest request = new RegisterRequest(
        "Student@Aub.edu.kh",
        "+85512345678",
        "Password1!",
        "Student Name",
        Role.USER
    );

    when(userRepository.existsByEmailIgnoreCase("student@aub.edu.kh")).thenReturn(false);
    when(userRepository.existsByPhone("+85512345678")).thenReturn(false);
    when(passwordEncoder.encode("Password1!")).thenReturn("hashed");
    when(userRepository.save(any(User.class))).thenAnswer(invocation -> {
      User user = invocation.getArgument(0);
      user.setId(UUID.randomUUID());
      return user;
    });
    when(emailVerificationTokenRepository.save(any(EmailVerificationToken.class)))
        .thenAnswer(invocation -> invocation.getArgument(0));
    when(tokenService.issueTokens(any(User.class)))
        .thenReturn(new TokenResponse("access", "refresh", 900));
    when(userMapper.toAuthResponse(any(User.class)))
        .thenReturn(new com.vithey.auth.dto.response.UserAuthResponse(
            UUID.randomUUID(),
            "student@aub.edu.kh",
            "+85512345678",
            "Student Name",
            Role.USER,
            false,
            false
        ));

    authService.register(request);

    ArgumentCaptor<EmailVerificationToken> storedToken =
        ArgumentCaptor.forClass(EmailVerificationToken.class);
    ArgumentCaptor<String> rawToken = ArgumentCaptor.forClass(String.class);
    verify(emailVerificationTokenRepository).save(storedToken.capture());
    verify(authMailSender).sendEmailVerification(eq("student@aub.edu.kh"), rawToken.capture());

    assertThat(rawToken.getValue()).isNotBlank();
    assertThat(storedToken.getValue().getTokenHash()).isEqualTo(TokenHash.sha256(rawToken.getValue()));
  }
}
