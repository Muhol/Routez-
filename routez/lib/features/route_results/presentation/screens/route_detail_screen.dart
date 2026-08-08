import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/map_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class RouteDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? routeData;

  const RouteDetailScreen({super.key, this.routeData});

  @override
  ConsumerState<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends ConsumerState<RouteDetailScreen> {

  // Representative route waypoints for the preview map
  static const LatLng _startStage = LatLng(-1.3155, 36.8901);   // Pipeline Stage
  static const LatLng _midStage = LatLng(-1.3018, 36.8652);     // Mid-route waypoint
  static const LatLng _kencomStage = LatLng(-1.2864, 36.8252);  // Kencom
  static const LatLng _westlandsStage = LatLng(-1.2642, 36.8058); // Westlands

  static const CameraPosition _routeOverviewCamera = CameraPosition(
    target: LatLng(-1.2900, 36.8480),
    zoom: 12.0,
  );

  Set<Marker> _getRouteMarkers() {
    return {
      const Marker(
        markerId: MarkerId('route_start'),
        position: _startStage,
        infoWindow: InfoWindow(title: 'Pipeline Stage', snippet: 'Board here'),
      ),
      Marker(
        markerId: const MarkerId('route_end'),
        position: _westlandsStage,
        infoWindow: const InfoWindow(title: 'Westlands Stage', snippet: 'Alight here'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
  }

  Set<Polyline> _getRoutePolylines() {
    return {
      const Polyline(
        polylineId: PolylineId('route_preview_path'),
        points: [
          _startStage,
          _midStage,
          _kencomStage,
          _westlandsStage,
        ],
        color: AppColors.accent,
        width: 5,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final routeNumber = widget.routeData?['routeNumber'] ?? '23';
    final estimatedTime = widget.routeData?['estimatedTime'] ?? '45 mins';
    final fare = widget.routeData?['fare'] ?? 'KES 60';
    final walkMinutes = widget.routeData?['walkMinutes'] ?? 5;
    final transitMinutes = widget.routeData?['transitMinutes'] ?? 40;

    final themeMode = ref.watch(themeModeProvider);
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && platformBrightness == Brightness.dark);

    return Scaffold(
      appBar: AppBar(
        title: Text('Route $routeNumber Details'),
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
                            'Route $routeNumber',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          fare,
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
                          'Total Time: $estimatedTime',
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
                        const Icon(Icons.directions_walk, color: Colors.white70, size: 20),
                        const SizedBox(width: AppSizes.p8),
                        Text(
                          '$walkMinutes min walk  •  $transitMinutes min Matatu',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.p20),

              // --- Interactive Map Preview ---
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                child: Container(
                  height: 210,
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
                      // Google Map
                      GoogleMap(
                        initialCameraPosition: _routeOverviewCamera,
                        markers: _getRouteMarkers(),
                        polylines: _getRoutePolylines(),
                        myLocationEnabled: false,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        zoomGesturesEnabled: false,
                        scrollGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                        mapType: MapType.normal,
                        style: isDark ? kMapStyleDark : kMapStyleLight,
                      ),
                      // Overlay: Route label badge
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.p10,
                            vertical: AppSizes.p4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.route, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'Route $routeNumber Preview',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Fullscreen button overlay
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: Material(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                          elevation: 2,
                          child: InkWell(
                            onTap: () => context.push('/active-trip'),
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(Icons.fullscreen, size: 22),
                            ),
                          ),
                        ),
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

              // Segment 1: Walk to Stage
              _buildTimelineStep(
                context,
                icon: Icons.directions_walk,
                iconColor: AppColors.primary,
                title: 'Walk to Stage',
                subtitle: 'Pipeline Stage (5 mins walk)',
                description: 'Head North towards Outering Road, cross safely at the pedestrian walkway.',
                isFirst: true,
              ),

              // Segment 2: Board Matatu
              _buildTimelineStep(
                context,
                icon: Icons.directions_bus,
                iconColor: AppColors.accent,
                title: 'Board Matatu $routeNumber',
                subtitle: 'Pipeline Stage → Westlands Stage ($transitMinutes mins)',
                description: 'Board Matatu $routeNumber. Expected fare: $fare. Prepare cash or M-Pesa.',
              ),

              // Segment 3: Alight
              _buildTimelineStep(
                context,
                icon: Icons.location_on,
                iconColor: AppColors.error,
                title: 'Alight at Destination Stage',
                subtitle: 'Westlands Stage',
                description: 'Alight near Westlands Roundabout. Walk 2 mins to final destination.',
                isLast: true,
              ),

              const SizedBox(height: AppSizes.p16),

              // Stage Tips Card
              Container(
                padding: const EdgeInsets.all(AppSizes.p16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: AppColors.warning),
                    SizedBox(width: AppSizes.p12),
                    Expanded(
                      child: Text(
                        'Matatus operate every 3-5 mins from Pipeline Stage. Confirm destination sign on windshield before boarding.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
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

  Widget _buildTimelineStep(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String description,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.p10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
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
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondaryLight,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppSizes.p4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
