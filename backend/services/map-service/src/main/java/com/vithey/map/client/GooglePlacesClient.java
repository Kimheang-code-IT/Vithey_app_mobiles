package com.vithey.map.client;

import com.vithey.map.client.dto.GoogleAutocompleteRequestBody;
import com.vithey.map.client.dto.GoogleAutocompleteResponse;
import com.vithey.map.client.dto.GoogleNearbyRequestBody;
import com.vithey.map.client.dto.GooglePlace;
import com.vithey.map.client.dto.GoogleSearchResponse;
import com.vithey.map.client.dto.GoogleSearchTextRequestBody;
import com.vithey.map.exception.ApiException;
import com.vithey.map.exception.ErrorCode;
import io.github.resilience4j.circuitbreaker.CallNotPermittedException;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import reactor.core.publisher.Mono;

/**
 * Outbound client for Google Places API (New) protected by a Resilience4j
 * circuit breaker. Error mapping:
 * 400 → VALIDATION_ERROR 400, 404 → NOT_FOUND 404,
 * 403/429/5xx/timeout → UPSTREAM_ERROR 502,
 * circuit open → UPSTREAM_ERROR 503.
 * The API key is attached by the WebClient bean and never logged.
 */
@Component
public class GooglePlacesClient {

  private static final String PLACES_FIELD_MASK = String.join(",",
      "places.id",
      "places.displayName",
      "places.formattedAddress",
      "places.location",
      "places.rating",
      "places.userRatingCount",
      "places.priceLevel",
      "places.currentOpeningHours.openNow",
      "places.photos",
      "places.primaryType");

  private static final String SEARCH_FIELD_MASK = PLACES_FIELD_MASK + ",nextPageToken";

  private static final String DETAIL_FIELD_MASK = String.join(",",
      "id",
      "displayName",
      "formattedAddress",
      "location",
      "rating",
      "userRatingCount",
      "priceLevel",
      "currentOpeningHours",
      "regularOpeningHours",
      "internationalPhoneNumber",
      "websiteUri",
      "googleMapsUri",
      "photos",
      "primaryType");

  private static final String AUTOCOMPLETE_FIELD_MASK = String.join(",",
      "suggestions.placePrediction.placeId",
      "suggestions.placePrediction.text",
      "suggestions.placePrediction.structuredFormat",
      "suggestions.placePrediction.distanceMeters");

  private final WebClient webClient;

  public GooglePlacesClient(WebClient googlePlacesWebClient) {
    this.webClient = googlePlacesWebClient;
  }

  @CircuitBreaker(name = "googlePlaces", fallbackMethod = "upstreamFallback")
  public GoogleSearchResponse searchNearby(GoogleNearbyRequestBody body) {
    return webClient.post()
        .uri("/places:searchNearby")
        .header("X-Goog-FieldMask", PLACES_FIELD_MASK)
        .contentType(MediaType.APPLICATION_JSON)
        .bodyValue(body)
        .retrieve()
        .onStatus(HttpStatusCode::isError, response -> upstreamError(response.statusCode()))
        .bodyToMono(GoogleSearchResponse.class)
        .block();
  }

  @CircuitBreaker(name = "googlePlaces", fallbackMethod = "upstreamFallback")
  public GoogleSearchResponse searchText(GoogleSearchTextRequestBody body) {
    return webClient.post()
        .uri("/places:searchText")
        .header("X-Goog-FieldMask", SEARCH_FIELD_MASK)
        .contentType(MediaType.APPLICATION_JSON)
        .bodyValue(body)
        .retrieve()
        .onStatus(HttpStatusCode::isError, response -> upstreamError(response.statusCode()))
        .bodyToMono(GoogleSearchResponse.class)
        .block();
  }

  @CircuitBreaker(name = "googlePlaces", fallbackMethod = "upstreamFallback")
  public GooglePlace getPlace(String googlePlaceId) {
    return webClient.get()
        .uri(uriBuilder -> uriBuilder
            .path("/places/{placeId}")
            .queryParam("languageCode", "en")
            .build(googlePlaceId))
        .header("X-Goog-FieldMask", DETAIL_FIELD_MASK)
        .retrieve()
        .onStatus(HttpStatusCode::isError, response -> upstreamError(response.statusCode()))
        .bodyToMono(GooglePlace.class)
        .block();
  }

  @CircuitBreaker(name = "googlePlaces", fallbackMethod = "upstreamFallback")
  public GoogleAutocompleteResponse autocomplete(GoogleAutocompleteRequestBody body) {
    return webClient.post()
        .uri("/places:autocomplete")
        .header("X-Goog-FieldMask", AUTOCOMPLETE_FIELD_MASK)
        .contentType(MediaType.APPLICATION_JSON)
        .bodyValue(body)
        .retrieve()
        .onStatus(HttpStatusCode::isError, response -> upstreamError(response.statusCode()))
        .bodyToMono(GoogleAutocompleteResponse.class)
        .block();
  }

  // --- fallbacks (circuit breaker + error mapping) ---

  private GoogleSearchResponse upstreamFallback(GoogleNearbyRequestBody body, Throwable cause) {
    throw mapUpstream(cause);
  }

  private GoogleSearchResponse upstreamFallback(GoogleSearchTextRequestBody body, Throwable cause) {
    throw mapUpstream(cause);
  }

  private GooglePlace upstreamFallback(String placeId, Throwable cause) {
    throw mapUpstream(cause);
  }

  private GoogleAutocompleteResponse upstreamFallback(GoogleAutocompleteRequestBody body, Throwable cause) {
    throw mapUpstream(cause);
  }

  private RuntimeException mapUpstream(Throwable cause) {
    if (cause instanceof ApiException apiException) {
      return apiException;
    }
    if (cause instanceof CallNotPermittedException) {
      return ApiException.upstreamError(
          "Places provider temporarily unavailable (circuit open)", HttpStatus.SERVICE_UNAVAILABLE);
    }
    if (cause instanceof WebClientResponseException responseException) {
      int status = responseException.getStatusCode().value();
      if (status == 429 || status == 403 || status >= 500) {
        return ApiException.upstreamError(
            "Places provider rejected the request (HTTP " + status + ")", HttpStatus.BAD_GATEWAY);
      }
      if (status == 404) {
        return new ApiException(ErrorCode.NOT_FOUND, "Place not found");
      }
      return new ApiException(
          ErrorCode.VALIDATION_ERROR, "Places provider rejected the request (HTTP " + status + ")");
    }
    // Timeouts, connection failures, unexpected transport errors.
    return ApiException.upstreamError("Failed to reach the places provider", HttpStatus.BAD_GATEWAY);
  }

  private ApiException notFound() {
    return new ApiException(ErrorCode.NOT_FOUND, "Place not found");
  }

  private ApiException invalidArgument() {
    return new ApiException(ErrorCode.VALIDATION_ERROR, "Places provider rejected the request parameters");
  }

  /** In-pipeline HTTP status mapping (also active without the CB proxy). */
  private Mono<? extends Throwable> upstreamError(HttpStatusCode status) {
    int code = status.value();
    if (code == 400) {
      return Mono.error(invalidArgument());
    }
    if (code == 404) {
      return Mono.error(notFound());
    }
    return Mono.error(ApiException.upstreamError(
        "Places provider rejected the request (HTTP " + code + ")", HttpStatus.BAD_GATEWAY));
  }
}
