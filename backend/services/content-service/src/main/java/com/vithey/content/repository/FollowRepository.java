package com.vithey.content.repository;

import com.vithey.content.entity.Follow;
import java.util.List;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface FollowRepository extends JpaRepository<Follow, UUID> {

  @Query("SELECT f.followingId FROM Follow f WHERE f.followerId = :followerId")
  List<UUID> findFollowingIdsByFollowerId(@Param("followerId") UUID followerId);

  boolean existsByFollowerIdAndFollowingId(UUID followerId, UUID followingId);

  void deleteByFollowerIdAndFollowingId(UUID followerId, UUID followingId);

  Page<Follow> findByFollowingIdOrderByCreatedAtDesc(UUID followingId, Pageable pageable);

  Page<Follow> findByFollowerIdOrderByCreatedAtDesc(UUID followerId, Pageable pageable);
}
