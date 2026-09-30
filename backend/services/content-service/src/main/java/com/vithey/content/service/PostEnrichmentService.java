package com.vithey.content.service;

import com.vithey.content.client.FileServiceClient;
import com.vithey.content.client.UserProfileClient;
import com.vithey.content.dto.response.AuthorSummaryResponse;
import com.vithey.content.dto.response.PostResponse;
import com.vithey.content.entity.Post;
import com.vithey.content.mapper.PostMapper;
import com.vithey.content.repository.CommentRepository;
import com.vithey.content.repository.ReactionRepository;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
public class PostEnrichmentService {

  private final PostMapper postMapper;
  private final UserProfileClient userProfileClient;
  private final FileServiceClient fileServiceClient;
  private final ReactionRepository reactionRepository;
  private final CommentRepository commentRepository;

  public PostEnrichmentService(
      PostMapper postMapper,
      UserProfileClient userProfileClient,
      FileServiceClient fileServiceClient,
      ReactionRepository reactionRepository,
      CommentRepository commentRepository
  ) {
    this.postMapper = postMapper;
    this.userProfileClient = userProfileClient;
    this.fileServiceClient = fileServiceClient;
    this.reactionRepository = reactionRepository;
    this.commentRepository = commentRepository;
  }

  public PostResponse enrich(Post post, UUID viewerId) {
    return enrichAll(List.of(post), viewerId).getFirst();
  }

  public List<PostResponse> enrichAll(List<Post> posts, UUID viewerId) {
    if (posts == null || posts.isEmpty()) {
      return List.of();
    }

    List<UUID> postIds = posts.stream().map(Post::getId).toList();
    Map<UUID, Long> reactionCounts = toCountMap(reactionRepository.countGroupedByPostId(postIds));
    Map<UUID, Long> commentCounts = toCountMap(commentRepository.countGroupedByPostId(postIds));
    Set<UUID> reactedPostIds = new HashSet<>();
    if (viewerId != null) {
      reactedPostIds.addAll(reactionRepository.findReactedPostIds(viewerId, postIds));
    }

    Map<UUID, AuthorSummaryResponse> authorCache = new HashMap<>();
    Map<UUID, String> mediaUrlCache = new HashMap<>();

    List<PostResponse> enriched = new ArrayList<>(posts.size());
    for (Post post : posts) {
      PostResponse base = postMapper.toBaseResponse(post);
      AuthorSummaryResponse author = authorCache.computeIfAbsent(post.getAuthorId(), this::resolveAuthor);
      String mediaUrl = null;
      if (post.getMediaFileId() != null) {
        mediaUrl = mediaUrlCache.computeIfAbsent(post.getMediaFileId(), this::resolveMediaUrl);
      }
      enriched.add(new PostResponse(
          base.postId(),
          author,
          base.type(),
          base.content(),
          mediaUrl,
          postMapper.toJobMeta(post),
          reactionCounts.getOrDefault(post.getId(), 0L),
          commentCounts.getOrDefault(post.getId(), 0L),
          reactedPostIds.contains(post.getId()),
          base.createdAt()
      ));
    }
    return enriched;
  }

  public AuthorSummaryResponse resolveAuthor(UUID userId) {
    var response = userProfileClient.getProfile(userId);
    if (response.data() == null) {
      return new AuthorSummaryResponse(userId, "Unknown User", null);
    }
    return new AuthorSummaryResponse(
        response.data().userId(),
        response.data().fullName(),
        response.data().avatarUrl()
    );
  }

  public List<AuthorSummaryResponse> resolveAuthors(List<UUID> userIds) {
    if (userIds == null || userIds.isEmpty()) {
      return List.of();
    }
    Map<UUID, AuthorSummaryResponse> cache = new HashMap<>();
    List<AuthorSummaryResponse> authors = new ArrayList<>(userIds.size());
    for (UUID userId : userIds) {
      authors.add(cache.computeIfAbsent(userId, this::resolveAuthor));
    }
    return authors;
  }

  private String resolveMediaUrl(UUID mediaFileId) {
    var response = fileServiceClient.getFile(mediaFileId);
    return response.data() == null ? null : response.data().url();
  }

  private static Map<UUID, Long> toCountMap(List<Object[]> rows) {
    Map<UUID, Long> counts = new HashMap<>();
    for (Object[] row : rows) {
      counts.put((UUID) row[0], (Long) row[1]);
    }
    return counts;
  }
}
