package com.vithey.map.service;

import com.vithey.map.dto.response.PlaceHistoryResponse;
import com.vithey.map.entity.PlaceSearchHistory;
import com.vithey.map.repository.PlaceSearchHistoryRepository;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Recent searches per user, trimmed to the last 20 rows. */
@Service
public class PlaceHistoryService {

  private final PlaceSearchHistoryRepository placeSearchHistoryRepository;

  public PlaceHistoryService(PlaceSearchHistoryRepository placeSearchHistoryRepository) {
    this.placeSearchHistoryRepository = placeSearchHistoryRepository;
  }

  @Transactional(readOnly = true)
  public List<PlaceHistoryResponse> history(UUID userId) {
    return placeSearchHistoryRepository.findTop20ByUserIdOrderByCreatedAtDesc(userId).stream()
        .map(row -> new PlaceHistoryResponse(
            row.getQuery(),
            row.getCategory(),
            row.getLatitude(),
            row.getLongitude(),
            row.getRadiusM(),
            row.getCreatedAt()))
        .toList();
  }

  /** Skips rows with no query and no category (plain camera moves). */
  @Transactional
  public void record(UUID userId, String query, String category, double latitude, double longitude, int radiusM) {
    if (userId == null) {
      return;
    }
    boolean hasQuery = query != null && !query.isBlank();
    boolean hasCategory = category != null && !category.isBlank();
    if (!hasQuery && !hasCategory) {
      return;
    }

    placeSearchHistoryRepository.save(new PlaceSearchHistory(
        userId,
        hasQuery ? trimQuery(query) : null,
        hasCategory ? category : null,
        latitude,
        longitude,
        radiusM));

    trimToTwenty(userId);
  }

  @Transactional
  public void clear(UUID userId) {
    placeSearchHistoryRepository.deleteByUserId(userId);
  }

  private void trimToTwenty(UUID userId) {
    long total = placeSearchHistoryRepository.countByUserId(userId);
    if (total <= PlaceSearchHistory.MAX_ENTRIES_PER_USER) {
      return;
    }
    List<PlaceSearchHistory> keep = placeSearchHistoryRepository
        .findTop20ByUserIdOrderByCreatedAtDesc(userId);
    List<UUID> keepIds = keep.stream().map(PlaceSearchHistory::getId).toList();
    placeSearchHistoryRepository.deleteByUserIdAndIdNotIn(userId, keepIds);
  }

  private String trimQuery(String query) {
    String trimmed = query.trim();
    return trimmed.length() > 100 ? trimmed.substring(0, 100) : trimmed;
  }
}
