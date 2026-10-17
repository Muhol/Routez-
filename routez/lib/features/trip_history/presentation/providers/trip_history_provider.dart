import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routez/features/authentication/presentation/providers/auth_provider.dart';
import 'package:routez/features/trip_history/data/models/trip_model.dart';
import 'package:routez/features/trip_history/data/repositories/trip_history_repository.dart';

final tripHistoryRepositoryProvider = Provider<TripHistoryRepository>((ref) {
  return TripHistoryRepository();
});

/// Stream of trip history for current logged-in user
final tripHistoryProvider = StreamProvider<List<TripModel>>((ref) {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) {
    return Stream.value([]);
  }
  final repo = ref.watch(tripHistoryRepositoryProvider);
  return repo.watchTripHistory(user.uid);
});

class TripHistoryController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addTrip(TripModel trip) async {
    final user = ref.read(authStateProvider).asData?.value;
    if (user == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(tripHistoryRepositoryProvider);
      await repo.addTrip(user.uid, trip);
    });
  }

  Future<void> clearAllTrips() async {
    final user = ref.read(authStateProvider).asData?.value;
    if (user == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(tripHistoryRepositoryProvider);
      await repo.clearAllTrips(user.uid);
    });
  }
}

final tripHistoryControllerProvider =
    AsyncNotifierProvider<TripHistoryController, void>(TripHistoryController.new);
