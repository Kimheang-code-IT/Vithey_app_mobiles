import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/data/fixtures/place_fixtures.dart';
import 'package:aub_connect_app/data/models/place_models.dart';
import 'package:aub_connect_app/data/services/place_service.dart';

class PlaceRepository {
  PlaceRepository(this._service, this._flags);

  final PlaceService _service;
  final FeatureFlags _flags;

  final Set<String> _mockFavoriteIds = {};
  final List<Map<String, dynamic>> _mockHistory = [];

  bool get useMockApi => _flags.useMockMap;

  Future<PlaceSearchResult> nearby({
    required double lat,
    required double lng,
    PlaceFilter filter = const PlaceFilter(),
    String? pageToken,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 280));
      return PlaceFixtures.nearby(
        lat: lat,
        lng: lng,
        filter: filter,
        favoriteIds: _mockFavoriteIds,
      );
    }
    return _service.nearby(
      lat: lat,
      lng: lng,
      filter: filter,
      pageToken: pageToken,
    );
  }

  Future<PlaceSearchResult> search({
    required String query,
    required double lat,
    required double lng,
    PlaceFilter filter = const PlaceFilter(),
    String? pageToken,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 280));
      _recordHistory(query: query, lat: lat, lng: lng, filter: filter);
      return PlaceFixtures.search(
        query: query,
        lat: lat,
        lng: lng,
        filter: filter,
        favoriteIds: _mockFavoriteIds,
      );
    }
    return _service.search(
      query: query,
      lat: lat,
      lng: lng,
      filter: filter,
      pageToken: pageToken,
    );
  }

  Future<List<PlaceAutocompleteSuggestion>> autocomplete({
    required String input,
    required double lat,
    required double lng,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 180));
      return PlaceFixtures.autocomplete(input: input, lat: lat, lng: lng);
    }
    return _service.autocomplete(input: input, lat: lat, lng: lng);
  }

  Future<PlaceDetail> detail(String googlePlaceId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      final d = PlaceFixtures.detail(
        googlePlaceId,
        favoriteIds: _mockFavoriteIds,
      );
      if (d == null) {
        throw PlaceServiceException('Place not found');
      }
      return d;
    }
    return _service.detail(googlePlaceId);
  }

  Future<List<PlaceCard>> favorites() async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 150));
      return _mockFavoriteIds
          .map(PlaceFixtures.byId)
          .whereType<PlaceCard>()
          .map((p) => p.copyWith(isFavorite: true))
          .toList();
    }
    return _service.favorites();
  }

  Future<PlaceCard> toggleFavorite(PlaceCard place) async {
    if (place.isFavorite) {
      await removeFavorite(place.googlePlaceId);
      return place.copyWith(isFavorite: false);
    }
    return saveFavorite(place);
  }

  Future<PlaceCard> saveFavorite(PlaceCard place) async {
    if (useMockApi) {
      _mockFavoriteIds.add(place.googlePlaceId);
      return place.copyWith(isFavorite: true);
    }
    return _service.saveFavorite(place);
  }

  Future<void> removeFavorite(String googlePlaceId) async {
    if (useMockApi) {
      _mockFavoriteIds.remove(googlePlaceId);
      return;
    }
    await _service.removeFavorite(googlePlaceId);
  }

  Future<List<Map<String, dynamic>>> history() async {
    if (useMockApi) {
      return List<Map<String, dynamic>>.from(_mockHistory.reversed);
    }
    return _service.history();
  }

  void _recordHistory({
    required String query,
    required double lat,
    required double lng,
    required PlaceFilter filter,
  }) {
    _mockHistory.add({
      'query': query,
      'category': filter.category,
      'latitude': lat,
      'longitude': lng,
      'radius_m': filter.radiusM,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
    while (_mockHistory.length > 20) {
      _mockHistory.removeAt(0);
    }
  }
}
