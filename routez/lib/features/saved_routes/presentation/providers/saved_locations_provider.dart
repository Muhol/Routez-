import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/saved_location_model.dart';
import '../../data/repositories/saved_locations_repository.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

final savedLocationsRepositoryProvider = Provider<SavedLocationsRepository>((ref) {
  return SavedLocationsRepository();
});

/// StreamProvider watching saved locations for current user in Firestore
final savedLocationsProvider = StreamProvider<List<SavedLocation>>((ref) {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) return Stream.value([]);

  final repository = ref.watch(savedLocationsRepositoryProvider);
  
  // Trigger seeding default locations once on first load
  repository.seedDefaultLocationsIfEmpty(user.uid);

  return repository.watchSavedLocations(user.uid);
});

/// Controller to perform add/update/delete actions on saved locations
class SavedLocationsController extends AsyncNotifier<void> {
  late final SavedLocationsRepository _repository;

  @override
  Future<void> build() async {
    _repository = ref.read(savedLocationsRepositoryProvider);
  }

  Future<bool> addLocation({
    required String name,
    required String address,
    double? latitude,
    double? longitude,
    String? iconName,
    String? colorHex,
    String? routes,
  }) async {
    final user = ref.read(authStateProvider).asData?.value;
    if (user == null) return false;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final location = SavedLocation(
        id: '',
        name: name,
        address: address,
        latitude: latitude,
        longitude: longitude,
        iconName: iconName ?? 'place_outlined',
        colorHex: colorHex ?? 'FF1E88E5',
        routes: routes ?? 'Direct Matatu Route',
      );
      await _repository.addSavedLocation(user.uid, location);
    });

    return !state.hasError;
  }

  Future<bool> updateLocation(
    String locationId, {
    required String name,
    required String address,
  }) async {
    final user = ref.read(authStateProvider).asData?.value;
    if (user == null) return false;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updateSavedLocation(user.uid, locationId, {
        'name': name,
        'address': address,
      });
    });

    return !state.hasError;
  }

  Future<bool> deleteLocation(String locationId) async {
    final user = ref.read(authStateProvider).asData?.value;
    if (user == null) return false;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteSavedLocation(user.uid, locationId);
    });

    return !state.hasError;
  }
}

final savedLocationsControllerProvider =
    AsyncNotifierProvider<SavedLocationsController, void>(
  SavedLocationsController.new,
);
