package com.vithey.map.service;

import com.vithey.map.client.GooglePlacesClient;
import com.vithey.map.client.dto.GoogleNearbyRequestBody;
import com.vithey.map.client.dto.GoogleSearchResponse;
import com.vithey.map.dto.request.NearbySearchRequest;
import com.vithey.map.dto.response.PlaceCardResponse;
import com.vithey.map.dto.response.PlaceSearchResultResponse;
import com.vithey.map.exception.ApiException;
import com.vithey.map.exception.ErrorCode;
import com.vithey.map.filter.PlaceCategory;
import com.vithey.map.filter.PlaceFilterSpec;
import com.vithey.map.mapper.PlaceMapper;
import com.vithey.map.security.CurrentUser;
import java.util.List;
import java.util.Set;
import org.springframework.stereotype.Service;

/**
 * Nearby shops/places around user coordinates: Redis get-or-load → Google
 * Nearby Search (New) → normalize → server-side filters → distance sort →
 * favorite flags → optional history row.
 */
@Service
public class NearbySearchService {

  private final GooglePlacesClient googlePlacesClient;
  private final PlaceCacheService placeCacheService;
  private final PlaceFavoriteService placeFavoriteService;
  private final PlaceHistoryService placeHistoryService;
  private final PlaceMapper placeMapper;

  public NearbySearchService(
      GooglePlacesClient googlePlacesClient,
      PlaceCacheService placeCacheService,
      PlaceFavoriteService placeFavoriteService,
      PlaceHistoryService placeHistoryService,
      PlaceMapper placeMapper
  ) {
    this.googlePlacesClient = googlePlacesClient;
    this.placeCacheService = placeCacheService;
    this.placeFavoriteService = placeFavoriteService;
    this.placeHistoryService = placeHistoryService;
    this.placeMapper = placeMapper;
  }

  public PlaceSearchResultResponse nearby(NearbySearchRequest request, CurrentUser currentUser) {
    PlaceCategory category = resolveCategory(request.getCategory());

    String cacheKey = PlaceCacheService.searchKey(
        "nearby",
        PlaceCacheService.roundCoordinate(request.getLat()),
        PlaceCacheService.roundCoordinate(request.getLng()),
        request.getRadiusM(),
        category == null ? "" : category.value(),
        request.getOpenNow(),
        request.getMinRating(),
        request.getPriceLevel(),
        request.getPageToken());

    PlaceSearchResultResponse result = placeCacheService.getSearchResult(cacheKey)
        .orElseGet(() -> loadFromGoogle(request, category));

    List<PlaceCardResponse> filtered = PlaceFilterSpec.apply(
        result.places(),
        request.getMinRating(),
        request.getPriceLevel(),
        request.getOpenNow(),
        request.getLimit());

    Set<String> favoriteIds = placeFavoriteService.favoritePlaceIds(currentUser.userId());
    List<PlaceCardResponse> marked = filtered.stream()
        .map(place -> place.withFavorite(favoriteIds.contains(place.googlePlaceId())))
        .toList();

    if (category != null) {
      placeHistoryService.record(
          currentUser.userId(), null, category.value(),
          request.getLat(), request.getLng(), request.getRadiusM());
    }

    return new PlaceSearchResultResponse(
        result.center(), result.radiusM(), marked, result.nextPageToken());
  }

  private PlaceSearchResultResponse loadFromGoogle(NearbySearchRequest request, PlaceCategory category) {
    GoogleNearbyRequestBody.LocationRestriction restriction = new GoogleNearbyRequestBody.LocationRestriction(
        new GoogleNearbyRequestBody.Circle(
            new com.vithey.map.client.dto.GoogleLocation(request.getLat(), request.getLng()),
            request.getRadiusM().doubleValue()));

    GoogleNearbyRequestBody body = new GoogleNearbyRequestBody(
        category != null && category.hasTypeFilter() ? category.googleTypes() : null,
        Math.min(request.getLimit(), 20),
        restriction,
        "DISTANCE");

    GoogleSearchResponse response = googlePlacesClient.searchNearby(body);
    PlaceSearchResultResponse mapped = placeMapper.toSearchResult(
        response.places(), response.nextPageToken(),
        request.getLat(), request.getLng(), request.getRadiusM());

    String cacheKey = PlaceCacheService.searchKey(
        "nearby",
        PlaceCacheService.roundCoordinate(request.getLat()),
        PlaceCacheService.roundCoordinate(request.getLng()),
        request.getRadiusM(),
        category == null ? "" : category.value(),
        request.getOpenNow(),
        request.getMinRating(),
        request.getPriceLevel(),
        request.getPageToken());
    placeCacheService.putSearchResult(cacheKey, mapped);
    return mapped;
  }

  private PlaceCategory resolveCategory(String raw) {
    try {
      return PlaceCategory.fromValue(raw);
    } catch (IllegalArgumentException exception) {
      throw new ApiException(ErrorCode.VALIDATION_ERROR, exception.getMessage());
    }
  }
}
