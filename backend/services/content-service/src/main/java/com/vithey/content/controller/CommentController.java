package com.vithey.content.controller;

import com.vithey.content.dto.request.CreateCommentRequest;
import com.vithey.content.dto.request.UpdateCommentRequest;
import com.vithey.content.dto.response.CommentResponse;
import com.vithey.content.security.CurrentUserProvider;
import com.vithey.content.service.CommentService;
import com.vithey.content.util.ApiResponseWrapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/posts/{postId}/comments")
@Tag(name = "Comments", description = "List, add, edit, and delete comments on posts")
public class CommentController {

  private final CommentService commentService;
  private final CurrentUserProvider currentUserProvider;

  public CommentController(CommentService commentService, CurrentUserProvider currentUserProvider) {
    this.commentService = commentService;
    this.currentUserProvider = currentUserProvider;
  }

  @GetMapping
  @Operation(
      summary = "List comments",
      description = "Paginated comments for a post, newest first. Requires JWT."
  )
  @ApiResponse(responseCode = "200", description = "Comment page")
  @ApiResponse(responseCode = "404", description = "Post not found")
  ResponseEntity<ApiResponseWrapper<List<CommentResponse>>> getComments(
      @Parameter(description = "Post UUID", example = "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
      @PathVariable UUID postId,
      @Parameter(description = "Page number (1-based)", example = "1")
      @RequestParam(defaultValue = "1") int page,
      @Parameter(description = "Page size (max 50)", example = "20")
      @RequestParam(defaultValue = "20") int limit
  ) {
    return ResponseEntity.ok(commentService.getComments(postId, page, limit));
  }

  @PostMapping
  @Operation(
      summary = "Add comment",
      description = "Adds a comment and optional mention_user_ids. Publishes comment.added and mention.created events. Requires JWT."
  )
  @ApiResponse(responseCode = "201", description = "Created")
  @ApiResponse(responseCode = "400", description = "Validation error")
  @ApiResponse(responseCode = "404", description = "Post not found")
  ResponseEntity<ApiResponseWrapper<CommentResponse>> addComment(
      @Parameter(description = "Post UUID", example = "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
      @PathVariable UUID postId,
      @Valid @RequestBody CreateCommentRequest request
  ) {
    UUID authorId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.status(HttpStatus.CREATED)
        .body(ApiResponseWrapper.success(commentService.addComment(postId, authorId, request)));
  }

  @PatchMapping("/{commentId}")
  @Operation(
      summary = "Edit comment",
      description = "Updates the text of a comment. Comment author only. Requires JWT."
  )
  @ApiResponse(responseCode = "200", description = "Updated comment")
  @ApiResponse(responseCode = "400", description = "Validation error")
  @ApiResponse(responseCode = "403", description = "Not the comment author")
  @ApiResponse(responseCode = "404", description = "Post or comment not found")
  ResponseEntity<ApiResponseWrapper<CommentResponse>> updateComment(
      @Parameter(description = "Post UUID", example = "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
      @PathVariable UUID postId,
      @Parameter(description = "Comment UUID", example = "b2c3d4e5-f6a7-8901-bcde-f12345678901")
      @PathVariable UUID commentId,
      @Valid @RequestBody UpdateCommentRequest request
  ) {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(
        ApiResponseWrapper.success(commentService.updateComment(postId, commentId, userId, request))
    );
  }

  @DeleteMapping("/{commentId}")
  @Operation(
      summary = "Delete comment",
      description = "Deletes a comment and its mentions. Comment author only. Requires JWT."
  )
  @ApiResponse(responseCode = "204", description = "Deleted")
  @ApiResponse(responseCode = "403", description = "Not the comment author")
  @ApiResponse(responseCode = "404", description = "Post or comment not found")
  ResponseEntity<Void> deleteComment(
      @Parameter(description = "Post UUID", example = "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
      @PathVariable UUID postId,
      @Parameter(description = "Comment UUID", example = "b2c3d4e5-f6a7-8901-bcde-f12345678901")
      @PathVariable UUID commentId
  ) {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    commentService.deleteComment(postId, commentId, userId);
    return ResponseEntity.noContent().build();
  }
}
