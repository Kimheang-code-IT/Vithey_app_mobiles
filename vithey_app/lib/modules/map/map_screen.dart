import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/vithey_card.dart';
import 'package:aub_connect_app/core/widgets/vithey_icon_button.dart';
import 'package:aub_connect_app/core/widgets/vithey_search_pill.dart';
import 'package:aub_connect_app/data/fixtures/place_fixtures.dart';
import 'package:aub_connect_app/data/models/place_models.dart';
import 'package:aub_connect_app/modules/map/map_controller.dart';
import 'package:aub_connect_app/modules/map/map_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class MapScreen extends GetView<MapController> {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final colors = context.appColors;

    return Scaffold(
      body: Stack(
        children: [
          Obx(
            () {
              final dropping = controller.isDroppingPin.value;
              final hasPin = controller.droppedPin.value != null;
              final extraBottom = dropping
                  ? 96.0
                  : hasPin
                      ? 108.0
                      : 0.0;
              return GoogleMap(
                key: const ValueKey('vithey-google-map'),
                onMapCreated: controller.onMapCreated,
                style: Theme.of(context).brightness == Brightness.dark
                    ? darkMapStyle
                    : null,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(
                    PlaceFixtures.defaultLat,
                    PlaceFixtures.defaultLng,
                  ),
                  zoom: 14,
                ),
                myLocationEnabled: controller.isLocationGranted.value,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: false,
                mapToolbarEnabled: false,
                markers: Set<Marker>.of(controller.markers),
                polylines: Set<Polyline>.of(controller.polylines),
                onCameraMove: controller.onCameraMove,
                onCameraIdle: controller.onCameraIdle,
                onLongPress: controller.onMapLongPress,
                padding: EdgeInsets.only(
                  top: 72,
                  bottom: bottomPadding + 88 + extraBottom,
                ),
              );
            },
          ),
          Obx(() {
            if (!controller.isDroppingPin.value) {
              return const SizedBox.shrink();
            }
            return Positioned.fill(
              child: IgnorePointer(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 72,
                    bottom: bottomPadding + 88 + 96,
                  ),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 36),
                      child: VitheyIcon(
                        LucideIcons.mapPin,
                        size: 48,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      VitheyIconButton(
                        icon: LucideIcons.arrowLeft,
                        onTap: controller.goBack,
                        circle: true,
                        tooltip: 'Back',
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: controller.textController,
                          builder: (context, value, _) => Obx(
                            () => VitheySearchPill(
                              controller: controller.textController,
                              hintText: 'Search shops nearby',
                              compact: true,
                              onChanged: controller.onSearchChanged,
                              onSubmitted: controller.onSearchSubmitted,
                              onClear: controller.clearSearch,
                              trailing: [
                                if (controller.isSearching.value)
                                  const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                IconButton(
                                  icon: const VitheyIcon(
                                    LucideIcons.slidersHorizontal,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  onPressed: controller.openFilterModal,
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Obx(() {
                    if (controller.errorMessage.value.isNotEmpty) {
                      return Container(
                        margin: const EdgeInsets.only(top: 8, left: 48),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius:
                              BorderRadius.circular(VitheyRadii.card),
                        ),
                        child: Text(
                          controller.errorMessage.value,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      );
                    }
                    if (controller.suggestions.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      margin: const EdgeInsets.only(top: 8, left: 48),
                      constraints: const BoxConstraints(maxHeight: 220),
                      decoration: BoxDecoration(
                        color: colors.cardSurface,
                        borderRadius: BorderRadius.circular(VitheyRadii.card),
                        boxShadow: [
                          BoxShadow(
                            color: colors.subtleShadow,
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: controller.suggestions.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: colors.border,
                        ),
                        itemBuilder: (context, index) {
                          final s = controller.suggestions[index];
                          return ListTile(
                            dense: true,
                            leading: const VitheyIcon(
                              LucideIcons.mapPin,
                              color: AppColors.primary,
                            ),
                            title: Text(s.primaryText),
                            subtitle: s.secondaryText == null
                                ? null
                                : Text(s.secondaryText!),
                            onTap: () => controller.selectSuggestion(s),
                          );
                        },
                      ),
                    );
                  }),
                  Obx(() {
                    final category = controller.filter.value.category;
                    if (category == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8, left: 48),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _ActiveFilterPill(
                          label: PlaceCategories.label(category),
                          onDeleted: () => controller.updateFilter(
                            controller.filter.value.copyWith(
                              clearCategory: true,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            ),
          ),
          Obx(() {
            if (!controller.showSearchThisArea.value ||
                controller.isDroppingPin.value) {
              return const SizedBox.shrink();
            }
            return Positioned(
              top: MediaQuery.of(context).padding.top + 72,
              left: 0,
              right: 0,
              child: Center(
                child: Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(VitheyRadii.pill),
                  color: colors.cardSurface,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(VitheyRadii.pill),
                    onTap: controller.searchThisArea,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Text(
                        'Search this area',
                        style: context.text.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          Obx(() {
            if (!controller.isLoadingPlaces.value) {
              return const SizedBox.shrink();
            }
            return const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                minHeight: 2,
                color: AppColors.primary,
              ),
            );
          }),
          Obx(() {
            final dropping = controller.isDroppingPin.value;
            final hasPin = controller.droppedPin.value != null && !dropping;
            final extraBottom = dropping
                ? 96.0
                : hasPin
                    ? 108.0
                    : 0.0;
            return Positioned(
              right: 16,
              bottom: bottomPadding + 88 + extraBottom,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!dropping)
                    _MapCircleButton(
                      icon: LucideIcons.mapPinPlus,
                      tooltip: 'Drop pin',
                      onPressed: controller.startDropPin,
                    ),
                  if (!dropping) const SizedBox(height: 10),
                  GestureDetector(
                    onLongPress: controller.onMyLocationLongPress,
                    child: _MapCircleButton(
                      icon: controller.isFollowingGps.value
                          ? LucideIcons.locate
                          : LucideIcons.locateFixed,
                      tooltip: 'My location',
                      solid: true,
                      onPressed: controller.onMyLocationTap,
                    ),
                  ),
                ],
              ),
            );
          }),
          Obx(() {
            if (!controller.isDroppingPin.value) {
              return const SizedBox.shrink();
            }
            return Positioned(
              left: 12,
              right: 12,
              bottom: bottomPadding + 16,
              child: _DropPinBar(controller: controller),
            );
          }),
          Obx(() {
            if (controller.isDroppingPin.value ||
                controller.droppedPin.value == null) {
              return const SizedBox.shrink();
            }
            return Positioned(
              left: 12,
              right: 12,
              bottom: bottomPadding + 16,
              child: _DroppedPinCard(controller: controller),
            );
          }),
        ],
      ),
    );
  }
}

/// Active category filter rendered as a Vithey pill (no Material Chip).
class _ActiveFilterPill extends StatelessWidget {
  const _ActiveFilterPill({required this.label, required this.onDeleted});

  final String label;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(VitheyRadii.pill),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onDeleted,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: context.text.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 6),
              const VitheyIcon(LucideIcons.x, size: 16, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact bar while dragging the map to drop a pin.
class _DropPinBar extends StatelessWidget {
  const _DropPinBar({required this.controller});

  final MapController controller;

  @override
  Widget build(BuildContext context) {
    return VitheyCard(
      borderRadius: VitheyRadii.sheet,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Drag the map to set the pin',
            style: context.text.bodySmall,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Cancel',
                  variant: CustomButtonVariant.ghost,
                  onPressed: controller.cancelDropPin,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomButton(
                  label: 'Set location',
                  icon: LucideIcons.mapPin,
                  onPressed: controller.setDroppedLocation,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Google Maps-style dropped pin card with a route line + directions.
class _DroppedPinCard extends StatelessWidget {
  const _DroppedPinCard({required this.controller});

  final MapController controller;

  @override
  Widget build(BuildContext context) {
    return VitheyCard(
      borderRadius: VitheyRadii.sheet,
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      child: Row(
        children: [
          const VitheyIcon(
            LucideIcons.mapPin,
            size: 22,
            color: AppColors.error,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Dropped pin',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Obx(() {
                  final label = controller.routeDistanceLabel;
                  if (label.isEmpty) return const SizedBox.shrink();
                  return Text(
                    '$label from you',
                    style: context.text.labelMedium,
                  );
                }),
              ],
            ),
          ),
          Flexible(
            child: CustomButton(
              label: 'Directions',
              icon: LucideIcons.navigation,
              onPressed: controller.directionsToDroppedPin,
            ),
          ),
          VitheyIconButton(
            icon: LucideIcons.x,
            tooltip: 'Clear pin',
            onTap: controller.clearDroppedPin,
            circle: true,
          ),
        ],
      ),
    );
  }
}

/// 48px circular map chrome (locate / add place) — no floating FAB squares.
class _MapCircleButton extends StatelessWidget {
  const _MapCircleButton({
    required this.icon,
    required this.onPressed,
    this.solid = false,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool solid;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final background = solid ? AppColors.primary : context.appColors.cardSurface;
    final foreground =
        solid ? context.scheme.onPrimary : AppColors.primary;

    final button = Material(
      color: background,
      shape: const CircleBorder(),
      elevation: solid ? 0 : 2,
      child: SizedBox(
        width: VitheyRadii.iconButton,
        height: VitheyRadii.iconButton,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: VitheyIcon(icon, size: 22, color: foreground),
        ),
      ),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}
