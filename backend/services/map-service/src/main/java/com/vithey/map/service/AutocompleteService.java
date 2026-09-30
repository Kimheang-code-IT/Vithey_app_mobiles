package com.vithey.map.service;

import com.vithey.map.client.GooglePlacesClient;
import com.vithey.map.client.dto.GoogleAutocompleteRequestBody;
import com.vithey.map.client.dto.GoogleAutocompleteResponse;
import com.vithey.map.client.dto.GoogleLocation;
import com.vithey.map.dto.response.AutocompleteSuggestionResponse;
import com.vithey.map.mapper.PlaceMapper;
import java.util.List;
import org.springframework.stereotype.Service;

/** Typeahead suggestions biased to user coordinates (no heavy place details). */
@Service
public class AutocompleteService {

  private static final int MIN_INPUT_LENGTH = 1;

  private final GooglePlacesClient googlePlacesClient;
  private final PlaceMapper placeMapper;

  public AutocompleteService(GooglePlacesClient googlePlacesClient, PlaceMapper placeMapper) {
    this.googlePlacesClient = googlePlacesClient;
    this.placeMapper = placeMapper;
  }

  public List<AutocompleteSuggestionResponse> suggest(String input, Double lat, Double lng) {
    if (input == null || input.trim().length() < MIN_INPUT_LENGTH) {
      return List.of();
    }

    GoogleAutocompleteRequestBody.LocationBias bias = lat != null && lng != null
        ? new GoogleAutocompleteRequestBody.LocationBias(
            new GoogleAutocompleteRequestBody.Circle(new GoogleLocation(lat, lng), 50_000.0))
        : null;

    GoogleAutocompleteResponse response = googlePlacesClient.autocomplete(
        new GoogleAutocompleteRequestBody(input.trim(), bias));

    if (response == null || response.suggestions() == null) {
      return List.of();
    }
    return response.suggestions().stream()
        .map(GoogleAutocompleteResponse.Suggestion::placePrediction)
        .filter(prediction -> prediction != null && prediction.placeId() != null)
        .map(placeMapper::toSuggestion)
        .toList();
  }
}
