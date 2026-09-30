package com.vithey.map.dto.response;

import java.util.List;

/** Envelope payload for nearby / text search: markers + list + pagination. */
public record PlaceSearchResultResponse(
    Center center,
    int radiusM,
    List<PlaceCardResponse> places,
    String nextPageToken
) {

  public record Center(double lat, double lng) {
  }
}
