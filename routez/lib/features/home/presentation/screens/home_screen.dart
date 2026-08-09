import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/map_styles.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  GoogleMapController? _mapController;

  static const LatLng _userLocation = LatLng(-1.3148, 36.8912); // Nairobi Pipeline

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: _userLocation,
    zoom: 14.5,
  );

  final List<Map<String, dynamic>> _stages = [
    {
      'name': 'Pipeline Stage',
      'distance': '2 mins walk',
      'routes': 'Route 23, 110 Express',
      'latLng': const LatLng(-1.3155, 36.8901),
      'offset': const Offset(-60, -80),
      'fare': 'KES 60',
    },
    {
      'name': 'Taj Mall Stage',
      'distance': '5 mins walk',
      'routes': 'Route 46, 33',
      'latLng': const LatLng(-1.3180, 36.8935),
      'offset': const Offset(80, -120),
      'fare': 'KES 50',
    },
    {
      'name': 'Kencom Stage',
      'distance': '12 mins away',
      'routes': 'Route 100, 102',
      'latLng': const LatLng(-1.2864, 36.8252),
      'offset': const Offset(-100, 100),
      'fare': 'KES 80',
    },
    {
      'name': 'Westlands Stage',
      'distance': '20 mins away',
      'routes': 'Route 23, 105',
      'latLng': const LatLng(-1.2642, 36.8058),
      'offset': const Offset(120, 80),
      'fare': 'KES 70',
    },
  ];

  /// Determines if we should use a dark map style given the current theme
  /// mode setting and platform brightness.
  bool _resolveIsDark() {
    final themeMode = ref.read(themeModeProvider);
    switch (themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
  }

  /// Applies the correct map style to the live controller whenever the
  /// theme changes (called from `didChangeDependencies` and `onMapCreated`).
  void _applyMapStyle() {
    final style = _resolveIsDark() ? kMapStyleDark : kMapStyleLight;
    _mapController?.setMapStyle(style);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-apply the map style when brightness or theme mode changes.
    _applyMapStyle();
  }

  Set<Marker> _getGoogleMapMarkers() {
    return _stages.map((stage) {
      return Marker(
        markerId: MarkerId(stage['name']),
        position: stage['latLng'] as LatLng,
        infoWindow: InfoWindow(
          title: stage['name'],
          snippet: '${stage['routes']} • ${stage['distance']}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        onTap: () {
          _showStageDetails(stage);
        },
      );
    }).toSet();
  }

  void _recenterMap() {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(_initialCameraPosition),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.my_location, color: Colors.white, size: 18),
            SizedBox(width: AppSizes.p8),
            Text('Re-centered to current location (Nairobi, Pipeline)'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showStageDetails(Map<String, dynamic> stage) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
      ),
      builder: (context) {
        return Padding(
          // padding: const EdgeInsets.all(AppSizes.p24),
          padding: EdgeInsets.only(top: AppSizes.p24, bottom: AppSizes.p24+80, left: AppSizes.p24, right: AppSizes.p24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSizes.p10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.directions_bus, color: AppColors.primary),
                      ),
                      const SizedBox(width: AppSizes.p12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stage['name'],
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            stage['distance'],
                            style: const TextStyle(color: AppColors.textSecondaryLight),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.p16),
              const Divider(),
              const SizedBox(height: AppSizes.p12),
              Row(
                children: [
                  const Icon(Icons.alt_route, size: 18, color: AppColors.accent),
                  const SizedBox(width: AppSizes.p8),
                  Text(
                    'Active Routes: ${stage['routes']}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.p8),
              Row(
                children: [
                  const Icon(Icons.payments_outlined, size: 18, color: AppColors.primary),
                  const SizedBox(width: AppSizes.p8),
                  Text(
                    'Avg. Fare: ${stage['fare']}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.p24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/route-results');
                  },
                  icon: const Icon(Icons.search),
                  label: const Text('View Routes from this Stage'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.p14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch themeModeProvider so the widget rebuilds when user changes the theme.
    final themeMode = ref.watch(themeModeProvider);
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && platformBrightness == Brightness.dark);

    return Scaffold(
      body: Stack(
        children: [
          // ── Google Map ──────────────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            markers: _getGoogleMapMarkers(),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            onMapCreated: (controller) {
              _mapController = controller;
              // Apply correct style as soon as the map is ready.
              final style = isDark ? kMapStyleDark : kMapStyleLight;
              controller.setMapStyle(style);
            },
          ),

          // ── Top Search Bar (Fully Rounded & Glassmorphic) ─────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: GestureDetector(
                onTap: () => context.push('/search'),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 13, sigmaY: 13),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.p20,
                        vertical: AppSizes.p14,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.glassBackgroundDark
                            : AppColors.glassBackgroundLight,
                        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                        border: Border.all(
                          color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: AppColors.primary),
                          const SizedBox(width: AppSizes.p12),
                          Text(
                            'Where are you going?',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: AppColors.textSecondaryLight),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Floating Re-centre Button ───────────────────────────────────────
          Positioned(
            right: AppSizes.p16,
            bottom: AppSizes.p200 + 20,
            child: FloatingActionButton(
              onPressed: _recenterMap,
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.primary,
              tooltip: 'Re-center Location',
              child: const Icon(Icons.my_location),
            ),
          ),

          // ── Draggable Bottom Sheet ──────────────────────────────────────────
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.15,
            maxChildSize: 0.6,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSizes.radiusLarge),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSizes.p16),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: AppSizes.p16),
                        decoration: BoxDecoration(
                          color: AppColors.dividerLight,
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        ),
                      ),
                    ),
                    Text(
                      'Nearby Stages',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSizes.p8),
                    ..._stages.take(2).map((stage) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(AppSizes.p8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.directions_bus, color: AppColors.primary),
                        ),
                        title: Text(stage['name']),
                        subtitle: Text('${stage['distance']}  •  ${stage['routes']}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showStageDetails(stage),
                      );
                    }),
                    const Divider(),
                    const SizedBox(height: AppSizes.p8),
                    Text(
                      'Suggested Routes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(AppSizes.p8),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.route, color: AppColors.accent),
                      ),
                      title: const Text('Westlands (Route 23)'),
                      subtitle: const Text('ETA: 45 mins • KES 60'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/route-results'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
