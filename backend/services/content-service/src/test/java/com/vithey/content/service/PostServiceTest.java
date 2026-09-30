package com.vithey.content.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.vithey.content.client.FileServiceClient;
import com.vithey.content.dto.request.CreatePostRequest;
import com.vithey.content.dto.request.UpdatePostRequest;
import com.vithey.content.dto.response.FileMetadataResponse;
import com.vithey.content.dto.response.PostResponse;
import com.vithey.content.entity.Post;
import com.vithey.content.entity.PostType;
import com.vithey.content.event.publisher.ContentEventPublisher;
import com.vithey.content.exception.ApiException;
import com.vithey.content.exception.ErrorCode;
import com.vithey.content.repository.PostRepository;
import com.vithey.content.util.ApiResponseWrapper;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class PostServiceTest {

  @Mock
  private PostRepository postRepository;

  @Mock
  private FileServiceClient fileServiceClient;

  @Mock
  private PostEnrichmentService postEnrichmentService;

  @Mock
  private ContentEventPublisher contentEventPublisher;

  @InjectMocks
  private PostService postService;

  @Test
  void createPost_rejectsMediaPostWithoutFileId() {
    CreatePostRequest request = new CreatePostRequest(PostType.POSTER, "hello", null, null);

    ApiException exception = assertThrows(
        ApiException.class,
        () -> postService.createPost(UUID.randomUUID(), request)
    );

    assertEquals(ErrorCode.VALIDATION_ERROR, exception.getErrorCode());
    verify(postRepository, never()).save(any());
  }

  @Test
  void createPost_rejectsJobWithoutTitle() {
    CreatePostRequest request = new CreatePostRequest(
        PostType.JOB,
        "hiring",
        null,
        new CreatePostRequest.JobMetaRequest(null, "desc", "req", null)
    );

    ApiException exception = assertThrows(
        ApiException.class,
        () -> postService.createPost(UUID.randomUUID(), request)
    );

    assertEquals(ErrorCode.VALIDATION_ERROR, exception.getErrorCode());
    verify(postRepository, never()).save(any());
  }

  @Test
  void createPost_persistsJobAndPublishesEvent() {
    UUID authorId = UUID.randomUUID();
    CreatePostRequest request = new CreatePostRequest(
        PostType.JOB,
        "hiring",
        null,
        new CreatePostRequest.JobMetaRequest("Intern", "desc", "req", null)
    );
    when(postRepository.save(any(Post.class))).thenAnswer(invocation -> invocation.getArgument(0));
    when(postEnrichmentService.enrich(any(Post.class), any(UUID.class)))
        .thenReturn(new PostResponse(
            UUID.randomUUID(), null, PostType.JOB, "hiring", null, null, 0, 0, false, null
        ));

    PostResponse response = postService.createPost(authorId, request);

    assertEquals(PostType.JOB, response.type());
    verify(contentEventPublisher).publishPostCreated(any());
    verify(fileServiceClient, never()).getFile(any());
  }

  @Test
  void createPost_rejectsMismatchedMediaType() {
    UUID fileId = UUID.randomUUID();
    CreatePostRequest request = new CreatePostRequest(PostType.VIDEO, "clip", fileId, null);
    when(fileServiceClient.getFile(fileId)).thenReturn(ApiResponseWrapper.success(
        new FileMetadataResponse(fileId, "POSTER", "http://x")
    ));

    ApiException exception = assertThrows(
        ApiException.class,
        () -> postService.createPost(UUID.randomUUID(), request)
    );

    assertEquals(ErrorCode.INVALID_FILE, exception.getErrorCode());
    verify(postRepository, never()).save(any());
  }

  @Test
  void updatePost_rejectsNonOwner() {
    UUID postId = UUID.randomUUID();
    UUID owner = UUID.randomUUID();
    UUID other = UUID.randomUUID();
    Post post = new Post();
    post.setId(postId);
    post.setAuthorId(owner);
    post.setType(PostType.POSTER);
    when(postRepository.findByIdAndDeletedAtIsNull(postId)).thenReturn(Optional.of(post));

    ApiException exception = assertThrows(
        ApiException.class,
        () -> postService.updatePost(postId, other, new UpdatePostRequest("new", null))
    );

    assertEquals(ErrorCode.FORBIDDEN, exception.getErrorCode());
    verify(postRepository, never()).save(any());
  }

  @Test
  void updatePost_rejectsMissingPost() {
    UUID postId = UUID.randomUUID();
    when(postRepository.findByIdAndDeletedAtIsNull(postId)).thenReturn(Optional.empty());

    ApiException exception = assertThrows(
        ApiException.class,
        () -> postService.updatePost(postId, UUID.randomUUID(), new UpdatePostRequest("x", null))
    );

    assertEquals(ErrorCode.NOT_FOUND, exception.getErrorCode());
  }

  @Test
  void updatePost_updatesContentAndJobMeta() {
    UUID postId = UUID.randomUUID();
    UUID owner = UUID.randomUUID();
    Post post = new Post();
    post.setId(postId);
    post.setAuthorId(owner);
    post.setType(PostType.JOB);
    post.setContent("old");
    post.setJobTitle("old title");
    when(postRepository.findByIdAndDeletedAtIsNull(postId)).thenReturn(Optional.of(post));
    when(postRepository.save(any(Post.class))).thenAnswer(invocation -> invocation.getArgument(0));
    when(postEnrichmentService.enrich(any(Post.class), any(UUID.class)))
        .thenReturn(new PostResponse(
            postId, null, PostType.JOB, "new", null, null, 0, 0, false, null
        ));

    PostResponse response = postService.updatePost(
        postId,
        owner,
        new UpdatePostRequest("new", new CreatePostRequest.JobMetaRequest("new title", "d", "r", null))
    );

    assertEquals("new", post.getContent());
    assertEquals("new title", post.getJobTitle());
    assertEquals(PostType.JOB, response.type());
    verify(postRepository).save(any(Post.class));
  }
}
