package com.vithey.finance.security;

import java.util.List;
import java.util.UUID;

public record CurrentUser(UUID userId, String email, List<String> roles) {

  public boolean hasRole(String role) {
    return roles.stream().anyMatch(value -> value.equalsIgnoreCase(role));
  }
}
