import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';

class ActiveTripScreen extends StatefulWidget {
  const ActiveTripScreen({super.key});

  @override
  State<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends State<ActiveTripScreen> {
  int _currentStepIndex = 0;
  bool _isVoiceEnabled = true;

  final List<Map<String, dynamic>> _tripSteps = [
    {
      'title': 'Walk to Pipeline Stage',
      'subtitle': '5 mins remaining (400m)',
      'instruction': 'Head North on Outering Road walkway to Pipeline Stage.',
      'icon': Icons.directions_walk,
      'color': AppColors.primary,
      'progress': 0.3,
    },
    {
      'title': 'Board Matatu Route 23',
      'subtitle': '40 mins in transit • Fare: KES 60',
      'instruction': 'Board Matatu 23 towards Westlands. Stay alert for your stop.',
      'icon': Icons.directions_bus,
      'color': AppColors.accent,
      'progress': 0.65,
    },
    {
      'title': 'Alight at Westlands Stage',
      'subtitle': '2 mins walk to final destination',
      'instruction': 'Prepare to alight at Westlands Stage near the flyover.',
      'icon': Icons.location_on,
      'color': AppColors.error,
      'progress': 0.95,
    },
  ];

  void _nextStep() {
    if (_currentStepIndex < _tripSteps.length - 1) {
      setState(() {
        _currentStepIndex++;
      });
    } else {
      _showEndTripConfirmation();
    }
  }

  void _previousStep() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
      });
    }
  }

  void _toggleVoiceNavigation() {
    setState(() {
      _isVoiceEnabled = !_isVoiceEnabled;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isVoiceEnabled
              ? 'Voice navigation enabled'
              : 'Voice navigation muted',
        ),
        duration: const Duration(seconds: 1),
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
          title: Row(
            children: [
              const Icon(Icons.notifications_active, color: AppColors.warning),
              const SizedBox(width: AppSizes.p8),
              const Text('Proximity Alert'),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Route Polyline Overview Container (Mock Transit Map)
          Container(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                // Custom Route Polyline Painter
                CustomPaint(
                  size: Size.infinite,
                  painter: _RoutePolylinePainter(
                    currentStepProgress: currentStep['progress'] as double,
                    isDark: isDark,
                  ),
                ),

                // Map Control Overlays (Voice Guidance & Proximity Trigger)
                Positioned(
                  right: AppSizes.p16,
                  top: AppSizes.p80,
                  child: Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'voice_toggle',
                        onPressed: _toggleVoiceNavigation,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        foregroundColor: _isVoiceEnabled
                            ? AppColors.primary
                            : AppColors.textSecondaryLight,
                        tooltip: 'Voice Guidance',
                        child: Icon(
                          _isVoiceEnabled ? Icons.volume_up : Icons.volume_off,
                        ),
                      ),
                      const SizedBox(height: AppSizes.p12),
                      FloatingActionButton.small(
                        heroTag: 'proximity_alert',
                        onPressed: _showProximityAlert,
                        backgroundColor: AppColors.warning,
                        foregroundColor: Colors.white,
                        tooltip: 'Test Proximity Alert',
                        child: const Icon(Icons.notifications_active),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Top Header Overlay
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
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusMedium,
                        ),
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
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.white70),
                          ),
                          Text(
                            'ETA: 10:45 AM (40 mins)',
                            style: Theme.of(context).textTheme.titleMedium
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

          // Bottom Step Wizard Navigation Card
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
                              style: Theme.of(context).textTheme.titleMedium
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

                  // Step Guidance Note
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.p12),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      border: Border.all(color: AppColors.dividerLight),
                    ),
                    child: Text(
                      currentStep['instruction'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
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

// Custom Painter for Route Polyline Overview Container
class _RoutePolylinePainter extends CustomPainter {
  final double currentStepProgress;
  final bool isDark;

  _RoutePolylinePainter({
    required this.currentStepProgress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final activePathPaint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final p1 = Offset(size.width * 0.2, size.height * 0.25);
    final p2 = Offset(size.width * 0.5, size.height * 0.45);
    final p3 = Offset(size.width * 0.8, size.height * 0.3);

    path.moveTo(p1.dx, p1.dy);
    path.lineTo(p2.dx, p2.dy);
    path.lineTo(p3.dx, p3.dy);

    // Draw base route polyline
    canvas.drawPath(path, backgroundPaint);

    // Calculate active point on polyline based on progress
    Offset currentPosition;
    if (currentStepProgress <= 0.5) {
      final t = currentStepProgress / 0.5;
      currentPosition = Offset.lerp(p1, p2, t)!;
    } else {
      final t = (currentStepProgress - 0.5) / 0.5;
      currentPosition = Offset.lerp(p2, p3, t)!;
    }

    // Draw active path segment up to currentPosition
    final activePath = Path();
    activePath.moveTo(p1.dx, p1.dy);
    if (currentStepProgress <= 0.5) {
      activePath.lineTo(currentPosition.dx, currentPosition.dy);
    } else {
      activePath.lineTo(p2.dx, p2.dy);
      activePath.lineTo(currentPosition.dx, currentPosition.dy);
    }
    canvas.drawPath(activePath, activePathPaint);

    // Draw Stop Markers (Pipeline Stage, Boarding Stage, Alight Stage)
    _drawMarker(canvas, p1, 'Pipeline Stage', isDark);
    _drawMarker(canvas, p2, 'Transfer / Board 23', isDark);
    _drawMarker(canvas, p3, 'Westlands Stage', isDark);

    // Draw Active Navigation Position Pulse
    final pulsePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    canvas.drawCircle(currentPosition, 16, pulsePaint);
    canvas.drawCircle(currentPosition, 7, dotPaint);
  }

  void _drawMarker(Canvas canvas, Offset point, String label, bool isDark) {
    final markerPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(point, 6, markerPaint);
  }

  @override
  bool shouldRepaint(covariant _RoutePolylinePainter oldDelegate) {
    return oldDelegate.currentStepProgress != currentStepProgress ||
        oldDelegate.isDark != isDark;
  }
}
