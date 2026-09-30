package com.vithey.content.service;

import com.vithey.content.dto.response.PostResponse;
import com.vithey.content.entity.Post;
import com.vithey.content.entity.PostType;
import com.vithey.content.exception.ApiException;
import com.vithey.content.exception.ErrorCode;
import com.vithey.content.repository.PostRepository;
import com.vithey.content.util.ApiResponseWrapper;
import java.util.List;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
public class PostSearchService {

  private static final int MAX_LIMIT = 50;

  private final PostRepository postRepository;
  private final PostEnrichmentService postEnrichmentService;

  public PostSearchService(PostRepository postRepository, PostEnrichmentService postEnrichmentService) {
    this.postRepository = postRepository;
    this.postEnrichmentService = postEnrichmentService;
  }

  @Transactional(readOnly = true)
  public ApiResponseWrapper<List<PostResponse>> search(
      String search,
      PostType type,
      UUID viewerId,
      int page,
      int limit
  ) {
    String trimmed = search == null ? "" : search.trim();
    if (!StringUtils.hasText(trimmed) || trimmed.length() < 2) {
      throw new ApiException(ErrorCode.VALIDATION_ERROR, "search must be at least 2 characters");
    }

    int safePage = Math.max(page, 1);
    int safeLimit = Math.min(Math.max(limit, 1), MAX_LIMIT);
    PageRequest pageable = PageRequest.of(safePage - 1, safeLimit);

    Page<Post> posts = type == null
        ? postRepository.searchByText(trimmed, pageable)
        : postRepository.searchByTextAndType(trimmed, type, pageable);

    List<PostResponse> content = posts.getContent().stream()
        .map(post -> postEnrichmentService.enrich(post, viewerId))
        .toList();

    return ApiResponseWrapper.paginated(
        content,
        new ApiResponseWrapper.Meta(safePage, safeLimit, posts.getTotalElements(), posts.getTotalPages())
    );
  }
}
