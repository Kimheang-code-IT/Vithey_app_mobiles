package com.vithey.map.controller;

import com.vithey.map.dto.response.PlaceHistoryResponse;
import com.vithey.map.security.CurrentUser;
import com.vithey.map.service.PlaceHistoryService;
import com.vithey.map.util.ApiResponseWrapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/places/history")
@Tag(name = "History", description = "Recent searches, max 20 per user")
public class PlaceHistoryController {

  private final PlaceHistoryService placeHistoryService;

  public PlaceHistoryController(PlaceHistoryService placeHistoryService) {
    this.placeHistoryService = placeHistoryService;
  }

  @GetMapping
  @Operation(summary = "Recent searches", description = "Last 20 searches, newest first")
  public ResponseEntity<ApiResponseWrapper<List<PlaceHistoryResponse>>> history(CurrentUser currentUser) {
    return ResponseEntity.ok(ApiResponseWrapper.success(
        placeHistoryService.history(currentUser.userId())));
  }

  @DeleteMapping
  @Operation(summary = "Clear history", description = "Deletes all search history for the caller")
  public ResponseEntity<Void> clear(CurrentUser currentUser) {
    placeHistoryService.clear(currentUser.userId());
    return ResponseEntity.noContent().build();
  }
}
