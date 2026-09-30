package com.vithey.chat.security;

import com.vithey.chat.exception.ApiException;
import com.vithey.chat.exception.ErrorCode;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

@Component
public class CurrentUserProvider {

  public CurrentUser requireCurrentUser() {
    Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
    if (authentication == null || !(authentication.getPrincipal() instanceof CurrentUser currentUser)) {
      throw new ApiException(ErrorCode.UNAUTHORIZED);
    }
    return currentUser;
  }
}
