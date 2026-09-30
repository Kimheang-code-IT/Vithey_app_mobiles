package com.vithey.content.repository;

import com.vithey.content.entity.Comment;
import java.util.Collection;
import java.util.List;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface CommentRepository extends JpaRepository<Comment, UUID> {

  Page<Comment> findByPostIdOrderByCreatedAtDesc(UUID postId, Pageable pageable);

  java.util.Optional<Comment> findByIdAndPostId(UUID id, UUID postId);

  long countByPostId(UUID postId);

  @Query("""
      select c.postId, count(c)
      from Comment c
      where c.postId in :postIds
      group by c.postId
      """)
  List<Object[]> countGroupedByPostId(@Param("postIds") Collection<UUID> postIds);
}
