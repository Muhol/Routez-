import '../models/stage_model.dart';
import '../models/journey_leg_model.dart';
import 'graph_builder.dart';

class Pathfinder {
  final TransitGraph graph;

  Pathfinder(this.graph);

  /// Find and rank top journey options between origin and destination stages.
  List<JourneyOption> findPaths(StageModel origin, StageModel destination) {
    if (origin.id == destination.id) return [];

    final results = <List<GraphEdge>>[];
    final visitedNodes = <String>{origin.id};

    _dfs(
      currentStageId: origin.id,
      targetStageId: destination.id,
      currentPath: [],
      visitedNodes: visitedNodes,
      matatuLegCount: 0,
      totalEdgeCount: 0,
      lastWasWalk: false,
      results: results,
    );

    // Convert raw edge paths to JourneyOption models
    final journeyOptions = results.map((path) {
      final legs = path.map((edge) {
        if (edge.type == LegType.matatu) {
          return JourneyLegModel(
            type: LegType.matatu,
            fromStage: edge.from,
            toStage: edge.to,
            routeNumber: edge.routeNumber,
            saccoOptions: edge.saccoOptions,
          );
        } else {
          return JourneyLegModel(
            type: LegType.walk,
            fromStage: edge.from,
            toStage: edge.to,
            distanceMeters: edge.distanceMeters,
            durationMinutes: edge.walkMinutes,
          );
        }
      }).toList();
      return JourneyOption(legs: legs);
    }).toList();

    // Rank paths:
    // (a) fewest matatu legs first
    // (b) total estimated duration
    // (c) total fare
    journeyOptions.sort((a, b) {
      final legComp = a.matatuCount.compareTo(b.matatuCount);
      if (legComp != 0) return legComp;

      final timeComp = a.totalMinutes.compareTo(b.totalMinutes);
      if (timeComp != 0) return timeComp;

      return a.totalCheapestFare.compareTo(b.totalCheapestFare);
    });

    // Return top 3 distinct options
    return journeyOptions.take(3).toList();
  }

  void _dfs({
    required String currentStageId,
    required String targetStageId,
    required List<GraphEdge> currentPath,
    required Set<String> visitedNodes,
    required int matatuLegCount,
    required int totalEdgeCount,
    required bool lastWasWalk,
    required List<List<GraphEdge>> results,
  }) {
    if (currentStageId == targetStageId) {
      results.add(List.from(currentPath));
      return;
    }

    // Hard caps check
    if (totalEdgeCount >= 6) return;

    final outgoingEdges = graph[currentStageId] ?? [];
    for (final edge in outgoingEdges) {
      final nextStageId = edge.to.id;

      // Simple path requirement: no repeated nodes
      if (visitedNodes.contains(nextStageId)) continue;

      final isMatatu = edge.type == LegType.matatu;
      final isWalk = edge.type == LegType.walk;

      // Constraint: No consecutive walk edges
      if (isWalk && lastWasWalk) continue;

      // Constraint: Capped at max 3 matatu legs
      final nextMatatuCount = matatuLegCount + (isMatatu ? 1 : 0);
      if (nextMatatuCount > 3) continue;

      // Advance search
      visitedNodes.add(nextStageId);
      currentPath.add(edge);

      _dfs(
        currentStageId: nextStageId,
        targetStageId: targetStageId,
        currentPath: currentPath,
        visitedNodes: visitedNodes,
        matatuLegCount: nextMatatuCount,
        totalEdgeCount: totalEdgeCount + 1,
        lastWasWalk: isWalk,
        results: results,
      );

      // Backtrack
      currentPath.removeLast();
      visitedNodes.remove(nextStageId);
    }
  }
}
