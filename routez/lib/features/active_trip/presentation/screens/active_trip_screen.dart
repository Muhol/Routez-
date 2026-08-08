import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/map_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class ActiveTripScreen extends ConsumerStatefulWidget {
  const ActiveTripScreen({super.key});

  @override
  ConsumerState<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends ConsumerState<ActiveTripScreen> {
  GoogleMapController? _mapController;
  int _currentStepIndex = 0;
  bool _isVoiceEnabled = true;

  static const LatLng _pipelineStage = LatLng(-1.3155, 36.8901);
  static const LatLng _tajMallStage = LatLng(-1.3180, 36.8935);
  static const LatLng _kencomStage = LatLng(-1.2864, 36.8252);
  static const LatLng _westlandsStage = LatLng(-1.2642, 36.8058);

  static const CameraPosition _overviewCameraPosition = CameraPosition(
    target: LatLng(-1.2900, 36.8480),
    zoom: 12.5,
  );

  final List<Map<String, dynamic>> _tripSteps = [
    {
      'title': 'Walk to Pipeline Stage',
      'subtitle': '5 mins remaining (400m)',
      'instruction': 'Head North on Outering Road walkway to Pipeline Stage.',
      'icon': Icons.directions_walk,
      'color': AppColors.primary,
      'location': _pipelineStage,
      'progress': 0.3,
    },
    {
      'title': 'Board Matatu Route 23',
      'subtitle': '40 mins in transit • Fare: KES 60',
      'instruction': 'Board Matatu 23 towards Westlands. Stay alert for your stop.',
      'icon': Icons.directions_bus,
      'color': AppColors.accent,
      'location': _kencomStage,
      'progress': 0.65,
    },
    {
      'title': 'Alight at Westlands Stage',
      'subtitle': '2 mins walk to final destination',
      'instruction': 'Prepare to alight at Westlands Stage near the flyover.',
      'icon': Icons.location_on,
      'color': AppColors.error,
      'location': _westlandsStage,
      'progress': 0.95,
    },
  ];

  Set<Marker> _getTripMarkers() {
    return {
      Marker(
        markerId: const MarkerId('start_stage'),
        position: _pipelineStage,
        infoWindow: const InfoWindow(title: 'Start: Pipeline Stage'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      Marker(
        markerId: const MarkerId('transit_stage'),
        position: _kencomStage,
        infoWindow: const InfoWindow(title: 'Transfer: Kencom Stage'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
      Marker(
        markerId: const MarkerId('end_stage'),
        position: _westlandsStage,
        infoWindow: const InfoWindow(title: 'Destination: Westlands Stage'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
  }

  Set<Polyline> _getTripPolylines() {
    return {
      const Polyline(
        polylineId: PolylineId('transit_route'),
        points: [
          _pipelineStage,
          _tajMallStage,
          _kencomStage,
          _westlandsStage,
        ],
        color: AppColors.accent,
        width: 5,
      ),
    };
  }

  void _nextStep() {
    if (_currentStepIndex < _tripSteps.length - 1) {
      setState(() {
        _currentStepIndex++;
      });
      _animateCameraToCurrentStep();
    } else {
      _showEndTripConfirmation();
    }
  }

  void _previousStep() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
      });
      _animateCameraToCurrentStep();
    }
  }

  void _animateCameraToCurrentStep() {
    final stepLocation = _tripSteps[_currentStepIndex]['location'] as LatLng;
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(stepLocation, 14.5),
    );
  }

  void _toggleVoiceNavigation() {
    setState(() {
      _isVoiceEnabled = !_isVoiceEnabled;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _isVoiceEnabled ? Icons.record_voice_over : Icons.voice_over_off,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: AppSizes.p8),
            Text(
              _isVoiceEnabled
                  ? 'Voice Assistant Enabled: Turn-by-turn guidance active'
                  : 'Voice Assistant Muted',
            ),
          ],
        ),
        backgroundColor: _isVoiceEnabled ? AppColors.success : AppColors.textSecondaryLight,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showProximityAlert() {
    final step = _tripSteps[_currentStepIndex];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          ),
          title: const Row(
            children: [
              Icon(Icons.notifications_active, color: AppColors.warning),
              SizedBox(width: AppSizes.p8),
              Text('Proximity Alert'),
            ],
          ),
          content: Text(
            'Approaching ${step['title']}! Prepare for your next action.',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (_currentStepIndex < _tripSteps.length - 1) {
                  _nextStep();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Acknowledge'),
            ),
          ],
        );
      },
    );
  }

  void _showEndTripConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          ),
          title: const Text('End Current Trip?'),
          content: const Text(
            'Are you sure you want to stop live navigation and end this trip?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('End Trip'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _tripSteps[_currentStepIndex];
    final themeMode = ref.watch(themeModeProvider);
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && platformBrightness == Brightness.dark);

    return Scaffold(
      body: Stack(
        children: [
          // Live Google Map Widget for Active Trip
          GoogleMap(
            initialCameraPosition: _overviewCameraPosition,
            markers: _getTripMarkers(),
            polylines: _getTripPolylines(),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            onMapCreated: (controller) {
              _mapController = controller;
              final style = isDark ? kMapStyleDark : kMapStyleLight;
              controller.setMapStyle(style);
            },
          ),

          // Right Floating Control Overlays (Voice Assistant Toggle & Proximity Alert)
          Positioned(
            right: AppSizes.p16,
            top: 120.0,
            child: Column(
              children: [
                // Prominent Voice Assistant Floating Button
                FloatingActionButton(
                  heroTag: 'voice_toggle_fab',
                  onPressed: _toggleVoiceNavigation,
                  backgroundColor: _isVoiceEnabled ? AppColors.accent : Theme.of(context).colorScheme.surface,
                  foregroundColor: _isVoiceEnabled ? Colors.white : AppColors.primary,
                  tooltip: _isVoiceEnabled ? 'Voice Guidance Active' : 'Muted - Tap to enable voice',
                  child: Icon(
                    _isVoiceEnabled ? Icons.record_voice_over : Icons.voice_over_off,
                  ),
                ),
                const SizedBox(height: AppSizes.p12),
                FloatingActionButton.small(
                  heroTag: 'proximity_alert_fab',
                  onPressed: _showProximityAlert,
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  tooltip: 'Test Proximity Alert',
                  child: const Icon(Icons.notifications_active),
                ),
                const SizedBox(height: AppSizes.p12),
                FloatingActionButton.small(
                  heroTag: 'recenter_trip_fab',
                  onPressed: _animateCameraToCurrentStep,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  tooltip: 'Center on Active Step',
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          ),

          // Top Navigation Status Bar Overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _showEndTripConfirmation,
                      tooltip: 'End Trip',
                    ),
                  ),
                  const SizedBox(width: AppSizes.p12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.p16,
                        vertical: AppSizes.p12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Active Navigation • To Westlands',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.white70),
                          ),
                          Text(
                            'ETA: 10:45 AM (40 mins)',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Active Navigation Wizard Card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(AppSizes.p16),
              padding: const EdgeInsets.all(AppSizes.p20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Step Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_tripSteps.length, (index) {
                      final isActive = index == _currentStepIndex;
                      final isPassed = index < _currentStepIndex;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: AppSizes.p4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : (isPassed
                                  ? AppColors.accent
                                  : AppColors.dividerLight),
                          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSizes.p16),

                  // Current Step Info Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSizes.p12),
                        decoration: BoxDecoration(
                          color: (currentStep['color'] as Color).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          currentStep['icon'] as IconData,
                          size: 30,
                          color: currentStep['color'] as Color,
                        ),
                      ),
                      const SizedBox(width: AppSizes.p16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentStep['title'] as String,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              currentStep['subtitle'] as String,
                              style: const TextStyle(
                                color: AppColors.textSecondaryLight,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p12),

                  // Step Guidance & Voice Assistant Action Button Bar
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.p12,
                            vertical: AppSizes.p10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundHighlight,
                            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                          ),
                          child: Text(
                            currentStep['instruction'] as String,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.p8),
                      // Dedicated Voice Assistance Button Chip
                      InkWell(
                        onTap: _toggleVoiceNavigation,
                        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.p12,
                            vertical: AppSizes.p10,
                          ),
                          decoration: BoxDecoration(
                            color: _isVoiceEnabled
                                ? AppColors.accent.withValues(alpha: 0.15)
                                : AppColors.dividerLight.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                            border: Border.all(
                              color: _isVoiceEnabled ? AppColors.accent : AppColors.textSecondaryLight,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isVoiceEnabled ? Icons.volume_up : Icons.volume_off,
                                size: 16,
                                color: _isVoiceEnabled ? AppColors.accent : AppColors.textSecondaryLight,
                              ),
                              const SizedBox(width: AppSizes.p4),
                              Text(
                                _isVoiceEnabled ? 'Voice ON' : 'Muted',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _isVoiceEnabled ? AppColors.accent : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p16),

                  // Step Progress Bar
                  LinearProgressIndicator(
                    value: (currentStep['progress'] as double),
                    backgroundColor: AppColors.dividerLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      currentStep['color'] as Color,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p20),

                  // Wizard Step Action Buttons (Prev / Next / End)
                  Row(
                    children: [
                      if (_currentStepIndex > 0)
                        IconButton.outlined(
                          onPressed: _previousStep,
                          icon: const Icon(Icons.arrow_back),
                          tooltip: 'Previous Step',
                        ),
                      if (_currentStepIndex > 0)
                        const SizedBox(width: AppSizes.p12),
                      Expanded(
                        child: PrimaryButton(
                          text: _currentStepIndex == _tripSteps.length - 1
                              ? 'Finish Navigation'
                              : 'Next Step',
                          onPressed: _nextStep,
                        ),
                      ),
                      const SizedBox(width: AppSizes.p12),
                      IconButton.outlined(
                        onPressed: _showEndTripConfirmation,
                        icon: const Icon(Icons.stop_circle_outlined, color: AppColors.error),
                        tooltip: 'End Trip',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
