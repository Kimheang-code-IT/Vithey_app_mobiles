import 'package:aub_connect_app/core/constants/api_endpoints.dart';
import 'package:aub_connect_app/core/network/api_service.dart';
import 'package:aub_connect_app/data/models/place_models.dart';

class PlaceService {
  PlaceService(this._api);

  final ApiService _api;

  Future<PlaceSearchResult> nearby({
    required double lat,
    required double lng,
    PlaceFilter filter = const PlaceFilter(),
    String? pageToken,
  }) async {
    final response = await _api.get<PlaceSearchResult>(
      ApiEndpoints.placesNearby,
      queryParameters: filter.toQuery(lat: lat, lng: lng, pageToken: pageToken),
      fromJson: (json) =>
          PlaceSearchResult.fromJson(json as Map<String, dynamic>),
    );
    if (!response.isSuccess || response.data == null) {
      throw PlaceServiceException(response.error?.message ?? 'Nearby failed');
    }
    return response.data!;
  }

  Future<PlaceSearchResult> search({
    required String query,
    required double lat,
    required double lng,
    PlaceFilter filter = const PlaceFilter(),
    String? pageToken,
  }) async {
    final response = await _api.get<PlaceSearchResult>(
      ApiEndpoints.placesSearch,
      queryParameters: filter.toQuery(
        lat: lat,
        lng: lng,
        query: query,
        pageToken: pageToken,
      ),
      fromJson: (json) =>
          PlaceSearchResult.fromJson(json as Map<String, dynamic>),
    );
    if (!response.isSuccess || response.data == null) {
      throw PlaceServiceException(response.error?.message ?? 'Search failed');
    }
    return response.data!;
  }

  Future<List<PlaceAutocompleteSuggestion>> autocomplete({
    required String input,
    required double lat,
    required double lng,
  }) async {
    final response = await _api.get<List<PlaceAutocompleteSuggestion>>(
      ApiEndpoints.placesAutocomplete,
      queryParameters: {
        'input': input,
        'lat': lat,
        'lng': lng,
      },
      fromJson: (json) {
        final list = json as List<dynamic>? ?? [];
        return list
            .map(
              (e) => PlaceAutocompleteSuggestion.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList();
      },
    );
    if (!response.isSuccess || response.data == null) {
      throw PlaceServiceException(
        response.error?.message ?? 'Autocomplete failed',
      );
    }
    return response.data!;
  }

  Future<PlaceDetail> detail(String googlePlaceId) async {
    final response = await _api.get<PlaceDetail>(
      ApiEndpoints.placeById(googlePlaceId),
      fromJson: (json) => PlaceDetail.fromJson(json as Map<String, dynamic>),
    );
    if (!response.isSuccess || response.data == null) {
      throw PlaceServiceException(response.error?.message ?? 'Detail failed');
    }
    return response.data!;
  }

  Future<List<PlaceCard>> favorites() async {
    final response = await _api.get<List<PlaceCard>>(
      ApiEndpoints.placesFavorites,
      fromJson: (json) {
        final list = json as List<dynamic>? ?? [];
        return list
            .map((e) => PlaceCard.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    if (!response.isSuccess || response.data == null) {
      throw PlaceServiceException(
        response.error?.message ?? 'Favorites failed',
      );
    }
    return response.data!;
  }

  Future<List<Map<String, dynamic>>> history() async {
    final response = await _api.get<List<Map<String, dynamic>>>(
      ApiEndpoints.placesHistory,
      fromJson: (json) {
        final list = json as List<dynamic>? ?? [];
        return list
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      },
    );
    if (!response.isSuccess || response.data == null) {
      throw PlaceServiceException(response.error?.message ?? 'History failed');
    }
    return response.data!;
  }

  Future<PlaceCard> saveFavorite(PlaceCard place) async {
    final response = await _api.post<PlaceCard>(
      ApiEndpoints.placesFavorites,
      data: place.toFavoriteJson(),
      fromJson: (json) => PlaceCard.fromJson(json as Map<String, dynamic>),
    );
    if (!response.isSuccess || response.data == null) {
      throw PlaceServiceException(response.error?.message ?? 'Save failed');
    }
    return response.data!;
  }

  Future<void> removeFavorite(String googlePlaceId) async {
    final response = await _api.delete<Object?>(
      ApiEndpoints.placeFavoriteById(googlePlaceId),
      fromJson: (_) => null,
    );
    if (!response.isSuccess) {
      throw PlaceServiceException(response.error?.message ?? 'Remove failed');
    }
  }
}

class PlaceServiceException implements Exception {
  PlaceServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
