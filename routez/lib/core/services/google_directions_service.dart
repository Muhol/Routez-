import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class DirectionsRouteInfo {
  final List<LatLng> polylinePoints;
  final String durationText;
  final int durationValue; // in seconds
  final String distanceText;
  final List<DirectionsStep> steps;

  DirectionsRouteInfo({
    required this.polylinePoints,
    required this.durationText,
    required this.durationValue,
    required this.distanceText,
    required this.steps,
  });
}

class DirectionsStep {
  final String instruction;
  final String durationText;
  final String distanceText;
  final LatLng startLocation;
  final LatLng endLocation;
  final String travelMode; // 'WALKING' or 'TRANSIT'

  DirectionsStep({
    required this.instruction,
    required this.durationText,
    required this.distanceText,
    required this.startLocation,
    required this.endLocation,
    required this.travelMode,
  });
}

class GoogleDirectionsService {
  static const String _apiKey = 'AIzaSyDkoS9TRqEZ1MA2qrsKiDQ3m5bHkfZOs2E';

  /// Get directions route information (polyline points, duration, steps) between origin and destination.
  /// Can take text (place names) or LatLng coordinates format 'lat,lng'.
  static Future<DirectionsRouteInfo?> getDirections({
    required String origin,
    required String destination,
    String mode = 'transit', // 'transit', 'walking', 'driving'
  }) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=${Uri.encodeComponent(origin)}'
      '&destination=${Uri.encodeComponent(destination)}'
      '&mode=$mode'
      '&key=$_apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final status = data['status'] as String?;
        
        if (status == 'OK') {
          final routes = data['routes'] as List<dynamic>? ?? [];
          if (routes.isEmpty) return null;

          final route = routes[0] as Map<String, dynamic>;
          final overviewPolyline = route['overview_polyline'] as Map<String, dynamic>?;
          final polylineString = overviewPolyline?['points'] as String? ?? '';
          final polylinePoints = _decodePolyline(polylineString);

          final legs = route['legs'] as List<dynamic>? ?? [];
          if (legs.isEmpty) return null;

          final leg = legs[0] as Map<String, dynamic>;
          final duration = leg['duration'] as Map<String, dynamic>?;
          final durationText = duration?['text'] as String? ?? '';
          final durationValue = (duration?['value'] as num?)?.toInt() ?? 0;
          final distanceText = (leg['distance'] as Map<String, dynamic>?)?['text'] as String? ?? '';

          final stepsList = leg['steps'] as List<dynamic>? ?? [];
          final steps = stepsList.map((stepJson) {
            final stepMap = stepJson as Map<String, dynamic>;
            final startLoc = stepMap['start_location'] as Map<String, dynamic>?;
            final endLoc = stepMap['end_location'] as Map<String, dynamic>?;
            
            // Clean up HTML tags from instruction text
            String htmlInstruction = stepMap['html_instructions'] as String? ?? '';
            String cleanInstruction = htmlInstruction.replaceAll(RegExp(r'<[^>]*>'), '');

            return DirectionsStep(
              instruction: cleanInstruction,
              durationText: (stepMap['duration'] as Map<String, dynamic>?)?['text'] as String? ?? '',
              distanceText: (stepMap['distance'] as Map<String, dynamic>?)?['text'] as String? ?? '',
              startLocation: LatLng(
                (startLoc?['lat'] as num?)?.toDouble() ?? 0.0,
                (startLoc?['lng'] as num?)?.toDouble() ?? 0.0,
              ),
              endLocation: LatLng(
                (endLoc?['lat'] as num?)?.toDouble() ?? 0.0,
                (endLoc?['lng'] as num?)?.toDouble() ?? 0.0,
              ),
              travelMode: stepMap['travel_mode'] as String? ?? 'WALKING',
            );
          }).toList();

          return DirectionsRouteInfo(
            polylinePoints: polylinePoints,
            durationText: durationText,
            durationValue: durationValue,
            distanceText: distanceText,
            steps: steps,
          );
        } else {
          final errorMsg = data['error_message'] ?? 'No error message provided';
          debugPrint('⚠️ [Google Directions API Warning] Status: $status | Reason: $errorMsg');
        }
      } else {
        debugPrint('⚠️ [Google Directions API HTTP Error] Code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('⚠️ [Google Directions Service Error]: $e');
    }
    return null;
  }

  /// Decode Google overview_polyline string using the standard polyline algorithm
  static List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
}
