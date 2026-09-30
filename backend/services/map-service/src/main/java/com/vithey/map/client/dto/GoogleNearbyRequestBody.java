package com.vithey.map.client.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

/** Body for places:searchNearby. */
@JsonInclude(JsonInclude.Include.NON_NULL)
public record GoogleNearbyRequestBody(
    @JsonProperty("includedTypes") List<String> includedTypes,
    @JsonProperty("maxResultCount") Integer maxResultCount,
    @JsonProperty("locationRestriction") LocationRestriction locationRestriction,
    @JsonProperty("rankPreference") String rankPreference
) {

  @JsonInclude(JsonInclude.Include.NON_NULL)
  public record LocationRestriction(
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
