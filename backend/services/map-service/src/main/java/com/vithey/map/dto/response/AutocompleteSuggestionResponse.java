package com.vithey.map.dto.response;

/** Compact typeahead suggestion (no heavy place details). */
public record AutocompleteSuggestionResponse(
    String googlePlaceId,
    String primaryText,
    String secondaryText,
    Long distanceM
) {
}
