package com.vithey.content.service;

import com.vithey.content.client.FileServiceClient;
import com.vithey.content.dto.request.CreatePostRequest;
import com.vithey.content.dto.response.PostResponse;
import com.vithey.content.entity.Post;
import com.vithey.content.entity.PostType;
import com.vithey.content.event.payload.PostCreatedEvent;
import com.vithey.content.event.publisher.ContentEventPublisher;
import com.vithey.content.exception.ApiException;
import com.vithey.content.exception.ErrorCode;
import com.vithey.content.repository.PostRepository;
import com.vithey.content.util.ApiResponseWrapper;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PostService {

  private static final int DEFAULT_LIMIT = 20;
  private static final int MAX_LIMIT = 50;

  private final PostRepository postRepository;
  private final FileServiceClient fileServiceClient;
  private final PostEnrichmentService postEnrichmentService;
  private final ContentEventPublisher contentEventPublisher;

  public PostService(
      PostRepository postRepository,
      FileServiceClient fileServiceClient,
      PostEnrichmentService postEnrichmentService,
      ContentEventPublisher contentEventPublisher
  ) {
    this.postRepository = postRepository;
    this.fileServiceClient = fileServiceClient;
    this.postEnrichmentService = postEnrichmentService;
    this.contentEventPublisher = contentEventPublisher;
  }

  @Transactional
  public PostResponse createPost(UUID authorId, CreatePostRequest request) {
    validateCreateRequest(request);

    OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
    Post post = new Post();
    post.setId(UUID.randomUUID());
    post.setAuthorId(authorId);
    post.setType(request.type());
    post.setContent(request.content());
    post.setCreatedAt(now);
    post.setUpdatedAt(now);

    if (request.type() == PostType.JOB) {
      CreatePostRequest.JobMetaRequest jobMeta = request.jobMeta();
      post.setJobTitle(jobMeta.title());
      post.setJobDescription(jobMeta.description());
      post.setJobRequirement(jobMeta.requirement());
      post.setJobDeadline(jobMeta.deadline());
    } else {
      post.setMediaFileId(request.mediaFileId());
      validateMediaFile(request.type(), request.mediaFileId());
    }

    Post saved = postRepository.save(post);
    contentEventPublisher.publishPostCreated(new PostCreatedEvent(
        saved.getId(),
        saved.getAuthorId(),
        saved.getType(),
        saved.getCreatedAt()
    ));
    return postEnrichmentService.enrich(saved, authorId);
  }

  @Transactional(readOnly = true)
  public PostResponse getPost(UUID postId, UUID viewerId) {
    Post post = requireActivePost(postId);
    return postEnrichmentService.enrich(post, viewerId);
  }

  @Transactional
  public void deletePost(UUID postId, UUID userId) {
    Post post = requireActivePost(postId);
    if (!post.getAuthorId().equals(userId)) {
      throw new ApiException(ErrorCode.FORBIDDEN);
    }
    post.setDeletedAt(OffsetDateTime.now(ZoneOffset.UTC));
    post.setUpdatedAt(OffsetDateTime.now(ZoneOffset.UTC));
    postRepository.save(post);
  }

  @Transactional(readOnly = true)
  public ApiResponseWrapper<java.util.List<PostResponse>> getUserPosts(
      UUID userId,
      PostType type,
      UUID viewerId,
      int page,
      int limit
  ) {
    int safePage = Math.max(page, 1);
    int safeLimit = Math.min(Math.max(limit, 1), MAX_LIMIT);
    PageRequest pageable = PageRequest.of(safePage - 1, safeLimit);

    Page<Post> posts = type == null
        ? postRepository.findByAuthorIdAndDeletedAtIsNullOrderByCreatedAtDesc(userId, pageable)
        : postRepository.findByAuthorIdAndTypeAndDeletedAtIsNullOrderByCreatedAtDesc(userId, type, pageable);

    java.util.List<PostResponse> content = postEnrichmentService.enrichAll(posts.getContent(), viewerId);

    return ApiResponseWrapper.paginated(
        content,
        new ApiResponseWrapper.Meta(safePage, safeLimit, posts.getTotalElements(), posts.getTotalPages())
    );
  }

  Post requireActivePost(UUID postId) {
    return postRepository.findByIdAndDeletedAtIsNull(postId)
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND));
  }

  private void validateCreateRequest(CreatePostRequest request) {
    if (request.type() == PostType.JOB) {
      if (request.jobMeta() == null || request.jobMeta().title() == null || request.jobMeta().title().isBlank()) {
        throw new ApiException(ErrorCode.VALIDATION_ERROR, "Job posts require job_meta with a title");
      }
      return;
    }
    if (request.mediaFileId() == null) {
      throw new ApiException(ErrorCode.VALIDATION_ERROR, "Media posts require media_file_id");
    }
  }

  private void validateMediaFile(PostType postType, UUID mediaFileId) {
    var response = fileServiceClient.getFile(mediaFileId);
    if (response.data() == null) {
      throw new ApiException(ErrorCode.INVALID_FILE);
    }
    String expectedType = postType == PostType.VIDEO ? "VIDEO" : "POSTER";
    if (!expectedType.equalsIgnoreCase(response.data().fileType())) {
      throw new ApiException(ErrorCode.INVALID_FILE, "File type does not match post type");
    }
  }
}
