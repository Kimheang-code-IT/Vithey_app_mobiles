package com.vithey.auth.security;

/**
 * Verified identity extracted from a trusted Google ID token.
 *
 * <p>Values here originate from the cryptographically verified token payload,
 * never from client-supplied request fields.</p>
 */
public record GoogleIdentity(
    String subject,
    String email,
    boolean emailVerified,
    String fullName,
    String pictureUrl
) {
}
