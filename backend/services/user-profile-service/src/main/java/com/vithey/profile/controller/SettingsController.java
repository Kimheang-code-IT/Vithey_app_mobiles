package com.vithey.profile.controller;

import com.vithey.profile.dto.request.UpdateSettingsRequest;
import com.vithey.profile.dto.response.SettingsResponse;
import com.vithey.profile.security.CurrentUserProvider;
import com.vithey.profile.service.SettingsService;
import com.vithey.profile.util.ApiResponseWrapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.UUID;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/users/me/settings")
@Tag(name = "User Settings", description = "Language, theme, notifications, privacy, and FCM token")
public class SettingsController {

  private final SettingsService settingsService;
  private final CurrentUserProvider currentUserProvider;

  public SettingsController(SettingsService settingsService, CurrentUserProvider currentUserProvider) {
    this.settingsService = settingsService;
    this.currentUserProvider = currentUserProvider;
  }

  @GetMapping
  @Operation(
      summary = "Get my settings",
      description = "Returns language, theme, notifications, privacy, and fcm_token for the current user. Requires JWT."
  )
  ResponseEntity<ApiResponseWrapper<SettingsResponse>> getSettings() {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(settingsService.getSettings(userId)));
  }

  @PatchMapping
  @Operation(
      summary = "Update my settings",
      description = "Partial update of settings / FCM token. language: km|en, theme: light|dark|system. Requires JWT."
  )
  ResponseEntity<ApiResponseWrapper<SettingsResponse>> updateSettings(
      @Valid @RequestBody UpdateSettingsRequest request
  ) {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(settingsService.updateSettings(userId, request)));
  }
}
