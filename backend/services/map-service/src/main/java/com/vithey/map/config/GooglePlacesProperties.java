package com.vithey.map.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * Google Places API (New) settings. The API key lives only on the server;
 * it is never returned to clients and never logged.
 */
@ConfigurationProperties(prefix = "vithey.map.google")
public record GooglePlacesProperties(
    String apiKey,
    String baseUrl,
    long connectTimeoutMs,
    long responseTimeoutMs,
    String photoUrlTemplate
) {

  public GooglePlacesProperties {
    if (baseUrl == null || baseUrl.isBlank()) {
      baseUrl = "https://places.googleapis.com/v1";
    }
    if (connectTimeoutMs <= 0) {
      connectTimeoutMs = 5000;
    }
    if (responseTimeoutMs <= 0) {
      responseTimeoutMs = 10000;
    }
  }

  public boolean hasApiKey() {
    return apiKey != null && !apiKey.isBlank();
  }
}
