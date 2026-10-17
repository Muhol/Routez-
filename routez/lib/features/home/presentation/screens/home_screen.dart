import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/map_styles.dart';
import '../../../../core/services/location_service.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  GoogleMapController? _mapController;
  LatLng _userLocation = LocationService.defaultLocation;

  CameraPosition get _initialCameraPosition => CameraPosition(
        target: _userLocation,
        zoom: 14.5,
      );

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

  void _applyMapStyle() {
    final style = _resolveIsDark() ? kMapStyleDark : kMapStyleLight;
    _mapController?.setMapStyle(style);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _applyMapStyle();
  }

  @override
  void initState() {
    super.initState();
    _fetchLocationAndCenter();
  }

  Future<void> _fetchLocationAndCenter() async {
    final latLng = await LocationService.getCurrentLatLng();
    if (!mounted) return;
    setState(() => _userLocation = latLng);
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 15),
      ),
    );
  }

  void _recenterMap() async {
    final latLng = await LocationService.getCurrentLatLng();
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 15),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.my_location, color: Colors.white, size: 18),
            SizedBox(width: AppSizes.p8),
            Text('Re-centered to current location'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            markers: const {},
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            onMapCreated: (controller) {
              _mapController = controller;
              final style = isDark ? kMapStyleDark : kMapStyleLight;
              controller.setMapStyle(style);
              // Center map on real user location once controller is ready
              _fetchLocationAndCenter();
            },
          ),

          // ── Top Search Bar ─────────────────────────────────────────────────
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
                          Icon(Icons.search, color: isDark ? Colors.white : AppColors.primary),
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
            initialChildSize: 0.22,
            minChildSize: 0.12,
            maxChildSize: 0.5,
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
                    // Drag handle
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

                    // Nearby Stages section
                    Text(
                      'Nearby Stages',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSizes.p12),
                    Row(
                      children: [
                        Icon(
                          Icons.location_searching,
                          size: 32,
                          color: AppColors.textSecondaryLight.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: AppSizes.p12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No nearby stages found',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Tap the search bar to find routes manually.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryLight.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: AppSizes.p32),

                    // Suggested Routes section
                    Text(
                      'Suggested Routes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSizes.p12),
                    Row(
                      children: [
                        Icon(
                          Icons.route_outlined,
                          size: 32,
                          color: AppColors.textSecondaryLight.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: AppSizes.p12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No suggestions yet',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Search for a route to get personalised suggestions.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryLight.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 100), // padding for bottom nav
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
