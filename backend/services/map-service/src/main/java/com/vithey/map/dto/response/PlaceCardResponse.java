package com.vithey.map.dto.response;

/** Card shared by the map markers and the result list sheet. */
public record PlaceCardResponse(
    String googlePlaceId,
    String name,
    String address,
    String category,
    double latitude,
    double longitude,
    Double rating,
    Integer userRatingCount,
    Integer priceLevel,
    Boolean openNow,
    Long distanceM,
    String photoUrl,
    boolean isFavorite
) {

  public PlaceCardResponse withFavorite(boolean favorite) {
    if (favorite == isFavorite) {
      return this;
    }
    return new PlaceCardResponse(
        googlePlaceId, name, address, category, latitude, longitude,
        rating, userRatingCount, priceLevel, openNow, distanceM, photoUrl, favorite);
  }
}
