package com.vithey.map.client.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

/** Normalized subset of a Google place object (Places API New field masks). */
@JsonIgnoreProperties(ignoreUnknown = true)
public record GooglePlace(
    @JsonProperty("id") String id,
    @JsonProperty("displayName") GoogleTextValue displayName,
    @JsonProperty("formattedAddress") String formattedAddress,
    @JsonProperty("location") GoogleLocation location,
    @JsonProperty("rating") Double rating,
    @JsonProperty("userRatingCount") Integer userRatingCount,
    @JsonProperty("priceLevel") String priceLevel,
    @JsonProperty("currentOpeningHours") GoogleOpeningHours currentOpeningHours,
    @JsonProperty("regularOpeningHours") GoogleOpeningHours regularOpeningHours,
    @JsonProperty("internationalPhoneNumber") String internationalPhoneNumber,
    @JsonProperty("websiteUri") String websiteUri,
    @JsonProperty("googleMapsUri") String googleMapsUri,
    @JsonProperty("photos") List<GooglePhoto> photos,
    @JsonProperty("primaryType") String primaryType
) {
}
