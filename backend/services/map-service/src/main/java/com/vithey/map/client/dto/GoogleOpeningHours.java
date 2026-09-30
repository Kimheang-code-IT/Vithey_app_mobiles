package com.vithey.map.client.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

@JsonIgnoreProperties(ignoreUnknown = true)
public record GoogleOpeningHours(
    @JsonProperty("openNow") Boolean openNow,
    @JsonProperty("weekdayDescriptions") List<String> weekdayDescriptions
) {
}
