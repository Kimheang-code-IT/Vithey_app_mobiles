package com.vithey.chat.security;

import java.security.Principal;

public record StompUser(CurrentUser currentUser) implements Principal {

  @Override
  public String getName() {
    return currentUser.userId().toString();
  }
}
