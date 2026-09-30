package com.vithey.notification.controller;

import com.vithey.notification.dto.request.RegisterDeviceRequest;
import com.vithey.notification.dto.response.DeviceTokenResponse;
import com.vithey.notification.security.CurrentUserProvider;
import com.vithey.notification.service.DeviceTokenService;
import com.vithey.notification.util.ApiResponseWrapper;
import jakarta.validation.Valid;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/notifications/devices")
public class DeviceTokenController {

  private final DeviceTokenService deviceTokenService;
  private final CurrentUserProvider currentUserProvider;

  public DeviceTokenController(DeviceTokenService deviceTokenService, CurrentUserProvider currentUserProvider) {
    this.deviceTokenService = deviceTokenService;
    this.currentUserProvider = currentUserProvider;
  }

  @PostMapping
  ResponseEntity<ApiResponseWrapper<DeviceTokenResponse>> registerDevice(
      @Valid @RequestBody RegisterDeviceRequest request
  ) {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.status(HttpStatus.CREATED)
        .body(ApiResponseWrapper.success(deviceTokenService.registerDevice(userId, request)));
  }

  @DeleteMapping("/{token}")
  ResponseEntity<Void> removeDevice(@PathVariable String token) {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    deviceTokenService.removeDevice(userId, token);
    return ResponseEntity.noContent().build();
  }
}
