package com.vithey.auth.dto.response;

public record TokenResponse(
    String accessToken,
    String refreshToken,
    long expiresIn
) {
}
