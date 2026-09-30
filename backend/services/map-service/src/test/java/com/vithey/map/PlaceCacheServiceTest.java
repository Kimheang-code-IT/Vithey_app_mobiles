package com.vithey.map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.vithey.map.dto.response.PlaceDetailResponse;
import com.vithey.map.dto.response.PlaceSearchResultResponse;
import com.vithey.map.service.PlaceCacheService;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.dao.DataAccessResourceFailureException;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ValueOperations;

class PlaceCacheServiceTest {

  private StringRedisTemplate redisTemplate;
  private ValueOperations<String, String> valueOperations;
  private PlaceCacheService placeCacheService;

  @BeforeEach
  @SuppressWarnings("unchecked")
  void setUp() {
    redisTemplate = mock(StringRedisTemplate.class);
    valueOperations = mock(ValueOperations.class);
    when(redisTemplate.opsForValue()).thenReturn(valueOperations);
    placeCacheService = new PlaceCacheService(redisTemplate, new ObjectMapper());
  }

  @Test
  void searchKeyIsStableAndRoundsCoordinates() {
    String key1 = PlaceCacheService.searchKey(
        "nearby", PlaceCacheService.roundCoordinate(11.5564123), PlaceCacheService.roundCoordinate(104.9282111), 1500);
    String key2 = PlaceCacheService.searchKey(
        "nearby", PlaceCacheService.roundCoordinate(11.5564400), PlaceCacheService.roundCoordinate(104.9282099), 1500);
    String key3 = PlaceCacheService.searchKey(
        "nearby", PlaceCacheService.roundCoordinate(11.5570), PlaceCacheService.roundCoordinate(104.9282), 1500);

    assertThat(key1).isEqualTo(key2);
    assertThat(key1).isNotEqualTo(key3);
    assertThat(key1).startsWith("places:nearby:");
  }

  @Test
  void getSearchResultReturnsEmptyOnMiss() {
    when(valueOperations.get(anyString())).thenReturn(null);

    assertThat(placeCacheService.getSearchResult("places:nearby:x")).isEmpty();
  }

  @Test
  void searchResultRoundTripsThroughJson() throws Exception {
    PlaceSearchResultResponse result = new PlaceSearchResultResponse(
        new PlaceSearchResultResponse.Center(11.5564, 104.9282), 1500, List.of(), "token-1");
    when(valueOperations.get("places:nearby:x"))
        .thenReturn(new ObjectMapper().writeValueAsString(result));

    Optional<PlaceSearchResultResponse> cached = placeCacheService.getSearchResult("places:nearby:x");

    assertThat(cached).isPresent();
    assertThat(cached.get().center().lat()).isEqualTo(11.5564);
    assertThat(cached.get().nextPageToken()).isEqualTo("token-1");
  }

  @Test
  void redisFailureIsTreatedAsCacheMiss() {
    when(valueOperations.get(anyString())).thenThrow(new DataAccessResourceFailureException("redis down"));

    assertThat(placeCacheService.getSearchResult("places:nearby:x")).isEmpty();
  }

  @Test
  void putSearchResultSwallowsRedisFailure() {
    when(redisTemplate.opsForValue()).thenThrow(new DataAccessResourceFailureException("redis down"));

    placeCacheService.putSearchResult("places:nearby:x",
        new PlaceSearchResultResponse(new PlaceSearchResultResponse.Center(11.5, 104.9), 1500, List.of(), null));

    verify(redisTemplate).opsForValue();
  }

  @Test
  void detailRoundTripsAndNeverCarriesFavoriteFlag() throws Exception {
    PlaceDetailResponse detail = new PlaceDetailResponse(
        "ChIJ1", "Brown", "addr", "cafe", 11.5, 104.9, 4.5, 10, 2, true,
        List.of("Mon–Fri 08:00–21:00"), "+855", "https://web", "https://maps", List.of(), false);
    when(valueOperations.get("places:detail:ChIJ1"))
        .thenReturn(new ObjectMapper().writeValueAsString(detail));

    Optional<PlaceDetailResponse> cached = placeCacheService.getDetail("ChIJ1");

    assertThat(cached).isPresent();
    assertThat(cached.get().isFavorite()).isFalse();
    assertThat(cached.get().openingHours()).containsExactly("Mon–Fri 08:00–21:00");
  }

  @Test
  void putDetailNeverFailsRequest() {
    when(redisTemplate.opsForValue()).thenThrow(new DataAccessResourceFailureException("redis down"));

    placeCacheService.putDetail("ChIJ1", new PlaceDetailResponse(
        "ChIJ1", "Brown", "addr", "cafe", 11.5, 104.9, 4.5, 10, 2, true,
        List.of(), null, null, null, List.of(), false));

    verify(redisTemplate).opsForValue();
    verify(valueOperations, never()).set(anyString(), anyString(), any(java.time.Duration.class));
  }
}
