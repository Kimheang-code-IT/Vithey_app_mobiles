package com.vithey.auth.mapper;

import com.vithey.auth.dto.response.UserAuthResponse;
import com.vithey.auth.entity.User;
import org.springframework.stereotype.Component;

@Component
public class UserMapper {

  public UserAuthResponse toAuthResponse(User user) {
    return new UserAuthResponse(
        user.getId(),
        user.getEmail(),
        user.getPhone(),
        user.getFullName(),
        user.getRole(),
        user.isStudentVerified(),
        user.isEmailVerified()
    );
  }
}
