package com.vithey.map.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.vithey.map.dto.response.PlaceDetailResponse;
import com.vithey.map.dto.response.PlaceSearchResultResponse;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Duration;
import java.util.HexFormat;
import java.util.Optional;
import org.springframework.dao.DataAccessException;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

/**
 * Redis response cache:
 * nearby/search payloads 5 min, place detail 24 h.
 * Redis failures degrade gracefully to "cache miss / no-op".
 */
@Service
public class PlaceCacheService {

  public static final Duration SEARCH_TTL = Duration.ofMinutes(5);
  public static final Duration DETAIL_TTL = Duration.ofHours(24);

  private final StringRedisTemplate redisTemplate;
  private final ObjectMapper objectMapper;

  public PlaceCacheService(StringRedisTemplate redisTemplate, ObjectMapper objectMapper) {
    this.redisTemplate = redisTemplate;
    this.objectMapper = objectMapper;
  }

  public Optional<PlaceSearchResultResponse> getSearchResult(String key) {
    try {
      String json = redisTemplate.opsForValue().get(key);
      if (json == null) {
        return Optional.empty();
      }
      return Optional.of(objectMapper.readValue(json, PlaceSearchResultResponse.class));
    } catch (DataAccessException | com.fasterxml.jackson.core.JsonProcessingException exception) {
      return Optional.empty();
    }
  }

  public void putSearchResult(String key, PlaceSearchResultResponse result) {
    try {
      redisTemplate.opsForValue().set(key, objectMapper.writeValueAsString(result), SEARCH_TTL);
    } catch (DataAccessException | com.fasterxml.jackson.core.JsonProcessingException exception) {
      // Cache write failure must not fail the request.
    }
  }

  public Optional<PlaceDetailResponse> getDetail(String googlePlaceId) {
    try {
      String json = redisTemplate.opsForValue().get(detailKey(googlePlaceId));
      if (json == null) {
        return Optional.empty();
      }
      return Optional.of(objectMapper.readValue(json, PlaceDetailResponse.class));
    } catch (DataAccessException | com.fasterxml.jackson.core.JsonProcessingException exception) {
      return Optional.empty();
    }
  }

  public void putDetail(String googlePlaceId, PlaceDetailResponse detail) {
    try {
      redisTemplate.opsForValue()
          .set(detailKey(googlePlaceId), objectMapper.writeValueAsString(detail), DETAIL_TTL);
    } catch (DataAccessException | com.fasterxml.jackson.core.JsonProcessingException exception) {
      // Cache write failure must not fail the request.
    }
  }

  public static String detailKey(String googlePlaceId) {
    return "places:detail:" + googlePlaceId;
  }

  /**
   * Stable cache key for a search: {@code places:{kind}:{hash}} where hash is
   * SHA-256 of the normalized parts. Coordinates are rounded to ~4 decimals
   * (~11 m) to improve hit rate.
   */
  public static String searchKey(String kind, Object... parts) {
    StringBuilder canonical = new StringBuilder(kind);
    for (Object part : parts) {
      canonical.append('|').append(part == null ? "" : part.toString());
    }
    return "places:" + kind + ":" + sha256(canonical.toString());
  }

  public static double roundCoordinate(double value) {
    return Math.round(value * 10_000.0) / 10_000.0;
  }

  private static String sha256(String input) {
    try {
      MessageDigest digest = MessageDigest.getInstance("SHA-256");
      byte[] hash = digest.digest(input.getBytes(StandardCharsets.UTF_8));
      return HexFormat.of().formatHex(hash);
    } catch (NoSuchAlgorithmException exception) {
      // SHA-256 is mandatory on every JVM.
      throw new IllegalStateException(exception);
    }
  }
}
