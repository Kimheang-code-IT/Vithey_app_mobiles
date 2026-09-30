package com.vithey.map.client.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Google photo reference. {@code name} looks like
 * {@code places/{place_id}/photos/{photo_ref}} — used to build client-visible
 * photo URLs via the configured template (photo proxy is deferred to v1.1).
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public record GooglePhoto(
    @JsonProperty("name") String name,
    @JsonProperty("widthPx") Integer widthPx,
    @JsonProperty("heightPx") Integer heightPx
) {
}
