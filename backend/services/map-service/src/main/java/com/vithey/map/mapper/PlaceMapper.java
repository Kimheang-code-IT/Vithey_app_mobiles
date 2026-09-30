package com.vithey.map.mapper;

import com.vithey.map.client.dto.GoogleAutocompleteResponse;
import com.vithey.map.client.dto.GoogleOpeningHours;
import com.vithey.map.client.dto.GooglePlace;
import com.vithey.map.client.dto.GoogleTextValue;
import com.vithey.map.config.GooglePlacesProperties;
import com.vithey.map.dto.response.AutocompleteSuggestionResponse;
import com.vithey.map.dto.response.PlaceCardResponse;
import com.vithey.map.dto.response.PlaceDetailResponse;
import com.vithey.map.dto.response.PlaceSearchResultResponse;
import com.vithey.map.entity.PlaceFavorite;
import com.vithey.map.filter.PlaceCategory;
import com.vithey.map.geo.Haversine;
import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Component;

/** Normalizes Google place payloads and entity snapshots into Vithey DTOs. */
@Component
public class PlaceMapper {

  private static final double METERS_PER_DEGREE_APPROX = 111320.0;

  private final GooglePlacesProperties properties;

  public PlaceMapper(GooglePlacesProperties properties) {
    this.properties = properties;
  }

  public PlaceCardResponse toCard(GooglePlace place, double centerLat, double centerLng) {
    GoogleTextValue displayName = place.displayName();
    double lat = place.location() == null ? centerLat : place.location().latitude();
    double lng = place.location() == null ? centerLng : place.location().longitude();
    long distanceM = Haversine.meters(centerLat, centerLng, lat, lng);

    return new PlaceCardResponse(
        place.id(),
        displayName == null ? "" : displayName.text(),
        place.formattedAddress(),
        PlaceCategory.fromGoogleType(place.primaryType()),
        lat,
        lng,
        place.rating(),
        place.userRatingCount(),
        priceLevel(place.priceLevel()),
        openNow(place),
        distanceM,
        primaryPhotoUrl(place).orElse(null),
        false);
  }

  public PlaceSearchResultResponse toSearchResult(
      List<GooglePlace> places, String nextPageToken, double lat, double lng, int radiusM) {
    List<PlaceCardResponse> cards = places == null
        ? List.of()
        : places.stream()
            .filter(place -> place.id() != null)
            .map(place -> toCard(place, lat, lng))
            .toList();
    return new PlaceSearchResultResponse(new PlaceSearchResultResponse.Center(lat, lng), radiusM, cards, nextPageToken);
  }

  public PlaceDetailResponse toDetail(GooglePlace place) {
    GoogleTextValue displayName = place.displayName();
    GoogleOpeningHours current = place.currentOpeningHours();
    GoogleOpeningHours regular = place.regularOpeningHours();
    double lat = place.location() == null ? 0 : place.location().latitude();
    double lng = place.location() == null ? 0 : place.location().longitude();

    List<String> photoUrls = place.photos() == null
        ? List.of()
        : place.photos().stream()
            .map(this::photoUrl)
            .filter(Optional::isPresent)
            .map(Optional::get)
            .toList();

    List<String> openingHours = current != null && current.weekdayDescriptions() != null
        ? current.weekdayDescriptions()
        : regular != null && regular.weekdayDescriptions() != null
            ? regular.weekdayDescriptions()
            : List.of();

    return new PlaceDetailResponse(
        place.id(),
        displayName == null ? "" : displayName.text(),
        place.formattedAddress(),
        PlaceCategory.fromGoogleType(place.primaryType()),
        lat,
        lng,
        place.rating(),
        place.userRatingCount(),
        priceLevel(place.priceLevel()),
        current == null ? null : current.openNow(),
        openingHours,
        place.internationalPhoneNumber(),
        place.websiteUri(),
        place.googleMapsUri(),
        photoUrls,
        false);
  }

  public PlaceCardResponse toCard(PlaceFavorite favorite) {
    return new PlaceCardResponse(
        favorite.getGooglePlaceId(),
        favorite.getName(),
        favorite.getAddress(),
        favorite.getCategory(),
        favorite.getLatitude(),
        favorite.getLongitude(),
        null,
        null,
        null,
        null,
        null,
        favorite.getPhotoUrl(),
        true);
  }

  public AutocompleteSuggestionResponse toSuggestion(
      GoogleAutocompleteResponse.PlacePrediction prediction) {
    String primary = prediction.structuredFormat() != null
        && prediction.structuredFormat().mainText() != null
        ? prediction.structuredFormat().mainText().text()
        : prediction.text() == null ? "" : prediction.text().text();
    String secondary = prediction.structuredFormat() != null
        && prediction.structuredFormat().secondaryText() != null
        ? prediction.structuredFormat().secondaryText().text()
        : null;

    return new AutocompleteSuggestionResponse(
        prediction.placeId(),
        primary,
        secondary,
        prediction.distanceMeters() == null ? null : prediction.distanceMeters().longValue());
  }

  private Integer priceLevel(String priceLevel) {
    if (priceLevel == null) {
      return null;
    }
    return switch (priceLevel) {
      case "PRICE_LEVEL_FREE" -> 0;
      case "PRICE_LEVEL_INEXPENSIVE" -> 1;
      case "PRICE_LEVEL_MODERATE" -> 2;
      case "PRICE_LEVEL_EXPENSIVE" -> 3;
      case "PRICE_LEVEL_VERY_EXPENSIVE" -> 4;
      default -> null;
    };
  }

  private Boolean openNow(GooglePlace place) {
    return place.currentOpeningHours() == null ? null : place.currentOpeningHours().openNow();
  }

  private Optional<String> primaryPhotoUrl(GooglePlace place) {
    if (place.photos() == null || place.photos().isEmpty()) {
      return Optional.empty();
    }
    return photoUrl(place.photos().get(0));
  }

  /**
   * Builds a client-safe photo URL from the configured template. The raw
   * Google media endpoint requires the API key, so without a template (the
   * v1 default; photo proxy is deferred to v1.1) no URL is emitted.
   */
  private Optional<String> photoUrl(com.vithey.map.client.dto.GooglePhoto photo) {
    if (photo == null || photo.name() == null) {
      return Optional.empty();
    }
    String template = properties.photoUrlTemplate();
    if (template == null || template.isBlank()) {
      return Optional.empty();
    }
    return Optional.of(template.replace("{name}", photo.name()));
  }
}
