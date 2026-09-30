package com.vithey.content.controller;

import com.vithey.content.dto.response.ReactionSummaryResponse;
import com.vithey.content.security.CurrentUserProvider;
import com.vithey.content.service.ReactionService;
import com.vithey.content.util.ApiResponseWrapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.UUID;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/posts/{postId}/reactions")
@Tag(name = "Reactions", description = "Toggle and read post reactions")
public class ReactionController {

  private final ReactionService reactionService;
  private final CurrentUserProvider currentUserProvider;

  public ReactionController(ReactionService reactionService, CurrentUserProvider currentUserProvider) {
    this.reactionService = reactionService;
    this.currentUserProvider = currentUserProvider;
  }

  @PostMapping
  @Operation(
      summary = "Toggle reaction",
      description = "Adds a like if absent, removes it if present. Publishes reaction.added only on insert. Requires JWT."
  )
  @ApiResponse(responseCode = "200", description = "Updated summary")
  @ApiResponse(responseCode = "404", description = "Post not found")
  ResponseEntity<ApiResponseWrapper<ReactionSummaryResponse>> toggleReaction(
      @Parameter(description = "Post UUID", example = "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
      @PathVariable UUID postId
  ) {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(reactionService.toggleReaction(postId, userId)));
  }

  @GetMapping
  @Operation(
      summary = "Get reaction summary",
      description = "Returns reaction_count and whether the current user reacted. Requires JWT."
  )
  @ApiResponse(responseCode = "200", description = "Summary")
  @ApiResponse(responseCode = "404", description = "Post not found")
  ResponseEntity<ApiResponseWrapper<ReactionSummaryResponse>> getReactions(
      @Parameter(description = "Post UUID", example = "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
      @PathVariable UUID postId
  ) {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(reactionService.getReactions(postId, userId)));
  }
}
