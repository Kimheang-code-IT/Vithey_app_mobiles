package com.vithey.map.client.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

/** Google location: { "latitude": ..., "longitude": ... }. */
@JsonIgnoreProperties(ignoreUnknown = true)
public record GoogleLocation(
    @JsonProperty("latitude") double latitude,
    @JsonProperty("longitude") double longitude
) {
}
