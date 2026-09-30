package com.vithey.map.dto.request;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

/** Query params for GET /places/nearby. Bound by Spring MVC from the query string. */
public class NearbySearchRequest {

  @NotNull
  @DecimalMin("-90.0")
  @DecimalMax("90.0")
  private Double lat;

  @NotNull
  @DecimalMin("-180.0")
  @DecimalMax("180.0")
  private Double lng;

  @Min(100)
  @Max(20000)
  private Integer radiusM = 1500;

  private String category;

  private Boolean openNow;

  @DecimalMin("1.0")
  @DecimalMax("5.0")
  private Double minRating;

  @Min(0)
  @Max(4)
  private Integer priceLevel;

  private String pageToken;

  @Min(1)
  @Max(40)
  private Integer limit = 20;

  public Double getLat() {
    return lat;
  }

  public void setLat(Double lat) {
    this.lat = lat;
  }

  public Double getLng() {
    return lng;
  }

  public void setLng(Double lng) {
    this.lng = lng;
  }

  public Integer getRadiusM() {
    return radiusM == null ? 1500 : radiusM;
  }

  public void setRadiusM(Integer radiusM) {
    this.radiusM = radiusM;
  }

  public String getCategory() {
    return category;
  }

  public void setCategory(String category) {
    this.category = category;
  }

  public Boolean getOpenNow() {
    return openNow;
  }

  public void setOpenNow(Boolean openNow) {
    this.openNow = openNow;
  }

  public Double getMinRating() {
    return minRating;
  }

  public void setMinRating(Double minRating) {
    this.minRating = minRating;
  }

  public Integer getPriceLevel() {
    return priceLevel;
  }

  public void setPriceLevel(Integer priceLevel) {
    this.priceLevel = priceLevel;
  }

  public String getPageToken() {
    return pageToken;
  }

  public void setPageToken(String pageToken) {
    this.pageToken = pageToken;
  }

  public Integer getLimit() {
    return limit == null ? 20 : limit;
  }

  public void setRadius_m(Integer radiusM) {
    this.radiusM = radiusM;
  }

  public void setOpen_now(Boolean openNow) {
    this.openNow = openNow;
  }

  public void setMin_rating(Double minRating) {
    this.minRating = minRating;
  }

  public void setPrice_level(Integer priceLevel) {
    this.priceLevel = priceLevel;
  }

  public void setPage_token(String pageToken) {
    this.pageToken = pageToken;
  }

  public void setLimit(Integer limit) {
    this.limit = limit;
  }
}
