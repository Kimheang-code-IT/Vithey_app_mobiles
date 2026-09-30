package com.vithey.auth.service;

import com.vithey.auth.dto.response.TokenResponse;
import com.vithey.auth.entity.RefreshToken;
import com.vithey.auth.entity.User;
import com.vithey.auth.exception.ApiException;
import com.vithey.auth.exception.ErrorCode;
import com.vithey.auth.repository.RefreshTokenRepository;
import com.vithey.auth.security.JwtProvider;
import com.vithey.auth.util.OpaqueTokenGenerator;
import com.vithey.auth.util.TokenHash;
import java.time.Duration;
import java.time.OffsetDateTime;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class TokenService {

  private static final int REFRESH_TOKEN_BYTES = 48;

  private final RefreshTokenRepository refreshTokenRepository;
  private final JwtProvider jwtProvider;
  private final Duration refreshTokenTtl;

  public TokenService(
      RefreshTokenRepository refreshTokenRepository,
      JwtProvider jwtProvider,
      @Value("${vithey.jwt.refresh-token-ttl}") Duration refreshTokenTtl
  ) {
    this.refreshTokenRepository = refreshTokenRepository;
    this.jwtProvider = jwtProvider;
    this.refreshTokenTtl = refreshTokenTtl;
  }

  @Transactional
  public TokenResponse issueTokens(User user) {
    String refreshTokenValue = generateOpaqueToken();

    RefreshToken refreshToken = new RefreshToken();
    refreshToken.setUser(user);
    refreshToken.setTokenHash(TokenHash.sha256(refreshTokenValue));
    refreshToken.setExpiresAt(OffsetDateTime.now().plus(refreshTokenTtl));
    refreshTokenRepository.save(refreshToken);

    return new TokenResponse(
        jwtProvider.createAccessToken(user),
        refreshTokenValue,
        jwtProvider.accessTokenExpiresInSeconds()
    );
  }

  @Transactional
  public TokenResponse rotateRefreshToken(String rawRefreshToken) {
    OffsetDateTime now = OffsetDateTime.now();
    RefreshToken refreshToken = refreshTokenRepository.findByTokenHash(TokenHash.sha256(rawRefreshToken))
        .orElseThrow(() -> new ApiException(ErrorCode.INVALID_TOKEN));

    if (refreshToken.isRevoked() || refreshToken.isExpired(now)) {
      throw new ApiException(ErrorCode.INVALID_TOKEN);
    }

    refreshToken.setRevokedAt(now);
    refreshTokenRepository.save(refreshToken);
    return issueTokens(refreshToken.getUser());
  }

  @Transactional
  public void revokeRefreshToken(String rawRefreshToken) {
    refreshTokenRepository.findByTokenHash(TokenHash.sha256(rawRefreshToken))
        .ifPresent(refreshToken -> {
          if (!refreshToken.isRevoked()) {
            refreshToken.setRevokedAt(OffsetDateTime.now());
            refreshTokenRepository.save(refreshToken);
          }
        });
  }

  private String generateOpaqueToken() {
    return OpaqueTokenGenerator.generate(REFRESH_TOKEN_BYTES);
  }
}
