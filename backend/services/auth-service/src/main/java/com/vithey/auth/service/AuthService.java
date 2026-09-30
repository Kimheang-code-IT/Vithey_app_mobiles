package com.vithey.auth.service;

import com.vithey.auth.dto.request.LoginRequest;
import com.vithey.auth.dto.request.RegisterRequest;
import com.vithey.auth.dto.response.AuthResponse;
import com.vithey.auth.dto.response.TokenResponse;
import com.vithey.auth.dto.response.UserAuthResponse;
import com.vithey.auth.entity.EmailVerificationToken;
import com.vithey.auth.entity.Role;
import com.vithey.auth.entity.User;
import com.vithey.auth.event.payload.UserRegisteredEvent;
import com.vithey.auth.event.publisher.UserRegisteredEventPublisher;
import com.vithey.auth.exception.ApiException;
import com.vithey.auth.exception.ErrorCode;
import com.vithey.auth.mail.AuthMailSender;
import com.vithey.auth.mapper.UserMapper;
import com.vithey.auth.repository.EmailVerificationTokenRepository;
import com.vithey.auth.repository.UserRepository;
import com.vithey.auth.util.OpaqueTokenGenerator;
import com.vithey.auth.util.TokenHash;
import java.time.OffsetDateTime;
import java.util.Locale;
import java.util.UUID;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

  private static final int EMAIL_VERIFICATION_TOKEN_BYTES = 40;

  private final UserRepository userRepository;
  private final EmailVerificationTokenRepository emailVerificationTokenRepository;
  private final PasswordEncoder passwordEncoder;
  private final TokenService tokenService;
  private final UserMapper userMapper;
  private final UserRegisteredEventPublisher userRegisteredEventPublisher;
  private final AuthMailSender authMailSender;

  public AuthService(
      UserRepository userRepository,
      EmailVerificationTokenRepository emailVerificationTokenRepository,
      PasswordEncoder passwordEncoder,
      TokenService tokenService,
      UserMapper userMapper,
      UserRegisteredEventPublisher userRegisteredEventPublisher,
      AuthMailSender authMailSender
  ) {
    this.userRepository = userRepository;
    this.emailVerificationTokenRepository = emailVerificationTokenRepository;
    this.passwordEncoder = passwordEncoder;
    this.tokenService = tokenService;
    this.userMapper = userMapper;
    this.userRegisteredEventPublisher = userRegisteredEventPublisher;
    this.authMailSender = authMailSender;
  }

  @Transactional
  public AuthResponse register(RegisterRequest request) {
    if (request.role() != Role.USER && request.role() != Role.COMPANY) {
      throw new ApiException(ErrorCode.BUSINESS_RULE_VIOLATION, "Registration role must be USER or COMPANY");
    }

    String email = normalizeEmail(request.email());
    if (userRepository.existsByEmailIgnoreCase(email)) {
      throw new ApiException(ErrorCode.CONFLICT, "Email is already registered");
    }
    if (userRepository.existsByPhone(request.phone())) {
      throw new ApiException(ErrorCode.CONFLICT, "Phone is already registered");
    }

    User user = new User();
    user.setEmail(email);
    user.setPhone(request.phone());
    user.setFullName(request.fullName());
    user.setPasswordHash(passwordEncoder.encode(request.password()));
    user.setRole(request.role());
    User savedUser = userRepository.save(user);

    createEmailVerificationToken(savedUser);
    TokenResponse tokens = tokenService.issueTokens(savedUser);
    userRegisteredEventPublisher.publish(new UserRegisteredEvent(
        savedUser.getId(),
        savedUser.getEmail(),
        savedUser.getFullName(),
        savedUser.getRole(),
        OffsetDateTime.now()
    ));

    return new AuthResponse(userMapper.toAuthResponse(savedUser), tokens);
  }

  @Transactional
  public AuthResponse login(LoginRequest request) {
    User user = findActiveUserByEmailOrPhone(request.emailOrPhone());
    if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
      throw new ApiException(ErrorCode.INVALID_CREDENTIALS);
    }
    return new AuthResponse(userMapper.toAuthResponse(user), tokenService.issueTokens(user));
  }

  @Transactional
  public TokenResponse refresh(String refreshToken) {
    return tokenService.rotateRefreshToken(refreshToken);
  }

  @Transactional
  public void logout(String refreshToken) {
    tokenService.revokeRefreshToken(refreshToken);
  }

  @Transactional
  public void changePassword(UUID userId, String currentPassword, String newPassword) {
    User user = userRepository.findById(userId)
        .filter(candidate -> candidate.getDeletedAt() == null && candidate.isActive())
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND, "User not found"));

    if (!passwordEncoder.matches(currentPassword, user.getPasswordHash())) {
      throw new ApiException(ErrorCode.INVALID_CREDENTIALS);
    }

    user.setPasswordHash(passwordEncoder.encode(newPassword));
    userRepository.save(user);
  }

  @Transactional(readOnly = true)
  public UserAuthResponse getMe(UUID userId) {
    User user = userRepository.findById(userId)
        .filter(candidate -> candidate.getDeletedAt() == null && candidate.isActive())
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND, "User not found"));
    return userMapper.toAuthResponse(user);
  }

  @Transactional
  public void verifyEmail(String token) {
    EmailVerificationToken verificationToken = emailVerificationTokenRepository.findByTokenHash(TokenHash.sha256(token))
        .orElseThrow(() -> new ApiException(ErrorCode.INVALID_TOKEN));

    OffsetDateTime now = OffsetDateTime.now();
    if (!verificationToken.isUsable(now)) {
      throw new ApiException(ErrorCode.INVALID_TOKEN);
    }

    User user = verificationToken.getUser();
    user.setEmailVerified(true);
    verificationToken.setUsedAt(now);
    userRepository.save(user);
    emailVerificationTokenRepository.save(verificationToken);
  }

  private User findActiveUserByEmailOrPhone(String emailOrPhone) {
    String value = emailOrPhone.trim();
    return (value.contains("@")
            ? userRepository.findByEmailIgnoreCaseAndDeletedAtIsNull(normalizeEmail(value))
            : userRepository.findByPhoneAndDeletedAtIsNull(value))
        .filter(User::isActive)
        .orElseThrow(() -> new ApiException(ErrorCode.INVALID_CREDENTIALS));
  }

  private void createEmailVerificationToken(User user) {
    String rawToken = OpaqueTokenGenerator.generate(EMAIL_VERIFICATION_TOKEN_BYTES);
    EmailVerificationToken token = new EmailVerificationToken();
    token.setUser(user);
    token.setTokenHash(TokenHash.sha256(rawToken));
    token.setExpiresAt(OffsetDateTime.now().plusDays(1));
    emailVerificationTokenRepository.save(token);
    authMailSender.sendEmailVerification(user.getEmail(), rawToken);
  }

  private String normalizeEmail(String email) {
    return email.trim().toLowerCase(Locale.ROOT);
  }
}
