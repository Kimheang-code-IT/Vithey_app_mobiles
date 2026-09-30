import 'dart:math' as math;

import 'package:aub_connect_app/data/models/place_models.dart';

class PlaceFixtures {
  PlaceFixtures._();

  /// Phnom Penh default center (Aeon / BKK area).
  static const double defaultLat = 11.5564;
  static const double defaultLng = 104.9282;

  static final List<PlaceCard> _places = [
    const PlaceCard(
      googlePlaceId: 'mock-brown-aeon',
      name: 'Brown Coffee AEON',
      address: 'Aeon Mall Phnom Penh',
      category: 'cafe',
      latitude: 11.5501,
      longitude: 104.9312,
      rating: 4.5,
      userRatingCount: 320,
      priceLevel: 2,
      openNow: true,
      photoUrl: null,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-starbucks-tk',
      name: 'Starbucks The Peak',
      address: 'Olympic, Phnom Penh',
      category: 'cafe',
      latitude: 11.5560,
      longitude: 104.9215,
      rating: 4.3,
      userRatingCount: 210,
      priceLevel: 3,
      openNow: true,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-kfc-tk',
      name: 'KFC Toul Kork',
      address: 'Street 289, Phnom Penh',
      category: 'restaurant',
      latitude: 11.5620,
      longitude: 104.9100,
      rating: 4.1,
      userRatingCount: 540,
      priceLevel: 2,
      openNow: true,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-lucky-supermarket',
      name: 'Lucky Supermarket',
      address: 'Sihanouk Blvd',
      category: 'supermarket',
      latitude: 11.5515,
      longitude: 104.9220,
      rating: 4.0,
      userRatingCount: 180,
      priceLevel: 2,
      openNow: true,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-pharmacy-pp',
      name: 'Pharmacie De La Gare',
      address: 'Near Central Market',
      category: 'pharmacy',
      latitude: 11.5695,
      longitude: 104.9210,
      rating: 4.4,
      userRatingCount: 95,
      priceLevel: 1,
      openNow: false,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-aba-atm',
      name: 'ABA Bank ATM',
      address: 'Street 271',
      category: 'atm',
      latitude: 11.5540,
      longitude: 104.9250,
      rating: 4.2,
      userRatingCount: 40,
      priceLevel: 0,
      openNow: true,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-aeon-mall',
      name: 'AEON Mall Phnom Penh',
      address: 'Samdach Sothearos Blvd',
      category: 'shopping_mall',
      latitude: 11.5485,
      longitude: 104.9350,
      rating: 4.6,
      userRatingCount: 2100,
      priceLevel: 3,
      openNow: true,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-aub',
      name: 'American University of Phnom Penh',
      address: 'Street 2004',
      category: 'university',
      latitude: 11.5688,
      longitude: 104.8935,
      rating: 4.7,
      userRatingCount: 120,
      priceLevel: null,
      openNow: true,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-phone-shop',
      name: 'Cellcard Store',
      address: 'Soriya Mall',
      category: 'other',
      latitude: 11.5605,
      longitude: 104.9180,
      rating: 3.9,
      userRatingCount: 70,
      priceLevel: 2,
      openNow: true,
    ),
    const PlaceCard(
      googlePlaceId: 'mock-gas-caltex',
      name: 'Caltex Station',
      address: 'Russian Blvd',
      category: 'gas_station',
      latitude: 11.5650,
      longitude: 104.9000,
      rating: 4.0,
      userRatingCount: 55,
      priceLevel: 2,
      openNow: true,
    ),
  ];

  static int _distanceM(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371000.0;
    final dLat = _rad(lat2 - lat1);
    final dLng = _rad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return (r * c).round();
  }

  static double _rad(double deg) => deg * math.pi / 180;

  static PlaceSearchResult nearby({
    required double lat,
    required double lng,
    PlaceFilter filter = const PlaceFilter(),
    Set<String> favoriteIds = const {},
  }) {
    var list = _places.map((p) {
      final d = _distanceM(lat, lng, p.latitude, p.longitude);
      return p.copyWith(
        distanceM: d,
        isFavorite: favoriteIds.contains(p.googlePlaceId),
      );
    }).where((p) {
      if (p.distanceM != null && p.distanceM! > filter.radiusM) return false;
      if (filter.category != null &&
          filter.category!.isNotEmpty &&
          p.category != filter.category) {
        return false;
      }
      if (filter.openNow == true && p.openNow != true) return false;
      if (filter.minRating != null &&
          (p.rating == null || p.rating! < filter.minRating!)) {
        return false;
      }
      if (filter.priceLevel != null && p.priceLevel != filter.priceLevel) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => (a.distanceM ?? 0).compareTo(b.distanceM ?? 0));

    if (list.length > filter.limit) {
      list = list.take(filter.limit).toList();
    }

    return PlaceSearchResult(
      centerLat: lat,
      centerLng: lng,
      radiusM: filter.radiusM,
      places: list,
    );
  }

  static PlaceSearchResult search({
    required String query,
    required double lat,
    required double lng,
    PlaceFilter filter = const PlaceFilter(),
    Set<String> favoriteIds = const {},
  }) {
    final q = query.trim().toLowerCase();
    final base = nearby(
      lat: lat,
      lng: lng,
      filter: filter,
      favoriteIds: favoriteIds,
    );
    final filtered = base.places
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              (p.address?.toLowerCase().contains(q) ?? false) ||
              (p.category?.toLowerCase().contains(q) ?? false),
        )
        .toList();
    return PlaceSearchResult(
      centerLat: lat,
      centerLng: lng,
      radiusM: filter.radiusM,
      places: filtered,
    );
  }

  static List<PlaceAutocompleteSuggestion> autocomplete({
    required String input,
    required double lat,
    required double lng,
  }) {
    final q = input.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return _places
        .where((p) => p.name.toLowerCase().contains(q))
        .map(
          (p) => PlaceAutocompleteSuggestion(
            googlePlaceId: p.googlePlaceId,
            primaryText: p.name,
            secondaryText: p.address,
            distanceM: _distanceM(lat, lng, p.latitude, p.longitude),
            latitude: p.latitude,
            longitude: p.longitude,
          ),
        )
        .take(8)
        .toList();
  }

  static PlaceDetail? detail(String id, {Set<String> favoriteIds = const {}}) {
    final p = _places.cast<PlaceCard?>().firstWhere(
          (e) => e!.googlePlaceId == id,
          orElse: () => null,
        );
    if (p == null) return null;
    return PlaceDetail(
      googlePlaceId: p.googlePlaceId,
      name: p.name,
      address: p.address,
      category: p.category,
      latitude: p.latitude,
      longitude: p.longitude,
      rating: p.rating,
      userRatingCount: p.userRatingCount,
      priceLevel: p.priceLevel,
      openNow: p.openNow,
      openingHours: const ['Mon–Sun 08:00–21:00'],
      photoUrls: p.photoUrl == null ? const [] : [p.photoUrl!],
      isFavorite: favoriteIds.contains(p.googlePlaceId),
      googleMapsUri:
          'https://www.google.com/maps/search/?api=1&query=${p.latitude},${p.longitude}',
    );
  }

  static PlaceCard? byId(String id) {
    try {
      return _places.firstWhere((p) => p.googlePlaceId == id);
    } catch (_) {
      return null;
    }
  }
}
