package com.vithey.content.repository;

import com.vithey.content.entity.Reaction;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ReactionRepository extends JpaRepository<Reaction, UUID> {

  long countByPostId(UUID postId);

  Optional<Reaction> findByPostIdAndUserId(UUID postId, UUID userId);

  boolean existsByPostIdAndUserId(UUID postId, UUID userId);

  void deleteByPostIdAndUserId(UUID postId, UUID userId);

  @Query("""
      select r.postId, count(r)
      from Reaction r
      where r.postId in :postIds
      group by r.postId
      """)
  List<Object[]> countGroupedByPostId(@Param("postIds") Collection<UUID> postIds);

  @Query("""
      select r.postId
      from Reaction r
      where r.userId = :userId and r.postId in :postIds
      """)
  List<UUID> findReactedPostIds(
      @Param("userId") UUID userId,
      @Param("postIds") Collection<UUID> postIds
  );
}
