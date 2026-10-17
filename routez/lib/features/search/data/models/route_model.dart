import 'sacco_model.dart';
import 'stage_model.dart';

/// Represents a specific Sacco servicing a route (with its unique price, fleet, & stop sequence path)
class SaccoRouteOption {
  final String saccoRouteId;
  final SaccoModel sacco;
  final String routeNumber;
  final int fareOffPeak;
  final int farePeak;
  final int typicalDurationMins;
  final String fleetType; // e.g. "14-seater", "33-seater bus", "51-seater"
  final bool isExpress;
  final List<StageModel> stopsPath; // Ordered sequence of stages for this Sacco

  SaccoRouteOption({
    required this.saccoRouteId,
    required this.sacco,
    required this.routeNumber,
    required this.fareOffPeak,
    required this.farePeak,
    required this.typicalDurationMins,
    this.fleetType = 'Matatu 14-seater',
    this.isExpress = false,
    required this.stopsPath,
  });

  factory SaccoRouteOption.fromJson(Map<String, dynamic> json) {
    final saccoData = json['saccos'] as Map<String, dynamic>? ?? {};
    final routesData = json['routes'] as Map<String, dynamic>? ?? {};
    final stopsList = json['stops'] as List? ?? [];
    final routeNum = (routesData['route_number'] as String?) ??
        (json['route_number'] as String?) ??
        '23';

    return SaccoRouteOption(
      saccoRouteId: json['id']?.toString() ?? '',
      sacco: SaccoModel.fromJson(saccoData),
      routeNumber: routeNum,
      fareOffPeak: (json['fare_offpeak'] as num?)?.toInt() ?? 50,
      farePeak: (json['fare_peak'] as num?)?.toInt() ?? 80,
      typicalDurationMins:
          (json['typical_duration_mins'] as num?)?.toInt() ?? 45,
      fleetType: json['fleet_type'] as String? ?? 'Matatu 14-seater',
      isExpress: json['is_express'] as bool? ?? false,
      stopsPath: stopsList
          .map((s) => StageModel.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sacco_route_id': saccoRouteId,
      'sacco': sacco.toJson(),
      'route_number': routeNumber,
      'fare_offpeak': fareOffPeak,
      'fare_peak': farePeak,
      'typical_duration_mins': typicalDurationMins,
      'fleet_type': fleetType,
      'is_express': isExpress,
      'stops_path': stopsPath.map((s) => s.toJson()).toList(),
    };
  }
}

/// Master Route containing origin, destination, and all servicing Sacco options
class RouteResultModel {
  final String id;
  final String routeNumber;
  final String originName;
  final String destinationName;
  final List<SaccoRouteOption> saccoOptions;

  RouteResultModel({
    required this.id,
    required this.routeNumber,
    required this.originName,
    required this.destinationName,
    required this.saccoOptions,
  });

  int get minFare => saccoOptions.isEmpty
      ? 50
      : saccoOptions
          .map((s) => s.fareOffPeak)
          .reduce((a, b) => a < b ? a : b);

  int get maxFare => saccoOptions.isEmpty
      ? 100
      : saccoOptions
          .map((s) => s.farePeak)
          .reduce((a, b) => a > b ? a : b);

  factory RouteResultModel.fromJson(Map<String, dynamic> json) {
    final saccosList = json['sacco_options'] as List? ?? [];
    return RouteResultModel(
      id: json['id']?.toString() ?? '',
      routeNumber: json['route_number'] as String? ?? '',
      originName: json['origin_name'] as String? ?? '',
      destinationName: json['destination_name'] as String? ?? '',
      saccoOptions: saccosList
          .map((s) => SaccoRouteOption.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}
