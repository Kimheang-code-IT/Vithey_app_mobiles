package com.vithey.map.filter;

import com.vithey.map.dto.response.PlaceCardResponse;
import java.util.Comparator;
import java.util.List;

/**
 * Server-side post-filtering applied after Google results are normalized:
 * min_rating, price_level, open_now, distance sort, and limit truncation.
 */
public final class PlaceFilterSpec {

  private PlaceFilterSpec() {
  }

  public static List<PlaceCardResponse> apply(
      List<PlaceCardResponse> places,
      Double minRating,
      Integer priceLevel,
      Boolean openNow,
      int limit
  ) {
    List<PlaceCardResponse> filtered = places.stream()
        .filter(place -> minRating == null || (place.rating() != null && place.rating() >= minRating))
        .filter(place -> priceLevel == null || (place.priceLevel() != null && place.priceLevel() == priceLevel))
        .filter(place -> !Boolean.TRUE.equals(openNow) || Boolean.TRUE.equals(place.openNow()))
        .sorted(Comparator.comparing(PlaceCardResponse::distanceM,
            Comparator.nullsLast(Comparator.naturalOrder())))
        .toList();

    if (filtered.size() <= limit) {
      return filtered;
    }
    return filtered.subList(0, limit);
  }
}
