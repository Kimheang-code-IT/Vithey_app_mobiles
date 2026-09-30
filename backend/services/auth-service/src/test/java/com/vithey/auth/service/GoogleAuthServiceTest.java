package com.vithey.auth.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.vithey.auth.dto.request.GoogleLoginRequest;
import com.vithey.auth.dto.response.AuthResponse;
import com.vithey.auth.dto.response.TokenResponse;
import com.vithey.auth.dto.response.UserAuthResponse;
import com.vithey.auth.entity.AuthProvider;
import com.vithey.auth.entity.Role;
import com.vithey.auth.entity.User;
import com.vithey.auth.entity.UserExternalIdentity;
import com.vithey.auth.event.payload.UserRegisteredEvent;
import com.vithey.auth.event.publisher.UserRegisteredEventPublisher;
import com.vithey.auth.exception.ApiException;
import com.vithey.auth.exception.ErrorCode;
import com.vithey.auth.mapper.UserMapper;
import com.vithey.auth.repository.UserExternalIdentityRepository;
import com.vithey.auth.repository.UserRepository;
import com.vithey.auth.security.GoogleIdentity;
import com.vithey.auth.security.GoogleTokenVerifier;
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
class GoogleAuthServiceTest {

  private static final String SUBJECT = "10769150350006150715113082367";
  private static final String EMAIL = "student@aub.edu.kh";

  @Mock
  private GoogleTokenVerifier googleTokenVerifier;
  @Mock
  private UserRepository userRepository;
  @Mock
  private UserExternalIdentityRepository userExternalIdentityRepository;
  @Mock
  private PasswordEncoder passwordEncoder;
  @Mock
  private TokenService tokenService;
  @Mock
  private UserMapper userMapper;
  @Mock
  private UserRegisteredEventPublisher userRegisteredEventPublisher;

  private GoogleAuthService googleAuthService;

  @BeforeEach
  void setUp() {
    googleAuthService = new GoogleAuthService(
        googleTokenVerifier,
        userRepository,
        userExternalIdentityRepository,
        passwordEncoder,
        tokenService,
        userMapper,
        userRegisteredEventPublisher
    );
    lenient().when(tokenService.issueTokens(any(User.class)))
        .thenReturn(new TokenResponse("access", "refresh", 900));
    lenient().when(userMapper.toAuthResponse(any(User.class))).thenReturn(authResponse(EMAIL));
  }
  @Test
  void createsDefaultUserAndLinksIdentityForNewGoogleAccount() {
    when(googleTokenVerifier.verify("id-token")).thenReturn(identity());
    when(userExternalIdentityRepository
        .findByProviderAndProviderSubject(AuthProvider.GOOGLE, SUBJECT)).thenReturn(Optional.empty());
    when(userRepository.findByEmailIgnoreCaseAndDeletedAtIsNull(EMAIL)).thenReturn(Optional.empty());
    when(passwordEncoder.encode(anyString())).thenReturn("{bcrypt}random");
    when(userRepository.save(any(User.class))).thenAnswer(invocation -> {
      User user = invocation.getArgument(0);
      user.setId(UUID.randomUUID());
      return user;
    });

    AuthResponse response = googleAuthService.authenticate(new GoogleLoginRequest("id-token"));

    ArgumentCaptor<User> savedUser = ArgumentCaptor.forClass(User.class);
    verify(userRepository).save(savedUser.capture());
    assertThat(savedUser.getValue().getRole()).isEqualTo(Role.USER);
    assertThat(savedUser.getValue().getEmail()).isEqualTo(EMAIL);
    assertThat(savedUser.getValue().getPhone()).isNull();
    assertThat(savedUser.getValue().isEmailVerified()).isTrue();
    assertThat(savedUser.getValue().getPasswordHash()).isEqualTo("{bcrypt}random");

    ArgumentCaptor<UserExternalIdentity> linked = ArgumentCaptor.forClass(UserExternalIdentity.class);
    verify(userExternalIdentityRepository).save(linked.capture());
    assertThat(linked.getValue().getProvider()).isEqualTo(AuthProvider.GOOGLE);
    assertThat(linked.getValue().getProviderSubject()).isEqualTo(SUBJECT);

    verify(userRegisteredEventPublisher).publish(any(UserRegisteredEvent.class));
    verify(tokenService).issueTokens(savedUser.getValue());
    assertThat(response.tokens().accessToken()).isEqualTo("access");
  }

  @Test
  void authenticatesExistingLinkedUserWithoutCreatingAnything() {
    User user = activeUser();
    when(googleTokenVerifier.verify("id-token")).thenReturn(identity());
    when(userExternalIdentityRepository
        .findByProviderAndProviderSubject(AuthProvider.GOOGLE, SUBJECT))
        .thenReturn(Optional.of(linkedIdentity(user)));

    AuthResponse response = googleAuthService.authenticate(new GoogleLoginRequest("id-token"));

    assertThat(response.tokens().accessToken()).isEqualTo("access");
    verify(userRepository, never()).save(any(User.class));
    verify(userExternalIdentityRepository, never()).save(any(UserExternalIdentity.class));
    verify(tokenService).issueTokens(user);
  }

  @Test
  void linksExistingAccountWithSameVerifiedEmailInsteadOfCreatingDuplicate() {
    User existing = activeUser();
    existing.setEmailVerified(false);
    when(googleTokenVerifier.verify("id-token")).thenReturn(identity());
    when(userExternalIdentityRepository
        .findByProviderAndProviderSubject(AuthProvider.GOOGLE, SUBJECT)).thenReturn(Optional.empty());
    when(userRepository.findByEmailIgnoreCaseAndDeletedAtIsNull(EMAIL)).thenReturn(Optional.of(existing));
    when(userRepository.save(existing)).thenReturn(existing);

    googleAuthService.authenticate(new GoogleLoginRequest("id-token"));

    assertThat(existing.isEmailVerified()).isTrue();
    verify(userRepository).save(existing);
    ArgumentCaptor<UserExternalIdentity> linked = ArgumentCaptor.forClass(UserExternalIdentity.class);
    verify(userExternalIdentityRepository).save(linked.capture());
    assertThat(linked.getValue().getUser()).isSameAs(existing);
    verify(userRegisteredEventPublisher, never()).publish(any(UserRegisteredEvent.class));
  }

  @Test
  void rejectsDisabledLinkedAccount() {
    User user = activeUser();
    user.setActive(false);
    when(googleTokenVerifier.verify("id-token")).thenReturn(identity());
    when(userExternalIdentityRepository
        .findByProviderAndProviderSubject(AuthProvider.GOOGLE, SUBJECT))
        .thenReturn(Optional.of(linkedIdentity(user)));

    assertThatThrownBy(() -> googleAuthService.authenticate(new GoogleLoginRequest("id-token")))
        .isInstanceOf(ApiException.class)
        .satisfies(ex -> assertThat(((ApiException) ex).getErrorCode()).isEqualTo(ErrorCode.UNAUTHORIZED));

    verify(tokenService, never()).issueTokens(any(User.class));
  }

  @Test
  void rejectsDisabledAccountMatchingEmail() {
    User existing = activeUser();
    existing.setActive(false);
    when(googleTokenVerifier.verify("id-token")).thenReturn(identity());
    when(userExternalIdentityRepository
        .findByProviderAndProviderSubject(AuthProvider.GOOGLE, SUBJECT)).thenReturn(Optional.empty());
    when(userRepository.findByEmailIgnoreCaseAndDeletedAtIsNull(EMAIL)).thenReturn(Optional.of(existing));

    assertThatThrownBy(() -> googleAuthService.authenticate(new GoogleLoginRequest("id-token")))
        .isInstanceOf(ApiException.class)
        .satisfies(ex -> assertThat(((ApiException) ex).getErrorCode()).isEqualTo(ErrorCode.UNAUTHORIZED));

    verify(userExternalIdentityRepository, never()).save(any(UserExternalIdentity.class));
  }

  @Test
  void rejectsInvalidGoogleTokenAndDoesNotTouchAccounts() {
    when(googleTokenVerifier.verify("bad-token"))
        .thenThrow(new ApiException(ErrorCode.INVALID_TOKEN, "Google token is invalid or expired"));

    assertThatThrownBy(() -> googleAuthService.authenticate(new GoogleLoginRequest("bad-token")))
        .isInstanceOf(ApiException.class)
        .satisfies(ex -> assertThat(((ApiException) ex).getErrorCode()).isEqualTo(ErrorCode.INVALID_TOKEN));

    verify(userRepository, never()).save(any(User.class));
    verify(userExternalIdentityRepository, never()).findByProviderAndProviderSubject(any(), anyString());
  }

  @Test
  void issuesVitheyTokensAfterSuccessfulAuthentication() {
    User user = activeUser();
    when(googleTokenVerifier.verify("id-token")).thenReturn(identity());
    when(userExternalIdentityRepository
        .findByProviderAndProviderSubject(eq(AuthProvider.GOOGLE), eq(SUBJECT)))
        .thenReturn(Optional.of(linkedIdentity(user)));

    AuthResponse response = googleAuthService.authenticate(new GoogleLoginRequest("id-token"));

    assertThat(response.tokens().accessToken()).isEqualTo("access");
    assertThat(response.tokens().refreshToken()).isEqualTo("refresh");
    assertThat(response.tokens().expiresIn()).isEqualTo(900);
    assertThat(response.user()).isNotNull();
  }

  private GoogleIdentity identity() {
    return new GoogleIdentity(SUBJECT, EMAIL, true, "Test User", null);
  }

  private User activeUser() {
    User user = new User();
    user.setId(UUID.randomUUID());
    user.setEmail(EMAIL);
    user.setFullName("Test User");
    user.setPasswordHash("{bcrypt}existing");
    user.setRole(Role.USER);
    user.setActive(true);
    user.setEmailVerified(true);
    return user;
  }

  private UserExternalIdentity linkedIdentity(User user) {
    UserExternalIdentity identity = new UserExternalIdentity();
    identity.setUser(user);
    identity.setProvider(AuthProvider.GOOGLE);
    identity.setProviderSubject(SUBJECT);
    return identity;
  }

  private UserAuthResponse authResponse(String email) {
    return new UserAuthResponse(UUID.randomUUID(), email, null, "Test User", Role.USER, false, true);
  }
}
