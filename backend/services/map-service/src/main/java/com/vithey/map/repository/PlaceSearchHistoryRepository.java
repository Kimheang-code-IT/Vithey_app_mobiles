package com.vithey.map.repository;

import com.vithey.map.entity.PlaceSearchHistory;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PlaceSearchHistoryRepository extends JpaRepository<PlaceSearchHistory, UUID> {

  List<PlaceSearchHistory> findTop20ByUserIdOrderByCreatedAtDesc(UUID userId);

  long countByUserId(UUID userId);

  void deleteByUserIdAndIdNotIn(UUID userId, List<UUID> keepIds);

  void deleteByUserId(UUID userId);
}
