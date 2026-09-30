package com.vithey.content.controller;

import com.vithey.content.dto.request.CreatePostRequest;
import com.vithey.content.dto.response.PostResponse;
import com.vithey.content.entity.PostType;
import com.vithey.content.security.CurrentUserProvider;
import com.vithey.content.service.FeedService;
import com.vithey.content.service.PostSearchService;
import com.vithey.content.service.PostService;
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
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
@Tag(name = "Posts", description = "Home feed, create/get/delete posts, and user post lists")
public class PostController {

  private final FeedService feedService;
  private final PostSearchService postSearchService;
  private final PostService postService;
  private final CurrentUserProvider currentUserProvider;

  public PostController(
      FeedService feedService,
      PostSearchService postSearchService,
      PostService postService,
      CurrentUserProvider currentUserProvider
  ) {
    this.feedService = feedService;
    this.postSearchService = postSearchService;
    this.postService = postService;
    this.currentUserProvider = currentUserProvider;
  }

  @GetMapping("/posts")
  @Operation(
      summary = "Home feed or search",
      description = "Without search: posts from followed users plus the current user, newest first. With search: global content search. Paginated. Requires JWT."
  )
  @ApiResponse(responseCode = "200", description = "Feed or search page")
  @ApiResponse(responseCode = "401", description = "Missing or invalid JWT")
  ResponseEntity<ApiResponseWrapper<List<PostResponse>>> listPosts(
      @RequestParam(required = false) String search,
      @RequestParam(required = false) PostType type,
      @Parameter(description = "Page number (1-based)", example = "1")
      @RequestParam(defaultValue = "1") int page,
      @Parameter(description = "Page size (max 50)", example = "20")
      @RequestParam(defaultValue = "20") int limit
  ) {
    UUID viewerId = currentUserProvider.requireCurrentUser().userId();
    if (StringUtils.hasText(search)) {
      return ResponseEntity.ok(postSearchService.search(search, type, viewerId, page, limit));
    }
    return ResponseEntity.ok(feedService.getFeed(viewerId, page, limit));
  }

  @PostMapping("/posts")
  @Operation(
      summary = "Create post",
      description = "Create a VIDEO, POSTER, or JOB post. Media posts require media_file_id validated via file-service. Requires JWT."
  )
  @ApiResponse(responseCode = "201", description = "Created")
  @ApiResponse(responseCode = "400", description = "Validation or invalid media file")
  @ApiResponse(responseCode = "401", description = "Missing or invalid JWT")
  ResponseEntity<ApiResponseWrapper<PostResponse>> createPost(
      @Valid @RequestBody CreatePostRequest request
  ) {
    UUID authorId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.status(HttpStatus.CREATED)
        .body(ApiResponseWrapper.success(postService.createPost(authorId, request)));
  }

  @GetMapping("/posts/{postId}")
  @Operation(
      summary = "Get post detail",
      description = "Returns an active (not soft-deleted) post enriched with author, media URL, and reaction/comment counts. Requires JWT."
  )
  @ApiResponse(responseCode = "200", description = "Found")
  @ApiResponse(responseCode = "404", description = "Post not found or deleted")
  ResponseEntity<ApiResponseWrapper<PostResponse>> getPost(
      @Parameter(description = "Post UUID", example = "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
      @PathVariable UUID postId
  ) {
    UUID viewerId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(postService.getPost(postId, viewerId)));
  }

  @DeleteMapping("/posts/{postId}")
  @Operation(
      summary = "Delete own post",
      description = "Soft-deletes a post owned by the current user. Requires JWT."
  )
  @ApiResponse(responseCode = "204", description = "Deleted")
  @ApiResponse(responseCode = "403", description = "Not the post owner")
  @ApiResponse(responseCode = "404", description = "Post not found")
  ResponseEntity<Void> deletePost(
      @Parameter(description = "Post UUID", example = "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
      @PathVariable UUID postId
  ) {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    postService.deletePost(postId, userId);
    return ResponseEntity.noContent().build();
  }

  @GetMapping("/users/{userId}/posts")
  @Operation(
      summary = "List user posts",
      description = "Paginated posts for a user profile. Optional type filter: VIDEO, POSTER, JOB. Requires JWT."
  )
  @ApiResponse(responseCode = "200", description = "Post page")
  ResponseEntity<ApiResponseWrapper<List<PostResponse>>> getUserPosts(
      @Parameter(description = "Author user UUID", example = "f984000a-38f4-46e5-a047-019d20a66ce0")
      @PathVariable UUID userId,
      @Parameter(description = "Optional post type filter", example = "JOB")
      @RequestParam(required = false) PostType type,
      @Parameter(description = "Page number (1-based)", example = "1")
      @RequestParam(defaultValue = "1") int page,
      @Parameter(description = "Page size (max 50)", example = "20")
      @RequestParam(defaultValue = "20") int limit
  ) {
    UUID viewerId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(postService.getUserPosts(userId, type, viewerId, page, limit));
  }
}
