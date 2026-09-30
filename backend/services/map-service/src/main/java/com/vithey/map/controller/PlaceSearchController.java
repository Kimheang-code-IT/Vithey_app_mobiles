package com.vithey.map.controller;

import com.vithey.map.dto.request.NearbySearchRequest;
import com.vithey.map.dto.request.TextSearchRequest;
import com.vithey.map.dto.response.AutocompleteSuggestionResponse;
import com.vithey.map.dto.response.PlaceSearchResultResponse;
import com.vithey.map.security.CurrentUser;
import com.vithey.map.service.AutocompleteService;
import com.vithey.map.service.NearbySearchService;
import com.vithey.map.service.TextSearchService;
import com.vithey.map.util.ApiResponseWrapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/places")
@Validated
@Tag(name = "Place Search", description = "Nearby places, keyword search, and typeahead suggestions")
public class PlaceSearchController {

  private final NearbySearchService nearbySearchService;
  private final TextSearchService textSearchService;
  private final AutocompleteService autocompleteService;

  public PlaceSearchController(
      NearbySearchService nearbySearchService,
      TextSearchService textSearchService,
      AutocompleteService autocompleteService
  ) {
    this.nearbySearchService = nearbySearchService;
    this.textSearchService = textSearchService;
    this.autocompleteService = autocompleteService;
  }

  @GetMapping("/nearby")
  @Operation(summary = "Nearby places", description = "Shops/places around lat/lng with filters, for map markers and result list")
  public ResponseEntity<ApiResponseWrapper<PlaceSearchResultResponse>> nearby(
      @Valid NearbySearchRequest request,
      CurrentUser currentUser
  ) {
    return ResponseEntity.ok(ApiResponseWrapper.success(nearbySearchService.nearby(request, currentUser)));
  }

  @GetMapping("/search")
  @Operation(summary = "Keyword search", description = "Text search near the user with location bias and filters")
  public ResponseEntity<ApiResponseWrapper<PlaceSearchResultResponse>> search(
      @Valid TextSearchRequest request,
      CurrentUser currentUser
  ) {
    return ResponseEntity.ok(ApiResponseWrapper.success(textSearchService.search(request, currentUser)));
  }

  @GetMapping("/autocomplete")
  @Operation(summary = "Autocomplete", description = "Compact typeahead suggestions biased to the user location")
  public ResponseEntity<ApiResponseWrapper<List<AutocompleteSuggestionResponse>>> autocomplete(
      @RequestParam @NotBlank String input,
      @RequestParam(required = false) Double lat,
      @RequestParam(required = false) Double lng
  ) {
    return ResponseEntity.ok(ApiResponseWrapper.success(autocompleteService.suggest(input, lat, lng)));
  }
}
