package com.vithey.content.controller;

import com.vithey.content.dto.response.AuthorSummaryResponse;
import com.vithey.content.security.CurrentUserProvider;
import com.vithey.content.service.FollowService;
import com.vithey.content.util.ApiResponseWrapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/users/{userId}")
@Tag(name = "Follows", description = "Follow graph: follow, unfollow, followers, following")
public class FollowController {

  private final FollowService followService;
  private final CurrentUserProvider currentUserProvider;

  public FollowController(FollowService followService, CurrentUserProvider currentUserProvider) {
    this.followService = followService;
    this.currentUserProvider = currentUserProvider;
  }

  @PostMapping("/follow")
  @Operation(
      summary = "Follow user",
      description = "Follows the target user. Idempotent if already following. Rejects self-follow. Requires JWT."
  )
  @ApiResponse(responseCode = "201", description = "Follow created or already exists")
  @ApiResponse(responseCode = "422", description = "Self-follow rejected")
  ResponseEntity<Void> follow(
      @Parameter(description = "User to follow", example = "018a4379-a9e0-4391-8285-c231aeea577c")
      @PathVariable UUID userId
  ) {
    UUID followerId = currentUserProvider.requireCurrentUser().userId();
    followService.follow(followerId, userId);
    return ResponseEntity.status(HttpStatus.CREATED).build();
  }

  @DeleteMapping("/follow")
  @Operation(
      summary = "Unfollow user",
      description = "Removes the follow edge if present. Requires JWT."
  )
  @ApiResponse(responseCode = "204", description = "Unfollowed")
  ResponseEntity<Void> unfollow(
      @Parameter(description = "User to unfollow", example = "018a4379-a9e0-4391-8285-c231aeea577c")
      @PathVariable UUID userId
  ) {
    UUID followerId = currentUserProvider.requireCurrentUser().userId();
    followService.unfollow(followerId, userId);
    return ResponseEntity.noContent().build();
  }

  @GetMapping("/followers")
  @Operation(
      summary = "List followers",
      description = "Paginated followers for a user. Requires JWT."
  )
  @ApiResponse(responseCode = "200", description = "Followers page")
  ResponseEntity<ApiResponseWrapper<List<AuthorSummaryResponse>>> getFollowers(
      @Parameter(description = "Target user UUID", example = "f984000a-38f4-46e5-a047-019d20a66ce0")
      @PathVariable UUID userId,
      @Parameter(description = "Page number (1-based)", example = "1")
      @RequestParam(defaultValue = "1") int page,
      @Parameter(description = "Page size (max 50)", example = "20")
      @RequestParam(defaultValue = "20") int limit
  ) {
    return ResponseEntity.ok(followService.getFollowers(userId, page, limit));
  }

  @GetMapping("/following")
  @Operation(
      summary = "List following",
      description = "Paginated users the target follows. Requires JWT."
  )
  @ApiResponse(responseCode = "200", description = "Following page")
  ResponseEntity<ApiResponseWrapper<List<AuthorSummaryResponse>>> getFollowing(
      @Parameter(description = "Target user UUID", example = "f984000a-38f4-46e5-a047-019d20a66ce0")
      @PathVariable UUID userId,
      @Parameter(description = "Page number (1-based)", example = "1")
      @RequestParam(defaultValue = "1") int page,
      @Parameter(description = "Page size (max 50)", example = "20")
      @RequestParam(defaultValue = "20") int limit
  ) {
    return ResponseEntity.ok(followService.getFollowing(userId, page, limit));
  }
}
