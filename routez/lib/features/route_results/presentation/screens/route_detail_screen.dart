import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/map_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import 'package:routez/features/search/data/models/journey_leg_model.dart';
import '../../../../core/services/google_directions_service.dart';

class RouteDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? routeData;

  const RouteDetailScreen({super.key, this.routeData});

  @override
  ConsumerState<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends ConsumerState<RouteDetailScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoadingDirections = false;

  @override
  void initState() {
    super.initState();
    _loadDirectionsPreview();
  }

  Future<void> _loadDirectionsPreview() async {
    final journey = widget.routeData?['journey'] as JourneyOption?;
    if (journey == null || journey.legs.isEmpty) return;

    final stages = journey.orderedStages;
    final markers = <Marker>{};

    for (int i = 0; i < stages.length; i++) {
      final s = stages[i];
      final isFirst = i == 0;
      final isLast = i == stages.length - 1;

      markers.add(
        Marker(
          markerId: MarkerId('stage_$i'),
          position: LatLng(s.latitude, s.longitude),
          infoWindow: InfoWindow(
            title: s.name,
            snippet: isFirst ? 'Origin Stage' : (isLast ? 'Destination' : s.area),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isFirst
                ? BitmapDescriptor.hueGreen
                : (isLast ? BitmapDescriptor.hueRed : BitmapDescriptor.hueAzure),
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
      _isLoadingDirections = true;
    });

    // Fetch Google Directions API preview using origin & destination
    final originStr = '${stages.first.latitude},${stages.first.longitude}';
    final destStr = '${stages.last.latitude},${stages.last.longitude}';

    final directions = await GoogleDirectionsService.getDirections(
      origin: originStr,
      destination: destStr,
    );

    if (directions != null && directions.polylinePoints.isNotEmpty) {
      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('journey_preview_polyline'),
            points: directions.polylinePoints,
            color: AppColors.accent,
            width: 5,
          ),
        };
        _isLoadingDirections = false;
      });

      // Bounds fit
      if (_mapController != null) {
        _fitBounds(directions.polylinePoints);
      }
    } else {
      // Fallback stage straight-line connection
      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('stage_line_fallback'),
            points: stages.map((s) => LatLng(s.latitude, s.longitude)).toList(),
            color: AppColors.accent,
            width: 4,
          ),
        };
        _isLoadingDirections = false;
      });
    }
  }

  void _fitBounds(List<LatLng> points) {
    if (points.isEmpty) return;
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        40.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final journey = widget.routeData?['journey'] as JourneyOption?;
    final origin = widget.routeData?['origin'] as String? ?? 'Origin';
    final destination = widget.routeData?['destination'] as String? ?? 'Destination';

    final themeMode = ref.watch(themeModeProvider);
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && platformBrightness == Brightness.dark);

    if (journey == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Journey Details')),
        body: const Center(child: Text('No journey data available.')),
      );
    }

    final initialCamera = CameraPosition(
      target: LatLng(
        journey.orderedStages.first.latitude,
        journey.orderedStages.first.longitude,
      ),
      zoom: 12.0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${journey.matatuCountLabel.toUpperCase()} JOURNEY'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.p16,
              AppSizes.p16,
              AppSizes.p16,
              AppSizes.p80 + 20,
            ),
            children: [
              // Summary Banner Card
              Container(
                padding: const EdgeInsets.all(AppSizes.p20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.p12,
                            vertical: AppSizes.p6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                          ),
                          child: Text(
                            journey.matatuCountLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Text(
                          'From KES ${journey.totalCheapestFare}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.p16),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, color: Colors.white70, size: 20),
                        const SizedBox(width: AppSizes.p8),
                        Text(
                          'Est. Total Time: ~${journey.totalMinutes} mins',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.p8),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, color: Colors.white70, size: 20),
                        const SizedBox(width: AppSizes.p8),
                        Expanded(
                          child: Text(
                            '$origin → $destination',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.p20),

              // Interactive Map Preview
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : AppColors.dividerLight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: initialCamera,
                        markers: _markers,
                        polylines: _polylines,
                        myLocationEnabled: false,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        zoomGesturesEnabled: true,
                        scrollGesturesEnabled: true,
                        mapType: MapType.normal,
                        style: isDark ? kMapStyleDark : kMapStyleLight,
                        onMapCreated: (controller) {
                          _mapController = controller;
                          if (_polylines.isNotEmpty) {
                            _fitBounds(_polylines.first.points);
                          }
                        },
                      ),
                      if (_isLoadingDirections)
                        const Positioned(
                          top: 10,
                          right: 10,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.p24),

              // Step Timeline Header
              Text(
                'Step-by-Step Guidance',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.p16),

              // Render Timeline Steps for each leg
              ...List.generate(journey.legs.length, (index) {
                final leg = journey.legs[index];
                final isLast = index == journey.legs.length - 1;

                if (leg.isWalk) {
                  return _buildWalkStep(context, leg, isLast: isLast);
                } else {
                  return _buildMatatuStep(context, leg, isLast: isLast);
                }
              }),
            ],
          ),

          // Sticky Start Trip Bottom Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(AppSizes.p16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: PrimaryButton(
                text: 'Start Trip Now',
                onPressed: () => context.push('/active-trip'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalkStep(BuildContext context, JourneyLegModel leg, {required bool isLast}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.p10),
              decoration: const BoxDecoration(
                color: AppColors.dividerLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.directions_walk, color: AppColors.textSecondaryLight, size: 20),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 45,
                color: AppColors.dividerLight,
              ),
          ],
        ),
        const SizedBox(width: AppSizes.p16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.p20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Walk to ${leg.toStage.name}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.p4),
                Text(
                  'Distance: ${(leg.distanceMeters / 1000).toStringAsFixed(2)} km • Approx. ${leg.durationMinutes} mins',
                  style: const TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMatatuStep(BuildContext context, JourneyLegModel leg, {required bool isLast}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.p10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.directions_bus, color: AppColors.primary, size: 20),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 120,
                color: AppColors.dividerLight,
              ),
          ],
        ),
        const SizedBox(width: AppSizes.p16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.p20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Board Matatu Route ${leg.routeNumber}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${leg.fromStage.name} → ${leg.toStage.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondaryLight,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppSizes.p10),

                // Render Servicing SACCOs for this leg
                ...leg.saccoOptions.map((saccoOpt) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSizes.p8),
                    padding: const EdgeInsets.all(AppSizes.p12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                      border: Border.all(
                        color: AppColors.dividerLight.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              saccoOpt.sacco.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'KES ${saccoOpt.fareOffPeak} - ${saccoOpt.farePeak}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.p4),
                        Text(
                          '${saccoOpt.fleetType} • ~${saccoOpt.durationMins} mins',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

