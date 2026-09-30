package com.vithey.map.service;

import com.vithey.map.client.GooglePlacesClient;
import com.vithey.map.client.dto.GooglePlace;
import com.vithey.map.dto.response.PlaceDetailResponse;
import com.vithey.map.exception.ApiException;
import com.vithey.map.exception.ErrorCode;
import com.vithey.map.mapper.PlaceMapper;
import com.vithey.map.security.CurrentUser;
import org.springframework.stereotype.Service;

/**
 * Place detail with 24 h Redis cache; {@code is_favorite} is always computed
 * per caller and therefore never cached.
 */
@Service
public class PlaceDetailService {

  private final GooglePlacesClient googlePlacesClient;
  private final PlaceCacheService placeCacheService;
  private final PlaceFavoriteService placeFavoriteService;
  private final PlaceMapper placeMapper;

  public PlaceDetailService(
      GooglePlacesClient googlePlacesClient,
      PlaceCacheService placeCacheService,
      PlaceFavoriteService placeFavoriteService,
      PlaceMapper placeMapper
  ) {
    this.googlePlacesClient = googlePlacesClient;
    this.placeCacheService = placeCacheService;
    this.placeFavoriteService = placeFavoriteService;
    this.placeMapper = placeMapper;
  }

  public PlaceDetailResponse detail(String googlePlaceId, CurrentUser currentUser) {
    if (googlePlaceId == null || googlePlaceId.isBlank()) {
      throw new ApiException(ErrorCode.VALIDATION_ERROR, "googlePlaceId is required");
    }

    PlaceDetailResponse detail = placeCacheService.getDetail(googlePlaceId)
        .orElseGet(() -> loadFromGoogle(googlePlaceId));

    boolean favorite = placeFavoriteService.isFavorite(currentUser.userId(), googlePlaceId);
    return detail.withFavorite(favorite);
  }

  private PlaceDetailResponse loadFromGoogle(String googlePlaceId) {
    GooglePlace place = googlePlacesClient.getPlace(googlePlaceId);
    if (place == null || place.id() == null) {
      throw new ApiException(ErrorCode.NOT_FOUND, "Place not found");
    }
    PlaceDetailResponse detail = placeMapper.toDetail(place);
    placeCacheService.putDetail(googlePlaceId, detail);
    return detail;
  }
}
