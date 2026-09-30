package com.vithey.map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.vithey.map.client.GooglePlacesClient;
import com.vithey.map.client.dto.GoogleAutocompleteRequestBody;
import com.vithey.map.client.dto.GoogleAutocompleteResponse;
import com.vithey.map.client.dto.GoogleNearbyRequestBody;
import com.vithey.map.client.dto.GoogleLocation;
import com.vithey.map.exception.ApiException;
import com.vithey.map.exception.ErrorCode;
import java.io.IOException;
import okhttp3.mockwebserver.MockResponse;
import okhttp3.mockwebserver.MockWebServer;
import okhttp3.mockwebserver.RecordedRequest;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.reactive.function.client.WebClient;

/**
 * Error mapping + request shape of the Google Places client against a mock
 * HTTP server (no real API key needed; circuit breaker is not proxied here).
 */
class GooglePlacesClientTest {

  private MockWebServer server;
  private GooglePlacesClient client;

  @BeforeEach
  void setUp() throws IOException {
    server = new MockWebServer();
    server.start();
    WebClient webClient = WebClient.builder()
        .baseUrl(server.url("/v1").toString())
        .defaultHeader("X-Goog-Api-Key", "test-key")
        .build();
    client = new GooglePlacesClient(webClient);
  }

  @AfterEach
  void tearDown() throws IOException {
    server.shutdown();
  }

  @Test
  void searchNearbySendsPostFieldMaskAndParsesPlaces() throws Exception {
    server.enqueue(new MockResponse()
        .setHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
        .setBody("""
            {
              "places": [
                {
                  "id": "ChIJ1",
                  "displayName": {"text": "Brown Coffee"},
                  "formattedAddress": "Aeon Mall",
                  "location": {"latitude": 11.55, "longitude": 104.93},
                  "rating": 4.5,
                  "userRatingCount": 320,
                  "priceLevel": "PRICE_LEVEL_MODERATE",
                  "currentOpeningHours": {"openNow": true},
                  "primaryType": "coffee_shop"
                }
              ],
              "nextPageToken": null
            }
            """));

    var response = client.searchNearby(new GoogleNearbyRequestBody(
        List_of("cafe"), 20,
        new GoogleNearbyRequestBody.LocationRestriction(
            new GoogleNearbyRequestBody.Circle(new GoogleLocation(11.55, 104.93), 1500.0)),
        "DISTANCE"));

    assertThat(response.places()).hasSize(1);
    assertThat(response.places().get(0).id()).isEqualTo("ChIJ1");

    RecordedRequest recorded = server.takeRequest();
    assertThat(recorded.getMethod()).isEqualTo("POST");
    assertThat(recorded.getPath()).isEqualTo("/v1/places:searchNearby");
    assertThat(recorded.getHeader("X-Goog-FieldMask")).contains("places.displayName");
    assertThat(recorded.getHeader("X-Goog-FieldMask")).doesNotContain("nextPageToken");
    assertThat(recorded.getHeader("X-Goog-Api-Key")).isEqualTo("test-key");
  }

  @Test
  void google400MapsToValidationError() {
    server.enqueue(new MockResponse().setResponseCode(400).setBody("{\"error\":\"bad\"}"));

    assertThatThrownBy(() -> client.searchNearby(new GoogleNearbyRequestBody(
        List_of("cafe"), 20, null, null)))
        .isInstanceOf(ApiException.class)
        .extracting(ex -> ((ApiException) ex).getErrorCode())
        .isEqualTo(ErrorCode.VALIDATION_ERROR);
  }

  @Test
  void google404MapsToNotFound() {
    server.enqueue(new MockResponse().setResponseCode(404).setBody("{}"));

    assertThatThrownBy(() -> client.getPlace("ChIJmissing"))
        .isInstanceOf(ApiException.class)
        .extracting(ex -> ((ApiException) ex).getErrorCode())
        .isEqualTo(ErrorCode.NOT_FOUND);
  }

  @Test
  void googleQuotaAndServerErrorsMapToUpstreamError502() {
    server.enqueue(new MockResponse().setResponseCode(429).setBody("{}"));
    assertThatThrownBy(() -> client.getPlace("ChIJ1"))
        .isInstanceOf(ApiException.class)
        .extracting(ex -> ((ApiException) ex).getStatus())
        .isEqualTo(HttpStatus.BAD_GATEWAY);

    server.enqueue(new MockResponse().setResponseCode(500).setBody("{}"));
    assertThatThrownBy(() -> client.getPlace("ChIJ1"))
        .isInstanceOf(ApiException.class)
        .extracting(ex -> ((ApiException) ex).getErrorCode())
        .isEqualTo(ErrorCode.UPSTREAM_ERROR);
  }

  @Test
  void autocompleteParsesSuggestions() throws Exception {
    server.enqueue(new MockResponse()
        .setHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
        .setBody("""
            {
              "suggestions": [
                {
                  "placePrediction": {
                    "placeId": "ChIJ1",
                    "text": {"text": "Brown Coffee"},
                    "structuredFormat": {
                      "mainText": {"text": "Brown Coffee"},
                      "secondaryText": {"text": "Aeon Mall, Phnom Penh"}
                    },
                    "distanceMeters": 850
                  }
                }
              ]
            }
            """));

    GoogleAutocompleteResponse response = client.autocomplete(
        new GoogleAutocompleteRequestBody("brown", null));

    assertThat(response.suggestions()).hasSize(1);
    assertThat(response.suggestions().get(0).placePrediction().placeId()).isEqualTo("ChIJ1");
    assertThat(response.suggestions().get(0).placePrediction().distanceMeters()).isEqualTo(850);

    RecordedRequest recorded = server.takeRequest();
    assertThat(recorded.getPath()).isEqualTo("/v1/places:autocomplete");
  }

  private static java.util.List<String> List_of(String... items) {
    return java.util.List.of(items);
  }
}
