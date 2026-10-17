import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  /// Default fallback location: Pipeline Stage, Nairobi
  static const LatLng defaultLocation = LatLng(-1.3148, 36.8912);

  /// Determine current user position with permissions handling.
  /// Returns null silently if permission is denied or location unavailable.
  static Future<Position?> getCurrentPosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          debugPrint('[Location] Permission denied.');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('[Location] Permission permanently denied.');
        return null;
      }

      // Try last known position first — zero latency
      final lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null) {
        debugPrint('[Location] Using last known position: ${lastPos.latitude}, ${lastPos.longitude}');
        return lastPos;
      }

      // Try getting a live fix — give it 10s before silently giving up
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      // Swallow all errors (TimeoutException, PlatformException, etc.)
      debugPrint('[Location] Could not obtain location: $e');
      return null;
    }
  }

  /// Get LatLng from position, falls back to Pipeline Stage, Nairobi.
  static Future<LatLng> getCurrentLatLng() async {
    final pos = await getCurrentPosition();
    if (pos != null) {
      return LatLng(pos.latitude, pos.longitude);
    }
    debugPrint('[Location] Falling back to default: Pipeline Stage.');
    return defaultLocation;
  }
  /// Get a stream of position updates.
  static Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Update every 5 meters
      ),
    );
  }
}
