package com.vithey.map.controller;

import com.vithey.map.dto.response.PlaceDetailResponse;
import com.vithey.map.security.CurrentUser;
import com.vithey.map.service.PlaceDetailService;
import com.vithey.map.util.ApiResponseWrapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/places")
@Tag(name = "Place Detail", description = "Single place detail for pin tap / bottom sheet")
public class PlaceDetailController {

  private final PlaceDetailService placeDetailService;

  public PlaceDetailController(PlaceDetailService placeDetailService) {
    this.placeDetailService = placeDetailService;
  }

  @GetMapping("/{googlePlaceId}")
  @Operation(summary = "Place detail", description = "Full place payload including opening hours, contact, and favorite flag")
  public ResponseEntity<ApiResponseWrapper<PlaceDetailResponse>> detail(
      @PathVariable String googlePlaceId,
      CurrentUser currentUser
  ) {
    return ResponseEntity.ok(ApiResponseWrapper.success(
        placeDetailService.detail(googlePlaceId, currentUser)));
  }
}
