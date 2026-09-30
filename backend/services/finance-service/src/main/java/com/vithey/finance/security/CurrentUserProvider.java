package com.vithey.finance.security;

import com.vithey.finance.exception.ApiException;
import com.vithey.finance.exception.ErrorCode;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

@Component
public class CurrentUserProvider {

  public CurrentUser requireStudent() {
    CurrentUser currentUser = requireCurrentUser();
    if (!currentUser.hasRole("STUDENT")) {
      throw new ApiException(ErrorCode.FORBIDDEN, "Student access is required");
    }
    return currentUser;
  }

  public CurrentUser requireCurrentUser() {
    Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
    if (authentication == null || !(authentication.getPrincipal() instanceof CurrentUser currentUser)) {
      throw new ApiException(ErrorCode.UNAUTHORIZED);
    }
    return currentUser;
  }
}
