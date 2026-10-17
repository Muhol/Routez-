import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routez/core/services/google_places_service.dart';
import '../../data/models/stage_model.dart';
import '../../data/models/journey_leg_model.dart';
import '../../data/repositories/transit_repository.dart';

final transitRepositoryProvider = Provider<TransitRepository>((ref) {
  return TransitRepository();
});

/// FutureProvider for stage search autocomplete from database
final stageAutocompleteProvider =
    FutureProvider.family<List<StageModel>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  final repository = ref.read(transitRepositoryProvider);
  return repository.searchStages(query);
});

/// FutureProvider for Google Places autocomplete predictions
final googlePlacesAutocompleteProvider =
    FutureProvider.family<List<PlacePrediction>, String>((ref, query) async {
  if (query.trim().length < 2) return [];
  return GooglePlacesService.getPlacePredictions(query);
});

/// Parameter class for route search query
class RouteSearchQuery {
  final String origin;
  final String destination;

  RouteSearchQuery({required this.origin, required this.destination});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteSearchQuery &&
          runtimeType == other.runtimeType &&
          origin == other.origin &&
          destination == other.destination;

  @override
  int get hashCode => origin.hashCode ^ destination.hashCode;
}

/// FutureProvider fetching multi-leg ranked journey options
final journeySearchResultsProvider = FutureProvider.family<
    List<JourneyOption>, RouteSearchQuery>((ref, searchParams) async {
  final repository = ref.read(transitRepositoryProvider);
  return repository.searchJourneys(
    origin: searchParams.origin,
    destination: searchParams.destination,
  );
});

