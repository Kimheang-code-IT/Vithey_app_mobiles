package com.vithey.map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.vithey.map.config.GooglePlacesProperties;
import com.vithey.map.dto.request.SaveFavoriteRequest;
import com.vithey.map.dto.response.PlaceCardResponse;
import com.vithey.map.entity.PlaceFavorite;
import com.vithey.map.exception.ApiException;
import com.vithey.map.exception.ErrorCode;
import com.vithey.map.mapper.PlaceMapper;
import com.vithey.map.repository.PlaceFavoriteRepository;
import com.vithey.map.service.PlaceFavoriteService;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class PlaceFavoriteServiceTest {

  private static final UUID USER_ID = UUID.randomUUID();
  private static final UUID OTHER_USER_ID = UUID.randomUUID();
  private static final String PLACE_ID = "ChIJfav123";

  @Mock
  private PlaceFavoriteRepository placeFavoriteRepository;

  private PlaceFavoriteService placeFavoriteService;

  @BeforeEach
  void setUp() {
    placeFavoriteService = new PlaceFavoriteService(
        placeFavoriteRepository, new PlaceMapper(new GooglePlacesProperties(
            "test-key", "https://places.googleapis.com/v1", 5000, 10000, "")));
  }

  private SaveFavoriteRequest request() {
    return new SaveFavoriteRequest(
        PLACE_ID, "Brown Coffee AEON", "Aeon Mall Phnom Penh",
        11.5501, 104.9312, "cafe", "https://cdn.example.com/photo");
  }

  @Test
  void saveInsertsWhenMissing() {
    when(placeFavoriteRepository.findByUserIdAndGooglePlaceId(USER_ID, PLACE_ID)).thenReturn(Optional.empty());
    when(placeFavoriteRepository.save(any(PlaceFavorite.class)))
        .thenAnswer(invocation -> invocation.getArgument(0));

    PlaceCardResponse saved = placeFavoriteService.save(USER_ID, request());

    assertThat(saved.googlePlaceId()).isEqualTo(PLACE_ID);
    assertThat(saved.isFavorite()).isTrue();
    ArgumentCaptor<PlaceFavorite> captor = ArgumentCaptor.forClass(PlaceFavorite.class);
    verify(placeFavoriteRepository).save(captor.capture());
    assertThat(captor.getValue().getUserId()).isEqualTo(USER_ID);
  }

  @Test
  void saveIsIdempotentUpsertAndUpdatesSnapshot() {
    PlaceFavorite existing = new PlaceFavorite(
        USER_ID, PLACE_ID, "Old Name", "Old address", 11.0, 104.0, "cafe", null);
    when(placeFavoriteRepository.findByUserIdAndGooglePlaceId(USER_ID, PLACE_ID))
        .thenReturn(Optional.of(existing));
    when(placeFavoriteRepository.save(any(PlaceFavorite.class)))
        .thenAnswer(invocation -> invocation.getArgument(0));

    placeFavoriteService.save(USER_ID, request());

    ArgumentCaptor<PlaceFavorite> captor = ArgumentCaptor.forClass(PlaceFavorite.class);
    verify(placeFavoriteRepository).save(captor.capture());
    assertThat(captor.getValue().getName()).isEqualTo("Brown Coffee AEON");
    assertThat(captor.getValue().getAddress()).isEqualTo("Aeon Mall Phnom Penh");
  }

  @Test
  void removeIsOwnerScopedAndThrowsWhenMissing() {
    when(placeFavoriteRepository.findByUserIdAndGooglePlaceId(OTHER_USER_ID, PLACE_ID))
        .thenReturn(Optional.empty());

    assertThatThrownBy(() -> placeFavoriteService.remove(OTHER_USER_ID, PLACE_ID))
        .isInstanceOf(ApiException.class)
        .extracting(ex -> ((ApiException) ex).getErrorCode())
        .isEqualTo(ErrorCode.NOT_FOUND);
  }

  @Test
  void removeDeletesOwnedFavorite() {
    PlaceFavorite owned = new PlaceFavorite(
        USER_ID, PLACE_ID, "Brown", "addr", 11.0, 104.0, "cafe", null);
    when(placeFavoriteRepository.findByUserIdAndGooglePlaceId(USER_ID, PLACE_ID))
        .thenReturn(Optional.of(owned));

    placeFavoriteService.remove(USER_ID, PLACE_ID);

    verify(placeFavoriteRepository).delete(owned);
  }

  @Test
  void favoritesReturnsOnlyCallerRowsMappedAsCards() {
    PlaceFavorite row = new PlaceFavorite(
        USER_ID, PLACE_ID, "Brown", "addr", 11.0, 104.0, "cafe", null);
    when(placeFavoriteRepository.findByUserIdOrderByCreatedAtDesc(USER_ID)).thenReturn(List.of(row));

    List<PlaceCardResponse> favorites = placeFavoriteService.favorites(USER_ID);

    assertThat(favorites).hasSize(1);
    assertThat(favorites.get(0).googlePlaceId()).isEqualTo(PLACE_ID);
    assertThat(favorites.get(0).isFavorite()).isTrue();
    verify(placeFavoriteRepository).findByUserIdOrderByCreatedAtDesc(USER_ID);
  }
}
