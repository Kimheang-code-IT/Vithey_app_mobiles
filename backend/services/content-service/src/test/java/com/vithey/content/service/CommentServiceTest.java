package com.vithey.content.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.vithey.content.dto.request.UpdateCommentRequest;
import com.vithey.content.dto.response.CommentResponse;
import com.vithey.content.entity.Comment;
import com.vithey.content.event.publisher.ContentEventPublisher;
import com.vithey.content.exception.ApiException;
import com.vithey.content.exception.ErrorCode;
import com.vithey.content.mapper.CommentMapper;
import com.vithey.content.repository.CommentRepository;
import com.vithey.content.repository.MentionRepository;
import java.time.OffsetDateTime;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class CommentServiceTest {

  @Mock
  private CommentRepository commentRepository;

  @Mock
  private MentionRepository mentionRepository;

  @Mock
  private PostService postService;

  @Mock
  private CommentMapper commentMapper;

  @Mock
  private PostEnrichmentService postEnrichmentService;

  @Mock
  private ContentEventPublisher contentEventPublisher;

  @InjectMocks
  private CommentService commentService;

  @Test
  void deleteComment_authorDeletesOwnComment() {
    UUID postId = UUID.randomUUID();
    UUID authorId = UUID.randomUUID();
    UUID commentId = UUID.randomUUID();
    Comment comment = comment(postId, authorId, commentId);
    when(commentRepository.findByIdAndPostId(commentId, postId))
        .thenReturn(Optional.of(comment));

    commentService.deleteComment(postId, commentId, authorId);

    verify(mentionRepository).deleteByCommentId(commentId);
    verify(commentRepository).delete(comment);
  }

  @Test
  void deleteComment_rejectsNonAuthor() {
    UUID postId = UUID.randomUUID();
    UUID authorId = UUID.randomUUID();
    UUID otherUserId = UUID.randomUUID();
    UUID commentId = UUID.randomUUID();
    Comment comment = comment(postId, authorId, commentId);
    when(commentRepository.findByIdAndPostId(commentId, postId))
        .thenReturn(Optional.of(comment));

    ApiException exception = assertThrows(
        ApiException.class,
        () -> commentService.deleteComment(postId, commentId, otherUserId)
    );

    assertEquals(ErrorCode.FORBIDDEN, exception.getErrorCode());
    verify(commentRepository, never()).delete(any());
    verify(mentionRepository, never()).deleteByCommentId(any());
  }

  @Test
  void deleteComment_missingCommentIs404() {
    UUID postId = UUID.randomUUID();
    UUID userId = UUID.randomUUID();
    UUID commentId = UUID.randomUUID();
    when(commentRepository.findByIdAndPostId(commentId, postId))
        .thenReturn(Optional.empty());

    ApiException exception = assertThrows(
        ApiException.class,
        () -> commentService.deleteComment(postId, commentId, userId)
    );

    assertEquals(ErrorCode.NOT_FOUND, exception.getErrorCode());
  }

  @Test
  void updateComment_authorEditsOwnComment() {
    UUID postId = UUID.randomUUID();
    UUID authorId = UUID.randomUUID();
    UUID commentId = UUID.randomUUID();
    Comment comment = comment(postId, authorId, commentId);
    when(commentRepository.findByIdAndPostId(commentId, postId))
        .thenReturn(Optional.of(comment));
    when(commentRepository.save(comment)).thenReturn(comment);

    CommentResponse base = new CommentResponse(
        commentId, postId, null, "Great post! (edited)", comment.getCreatedAt()
    );
    when(commentMapper.toBaseResponse(comment)).thenReturn(base);
    when(postEnrichmentService.resolveAuthor(authorId)).thenReturn(null);

    CommentResponse response = commentService.updateComment(
        postId, commentId, authorId, new UpdateCommentRequest("Great post! (edited)")
    );

    assertEquals("Great post! (edited)", response.text());
    assertEquals("Great post! (edited)", comment.getText());
    assertNotNull(response);
  }

  @Test
  void updateComment_rejectsNonAuthor() {
    UUID postId = UUID.randomUUID();
    UUID authorId = UUID.randomUUID();
    UUID otherUserId = UUID.randomUUID();
    UUID commentId = UUID.randomUUID();
    Comment comment = comment(postId, authorId, commentId);
    when(commentRepository.findByIdAndPostId(commentId, postId))
        .thenReturn(Optional.of(comment));

    ApiException exception = assertThrows(
        ApiException.class,
        () -> commentService.updateComment(
            postId, commentId, otherUserId, new UpdateCommentRequest("hacked")
        )
    );

    assertEquals(ErrorCode.FORBIDDEN, exception.getErrorCode());
    verify(commentRepository, never()).save(any());
  }

  private Comment comment(UUID postId, UUID authorId, UUID commentId) {
    Comment comment = new Comment();
    comment.setId(commentId);
    comment.setPostId(postId);
    comment.setAuthorId(authorId);
    comment.setText("Great post!");
    comment.setCreatedAt(OffsetDateTime.now());
    return comment;
  }
}
