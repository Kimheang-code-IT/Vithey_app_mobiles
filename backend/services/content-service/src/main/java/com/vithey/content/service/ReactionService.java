package com.vithey.content.service;

import com.vithey.content.dto.response.ReactionSummaryResponse;
import com.vithey.content.entity.Reaction;
import com.vithey.content.event.payload.ReactionAddedEvent;
import com.vithey.content.event.publisher.ContentEventPublisher;
import com.vithey.content.repository.ReactionRepository;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ReactionService {

  private final ReactionRepository reactionRepository;
  private final PostService postService;
  private final ContentEventPublisher contentEventPublisher;

  public ReactionService(
      ReactionRepository reactionRepository,
      PostService postService,
      ContentEventPublisher contentEventPublisher
  ) {
    this.reactionRepository = reactionRepository;
    this.postService = postService;
    this.contentEventPublisher = contentEventPublisher;
  }

  @Transactional
  public ReactionSummaryResponse toggleReaction(UUID postId, UUID userId) {
    postService.requireActivePost(postId);

    var existing = reactionRepository.findByPostIdAndUserId(postId, userId);
    if (existing.isPresent()) {
      reactionRepository.deleteByPostIdAndUserId(postId, userId);
      return summary(postId, userId);
    }

    OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
    Reaction reaction = new Reaction();
    reaction.setId(UUID.randomUUID());
    reaction.setPostId(postId);
    reaction.setUserId(userId);
    reaction.setCreatedAt(now);
    reactionRepository.save(reaction);

    contentEventPublisher.publishReactionAdded(new ReactionAddedEvent(
        reaction.getId(),
        reaction.getPostId(),
        reaction.getUserId(),
        reaction.getCreatedAt()
    ));

    return summary(postId, userId);
  }

  @Transactional(readOnly = true)
  public ReactionSummaryResponse getReactions(UUID postId, UUID userId) {
    postService.requireActivePost(postId);
    return summary(postId, userId);
  }

  private ReactionSummaryResponse summary(UUID postId, UUID userId) {
    long count = reactionRepository.countByPostId(postId);
    boolean userReacted = reactionRepository.existsByPostIdAndUserId(postId, userId);
    return new ReactionSummaryResponse(count, userReacted);
  }
}
