import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/stage_model.dart';
import '../models/journey_leg_model.dart';
import 'graph_builder.dart';
import 'pathfinder.dart';

class TransitRepository {
  final SupabaseClient? _supabaseClient;

  TransitRepository({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient;

  SupabaseClient get _client => _supabaseClient ?? Supabase.instance.client;

  /// Search stages autocomplete by query name
  Future<List<StageModel>> searchStages(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final response = await _client
          .from('stages')
          .select()
          .ilike('name', '%$query%')
          .limit(10);

      final list = response as List;
      return list
          .map((item) => StageModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      debugPrint('[TransitRepository] searchStages error: $e');
      debugPrint('$st');
      return [];
    }
  }

  /// Search multi-leg journey options between origin and destination.
  Future<List<JourneyOption>> searchJourneys({
    required String origin,
    required String destination,
  }) async {
    if (origin.trim().isEmpty || destination.trim().isEmpty) return [];

    try {
      // 1. Load all stages
      final stagesRes = await _client.from('stages').select();
      final allStages = (stagesRes as List)
          .map((item) => StageModel.fromJson(item as Map<String, dynamic>))
          .toList();

      if (allStages.isEmpty) return [];

      // 2. Resolve origin stage and destination stage
      final originStage = _matchStage(origin, allStages) ?? allStages.first;
      var destStage = _matchStage(destination, allStages);

      if (destStage == null || destStage.id == originStage.id) {
        destStage = allStages.firstWhere(
          (s) => s.id != originStage.id,
          orElse: () => allStages.last,
        );
      }

      debugPrint('[TransitRepository] Searching path from: ${originStage.name} (${originStage.id}) -> ${destStage.name} (${destStage.id})');

      // 3. Build graph & run pathfinder
      final graphBuilder = GraphBuilder(_client);
      final graph = await graphBuilder.build();

      final pathfinder = Pathfinder(graph);
      final options = pathfinder.findPaths(originStage, destStage);
      debugPrint('[TransitRepository] Found ${options.length} journey options.');
      return options;
    } catch (e, st) {
      debugPrint('[TransitRepository] searchJourneys error: $e\n$st');
      return [];
    }
  }

  StageModel? _matchStage(String query, List<StageModel> stages) {
    final cleanQuery = query.toLowerCase().trim();
    // 1. Exact or contains match on name
    for (final stage in stages) {
      if (cleanQuery.contains(stage.name.toLowerCase()) ||
          stage.name.toLowerCase().contains(cleanQuery)) {
        return stage;
      }
    }
    // 2. Contains match on area
    for (final stage in stages) {
      if (cleanQuery.contains(stage.area.toLowerCase()) ||
          stage.area.toLowerCase().contains(cleanQuery)) {
        return stage;
      }
    }
    return null;
  }
}

