import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/stage_model.dart';
import '../models/sacco_model.dart';
import '../models/journey_leg_model.dart';

/// An edge in the transit graph.
class GraphEdge {
  final LegType type;
  final StageModel from;
  final StageModel to;

  // Matatu edge fields
  final String? routeNumber;
  final List<SaccoOnLeg> saccoOptions;

  // Walk edge fields
  final double distanceMeters;
  final int walkMinutes;

  const GraphEdge.matatu({
    required this.from,
    required this.to,
    required this.routeNumber,
    required this.saccoOptions,
  })  : type = LegType.matatu,
        distanceMeters = 0,
        walkMinutes = 0;

  const GraphEdge.walk({
    required this.from,
    required this.to,
    required this.distanceMeters,
    required this.walkMinutes,
  })  : type = LegType.walk,
        routeNumber = null,
        saccoOptions = const [];
}

/// The full transit graph: stageId -> list of outgoing edges.
typedef TransitGraph = Map<String, List<GraphEdge>>;

class GraphBuilder {
  final SupabaseClient _client;

  GraphBuilder(this._client);

  /// Build the complete directed graph from Supabase data.
  Future<TransitGraph> build() async {
    final graph = <String, List<GraphEdge>>{};

    // 1. Load all stages indexed by id.
    final stageMap = await _loadStages();

    // 2. Load sacco_route_stages grouped by sacco_route_id.
    final matatuEdges = await _buildMatatuEdges(stageMap);
    for (final edge in matatuEdges) {
      graph.putIfAbsent(edge.from.id, () => []).add(edge);
    }

    // 3. Load walk edges from nearby_stage_pairs().
    final walkEdges = await _buildWalkEdges(stageMap);
    for (final edge in walkEdges) {
      graph.putIfAbsent(edge.from.id, () => []).add(edge);
      // Bidirectional
      final reverse = GraphEdge.walk(
        from: edge.to,
        to: edge.from,
        distanceMeters: edge.distanceMeters,
        walkMinutes: edge.walkMinutes,
      );
      graph.putIfAbsent(reverse.from.id, () => []).add(reverse);
    }

    return graph;
  }

  Future<Map<String, StageModel>> _loadStages() async {
    try {
      final res = await _client.from('stages').select();
      final map = <String, StageModel>{};
      for (final row in res as List) {
        final stage = StageModel.fromJson(row as Map<String, dynamic>);
        map[stage.id] = stage;
      }
      return map;
    } catch (e) {
      debugPrint('[GraphBuilder] _loadStages error: $e');
      return {};
    }
  }

  /// Build directed matatu edges: for each sacco_route, every stage-pair
  /// (from earlier stop to later stop on the same route) is one edge.
  /// Multiple saccos on the same route share the same edge (different SaccoOnLeg).
  Future<List<GraphEdge>> _buildMatatuEdges(Map<String, StageModel> stageMap) async {
    try {
      final res = await _client.from('sacco_route_stages').select('''
        sacco_route_id,
        stage_id,
        stop_order,
        sacco_routes (
          id,
          fare_offpeak,
          fare_peak,
          typical_duration_mins,
          fleet_type,
          is_express,
          routes ( route_number ),
          saccos ( id, name, logo_url, contact_phone, rating )
        )
      ''').order('stop_order', ascending: true);

      final Map<String, List<Map<String, dynamic>>> routeStages = {};
      final Map<String, Map<String, dynamic>> routeMeta = {};

      for (final row in res as List) {
        final r = row as Map<String, dynamic>;
        final srId = r['sacco_route_id']?.toString();
        final saccoRoute = r['sacco_routes'] as Map<String, dynamic>?;
        if (srId == null || saccoRoute == null) continue;

        routeStages.putIfAbsent(srId, () => []).add(r);
        routeMeta[srId] = saccoRoute;
      }

      final Map<String, List<SaccoOnLeg>> edgeToSaccos = {};
      final Map<String, ({StageModel from, StageModel to, String routeNumber})> edgeMeta = {};

      for (final entry in routeStages.entries) {
        final srId = entry.key;
        final stageRows = entry.value;
        final meta = routeMeta[srId];
        if (meta == null) continue;

        final routeData = meta['routes'] as Map<String, dynamic>? ?? {};
        final saccoData = meta['saccos'] as Map<String, dynamic>? ?? {};
        final routeNumber = (routeData['route_number'] as String?) ?? '?';
        final sacco = SaccoModel.fromJson(saccoData);
        final saccoOnLeg = SaccoOnLeg(
          sacco: sacco,
          saccoRouteId: srId,
          fareOffPeak: (meta['fare_offpeak'] as num?)?.toInt() ?? 50,
          farePeak: (meta['fare_peak'] as num?)?.toInt() ?? 100,
          durationMins: (meta['typical_duration_mins'] as num?)?.toInt() ?? 45,
          fleetType: meta['fleet_type'] as String? ?? 'Matatu',
          isExpress: meta['is_express'] as bool? ?? false,
        );

        for (int i = 0; i < stageRows.length - 1; i++) {
          for (int j = i + 1; j < stageRows.length; j++) {
            final fromId = stageRows[i]['stage_id']?.toString();
            final toId = stageRows[j]['stage_id']?.toString();
            if (fromId == null || toId == null) continue;

            final fromStage = stageMap[fromId];
            final toStage = stageMap[toId];
            if (fromStage == null || toStage == null) continue;

            final key = '$fromId|$toId|$routeNumber';
            edgeToSaccos.putIfAbsent(key, () => []).add(saccoOnLeg);
            edgeMeta.putIfAbsent(key, () => (from: fromStage, to: toStage, routeNumber: routeNumber));
          }
        }
      }

      final edges = edgeMeta.entries.map((e) {
        return GraphEdge.matatu(
          from: e.value.from,
          to: e.value.to,
          routeNumber: e.value.routeNumber,
          saccoOptions: edgeToSaccos[e.key]!,
        );
      }).toList();

      debugPrint('[GraphBuilder] Built ${edges.length} matatu edges from ${routeStages.length} sacco routes.');
      return edges;
    } catch (e, st) {
      debugPrint('[GraphBuilder] _buildMatatuEdges error: $e\n$st');
      return [];
    }
  }

  /// Build walk edges by calling the nearby_stage_pairs() Postgres function.
  Future<List<GraphEdge>> _buildWalkEdges(Map<String, StageModel> stageMap) async {
    try {
      final res = await _client.rpc('nearby_stage_pairs', params: {'radius_meters': 900});
      final edges = <GraphEdge>[];
      for (final row in res as List) {
        final r = row as Map<String, dynamic>;
        final stageA = stageMap[r['stage_a']?.toString()];
        final stageB = stageMap[r['stage_b']?.toString()];
        if (stageA == null || stageB == null) continue;
        final distM = (r['distance_meters'] as num?)?.toDouble() ?? 0;
        final walkMins = (distM / 1000 * 12).ceil(); // 12 min/km walking pace
        edges.add(GraphEdge.walk(
          from: stageA,
          to: stageB,
          distanceMeters: distM,
          walkMinutes: walkMins,
        ));
      }
      return edges;
    } catch (e, st) {
      debugPrint('[GraphBuilder] _buildWalkEdges error: $e\n$st');
      return [];
    }
  }
}
