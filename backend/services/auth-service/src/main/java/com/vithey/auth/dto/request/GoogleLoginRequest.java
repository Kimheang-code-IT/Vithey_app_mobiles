package com.vithey.auth.dto.request;

import jakarta.validation.constraints.NotBlank;

/**
 * Google sign-in request. Only the Google-issued ID token is accepted; the
 * server derives the identity from the verified token and never trusts
 * separate email/name values.
 */
public record GoogleLoginRequest(
    @NotBlank String idToken
) {
}
