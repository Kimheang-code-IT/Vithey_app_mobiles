package com.vithey.content.service;

import com.vithey.content.dto.response.PostResponse;
import com.vithey.content.entity.Post;
import com.vithey.content.repository.FollowRepository;
import com.vithey.content.repository.PostRepository;
import com.vithey.content.util.ApiResponseWrapper;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

@Service
public class FeedService {

  private static final int DEFAULT_LIMIT = 20;
  private static final int MAX_LIMIT = 50;

  private final PostRepository postRepository;
  private final FollowRepository followRepository;
  private final PostEnrichmentService postEnrichmentService;

  public FeedService(
      PostRepository postRepository,
      FollowRepository followRepository,
      PostEnrichmentService postEnrichmentService
  ) {
    this.postRepository = postRepository;
    this.followRepository = followRepository;
    this.postEnrichmentService = postEnrichmentService;
  }

  public ApiResponseWrapper<List<PostResponse>> getFeed(UUID viewerId, int page, int limit) {
    int safePage = Math.max(page, 1);
    int safeLimit = Math.min(Math.max(limit, 1), MAX_LIMIT);
    PageRequest pageable = PageRequest.of(safePage - 1, safeLimit);

    List<UUID> authorIds = new ArrayList<>(followRepository.findFollowingIdsByFollowerId(viewerId));
    authorIds.add(viewerId);

    Page<Post> posts = postRepository.findByAuthorIdInAndDeletedAtIsNullOrderByCreatedAtDesc(authorIds, pageable);
    List<PostResponse> content = postEnrichmentService.enrichAll(posts.getContent(), viewerId);

    return ApiResponseWrapper.paginated(
        content,
        new ApiResponseWrapper.Meta(safePage, safeLimit, posts.getTotalElements(), posts.getTotalPages())
    );
  }
}
