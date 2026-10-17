import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final structured = json['structured_formatting'] as Map<String, dynamic>?;
    return PlacePrediction(
      placeId: json['place_id'] as String? ?? '',
      description: json['description'] as String? ?? '',
      mainText: structured?['main_text'] as String? ?? json['description'] as String? ?? '',
      secondaryText: structured?['secondary_text'] as String? ?? '',
    );
  }
}

class GooglePlacesService {
  static const String _apiKey = 'AIzaSyDkoS9TRqEZ1MA2qrsKiDQ3m5bHkfZOs2E';

  /// Fetch place predictions from Google Places Autocomplete API
  static Future<List<PlacePrediction>> getPlacePredictions(String input) async {
    if (input.trim().length < 2) return [];

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json'
      '?input=${Uri.encodeComponent(input)}'
      '&components=country:ke'
      '&key=$_apiKey',
    );

    try {
      final response = await http.get(url);
      
      // Print the raw JSON body to terminal for full visibility
      debugPrint('🔍 [RAW PLACES API RESPONSE] Status Code: ${response.statusCode}');
      debugPrint('🔍 [RAW PLACES API RESPONSE BODY]: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final status = data['status'] as String?;
        if (status == 'OK') {
          final predictions = data['predictions'] as List<dynamic>? ?? [];
          return predictions
              .map((p) => PlacePrediction.fromJson(p as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('⚠️ [Google Places Service Error]: $e');
    }
    return [];
  }
}
