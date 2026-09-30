package com.vithey.map.client.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

/** Response of places:searchNearby / places:searchText. */
@JsonIgnoreProperties(ignoreUnknown = true)
public record GoogleSearchResponse(
    @JsonProperty("places") List<GooglePlace> places,
    @JsonProperty("nextPageToken") String nextPageToken
) {

  public static GoogleSearchResponse empty() {
    return new GoogleSearchResponse(List.of(), null);
  }
}
