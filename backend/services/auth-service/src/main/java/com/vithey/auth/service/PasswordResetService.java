package com.vithey.auth.service;

import com.vithey.auth.entity.PasswordResetToken;
import com.vithey.auth.entity.User;
import com.vithey.auth.exception.ApiException;
import com.vithey.auth.exception.ErrorCode;
import com.vithey.auth.mail.AuthMailSender;
import com.vithey.auth.repository.PasswordResetTokenRepository;
import com.vithey.auth.repository.UserRepository;
import com.vithey.auth.util.OpaqueTokenGenerator;
import com.vithey.auth.util.TokenHash;
import java.time.OffsetDateTime;
import java.util.Locale;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PasswordResetService {

  private static final int RESET_TOKEN_BYTES = 40;

  private final UserRepository userRepository;
  private final PasswordResetTokenRepository passwordResetTokenRepository;
  private final PasswordEncoder passwordEncoder;
  private final AuthMailSender authMailSender;

  public PasswordResetService(
      UserRepository userRepository,
      PasswordResetTokenRepository passwordResetTokenRepository,
      PasswordEncoder passwordEncoder,
      AuthMailSender authMailSender
  ) {
    this.userRepository = userRepository;
    this.passwordResetTokenRepository = passwordResetTokenRepository;
    this.passwordEncoder = passwordEncoder;
    this.authMailSender = authMailSender;
  }

  @Transactional
  public void startReset(String email) {
    userRepository.findByEmailIgnoreCaseAndDeletedAtIsNull(email.trim().toLowerCase(Locale.ROOT))
        .filter(User::isActive)
        .ifPresent(user -> {
          String rawToken = OpaqueTokenGenerator.generate(RESET_TOKEN_BYTES);
          PasswordResetToken token = new PasswordResetToken();
          token.setUser(user);
          token.setTokenHash(TokenHash.sha256(rawToken));
          token.setExpiresAt(OffsetDateTime.now().plusMinutes(30));
          passwordResetTokenRepository.save(token);
          authMailSender.sendPasswordReset(user.getEmail(), rawToken);
        });
  }

  @Transactional
  public void resetPassword(String rawToken, String newPassword) {
    PasswordResetToken token = passwordResetTokenRepository.findByTokenHash(TokenHash.sha256(rawToken))
        .orElseThrow(() -> new ApiException(ErrorCode.INVALID_TOKEN));

    OffsetDateTime now = OffsetDateTime.now();
    if (!token.isUsable(now)) {
      throw new ApiException(ErrorCode.INVALID_TOKEN);
    }

    User user = token.getUser();
    user.setPasswordHash(passwordEncoder.encode(newPassword));
    token.setUsedAt(now);
    userRepository.save(user);
    passwordResetTokenRepository.save(token);
  }
}
