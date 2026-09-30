package com.vithey.map.dto.response;

import java.util.List;

/** Full place payload for pin tap / bottom sheet. */
public record PlaceDetailResponse(
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
    List<String> openingHours,
    String phone,
    String website,
    String googleMapsUri,
    List<String> photoUrls,
    boolean isFavorite
) {

  public PlaceDetailResponse withFavorite(boolean favorite) {
    if (favorite == isFavorite) {
      return this;
    }
    return new PlaceDetailResponse(
        googlePlaceId, name, address, category, latitude, longitude,
        rating, userRatingCount, priceLevel, openNow, openingHours,
        phone, website, googleMapsUri, photoUrls, favorite);
  }
}
