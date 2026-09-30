package com.vithey.map.client.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

/** Response of places:autocomplete. */
@JsonIgnoreProperties(ignoreUnknown = true)
public record GoogleAutocompleteResponse(
    @JsonProperty("suggestions") List<Suggestion> suggestions
) {

  @JsonIgnoreProperties(ignoreUnknown = true)
  public record Suggestion(
      @JsonProperty("placePrediction") PlacePrediction placePrediction
  ) {
  }

  @JsonIgnoreProperties(ignoreUnknown = true)
  public record PlacePrediction(
      @JsonProperty("placeId") String placeId,
      @JsonProperty("text") GoogleTextValue text,
      @JsonProperty("structuredFormat") StructuredFormat structuredFormat,
      @JsonProperty("distanceMeters") Integer distanceMeters
  ) {
  }

  @JsonIgnoreProperties(ignoreUnknown = true)
  public record StructuredFormat(
      @JsonProperty("mainText") GoogleTextValue mainText,
      @JsonProperty("secondaryText") GoogleTextValue secondaryText
  ) {
  }
}
