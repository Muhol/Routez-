import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/services/location_service.dart';

/// Provider for user's live or default LatLng
final userLocationProvider = FutureProvider<LatLng>((ref) async {
  return await LocationService.getCurrentLatLng();
});
