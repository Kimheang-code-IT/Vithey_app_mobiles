package com.vithey.map.client.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

/** Google localized text wrapper: { "text": "..." }. */
@JsonIgnoreProperties(ignoreUnknown = true)
public record GoogleTextValue(
    @JsonProperty("text") String text
) {
}
