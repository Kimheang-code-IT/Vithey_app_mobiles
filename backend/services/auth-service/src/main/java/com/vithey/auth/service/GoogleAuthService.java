package com.vithey.auth.service;

import com.vithey.auth.dto.request.GoogleLoginRequest;
import com.vithey.auth.dto.response.AuthResponse;
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
import java.time.OffsetDateTime;
import java.util.Optional;
import java.util.UUID;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

/**
 * Authenticates a user from a verified Google ID token and issues the standard
 * Vithey access + refresh tokens.
 *
 * <p>Account resolution:</p>
 * <ol>
 *   <li>Existing {@code GOOGLE} provider identity -> authenticate that user.</li>
 *   <li>No identity and no matching account -> create a default {@code USER}
 *       account and link the identity.</li>
 *   <li>No identity but a Vithey account already has the same verified email ->
 *       link the Google identity to that account (safe auto-link: Google has
 *       asserted control of the email). No duplicate account is created.</li>
 * </ol>
 *
 * <p>Privileged roles are never granted here; new accounts receive the default
 * {@code USER} role only. Student verification stays a separate flow.</p>
 */
@Service
public class GoogleAuthService {

  private static final AuthProvider GOOGLE_PROVIDER = AuthProvider.GOOGLE;

  private final GoogleTokenVerifier googleTokenVerifier;
  private final UserRepository userRepository;
  private final UserExternalIdentityRepository userExternalIdentityRepository;
  private final PasswordEncoder passwordEncoder;
  private final TokenService tokenService;
  private final UserMapper userMapper;
  private final UserRegisteredEventPublisher userRegisteredEventPublisher;

  public GoogleAuthService(
      GoogleTokenVerifier googleTokenVerifier,
      UserRepository userRepository,
      UserExternalIdentityRepository userExternalIdentityRepository,
      PasswordEncoder passwordEncoder,
      TokenService tokenService,
      UserMapper userMapper,
      UserRegisteredEventPublisher userRegisteredEventPublisher
  ) {
    this.googleTokenVerifier = googleTokenVerifier;
    this.userRepository = userRepository;
    this.userExternalIdentityRepository = userExternalIdentityRepository;
    this.passwordEncoder = passwordEncoder;
    this.tokenService = tokenService;
    this.userMapper = userMapper;
    this.userRegisteredEventPublisher = userRegisteredEventPublisher;
  }

  @Transactional
  public AuthResponse authenticate(GoogleLoginRequest request) {
    GoogleIdentity identity = googleTokenVerifier.verify(request.idToken());

    Optional<UserExternalIdentity> linkedIdentity = userExternalIdentityRepository
        .findByProviderAndProviderSubject(GOOGLE_PROVIDER, identity.subject());
    if (linkedIdentity.isPresent()) {
      User user = requireActiveAccount(linkedIdentity.get().getUser());
      return issueAuthResponse(user);
    }

    Optional<User> existingAccount =
        userRepository.findByEmailIgnoreCaseAndDeletedAtIsNull(identity.email());
    User user;
    if (existingAccount.isPresent()) {
      user = requireActiveAccount(existingAccount.get());
      if (!user.isEmailVerified()) {
        user.setEmailVerified(true);
        userRepository.save(user);
      }
    } else {
      user = createGoogleUser(identity);
    }

    linkIdentity(user, identity);
    return issueAuthResponse(user);
  }

  private User createGoogleUser(GoogleIdentity identity) {
    User user = new User();
    user.setEmail(identity.email());
    // Provider accounts may not have a phone number; the column is nullable.
    user.setPhone(null);
    user.setFullName(displayNameFor(identity));
    // Store a hash of a random, never-disclosed secret so password login stays
    // impossible until the user sets a password through the standard flow.
    user.setPasswordHash(passwordEncoder.encode(UUID.randomUUID().toString()));
    user.setRole(Role.USER);
    user.setEmailVerified(true);

    User savedUser = userRepository.save(user);
    userRegisteredEventPublisher.publish(new UserRegisteredEvent(
        savedUser.getId(),
        savedUser.getEmail(),
        savedUser.getFullName(),
        savedUser.getRole(),
        OffsetDateTime.now()
    ));
    return savedUser;
  }

  private void linkIdentity(User user, GoogleIdentity identity) {
    UserExternalIdentity externalIdentity = new UserExternalIdentity();
    externalIdentity.setUser(user);
    externalIdentity.setProvider(GOOGLE_PROVIDER);
    externalIdentity.setProviderSubject(identity.subject());
    userExternalIdentityRepository.save(externalIdentity);
  }

  private AuthResponse issueAuthResponse(User user) {
    return new AuthResponse(userMapper.toAuthResponse(user), tokenService.issueTokens(user));
  }

  private User requireActiveAccount(User user) {
    if (user.getDeletedAt() != null || !user.isActive()) {
      throw new ApiException(ErrorCode.UNAUTHORIZED, "This account is disabled. Contact support.");
    }
    return user;
  }

  private String displayNameFor(GoogleIdentity identity) {
    if (StringUtils.hasText(identity.fullName())) {
      return identity.fullName().trim();
    }
    String email = identity.email();
    int atIndex = email.indexOf('@');
    return atIndex > 0 ? email.substring(0, atIndex) : email;
  }
}
