package com.vithey.chat.security;

import java.util.List;
import java.util.UUID;

public record CurrentUser(UUID userId, String email, List<String> roles) {
}
