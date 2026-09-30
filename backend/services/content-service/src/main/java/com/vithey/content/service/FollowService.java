package com.vithey.content.service;

import com.vithey.content.dto.response.AuthorSummaryResponse;
import com.vithey.content.entity.Follow;
import com.vithey.content.event.payload.FollowCreatedEvent;
import com.vithey.content.event.publisher.ContentEventPublisher;
import com.vithey.content.exception.ApiException;
import com.vithey.content.exception.ErrorCode;
import com.vithey.content.repository.FollowRepository;
import com.vithey.content.util.ApiResponseWrapper;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class FollowService {

  private static final int DEFAULT_LIMIT = 20;
  private static final int MAX_LIMIT = 50;

  private final FollowRepository followRepository;
  private final PostEnrichmentService postEnrichmentService;
  private final ContentEventPublisher contentEventPublisher;

  public FollowService(
      FollowRepository followRepository,
      PostEnrichmentService postEnrichmentService,
      ContentEventPublisher contentEventPublisher
  ) {
    this.followRepository = followRepository;
    this.postEnrichmentService = postEnrichmentService;
    this.contentEventPublisher = contentEventPublisher;
  }

  @Transactional
  public void follow(UUID followerId, UUID followingId) {
    if (followerId.equals(followingId)) {
      throw new ApiException(ErrorCode.BUSINESS_RULE_VIOLATION, "You cannot follow yourself");
    }
    if (followRepository.existsByFollowerIdAndFollowingId(followerId, followingId)) {
      return;
    }

    OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
    Follow follow = new Follow();
    follow.setId(UUID.randomUUID());
    follow.setFollowerId(followerId);
    follow.setFollowingId(followingId);
    follow.setCreatedAt(now);
    followRepository.save(follow);

    contentEventPublisher.publishFollowCreated(new FollowCreatedEvent(
        follow.getId(),
        follow.getFollowerId(),
        follow.getFollowingId(),
        follow.getCreatedAt()
    ));
  }

  @Transactional
  public void unfollow(UUID followerId, UUID followingId) {
    followRepository.deleteByFollowerIdAndFollowingId(followerId, followingId);
  }

  @Transactional(readOnly = true)
  public ApiResponseWrapper<List<AuthorSummaryResponse>> getFollowers(UUID userId, int page, int limit) {
    return paginatedUsers(
        followRepository.findByFollowingIdOrderByCreatedAtDesc(userId, pageable(page, limit)),
        page,
        limit,
        Follow::getFollowerId
    );
  }

  @Transactional(readOnly = true)
  public ApiResponseWrapper<List<AuthorSummaryResponse>> getFollowing(UUID userId, int page, int limit) {
    return paginatedUsers(
        followRepository.findByFollowerIdOrderByCreatedAtDesc(userId, pageable(page, limit)),
        page,
        limit,
        Follow::getFollowingId
    );
  }

  private ApiResponseWrapper<List<AuthorSummaryResponse>> paginatedUsers(
      Page<Follow> pageResult,
      int page,
      int limit,
      java.util.function.Function<Follow, UUID> userIdExtractor
  ) {
    int safePage = Math.max(page, 1);
    int safeLimit = Math.min(Math.max(limit, 1), MAX_LIMIT);
    List<UUID> userIds = pageResult.getContent().stream().map(userIdExtractor).toList();
    List<AuthorSummaryResponse> content = postEnrichmentService.resolveAuthors(userIds);
    return ApiResponseWrapper.paginated(
        content,
        new ApiResponseWrapper.Meta(safePage, safeLimit, pageResult.getTotalElements(), pageResult.getTotalPages())
    );
  }

  private PageRequest pageable(int page, int limit) {
    int safePage = Math.max(page, 1);
    int safeLimit = Math.min(Math.max(limit, 1), MAX_LIMIT);
    return PageRequest.of(safePage - 1, safeLimit);
  }
}
