package com.vithey.auth.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.nimbusds.jose.JWSAlgorithm;
import com.nimbusds.jose.JWSHeader;
import com.nimbusds.jose.crypto.RSASSASigner;
import com.nimbusds.jose.jwk.JWKSet;
import com.nimbusds.jose.jwk.RSAKey;
import com.nimbusds.jose.jwk.source.ImmutableJWKSet;
import com.nimbusds.jose.jwk.source.JWKSource;
import com.nimbusds.jose.proc.SecurityContext;
import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.SignedJWT;
import com.vithey.auth.exception.ApiException;
import com.vithey.auth.exception.ErrorCode;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.interfaces.RSAPrivateKey;
import java.security.interfaces.RSAPublicKey;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Date;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

class GoogleTokenVerifierTest {

  private static final String CLIENT_ID = "1234567890-abcdef.apps.googleusercontent.com";
  private static final String SUBJECT = "10769150350006150715113082367";
  private static final String EMAIL = "Student@Aub.edu.kh";
  private static final String KEY_ID = "test-key";

  private static KeyPair signingKeyPair;
  private static KeyPair otherKeyPair;
  private static GoogleTokenVerifier verifier;

  @BeforeAll
  static void setUp() throws Exception {
    KeyPairGenerator generator = KeyPairGenerator.getInstance("RSA");
    generator.initialize(2048);
    signingKeyPair = generator.generateKeyPair();
    otherKeyPair = generator.generateKeyPair();

    RSAKey publicJwk = new RSAKey.Builder((RSAPublicKey) signingKeyPair.getPublic())
        .keyID(KEY_ID)
        .build();
    JWKSource<SecurityContext> jwkSource = new ImmutableJWKSet<>(new JWKSet(publicJwk));
    verifier = new GoogleTokenVerifier(CLIENT_ID, jwkSource);
  }

  @Test
  void acceptsValidTokenAndExtractsVerifiedIdentity() throws Exception {
    GoogleIdentity identity = verifier.verify(token(
        CLIENT_ID, "https://accounts.google.com", future(), SUBJECT, EMAIL, true, signingKeyPair));

    assertThat(identity.subject()).isEqualTo(SUBJECT);
    assertThat(identity.email()).isEqualTo("student@aub.edu.kh");
    assertThat(identity.emailVerified()).isTrue();
    assertThat(identity.fullName()).isEqualTo("Test User");
  }

  @Test
  void acceptsLegacyGoogleIssuer() throws Exception {
    GoogleIdentity identity = verifier.verify(token(
        CLIENT_ID, "accounts.google.com", future(), SUBJECT, EMAIL, true, signingKeyPair));

    assertThat(identity.subject()).isEqualTo(SUBJECT);
  }

  @Test
  void rejectsExpiredToken() throws Exception {
    assertInvalid(token(
        CLIENT_ID, "https://accounts.google.com", past(), SUBJECT, EMAIL, true, signingKeyPair));
  }

  @Test
  void rejectsWrongAudience() throws Exception {
    assertInvalid(token(
        "9999-other.apps.googleusercontent.com",
        "https://accounts.google.com", future(), SUBJECT, EMAIL, true, signingKeyPair));
  }

  @Test
  void rejectsWrongIssuer() throws Exception {
    assertInvalid(token(
        CLIENT_ID, "https://evil.example.com", future(), SUBJECT, EMAIL, true, signingKeyPair));
  }

  @Test
  void rejectsTokenSignedByUnknownKey() throws Exception {
    assertInvalid(token(
        CLIENT_ID, "https://accounts.google.com", future(), SUBJECT, EMAIL, true, otherKeyPair));
  }

  @Test
  void rejectsUnverifiedEmail() throws Exception {
    assertInvalid(token(
        CLIENT_ID, "https://accounts.google.com", future(), SUBJECT, EMAIL, false, signingKeyPair));
  }

  @Test
  void rejectsMissingEmail() throws Exception {
    assertInvalid(token(
        CLIENT_ID, "https://accounts.google.com", future(), SUBJECT, null, true, signingKeyPair));
  }

  @Test
  void rejectsBlankToken() {
    assertThatThrownBy(() -> verifier.verify(" "))
        .isInstanceOf(ApiException.class)
        .satisfies(ex -> assertThat(((ApiException) ex).getErrorCode()).isEqualTo(ErrorCode.INVALID_TOKEN));
  }

  @Test
  void reportsConfigurationErrorWhenClientIdMissing() {
    GoogleTokenVerifier unconfigured = new GoogleTokenVerifier("  ", new ImmutableJWKSet<>(new JWKSet()));
    assertThatThrownBy(() -> unconfigured.verify("token"))
        .isInstanceOf(ApiException.class)
        .satisfies(ex -> assertThat(((ApiException) ex).getErrorCode()).isEqualTo(ErrorCode.INTERNAL_ERROR));
  }

  private void assertInvalid(String token) {
    assertThatThrownBy(() -> verifier.verify(token))
        .isInstanceOf(ApiException.class)
        .satisfies(ex -> assertThat(((ApiException) ex).getErrorCode()).isEqualTo(ErrorCode.INVALID_TOKEN));
  }

  private Date future() {
    return Date.from(Instant.now().plus(5, ChronoUnit.MINUTES));
  }

  private Date past() {
    return Date.from(Instant.now().minus(10, ChronoUnit.MINUTES));
  }

  private String token(
      String audience,
      String issuer,
      Date expiration,
      String subject,
      String email,
      boolean emailVerified,
      KeyPair signingKey
  ) throws Exception {
    JWTClaimsSet.Builder claims = new JWTClaimsSet.Builder()
        .issuer(issuer)
        .audience(audience)
        .subject(subject)
        .expirationTime(expiration)
        .issueTime(Date.from(Instant.now().minus(1, ChronoUnit.MINUTES)))
        .claim("email_verified", emailVerified)
        .claim("name", "Test User");
    if (email != null) {
      claims.claim("email", email);
    }

    SignedJWT jwt = new SignedJWT(
        new JWSHeader.Builder(JWSAlgorithm.RS256).keyID(KEY_ID).build(),
        claims.build());
    jwt.sign(new RSASSASigner((RSAPrivateKey) signingKey.getPrivate()));
    return jwt.serialize();
  }
}
