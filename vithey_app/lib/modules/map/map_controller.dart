import 'dart:async';
import 'dart:math' as math;

import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/widgets/vithey_icon_button.dart';
import 'package:aub_connect_app/data/fixtures/place_fixtures.dart';
import 'package:aub_connect_app/data/models/place_models.dart';
import 'package:aub_connect_app/data/repositories/place_repository.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/vithey_card.dart';
import 'package:aub_connect_app/core/widgets/vithey_filter_chips.dart';
import 'package:aub_connect_app/core/widgets/vithey_switch.dart';
import 'package:aub_connect_app/core/widgets/vithey_text_link.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class MapController extends GetxController {
  MapController({PlaceRepository? repository})
      : _repository = repository ?? Get.find<PlaceRepository>();

  final PlaceRepository _repository;

  final searchQuery = ''.obs;
  final suggestions = <PlaceAutocompleteSuggestion>[].obs;
  final places = <PlaceCard>[].obs;
  final markers = <Marker>{}.obs;
  final isSearching = false.obs;
  final isLoadingPlaces = false.obs;
  final isLocationGranted = false.obs;
  final isFollowingGps = true.obs;
  final isDroppingPin = false.obs;
  final showSearchThisArea = false.obs;
  final errorMessage = ''.obs;
  final selectedPlace = Rxn<PlaceCard>();
  final droppedPin = Rxn<LatLng>();
  final routeDistanceM = 0.0.obs;
  final polylines = <Polyline>{}.obs;
  final filter = const PlaceFilter(category: 'cafe').obs;

  final gpsLatLng = Rxn<LatLng>();
  final searchCenter = LatLng(
    PlaceFixtures.defaultLat,
    PlaceFixtures.defaultLng,
  ).obs;

  final textController = TextEditingController();
  GoogleMapController? mapController;
  Timer? _debounce;
  LatLng? _pendingLongPress;
  Marker? _searchFromHereMarker;
  bool _locating = false;
  LatLng _cameraTarget = const LatLng(
    PlaceFixtures.defaultLat,
    PlaceFixtures.defaultLng,
  );
  final List<PlaceCard> _localPlaces = [];

  static const _searchFromHereId = MarkerId('search_from_here');
  static const _droppedPinId = MarkerId('dropped_pin');
  static const _routeId = PolylineId('route_to_pin');

  @override
  void onInit() {
    super.onInit();
    FocusManager.instance.primaryFocus?.unfocus();
    final args = Get.arguments;
    if (args is String && args.trim().isNotEmpty) {
      textController.text = args.trim();
      searchQuery.value = args.trim();
    }
    _checkLocationPermission();
  }

  @override
  void onClose() {
    textController.dispose();
    _debounce?.cancel();
    mapController?.dispose();
    mapController = null;
    super.onClose();
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      isLocationGranted.value = true;
      await goToCurrentLocation(runNearby: true);
    } else {
      isLocationGranted.value = false;
      await loadNearby();
    }
  }

  Future<void> onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    final gps = gpsLatLng.value;
    if (gps != null) {
      await mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(gps, 15),
      );
    }
    if (_locating) {
      if (places.isNotEmpty) _rebuildMarkers();
      return;
    }
    if (isLocationGranted.value && gps == null) {
      await goToCurrentLocation(runNearby: places.isEmpty);
    } else if (places.isEmpty) {
      await loadNearby();
    } else {
      _rebuildMarkers();
    }
  }

  Future<void> goToCurrentLocation({bool runNearby = true}) async {
    if (_locating) return;
    _locating = true;
    try {
      final position = await _readDevicePosition();
      if (position == null) {
        Get.snackbar(
          AppStrings.appName,
          'Could not get current location',
          snackPosition: SnackPosition.BOTTOM,
        );
        if (runNearby && places.isEmpty) await loadNearby();
        return;
      }
      final latLng = LatLng(position.latitude, position.longitude);
      gpsLatLng.value = latLng;
      searchCenter.value = latLng;
      isFollowingGps.value = true;
      showSearchThisArea.value = false;
      await mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 15),
      );
      if (runNearby) await loadNearby();
    } catch (_) {
      Get.snackbar(
        AppStrings.appName,
        'Could not get current location',
        snackPosition: SnackPosition.BOTTOM,
      );
      if (runNearby && places.isEmpty) await loadNearby();
    } finally {
      _locating = false;
    }
  }

  Future<Position?> _readDevicePosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
    } on TimeoutException {
      return Geolocator.getLastKnownPosition();
    } catch (_) {
      return Geolocator.getLastKnownPosition();
    }
  }

  Future<void> onMyLocationTap() async {
    final status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      final next = await Permission.locationWhenInUse.request();
      if (!next.isGranted) {
        Get.snackbar(
          AppStrings.appName,
          'Location permission needed. Open settings to enable.',
          snackPosition: SnackPosition.BOTTOM,
          // GetX types SnackbarController.mainButton as TextButton?;
          // VitheyTextLink extends TextButton so it satisfies the type.
          mainButton: VitheyTextLink(
            label: 'Settings',
            onPressed: openAppSettings,
          ),
        );
        return;
      }
      isLocationGranted.value = true;
    }
    await goToCurrentLocation(runNearby: true);
  }

  Future<void> onMyLocationLongPress() async {
    await goToCurrentLocation(runNearby: true);
    Get.snackbar(
      AppStrings.appName,
      'Back to my location',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  void onCameraMove(CameraPosition position) {
    _cameraTarget = position.target;
    if (isDroppingPin.value || !isFollowingGps.value) return;
    final center = searchCenter.value;
    final moved = Geolocator.distanceBetween(
          center.latitude,
          center.longitude,
          position.target.latitude,
          position.target.longitude,
        ) >
        80;
    if (moved) {
      isFollowingGps.value = false;
      showSearchThisArea.value = true;
    }
  }

  void onCameraIdle() {
    // no-op; Search this area is explicit
  }

  Future<void> searchThisArea() async {
    if (mapController == null) return;
    final bounds = await mapController!.getVisibleRegion();
    final lat =
        (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
    final lng =
        (bounds.northeast.longitude + bounds.southwest.longitude) / 2;
    await setSearchCenter(LatLng(lat, lng), fromGps: false);
  }

  Future<void> setSearchCenter(
    LatLng center, {
    required bool fromGps,
    String? label,
  }) async {
    searchCenter.value = center;
    isFollowingGps.value = fromGps;
    showSearchThisArea.value = false;
    if (!fromGps) {
      _searchFromHereMarker = Marker(
        markerId: _searchFromHereId,
        position: center,
        infoWindow: InfoWindow(title: label ?? 'Search from here'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
    } else {
      _searchFromHereMarker = null;
    }
    await mapController?.animateCamera(CameraUpdate.newLatLngZoom(center, 15));
    await loadNearby();
  }

  Future<void> onMapLongPress(LatLng position) async {
    if (isDroppingPin.value) return;
    _pendingLongPress = position;
    final confirm = await Get.bottomSheet<bool>(
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Search around here?',
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Set this pin as your search center and find nearby places.',
              ),
              const SizedBox(height: 16),
              CustomButton(
                label: 'Search around here',
                onPressed: () => Get.back(result: true),
              ),
              CustomButton(
                label: 'Cancel',
                onPressed: () => Get.back(result: false),
                variant: CustomButtonVariant.ghost,
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Get.theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(VitheyRadii.sheet)),
      ),
    );
    if (confirm == true && _pendingLongPress != null) {
      await setSearchCenter(_pendingLongPress!, fromGps: false);
    }
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      suggestions.clear();
      errorMessage.value = '';
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      await _runAutocomplete(value.trim());
    });
  }

  Future<void> onSearchSubmitted(String value) async {
    final q = value.trim();
    if (q.length < 2) return;
    suggestions.clear();
    await loadSearch(q);
  }

  void clearSearch() {
    textController.clear();
    searchQuery.value = '';
    suggestions.clear();
    errorMessage.value = '';
  }

  Future<void> _runAutocomplete(String input) async {
    isSearching.value = true;
    errorMessage.value = '';
    try {
      final center = searchCenter.value;
      suggestions.value = await _repository.autocomplete(
        input: input,
        lat: center.latitude,
        lng: center.longitude,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      suggestions.clear();
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> selectSuggestion(PlaceAutocompleteSuggestion suggestion) async {
    suggestions.clear();
    textController.text = suggestion.primaryText;
    searchQuery.value = suggestion.primaryText;

    double? lat = suggestion.latitude;
    double? lng = suggestion.longitude;
    if (lat == null || lng == null) {
      try {
        final detail = await _repository.detail(suggestion.googlePlaceId);
        lat = detail.latitude;
        lng = detail.longitude;
      } catch (_) {
        // fall through to text search
      }
    }

    if (lat != null && lng != null) {
      await setSearchCenter(
        LatLng(lat, lng),
        fromGps: false,
        label: suggestion.primaryText,
      );
    } else {
      await loadSearch(suggestion.primaryText);
    }
  }

  Future<void> loadNearby() async {
    isLoadingPlaces.value = true;
    errorMessage.value = '';
    try {
      final center = searchCenter.value;
      final result = await _repository.nearby(
        lat: center.latitude,
        lng: center.longitude,
        filter: filter.value,
      );
      places.assignAll(result.places);
      _mergeLocalPlaces();
      _rebuildMarkers();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingPlaces.value = false;
    }
  }

  Future<void> loadSearch(String query) async {
    isLoadingPlaces.value = true;
    errorMessage.value = '';
    try {
      final center = searchCenter.value;
      final result = await _repository.search(
        query: query,
        lat: center.latitude,
        lng: center.longitude,
        filter: filter.value,
      );
      places.assignAll(result.places);
      _mergeLocalPlaces();
      _rebuildMarkers();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingPlaces.value = false;
    }
  }

  void _mergeLocalPlaces() {
    for (final local in _localPlaces.reversed) {
      final exists = places.any((p) => p.googlePlaceId == local.googlePlaceId);
      if (!exists) places.insert(0, local);
    }
  }

  void updateFilter(PlaceFilter next) {
    filter.value = next;
    final q = searchQuery.value.trim();
    if (q.length >= 2) {
      loadSearch(q);
    } else {
      loadNearby();
    }
  }

  void openFilterModal() {
    final current = filter.value;
    final category = (current.category ?? '').obs;
    final radius = current.radiusM.toDouble().obs;
    final openNow = (current.openNow ?? false).obs;
    final minRating = (current.minRating ?? 0.0).obs;

    Get.bottomSheet(
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Filters',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                VitheyFilterChips(
                  items: [
                    const VitheyFilterChipItem(id: '', label: 'All'),
                    ...PlaceCategories.all.map(
                      (c) => VitheyFilterChipItem(
                        id: c,
                        label: PlaceCategories.label(c),
                        selected: category.value == c,
                      ),
                    ),
                  ],
                  onSelected: (id) => category.value = id,
                ),
                const SizedBox(height: 12),
                Text('Radius: ${radius.value.round()} m'),
                Slider(
                  value: radius.value,
                  min: 500,
                  max: 5000,
                  divisions: 9,
                  activeColor: AppColors.primary,
                  onChanged: (v) => radius.value = v,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Expanded(child: Text('Open now')),
                      VitheySwitch(
                        value: openNow.value,
                        onChanged: (v) => openNow.value = v,
                      ),
                    ],
                  ),
                ),
                Text('Min rating: ${minRating.value.toStringAsFixed(1)}'),
                Slider(
                  value: minRating.value,
                  min: 0,
                  max: 5,
                  divisions: 10,
                  activeColor: AppColors.primary,
                  onChanged: (v) => minRating.value = v,
                ),
                const SizedBox(height: 8),
                CustomButton(
                  label: 'Apply',
                  onPressed: () {
                    updateFilter(
                      PlaceFilter(
                        category:
                            category.value.isEmpty ? null : category.value,
                        radiusM: radius.value.round(),
                        openNow: openNow.value ? true : null,
                        minRating:
                            minRating.value <= 0 ? null : minRating.value,
                      ),
                    );
                    Get.back();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Get.theme.colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(VitheyRadii.sheet)),
      ),
    );
  }

  void _rebuildMarkers() {
    final next = <Marker>{};
    if (_searchFromHereMarker != null) {
      next.add(_searchFromHereMarker!);
    }
    final pin = droppedPin.value;
    if (pin != null && !isDroppingPin.value) {
      next.add(
        Marker(
          markerId: _droppedPinId,
          position: pin,
          infoWindow: const InfoWindow(title: 'Dropped pin'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
    for (final place in places) {
      next.add(
        Marker(
          markerId: MarkerId(place.googlePlaceId),
          position: LatLng(place.latitude, place.longitude),
          infoWindow: InfoWindow(
            title: place.name,
            snippet: place.address,
          ),
          onTap: () => openPlaceSheet(place),
        ),
      );
    }
    markers.assignAll(next);
  }

  Future<void> openPlaceSheet(PlaceCard place) async {
    selectedPlace.value = place;
    PlaceCard current = place;
    await Get.bottomSheet(
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return VitheyCard(
                borderRadius: VitheyRadii.sheet,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  Text(
                    current.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (current.address != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      current.address!,
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      if (current.rating != null)
                        Text('★ ${current.rating!.toStringAsFixed(1)}'),
                      if (current.distanceM != null)
                        Text('${current.distanceM} m'),
                      if (current.category != null)
                        Text(PlaceCategories.label(current.category!)),
                      if (current.openNow == true)
                        const Text(
                          'Open now',
                          style: TextStyle(color: AppColors.primary),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _SheetAction(
                          label: current.isFavorite ? 'Saved' : 'Favorite',
                          icon: current.isFavorite
                              ? LucideIcons.heart
                              : LucideIcons.heart,
                          onPressed: () async {
                            final updated =
                                await _repository.toggleFavorite(current);
                            current = updated;
                            selectedPlace.value = updated;
                            final idx = places.indexWhere(
                              (p) =>
                                  p.googlePlaceId == updated.googlePlaceId,
                            );
                            if (idx >= 0) places[idx] = updated;
                            setModalState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SheetAction(
                          label: 'Directions',
                          icon: LucideIcons.navigation,
                          onPressed: () => openDirections(current),
                        ),
                      ),
                    ],
                  ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      backgroundColor: Get.theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  Future<void> openDirections(PlaceCard place) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${place.latitude},${place.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> startDropPin() async {
    isDroppingPin.value = true;
    showSearchThisArea.value = false;
    isFollowingGps.value = false;
    polylines.clear();
    _rebuildMarkers();
  }

  void cancelDropPin() {
    isDroppingPin.value = false;
    _rebuildMarkers();
    _rebuildRouteLine();
  }

  Future<void> setDroppedLocation() async {
    final dest = _cameraTarget;
    droppedPin.value = dest;
    isDroppingPin.value = false;
    _rebuildMarkers();
    await _rebuildRouteLine();
    final origin = gpsLatLng.value ?? searchCenter.value;
    await _fitToRoute(origin, dest);
  }

  void clearDroppedPin() {
    droppedPin.value = null;
    routeDistanceM.value = 0;
    polylines.clear();
    _rebuildMarkers();
  }

  Future<void> directionsToDroppedPin() async {
    final dest = droppedPin.value;
    if (dest == null) return;
    await _rebuildRouteLine();
    final origin = gpsLatLng.value ?? searchCenter.value;
    await _fitToRoute(origin, dest);
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${origin.latitude},${origin.longitude}'
      '&destination=${dest.latitude},${dest.longitude}'
      '&travelmode=driving',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String get routeDistanceLabel {
    final meters = routeDistanceM.value;
    if (meters <= 0) return '';
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  Future<void> _rebuildRouteLine() async {
    polylines.clear();
    final dest = droppedPin.value;
    if (dest == null) return;
    final origin = gpsLatLng.value ?? searchCenter.value;
    routeDistanceM.value = Geolocator.distanceBetween(
      origin.latitude,
      origin.longitude,
      dest.latitude,
      dest.longitude,
    );
    polylines.add(
      Polyline(
        polylineId: _routeId,
        points: [origin, dest],
        color: AppColors.primary,
        width: 5,
        geodesic: true,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    );
  }

  Future<void> _fitToRoute(LatLng origin, LatLng dest) async {
    final distance = Geolocator.distanceBetween(
      origin.latitude,
      origin.longitude,
      dest.latitude,
      dest.longitude,
    );
    if (distance < 25) {
      await mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(dest, 17),
      );
      return;
    }
    final bounds = LatLngBounds(
      southwest: LatLng(
        math.min(origin.latitude, dest.latitude),
        math.min(origin.longitude, dest.longitude),
      ),
      northeast: LatLng(
        math.max(origin.latitude, dest.latitude),
        math.max(origin.longitude, dest.longitude),
      ),
    );
    try {
      await mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 80),
      );
    } catch (_) {
      await mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(dest, 15),
      );
    }
  }

  void goBack() {
    if (isDroppingPin.value) {
      cancelDropPin();
      return;
    }
    Get.back();
  }
}

/// Round circular icon action with a label, used in map bottom sheets.
class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      borderRadius: BorderRadius.circular(VitheyRadii.card),
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            VitheyIconButton(
              icon: icon,
              onTap: onPressed,
              circle: true,
              tooltip: label,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: context.text.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.heading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
