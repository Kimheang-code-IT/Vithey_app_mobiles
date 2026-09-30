package com.vithey.map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyDouble;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.vithey.map.client.GooglePlacesClient;
import com.vithey.map.client.dto.GoogleLocation;
import com.vithey.map.client.dto.GoogleNearbyRequestBody;
import com.vithey.map.client.dto.GooglePlace;
import com.vithey.map.client.dto.GoogleSearchResponse;
import com.vithey.map.client.dto.GoogleTextValue;
import com.vithey.map.config.GooglePlacesProperties;
import com.vithey.map.dto.request.NearbySearchRequest;
import com.vithey.map.dto.response.PlaceCardResponse;
import com.vithey.map.dto.response.PlaceSearchResultResponse;
import com.vithey.map.filter.PlaceFilterSpec;
import com.vithey.map.mapper.PlaceMapper;
import com.vithey.map.security.CurrentUser;
import com.vithey.map.service.NearbySearchService;
import com.vithey.map.service.PlaceCacheService;
import com.vithey.map.service.PlaceFavoriteService;
import com.vithey.map.service.PlaceHistoryService;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class NearbySearchServiceTest {

  private static final UUID USER_ID = UUID.randomUUID();

  @Mock
  private GooglePlacesClient googlePlacesClient;

  @Mock
  private PlaceCacheService placeCacheService;

  @Mock
  private PlaceFavoriteService placeFavoriteService;

  @Mock
  private PlaceHistoryService placeHistoryService;

  private NearbySearchService nearbySearchService;

  @BeforeEach
  void setUp() {
    PlaceMapper placeMapper = new PlaceMapper(new GooglePlacesProperties(
        "test-key", "https://places.googleapis.com/v1", 5000, 10000, ""));
    nearbySearchService = new NearbySearchService(
        googlePlacesClient, placeCacheService, placeFavoriteService, placeHistoryService, placeMapper);
  }

  private CurrentUser user() {
    return new CurrentUser(USER_ID, "user@vithey.dev", List.of("USER"));
  }

  private NearbySearchRequest request(double lat, double lng, int radiusM, String category) {
    NearbySearchRequest request = new NearbySearchRequest();
    request.setLat(lat);
    request.setLng(lng);
    request.setRadiusM(radiusM);
    request.setCategory(category);
    request.setLimit(40);
    return request;
  }

  private GooglePlace googlePlace(String id, String name, double lat, double lng, String primaryType) {
    return new GooglePlace(
        id,
        new GoogleTextValue(name),
        "Some address",
        new GoogleLocation(lat, lng),
        4.5,
        320,
        "PRICE_LEVEL_MODERATE",
        null,
        null,
        null,
        null,
        null,
        null,
        primaryType);
  }

  @Test
  void cacheHitSkipsGoogleCallAndMarksFavorites() {
    PlaceCardResponse cached = new PlaceCardResponse(
        "ChIJ1", "Brown Coffee", "Aeon Mall", "cafe", 11.55, 104.93,
        4.5, 320, 2, true, 850L, null, false);
    PlaceSearchResultResponse cachedResult = new PlaceSearchResultResponse(
        new PlaceSearchResultResponse.Center(11.5564, 104.9282), 2000, List.of(cached), null);

    when(placeCacheService.getSearchResult(anyString())).thenReturn(Optional.of(cachedResult));
    when(placeFavoriteService.favoritePlaceIds(USER_ID)).thenReturn(Set.of("ChIJ1"));

    PlaceSearchResultResponse response = nearbySearchService.nearby(request(11.5564, 104.9282, 2000, "cafe"), user());

    assertThat(response.places()).hasSize(1);
    assertThat(response.places().get(0).isFavorite()).isTrue();
    verify(googlePlacesClient, never()).searchNearby(any(GoogleNearbyRequestBody.class));
  }

  @Test
  void cacheMissCallsGoogleAndStoresResult() {
    when(placeCacheService.getSearchResult(anyString())).thenReturn(Optional.empty());
    when(googlePlacesClient.searchNearby(any(GoogleNearbyRequestBody.class)))
        .thenReturn(new GoogleSearchResponse(
            List.of(googlePlace("ChIJ1", "Brown Coffee", 11.5501, 104.9312, "cafe")), null));
    when(placeFavoriteService.favoritePlaceIds(USER_ID)).thenReturn(Set.of());

    PlaceSearchResultResponse response = nearbySearchService.nearby(request(11.5564, 104.9282, 1500, "cafe"), user());

    assertThat(response.places()).hasSize(1);
    assertThat(response.places().get(0).category()).isEqualTo("cafe");
    verify(placeCacheService).putSearchResult(anyString(), any(PlaceSearchResultResponse.class));
  }

  @Test
  void sendsCategoryTypesAndRadiusToGoogle() {
    when(placeCacheService.getSearchResult(anyString())).thenReturn(Optional.empty());
    when(googlePlacesClient.searchNearby(any(GoogleNearbyRequestBody.class)))
        .thenReturn(GoogleSearchResponse.empty());
    when(placeFavoriteService.favoritePlaceIds(USER_ID)).thenReturn(Set.of());

    nearbySearchService.nearby(request(11.5564, 104.9282, 2000, "supermarket"), user());

    ArgumentCaptor<GoogleNearbyRequestBody> captor =
        ArgumentCaptor.forClass(GoogleNearbyRequestBody.class);
    verify(googlePlacesClient).searchNearby(captor.capture());
    GoogleNearbyRequestBody body = captor.getValue();

    assertThat(body.includedTypes()).containsExactly("supermarket", "grocery_store");
    assertThat(body.maxResultCount()).isEqualTo(20);
    assertThat(body.locationRestriction().circle().center().latitude()).isEqualTo(11.5564);
    assertThat(body.locationRestriction().circle().radius()).isEqualTo(2000.0);
  }

  @Test
  void recordsHistoryWhenCategoryPresent() {
    when(placeCacheService.getSearchResult(anyString())).thenReturn(Optional.empty());
    when(googlePlacesClient.searchNearby(any(GoogleNearbyRequestBody.class)))
        .thenReturn(GoogleSearchResponse.empty());
    when(placeFavoriteService.favoritePlaceIds(USER_ID)).thenReturn(Set.of());

    nearbySearchService.nearby(request(11.5564, 104.9282, 1500, "atm"), user());

    verify(placeHistoryService).record(eq(USER_ID), eq(null), eq("atm"), eq(11.5564), eq(104.9282), eq(1500));
  }

  @Test
  void noHistoryForPlainCameraMoveWithoutCategory() {
    when(placeCacheService.getSearchResult(anyString())).thenReturn(Optional.empty());
    when(googlePlacesClient.searchNearby(any(GoogleNearbyRequestBody.class)))
        .thenReturn(GoogleSearchResponse.empty());
    when(placeFavoriteService.favoritePlaceIds(USER_ID)).thenReturn(Set.of());

    NearbySearchRequest plain = request(11.5564, 104.9282, 1500, null);
    plain.setLimit(20);
    nearbySearchService.nearby(plain, user());

    verify(placeHistoryService, never()).record(any(), any(), any(), anyDouble(), anyDouble(), anyInt());
  }

  @Test
  void invalidCategoryFailsValidation() {
    org.assertj.core.api.Assertions.assertThatThrownBy(
            () -> nearbySearchService.nearby(request(11.5, 104.9, 1500, "nightclub"), user()))
        .isInstanceOf(com.vithey.map.exception.ApiException.class)
        .extracting(ex -> ((com.vithey.map.exception.ApiException) ex).getErrorCode())
        .isEqualTo(com.vithey.map.exception.ErrorCode.VALIDATION_ERROR);
  }

  // --- PlaceFilterSpec: filter application, distance sort, truncation ---

  @Test
  void filterSpecAppliesMinRatingPriceOpenNowSortsAndTruncates() {
    PlaceCardResponse far = new PlaceCardResponse(
        "p1", "Far", "a", "cafe", 11.5, 104.9, 4.8, 10, 2, true, 3000L, null, false);
    PlaceCardResponse lowRating = new PlaceCardResponse(
        "p2", "Low", "a", "cafe", 11.5, 104.9, 3.0, 10, 2, true, 100L, null, false);
    PlaceCardResponse closed = new PlaceCardResponse(
        "p3", "Closed", "a", "cafe", 11.5, 104.9, 4.9, 10, 2, false, 50L, null, false);
    PlaceCardResponse expensive = new PlaceCardResponse(
        "p4", "Expensive", "a", "cafe", 11.5, 104.9, 4.9, 10, 4, true, 60L, null, false);
    PlaceCardResponse near = new PlaceCardResponse(
        "p5", "Near", "a", "cafe", 11.5, 104.9, 4.6, 10, 2, true, 120L, null, false);

    List<PlaceCardResponse> result = PlaceFilterSpec.apply(
        List.of(far, lowRating, closed, expensive, near), 4.0, 2, true, 3);

    assertThat(result).containsExactly(near, far);
  }
}
