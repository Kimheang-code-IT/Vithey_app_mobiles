package com.vithey.career.controller;

import com.vithey.career.dto.request.SetCvRequest;
import com.vithey.career.dto.response.UserCvResponse;
import com.vithey.career.security.CurrentUserProvider;
import com.vithey.career.service.UserCvService;
import com.vithey.career.util.ApiResponseWrapper;
import jakarta.validation.Valid;
import java.util.UUID;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/users/me/cv")
public class UserCvController {

  private final UserCvService userCvService;
  private final CurrentUserProvider currentUserProvider;

  public UserCvController(UserCvService userCvService, CurrentUserProvider currentUserProvider) {
    this.userCvService = userCvService;
    this.currentUserProvider = currentUserProvider;
  }

  @GetMapping
  ResponseEntity<ApiResponseWrapper<UserCvResponse>> getMyCv() {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(userCvService.getUserCv(userId)));
  }

  @PutMapping
  ResponseEntity<ApiResponseWrapper<UserCvResponse>> setMyCv(
      @Valid @RequestBody SetCvRequest request
  ) {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(userCvService.setUserCv(userId, request)));
  }
}
