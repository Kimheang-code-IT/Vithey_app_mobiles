package com.vithey.map.controller;

import com.vithey.map.dto.request.SaveFavoriteRequest;
import com.vithey.map.dto.response.PlaceCardResponse;
import com.vithey.map.security.CurrentUser;
import com.vithey.map.service.PlaceFavoriteService;
import com.vithey.map.util.ApiResponseWrapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/places/favorites")
@Tag(name = "Favorites", description = "Saved places, scoped to the current user")
public class PlaceFavoriteController {

  private final PlaceFavoriteService placeFavoriteService;

  public PlaceFavoriteController(PlaceFavoriteService placeFavoriteService) {
    this.placeFavoriteService = placeFavoriteService;
  }

  @GetMapping
  @Operation(summary = "List favorites", description = "My saved places (newest first)")
  public ResponseEntity<ApiResponseWrapper<List<PlaceCardResponse>>> favorites(CurrentUser currentUser) {
    return ResponseEntity.ok(ApiResponseWrapper.success(
        placeFavoriteService.favorites(currentUser.userId())));
  }

  @PostMapping
  @Operation(summary = "Save favorite", description = "Upsert a place snapshot; idempotent per (user, place)")
  public ResponseEntity<ApiResponseWrapper<PlaceCardResponse>> save(
      @Valid @RequestBody SaveFavoriteRequest request,
      CurrentUser currentUser
  ) {
    PlaceCardResponse saved = placeFavoriteService.save(currentUser.userId(), request);
    return ResponseEntity.status(201).body(ApiResponseWrapper.success(saved));
  }

  @DeleteMapping("/{googlePlaceId}")
  @Operation(summary = "Remove favorite", description = "Deletes only if owned by the caller")
  public ResponseEntity<Void> remove(
      @PathVariable String googlePlaceId,
      CurrentUser currentUser
  ) {
    placeFavoriteService.remove(currentUser.userId(), googlePlaceId);
    return ResponseEntity.noContent().build();
  }
}
