package com.vithey.content.repository;

import com.vithey.content.entity.Post;
import com.vithey.content.entity.PostType;
import java.util.Collection;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface PostRepository extends JpaRepository<Post, UUID> {

  Optional<Post> findByIdAndDeletedAtIsNull(UUID id);

  Page<Post> findByAuthorIdInAndDeletedAtIsNullOrderByCreatedAtDesc(
      Collection<UUID> authorIds,
      Pageable pageable
  );

  Page<Post> findByAuthorIdAndDeletedAtIsNullOrderByCreatedAtDesc(UUID authorId, Pageable pageable);

  Page<Post> findByAuthorIdAndTypeAndDeletedAtIsNullOrderByCreatedAtDesc(
      UUID authorId,
      PostType type,
      Pageable pageable
  );

  @Query("""
      SELECT post
      FROM Post post
      WHERE post.deletedAt IS NULL
        AND (
          LOWER(post.content) LIKE LOWER(CONCAT('%', :search, '%'))
          OR LOWER(post.jobTitle) LIKE LOWER(CONCAT('%', :search, '%'))
          OR LOWER(post.jobDescription) LIKE LOWER(CONCAT('%', :search, '%'))
        )
      ORDER BY post.createdAt DESC
      """)
  Page<Post> searchByText(@Param("search") String search, Pageable pageable);

  @Query("""
      SELECT post
      FROM Post post
      WHERE post.deletedAt IS NULL
        AND post.type = :type
        AND (
          LOWER(post.content) LIKE LOWER(CONCAT('%', :search, '%'))
          OR LOWER(post.jobTitle) LIKE LOWER(CONCAT('%', :search, '%'))
          OR LOWER(post.jobDescription) LIKE LOWER(CONCAT('%', :search, '%'))
        )
      ORDER BY post.createdAt DESC
      """)
  Page<Post> searchByTextAndType(
      @Param("search") String search,
      @Param("type") PostType type,
      Pageable pageable
  );
}
