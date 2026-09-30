package com.vithey.map.client.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;

/** Body for places:autocomplete. */
@JsonInclude(JsonInclude.Include.NON_NULL)
public record GoogleAutocompleteRequestBody(
    @JsonProperty("input") String input,
    @JsonProperty("locationBias") LocationBias locationBias
) {

  @JsonInclude(JsonInclude.Include.NON_NULL)
  public record LocationBias(
      @JsonProperty("circle") Circle circle
  ) {
  }

  @JsonInclude(JsonInclude.Include.NON_NULL)
  public record Circle(
      @JsonProperty("center") GoogleLocation center,
      @JsonProperty("radius") Double radius
  ) {
  }
}
