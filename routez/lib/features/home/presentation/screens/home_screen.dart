import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  Offset _mapOffset = Offset.zero;
  String? _selectedStagePin;
  bool _useGoogleMapWidget = true;

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
    if (_mapController != null && _useGoogleMapWidget) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(_initialCameraPosition),
      );
    }
    setState(() {
      _mapOffset = Offset.zero;
      _selectedStagePin = null;
    });
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
          padding: const EdgeInsets.all(AppSizes.p24),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Google Maps Widget Implementation
          _useGoogleMapWidget
              ? GoogleMap(
                  initialCameraPosition: _initialCameraPosition,
                  markers: _getGoogleMapMarkers(),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapType: isDark ? MapType.normal : MapType.normal,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                )
              : GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _mapOffset += details.delta;
                    });
                  },
                  child: Container(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    width: double.infinity,
                    height: double.infinity,
                    child: Stack(
                      children: [
                        CustomPaint(
                          size: Size.infinite,
                          painter: _MapGridPainter(offset: _mapOffset, isDark: isDark),
                        ),
                        ..._stages.map((stage) {
                          final baseOffset = stage['offset'] as Offset;
                          final pinPosition = Offset(
                            MediaQuery.of(context).size.width / 2 + baseOffset.dx + _mapOffset.dx,
                            MediaQuery.of(context).size.height / 2 + baseOffset.dy + _mapOffset.dy,
                          );

                          final isSelected = _selectedStagePin == stage['name'];

                          return Positioned(
                            left: pinPosition.dx - 20,
                            top: pinPosition.dy - 40,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedStagePin = stage['name'];
                                });
                                _showStageDetails(stage);
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSizes.p8,
                                      vertical: AppSizes.p4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.accent : AppColors.primary,
                                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      stage['name'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.location_on,
                                    color: isSelected ? AppColors.accent : AppColors.primary,
                                    size: 32,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

          // Top Search Bar Area
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: GestureDetector(
                onTap: () => context.push('/search'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.p16,
                    vertical: AppSizes.p16,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.textSecondaryLight),
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

          // Floating Action Button (Re-center Location)
          Positioned(
            right: AppSizes.p16,
            bottom: AppSizes.p200 + 20, // Positioned safely above bottom sheet
            child: FloatingActionButton(
              onPressed: _recenterMap,
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.primary,
              tooltip: 'Re-center Location',
              child: const Icon(Icons.my_location),
            ),
          ),

          // Draggable Bottom Sheet (Interactive Stage Items)
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

// Custom Painter for Map Grid Fallback
class _MapGridPainter extends CustomPainter {
  final Offset offset;
  final bool isDark;

  _MapGridPainter({required this.offset, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final linePaint = Paint()
      ..color = isDark ? const Color(0xFF475569) : Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final gridX = (offset.dx % 120);
    final gridY = (offset.dy % 120);

    for (double x = -120; x < size.width + 120; x += 120) {
      canvas.drawLine(
        Offset(x + gridX, 0),
        Offset(x + gridX, size.height),
        roadPaint,
      );
      canvas.drawLine(
        Offset(x + gridX, 0),
        Offset(x + gridX, size.height),
        linePaint,
      );
    }

    for (double y = -120; y < size.height + 120; y += 120) {
      canvas.drawLine(
        Offset(0, y + gridY),
        Offset(size.width, y + gridY),
        roadPaint,
      );
      canvas.drawLine(
        Offset(0, y + gridY),
        Offset(size.width, y + gridY),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) {
    return oldDelegate.offset != offset || oldDelegate.isDark != isDark;
  }
}
