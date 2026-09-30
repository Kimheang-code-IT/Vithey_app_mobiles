package com.vithey.map.client.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;

/** Body for places:searchText. */
@JsonInclude(JsonInclude.Include.NON_NULL)
public record GoogleSearchTextRequestBody(
    @JsonProperty("textQuery") String textQuery,
    @JsonProperty("includedType") String includedType,
    @JsonProperty("pageSize") Integer pageSize,
    @JsonProperty("pageToken") String pageToken,
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
