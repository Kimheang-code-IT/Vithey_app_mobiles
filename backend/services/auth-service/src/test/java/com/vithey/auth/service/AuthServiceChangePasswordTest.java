package com.vithey.auth.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.vithey.auth.entity.Role;
import com.vithey.auth.entity.User;
import com.vithey.auth.exception.ApiException;
import com.vithey.auth.exception.ErrorCode;
import com.vithey.auth.repository.UserRepository;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

@ExtendWith(MockitoExtension.class)
class AuthServiceChangePasswordTest {

  private static final UUID USER_ID = UUID.randomUUID();

  @Mock
  private UserRepository userRepository;
  @Mock
  private PasswordEncoder passwordEncoder;

  private AuthService authService;

  @BeforeEach
  void setUp() {
    authService = new AuthService(
        userRepository,
        org.mockito.Mockito.mock(com.vithey.auth.repository.EmailVerificationTokenRepository.class),
        passwordEncoder,
        org.mockito.Mockito.mock(TokenService.class),
        org.mockito.Mockito.mock(com.vithey.auth.mapper.UserMapper.class),
        org.mockito.Mockito.mock(com.vithey.auth.event.publisher.UserRegisteredEventPublisher.class),
        org.mockito.Mockito.mock(com.vithey.auth.mail.AuthMailSender.class)
    );
  }

  @Test
  void changePasswordRejectsWrongCurrentPassword() {
    User user = activeUser();
    when(userRepository.findById(USER_ID)).thenReturn(Optional.of(user));
    when(passwordEncoder.matches("WrongPass1!", user.getPasswordHash())).thenReturn(false);

    assertThatThrownBy(() -> authService.changePassword(USER_ID, "WrongPass1!", "NewSecure123!"))
        .isInstanceOf(ApiException.class)
        .satisfies(ex -> assertThat(((ApiException) ex).getErrorCode()).isEqualTo(ErrorCode.INVALID_CREDENTIALS));

    verify(passwordEncoder, org.mockito.Mockito.never()).encode(org.mockito.Mockito.anyString());
    verify(userRepository, org.mockito.Mockito.never()).save(any());
  }

  @Test
  void changePasswordStoresHashedNewPassword() {
    User user = activeUser();
    when(userRepository.findById(USER_ID)).thenReturn(Optional.of(user));
    when(passwordEncoder.matches("SecurePass123!", user.getPasswordHash())).thenReturn(true);
    when(passwordEncoder.encode("NewSecure123!")).thenReturn("{bcrypt}new-hash");
    when(userRepository.save(user)).thenReturn(user);

    authService.changePassword(USER_ID, "SecurePass123!", "NewSecure123!");

    assertThat(user.getPasswordHash()).isEqualTo("{bcrypt}new-hash");
    verify(userRepository).save(user);
  }

  private User activeUser() {
    User user = new User();
    user.setId(USER_ID);
    user.setEmail("student@aub.edu.kh");
    user.setRole(Role.USER);
    user.setActive(true);
    user.setPasswordHash("{bcrypt}current-hash");
    return user;
  }
}
