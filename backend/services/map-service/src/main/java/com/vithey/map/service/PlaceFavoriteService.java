package com.vithey.map.service;

import com.vithey.map.dto.request.SaveFavoriteRequest;
import com.vithey.map.dto.response.PlaceCardResponse;
import com.vithey.map.entity.PlaceFavorite;
import com.vithey.map.exception.ApiException;
import com.vithey.map.exception.ErrorCode;
import com.vithey.map.mapper.PlaceMapper;
import com.vithey.map.repository.PlaceFavoriteRepository;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Owner-scoped favorites: upsert by (user_id, google_place_id). */
@Service
public class PlaceFavoriteService {

  private final PlaceFavoriteRepository placeFavoriteRepository;
  private final PlaceMapper placeMapper;

  public PlaceFavoriteService(PlaceFavoriteRepository placeFavoriteRepository, PlaceMapper placeMapper) {
    this.placeFavoriteRepository = placeFavoriteRepository;
    this.placeMapper = placeMapper;
  }

  @Transactional(readOnly = true)
  public List<PlaceCardResponse> favorites(UUID userId) {
    return placeFavoriteRepository.findByUserIdOrderByCreatedAtDesc(userId).stream()
        .map(placeMapper::toCard)
        .toList();
  }

  @Transactional(readOnly = true)
  public Set<String> favoritePlaceIds(UUID userId) {
    return placeFavoriteRepository.findByUserIdOrderByCreatedAtDesc(userId).stream()
        .map(PlaceFavorite::getGooglePlaceId)
        .collect(Collectors.toSet());
  }

  @Transactional(readOnly = true)
  public boolean isFavorite(UUID userId, String googlePlaceId) {
    return placeFavoriteRepository.findByUserIdAndGooglePlaceId(userId, googlePlaceId).isPresent();
  }

  /** Idempotent upsert: re-saving refreshes the snapshot instead of failing. */
  @Transactional
  public PlaceCardResponse save(UUID userId, SaveFavoriteRequest request) {
    PlaceFavorite favorite = placeFavoriteRepository
        .findByUserIdAndGooglePlaceId(userId, request.googlePlaceId())
        .orElseGet(() -> new PlaceFavorite(
            userId,
            request.googlePlaceId(),
            request.name(),
            request.address(),
            request.latitude(),
            request.longitude(),
            request.category(),
            request.photoUrl()));

    favorite.setName(request.name());
    favorite.setAddress(request.address());
    favorite.setLatitude(request.latitude());
    favorite.setLongitude(request.longitude());
    favorite.setCategory(request.category());
    favorite.setPhotoUrl(request.photoUrl());

    return placeMapper.toCard(placeFavoriteRepository.save(favorite));
  }

  @Transactional
  public void remove(UUID userId, String googlePlaceId) {
    long removed = placeFavoriteRepository
        .findByUserIdAndGooglePlaceId(userId, googlePlaceId)
        .map(favorite -> {
          placeFavoriteRepository.delete(favorite);
          return 1;
        })
        .orElse(0);
    if (removed == 0) {
      throw new ApiException(ErrorCode.NOT_FOUND, "Favorite not found for this user");
    }
  }
}
