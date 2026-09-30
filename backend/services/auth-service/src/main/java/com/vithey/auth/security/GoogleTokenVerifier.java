package com.vithey.auth.security;

import com.nimbusds.jose.JOSEException;
import com.nimbusds.jose.JWSAlgorithm;
import com.nimbusds.jose.jwk.source.JWKSource;
import com.nimbusds.jose.jwk.source.RemoteJWKSet;
import com.nimbusds.jose.proc.BadJOSEException;
import com.nimbusds.jose.proc.JWSVerificationKeySelector;
import com.nimbusds.jose.proc.SecurityContext;
import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.proc.ConfigurableJWTProcessor;
import com.nimbusds.jwt.proc.DefaultJWTClaimsVerifier;
import com.nimbusds.jwt.proc.DefaultJWTProcessor;
import com.vithey.auth.exception.ApiException;
import com.vithey.auth.exception.ErrorCode;
import java.net.MalformedURLException;
import java.net.URL;
import java.text.ParseException;
import java.util.Locale;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

/**
 * Verifies Google OpenID Connect ID tokens.
 *
 * <p>Validation performed on every token:</p>
 * <ul>
 *   <li>RS256 signature against Google's published JWKS (key rotation aware)</li>
 *   <li>issuer is {@code https://accounts.google.com} (or the legacy
 *       {@code accounts.google.com})</li>
 *   <li>audience equals the configured Web OAuth client ID</li>
 *   <li>expiration (and not-before/issued-at when present)</li>
 *   <li>{@code sub}, {@code email} and {@code email_verified} are present, and
 *       the email is verified</li>
 * </ul>
 *
 * <p>The client-provided email/name are never trusted: identity values are only
 * read from the verified token payload.</p>
 */
@Component
public class GoogleTokenVerifier {

  static final String DEFAULT_JWK_SET_URI = "https://www.googleapis.com/oauth2/v3/certs";

  private static final Set<String> ACCEPTED_ISSUERS =
      Set.of("https://accounts.google.com", "accounts.google.com");
  private static final Set<String> REQUIRED_CLAIMS =
      Set.of("iss", "aud", "exp", "sub", "email", "email_verified");

  private final String webClientId;
  private final ConfigurableJWTProcessor<SecurityContext> processor;

  @Autowired
  public GoogleTokenVerifier(
      @Value("${vithey.oauth.google.web-client-id:}") String webClientId,
      @Value("${vithey.oauth.google.jwk-set-uri:" + DEFAULT_JWK_SET_URI + "}") String jwkSetUri
  ) throws MalformedURLException {
    this(webClientId, new RemoteJWKSet<>(new URL(jwkSetUri)));
  }

  /** Test-friendly constructor with an injectable key source. */
  GoogleTokenVerifier(String webClientId, JWKSource<SecurityContext> jwkSource) {
    this.webClientId = webClientId == null ? "" : webClientId.trim();

    DefaultJWTProcessor<SecurityContext> jwtProcessor = new DefaultJWTProcessor<>();
    jwtProcessor.setJWSKeySelector(new JWSVerificationKeySelector<>(JWSAlgorithm.RS256, jwkSource));

    JWTClaimsSet exactMatchClaims = StringUtils.hasText(this.webClientId)
        ? new JWTClaimsSet.Builder().audience(this.webClientId).build()
        : null;
    jwtProcessor.setJWTClaimsSetVerifier(
        new DefaultJWTClaimsVerifier<>(exactMatchClaims, REQUIRED_CLAIMS)
    );

    this.processor = jwtProcessor;
  }

  public GoogleIdentity verify(String idToken) {
    if (!StringUtils.hasText(webClientId)) {
      throw new ApiException(ErrorCode.INTERNAL_ERROR, "Google sign-in is not configured");
    }
    if (!StringUtils.hasText(idToken)) {
      throw new ApiException(ErrorCode.INVALID_TOKEN, "Google token is invalid or expired");
    }

    JWTClaimsSet claims;
    try {
      claims = processor.process(idToken, null);
    } catch (ParseException | BadJOSEException | JOSEException exception) {
      throw new ApiException(ErrorCode.INVALID_TOKEN, "Google token is invalid or expired");
    }

    String issuer = claims.getIssuer();
    if (issuer == null || !ACCEPTED_ISSUERS.contains(issuer)) {
      throw new ApiException(ErrorCode.INVALID_TOKEN, "Google token is invalid or expired");
    }

    String subject = claims.getSubject();
    String email = asText(claims.getClaim("email"));
    Object emailVerifiedClaim = claims.getClaim("email_verified");
    if (!StringUtils.hasText(subject) || !StringUtils.hasText(email)
        || !isTrue(emailVerifiedClaim)) {
      throw new ApiException(ErrorCode.INVALID_TOKEN, "Google account email is not verified");
    }

    return new GoogleIdentity(
        subject,
        email.trim().toLowerCase(Locale.ROOT),
        true,
        asText(claims.getClaim("name")),
        asText(claims.getClaim("picture"))
    );
  }

  private String asText(Object value) {
    return value == null ? null : value.toString();
  }

  private boolean isTrue(Object value) {
    if (value instanceof Boolean booleanValue) {
      return booleanValue;
    }
    return value != null && Boolean.parseBoolean(value.toString());
  }
}
