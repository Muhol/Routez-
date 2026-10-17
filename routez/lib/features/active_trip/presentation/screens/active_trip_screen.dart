import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/map_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import 'package:routez/features/trip_history/data/models/trip_model.dart';
import 'package:routez/features/trip_history/presentation/providers/trip_history_provider.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/google_directions_service.dart';

class ActiveTripScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? tripData;

  const ActiveTripScreen({super.key, this.tripData});

  @override
  ConsumerState<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends ConsumerState<ActiveTripScreen> {
  GoogleMapController? _mapController;
  int _currentStepIndex = 0;
  bool _isVoiceEnabled = true;

  StreamSubscription<Position>? _positionSubscription;
  Position? _currentPosition;

  List<Map<String, dynamic>> _tripSteps = [];
  Set<Marker> _tripMarkers = {};
  Set<Polyline> _tripPolylines = {};
  CameraPosition _initialCamera = const CameraPosition(
    target: LatLng(-1.2900, 36.8480),
    zoom: 12.5,
  );

  @override
  void initState() {
    super.initState();
    _initializeTripData();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _startLocationUpdates() {
    _positionSubscription = LocationService.getPositionStream().listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
        _checkProximityToNextStep();
      }
    });
  }

  void _checkProximityToNextStep() {
    if (_tripSteps.isEmpty || _currentPosition == null) return;
    
    final currentStep = _tripSteps[_currentStepIndex];
    final stepLocation = currentStep['location'] as LatLng;
    
    final distanceInMeters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      stepLocation.latitude,
      stepLocation.longitude,
    );

    // If within 50 meters of the step location and not the last step
    if (distanceInMeters < 50 && _currentStepIndex < _tripSteps.length - 1) {
      _showProximityAlert();
    }
  }

  void _initializeTripData() {
    final extra = widget.tripData;
    if (extra != null && extra['directions'] is DirectionsRouteInfo) {
      final directions = extra['directions'] as DirectionsRouteInfo;
      final routeData = extra['routeData'] as Map<String, dynamic>? ?? {};

      // Build steps
      final steps = <Map<String, dynamic>>[];
      for (int i = 0; i < directions.steps.length; i++) {
        final step = directions.steps[i];
        
        final icon = step.travelMode == 'TRANSIT' 
            ? Icons.directions_bus 
            : Icons.directions_walk;
            
        final color = i == 0 
            ? AppColors.primary 
            : i == directions.steps.length - 1 
                ? AppColors.error 
                : AppColors.accent;

        steps.add({
          'title': step.travelMode == 'TRANSIT' ? 'Transit' : 'Walk',
          'subtitle': step.durationText,
          'instruction': step.instruction,
          'icon': icon,
          'color': color,
          'location': step.startLocation,
          'progress': (i + 1) / directions.steps.length,
        });
      }
      _tripSteps = steps;

      // Build Polylines
      if (directions.polylinePoints.isNotEmpty) {
        _tripPolylines = {
          Polyline(
            polylineId: const PolylineId('transit_route'),
            points: directions.polylinePoints,
            color: AppColors.accent,
            width: 5,
          ),
        };
        _initialCamera = CameraPosition(
          target: directions.polylinePoints.first,
          zoom: 14.5,
        );
      }

      // Build Markers
      final markers = <Marker>{};
      if (directions.polylinePoints.isNotEmpty) {
        markers.add(
          Marker(
            markerId: const MarkerId('start'),
            position: directions.polylinePoints.first,
            infoWindow: InfoWindow(title: 'Start: ${routeData['origin'] ?? 'Origin'}'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ),
        );
        markers.add(
          Marker(
            markerId: const MarkerId('end'),
            position: directions.polylinePoints.last,
            infoWindow: InfoWindow(title: 'End: ${routeData['destination'] ?? 'Destination'}'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
      }
      for (int i = 0; i < directions.steps.length; i++) {
        final step = directions.steps[i];
        if (i > 0 && i < directions.steps.length - 1) {
          markers.add(
            Marker(
              markerId: MarkerId('step_$i'),
              position: step.startLocation,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            ),
          );
        }
      }
      _tripMarkers = markers;

    } else {
      // Fallback Mock Data
      const LatLng pipelineStage = LatLng(-1.3155, 36.8901);
      const LatLng tajMallStage = LatLng(-1.3180, 36.8935);
      const LatLng kencomStage = LatLng(-1.2864, 36.8252);
      const LatLng westlandsStage = LatLng(-1.2642, 36.8058);

      _tripSteps = [
        {
          'title': 'Walk to Pipeline Stage',
          'subtitle': '5 mins remaining (400m)',
          'instruction': 'Head North on Outering Road walkway to Pipeline Stage.',
          'icon': Icons.directions_walk,
          'color': AppColors.primary,
          'location': pipelineStage,
          'progress': 0.3,
        },
        {
          'title': 'Board Matatu Route 23',
          'subtitle': '40 mins in transit • Fare: KES 60',
          'instruction': 'Board Matatu 23 towards Westlands. Stay alert for your stop.',
          'icon': Icons.directions_bus,
          'color': AppColors.accent,
          'location': kencomStage,
          'progress': 0.65,
        },
        {
          'title': 'Alight at Westlands Stage',
          'subtitle': '2 mins walk to final destination',
          'instruction': 'Prepare to alight at Westlands Stage near the flyover.',
          'icon': Icons.location_on,
          'color': AppColors.error,
          'location': westlandsStage,
          'progress': 0.95,
        },
      ];

      _tripMarkers = {
        Marker(
          markerId: const MarkerId('start_stage'),
          position: pipelineStage,
          infoWindow: const InfoWindow(title: 'Start: Pipeline Stage'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
        Marker(
          markerId: const MarkerId('transit_stage'),
          position: kencomStage,
          infoWindow: const InfoWindow(title: 'Transfer: Kencom Stage'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
        Marker(
          markerId: const MarkerId('end_stage'),
          position: westlandsStage,
          infoWindow: const InfoWindow(title: 'Destination: Westlands Stage'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      };

      _tripPolylines = {
        const Polyline(
          polylineId: PolylineId('transit_route'),
          points: [
            pipelineStage,
            tajMallStage,
            kencomStage,
            westlandsStage,
          ],
          color: AppColors.accent,
          width: 5,
        ),
      };
      
      _initialCamera = const CameraPosition(
        target: LatLng(-1.2900, 36.8480),
        zoom: 12.5,
      );
    }
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
    if (_tripSteps.isEmpty) return;
    final stepLocation = _tripSteps[_currentStepIndex]['location'] as LatLng;
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(stepLocation, 16.0),
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

  bool _isProximityAlertVisible = false;

  void _showProximityAlert() {
    if (_tripSteps.isEmpty || _isProximityAlertVisible) return;
    final step = _tripSteps[_currentStepIndex];
    _isProximityAlertVisible = true;
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
                _isProximityAlertVisible = false;
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
    ).then((_) {
      _isProximityAlertVisible = false;
    });
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
                final routeData = widget.tripData?['routeData'] as Map<String, dynamic>? ?? {};
                final completedTrip = TripModel(
                  id: '',
                  origin: routeData['origin'] ?? 'Pipeline Stage',
                  destination: routeData['destination'] ?? 'Westlands Stage',
                  routeName: routeData['routeNumber'] != null ? 'Route ${routeData['routeNumber']}' : 'Route 23 Express',
                  routeNumber: routeData['routeNumber'] ?? '23',
                  fare: 80, // Hardcoded for now
                  durationMins: 45,
                  departedAt: DateTime.now().subtract(const Duration(minutes: 45)),
                  arrivedAt: DateTime.now(),
                  paymentMethod: 'M-Pesa',
                  mpesaRef: 'QX${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                  status: 'Completed',
                );
                ref.read(tripHistoryControllerProvider.notifier).addTrip(completedTrip);
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
    if (_tripSteps.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentStep = _tripSteps[_currentStepIndex];
    final themeMode = ref.watch(themeModeProvider);
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && platformBrightness == Brightness.dark);
    
    final routeData = widget.tripData?['routeData'] as Map<String, dynamic>? ?? {};
    final destination = routeData['destination'] ?? 'Westlands';
    final durationText = widget.tripData?['directions']?.durationText ?? '40 mins';

    return Scaffold(
      body: Stack(
        children: [
          // Live Google Map Widget for Active Trip
          GoogleMap(
            initialCameraPosition: _initialCamera,
            markers: _tripMarkers,
            polylines: _tripPolylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            onMapCreated: (controller) {
              _mapController = controller;
              final style = isDark ? kMapStyleDark : kMapStyleLight;
              controller.setMapStyle(style);
              
              if (widget.tripData != null && widget.tripData!['directions'] != null) {
                  final points = (widget.tripData!['directions'] as DirectionsRouteInfo).polylinePoints;
                  if (points.isNotEmpty) {
                      double minLat = points.first.latitude;
                      double maxLat = points.first.latitude;
                      double minLng = points.first.longitude;
                      double maxLng = points.first.longitude;

                      for (var point in points) {
                        if (point.latitude < minLat) minLat = point.latitude;
                        if (point.latitude > maxLat) maxLat = point.latitude;
                        if (point.longitude < minLng) minLng = point.longitude;
                        if (point.longitude > maxLng) maxLng = point.longitude;
                      }

                      Future.delayed(const Duration(milliseconds: 500), () {
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLngBounds(
                            LatLngBounds(
                              southwest: LatLng(minLat, minLng),
                              northeast: LatLng(maxLat, maxLng),
                            ),
                            50.0,
                          ),
                        );
                      });
                  }
              }
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
                    child: IconButton.filled(
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
                            'Active Navigation • To $destination',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.white70),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Duration: $durationText',
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
                    children: List.generate(_tripSteps.length > 5 ? 5 : _tripSteps.length, (i) {
                      // Show up to 5 dots if there are many steps
                      int relativeIndex = i;
                      if (_tripSteps.length > 5 && _currentStepIndex > 2) {
                          relativeIndex = _currentStepIndex - 2 + i;
                          if (relativeIndex >= _tripSteps.length) return const SizedBox.shrink();
                      }
                      
                      final isActive = relativeIndex == _currentStepIndex;
                      final isPassed = relativeIndex < _currentStepIndex;

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
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                          ),
                          child: Text(
                            currentStep['instruction'] as String,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
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
