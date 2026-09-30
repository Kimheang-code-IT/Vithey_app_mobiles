package com.vithey.profile.security;

import com.vithey.profile.exception.ApiException;
import com.vithey.profile.exception.ErrorCode;
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
