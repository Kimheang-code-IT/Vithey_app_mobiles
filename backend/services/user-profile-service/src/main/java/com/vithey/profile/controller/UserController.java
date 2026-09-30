package com.vithey.profile.controller;

import com.vithey.profile.dto.request.UpdateAvatarRequest;
import com.vithey.profile.dto.request.UpdateProfileRequest;
import com.vithey.profile.dto.response.MeProfileResponse;
import com.vithey.profile.dto.response.ProfileResponse;
import com.vithey.profile.dto.response.UserSearchResultResponse;
import com.vithey.profile.security.CurrentUserProvider;
import com.vithey.profile.service.ProfileService;
import com.vithey.profile.service.UserSearchService;
import com.vithey.profile.util.ApiResponseWrapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/users")
@Tag(name = "User Profile", description = "Current profile, public profile, avatar, and user search")
public class UserController {

  private final ProfileService profileService;
  private final UserSearchService userSearchService;
  private final CurrentUserProvider currentUserProvider;

  public UserController(
      ProfileService profileService,
      UserSearchService userSearchService,
      CurrentUserProvider currentUserProvider
  ) {
    this.profileService = profileService;
    this.userSearchService = userSearchService;
    this.currentUserProvider = currentUserProvider;
  }

  @GetMapping("/search")
  @Operation(
      summary = "Search users",
      description = "Search users by full name (ILIKE) for chat/mentions. Requires JWT."
  )
  ResponseEntity<ApiResponseWrapper<List<UserSearchResultResponse>>> searchUsers(
      @Parameter(description = "Search text matched against full_name", required = true, example = "Jane")
      @RequestParam String search,
      @Parameter(description = "Page number (1-based)", example = "1")
      @RequestParam(defaultValue = "1") int page,
      @Parameter(description = "Page size", example = "20")
      @RequestParam(defaultValue = "20") int limit
  ) {
    return ResponseEntity.ok(userSearchService.search(search, page, limit));
  }

  @GetMapping("/me")
  @Operation(
      summary = "Get my profile",
      description = "Returns the authenticated user's profile plus language/theme summary. Requires JWT."
  )
  ResponseEntity<ApiResponseWrapper<MeProfileResponse>> getMyProfile() {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(profileService.getMyProfile(userId)));
  }

  @GetMapping("/{userId}")
  @Operation(
      summary = "Get public profile by id",
      description = "Returns a public profile for the given user id. Requires JWT."
  )
  ResponseEntity<ApiResponseWrapper<ProfileResponse>> getPublicProfile(
      @Parameter(description = "Target user UUID", example = "00000000-0000-0000-0000-000000000001")
      @PathVariable UUID userId
  ) {
    return ResponseEntity.ok(ApiResponseWrapper.success(profileService.getPublicProfile(userId)));
  }

  @PatchMapping("/me")
  @Operation(
      summary = "Update my profile",
      description = "Partial update of the current user's profile fields. All body fields are optional. Requires JWT."
  )
  ResponseEntity<ApiResponseWrapper<ProfileResponse>> updateMyProfile(
      @Valid @RequestBody UpdateProfileRequest request
  ) {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(profileService.updateProfile(userId, request)));
  }

  @PatchMapping("/me/avatar")
  @Operation(
      summary = "Update my avatar",
      description = "Sets avatar from an uploaded file id (file-service). `avatar_file_id` is required. Requires JWT."
  )
  ResponseEntity<ApiResponseWrapper<ProfileResponse>> updateMyAvatar(
      @Valid @RequestBody UpdateAvatarRequest request
  ) {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(profileService.updateAvatar(userId, request)));
  }

}
