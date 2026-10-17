import 'stage_model.dart';
import 'sacco_model.dart';

/// Distinguishes a matatu boarding leg from a walking transfer/segment.
enum LegType { matatu, walk }

/// One sacco's offering on a specific matatu leg.
class SaccoOnLeg {
  final SaccoModel sacco;
  final String saccoRouteId;
  final int fareOffPeak;
  final int farePeak;
  final int durationMins;
  final String fleetType;
  final bool isExpress;

  const SaccoOnLeg({
    required this.sacco,
    required this.saccoRouteId,
    required this.fareOffPeak,
    required this.farePeak,
    required this.durationMins,
    required this.fleetType,
    this.isExpress = false,
  });

  int get cheapestFare => fareOffPeak;
}

/// A single leg in a multi-leg journey.
class JourneyLegModel {
  final LegType type;
  final StageModel fromStage;
  final StageModel toStage;

  // Matatu-only
  final String? routeNumber;
  final List<SaccoOnLeg> saccoOptions;

  // Walk-only
  final double distanceMeters;
  final int durationMinutes;

  const JourneyLegModel({
    required this.type,
    required this.fromStage,
    required this.toStage,
    this.routeNumber,
    this.saccoOptions = const [],
    this.distanceMeters = 0,
    this.durationMinutes = 0,
  });

  bool get isMatatu => type == LegType.matatu;
  bool get isWalk => type == LegType.walk;

  int get cheapestFare {
    if (isWalk || saccoOptions.isEmpty) return 0;
    return saccoOptions.map((s) => s.cheapestFare).reduce((a, b) => a < b ? a : b);
  }

  int get estimatedMinutes {
    if (isWalk) return durationMinutes;
    if (saccoOptions.isEmpty) return durationMinutes;
    return saccoOptions.map((s) => s.durationMins).reduce((a, b) => a < b ? a : b);
  }
}

/// A complete ranked journey option from origin to destination.
class JourneyOption {
  final List<JourneyLegModel> legs;

  const JourneyOption({required this.legs});

  List<JourneyLegModel> get matatuLegs => legs.where((l) => l.isMatatu).toList();
  List<JourneyLegModel> get walkLegs => legs.where((l) => l.isWalk).toList();

  int get matatuCount => matatuLegs.length;

  int get totalCheapestFare =>
      matatuLegs.fold(0, (sum, leg) => sum + leg.cheapestFare);

  int get totalMinutes =>
      legs.fold(0, (sum, leg) => sum + leg.estimatedMinutes);

  String get matatuCountLabel =>
      '$matatuCount ${matatuCount == 1 ? 'matatu' : 'matatus'}';

  /// All stages in order — used as Directions API waypoints.
  List<StageModel> get orderedStages {
    final stages = <StageModel>[];
    for (final leg in legs) {
      if (stages.isEmpty) stages.add(leg.fromStage);
      stages.add(leg.toStage);
    }
    return stages;
  }
}
