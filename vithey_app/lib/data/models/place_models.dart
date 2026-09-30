class PlaceCard {
  const PlaceCard({
    required this.googlePlaceId,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
    this.category,
    this.rating,
    this.userRatingCount,
    this.priceLevel,
    this.openNow,
    this.distanceM,
    this.photoUrl,
    this.isFavorite = false,
  });

  final String googlePlaceId;
  final String name;
  final String? address;
  final String? category;
  final double latitude;
  final double longitude;
  final double? rating;
  final int? userRatingCount;
  final int? priceLevel;
  final bool? openNow;
  final int? distanceM;
  final String? photoUrl;
  final bool isFavorite;

  PlaceCard copyWith({bool? isFavorite, int? distanceM}) {
    return PlaceCard(
      googlePlaceId: googlePlaceId,
      name: name,
      address: address,
      category: category,
      latitude: latitude,
      longitude: longitude,
      rating: rating,
      userRatingCount: userRatingCount,
      priceLevel: priceLevel,
      openNow: openNow,
      distanceM: distanceM ?? this.distanceM,
      photoUrl: photoUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory PlaceCard.fromJson(Map<String, dynamic> json) {
    return PlaceCard(
      googlePlaceId: json['google_place_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String?,
      category: json['category'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingCount: json['user_rating_count'] as int?,
      priceLevel: json['price_level'] as int?,
      openNow: json['open_now'] as bool?,
      distanceM: json['distance_m'] as int?,
      photoUrl: json['photo_url'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFavoriteJson() => {
        'google_place_id': googlePlaceId,
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'category': category,
        'photo_url': photoUrl,
      };
}

class PlaceSearchResult {
  const PlaceSearchResult({
    required this.centerLat,
    required this.centerLng,
    required this.radiusM,
    required this.places,
    this.nextPageToken,
  });

  final double centerLat;
  final double centerLng;
  final int radiusM;
  final List<PlaceCard> places;
  final String? nextPageToken;

  factory PlaceSearchResult.fromJson(Map<String, dynamic> json) {
    final center = json['center'] as Map<String, dynamic>? ?? {};
    final list = json['places'] as List<dynamic>? ?? [];
    return PlaceSearchResult(
      centerLat: (center['lat'] as num?)?.toDouble() ?? 0,
      centerLng: (center['lng'] as num?)?.toDouble() ?? 0,
      radiusM: json['radius_m'] as int? ?? 1500,
      places: list
          .map((e) => PlaceCard.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextPageToken: json['next_page_token'] as String?,
    );
  }
}

class PlaceAutocompleteSuggestion {
  const PlaceAutocompleteSuggestion({
    required this.googlePlaceId,
    required this.primaryText,
    this.secondaryText,
    this.distanceM,
    this.latitude,
    this.longitude,
  });

  final String googlePlaceId;
  final String primaryText;
  final String? secondaryText;
  final int? distanceM;
  final double? latitude;
  final double? longitude;

  factory PlaceAutocompleteSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceAutocompleteSuggestion(
      googlePlaceId: json['google_place_id'] as String? ?? '',
      primaryText: json['primary_text'] as String? ?? '',
      secondaryText: json['secondary_text'] as String?,
      distanceM: json['distance_m'] as int?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}

class PlaceDetail {
  const PlaceDetail({
    required this.googlePlaceId,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
    this.category,
    this.rating,
    this.userRatingCount,
    this.priceLevel,
    this.openNow,
    this.openingHours = const [],
    this.phone,
    this.website,
    this.googleMapsUri,
    this.photoUrls = const [],
    this.isFavorite = false,
  });

  final String googlePlaceId;
  final String name;
  final String? address;
  final String? category;
  final double latitude;
  final double longitude;
  final double? rating;
  final int? userRatingCount;
  final int? priceLevel;
  final bool? openNow;
  final List<String> openingHours;
  final String? phone;
  final String? website;
  final String? googleMapsUri;
  final List<String> photoUrls;
  final bool isFavorite;

  PlaceCard toCard({int? distanceM}) => PlaceCard(
        googlePlaceId: googlePlaceId,
        name: name,
        address: address,
        category: category,
        latitude: latitude,
        longitude: longitude,
        rating: rating,
        userRatingCount: userRatingCount,
        priceLevel: priceLevel,
        openNow: openNow,
        distanceM: distanceM,
        photoUrl: photoUrls.isEmpty ? null : photoUrls.first,
        isFavorite: isFavorite,
      );

  factory PlaceDetail.fromJson(Map<String, dynamic> json) {
    return PlaceDetail(
      googlePlaceId: json['google_place_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String?,
      category: json['category'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingCount: json['user_rating_count'] as int?,
      priceLevel: json['price_level'] as int?,
      openNow: json['open_now'] as bool?,
      openingHours: (json['opening_hours'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      googleMapsUri: json['google_maps_uri'] as String?,
      photoUrls: (json['photo_urls'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }
}

class PlaceFilter {
  const PlaceFilter({
    this.category,
    this.radiusM = 1500,
    this.openNow,
    this.minRating,
    this.priceLevel,
    this.limit = 20,
  });

  final String? category;
  final int radiusM;
  final bool? openNow;
  final double? minRating;
  final int? priceLevel;
  final int limit;

  PlaceFilter copyWith({
    String? category,
    int? radiusM,
    bool? openNow,
    double? minRating,
    int? priceLevel,
    int? limit,
    bool clearCategory = false,
    bool clearOpenNow = false,
    bool clearMinRating = false,
    bool clearPriceLevel = false,
  }) {
    return PlaceFilter(
      category: clearCategory ? null : (category ?? this.category),
      radiusM: radiusM ?? this.radiusM,
      openNow: clearOpenNow ? null : (openNow ?? this.openNow),
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      priceLevel: clearPriceLevel ? null : (priceLevel ?? this.priceLevel),
      limit: limit ?? this.limit,
    );
  }

  Map<String, dynamic> toQuery({
    required double lat,
    required double lng,
    String? query,
    String? pageToken,
  }) {
    return {
      'lat': lat,
      'lng': lng,
      'radius_m': radiusM,
      'limit': limit,
      if (category != null && category!.isNotEmpty) 'category': category,
      if (openNow != null) 'open_now': openNow,
      if (minRating != null) 'min_rating': minRating,
      if (priceLevel != null) 'price_level': priceLevel,
      if (query != null && query.isNotEmpty) 'query': query,
      if (pageToken != null && pageToken.isNotEmpty) 'page_token': pageToken,
    };
  }
}

/// Vithey category keys matching map-service.
class PlaceCategories {
  PlaceCategories._();

  static const all = <String>[
    'restaurant',
    'cafe',
    'convenience_store',
    'supermarket',
    'pharmacy',
    'atm',
    'bank',
    'gas_station',
    'shopping_mall',
    'lodging',
    'hospital',
    'university',
    'other',
  ];

  static String label(String key) {
    return key
        .split('_')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
