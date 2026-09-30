package com.vithey.map.dto.request;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/** Body for POST /places/favorites — coordinate snapshot for offline map pins. */
public record SaveFavoriteRequest(
    @NotBlank @Size(max = 255) String googlePlaceId,
    @NotBlank @Size(max = 255) String name,
    @Size(max = 512) String address,
    @NotNull @DecimalMin("-90.0") @DecimalMax("90.0") Double latitude,
    @NotNull @DecimalMin("-180.0") @DecimalMax("180.0") Double longitude,
    @Size(max = 64) String category,
    @Size(max = 1024) String photoUrl
) {
}
