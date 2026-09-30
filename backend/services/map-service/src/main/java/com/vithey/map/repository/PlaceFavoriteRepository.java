package com.vithey.map.repository;

import com.vithey.map.entity.PlaceFavorite;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PlaceFavoriteRepository extends JpaRepository<PlaceFavorite, UUID> {

  List<PlaceFavorite> findByUserIdOrderByCreatedAtDesc(UUID userId);

  Optional<PlaceFavorite> findByUserIdAndGooglePlaceId(UUID userId, String googlePlaceId);
}
