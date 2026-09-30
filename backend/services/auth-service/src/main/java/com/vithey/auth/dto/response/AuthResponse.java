package com.vithey.auth.dto.response;

public record AuthResponse(
    UserAuthResponse user,
    TokenResponse tokens
) {
}
