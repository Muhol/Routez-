import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/repositories/user_profile_repository.dart';
import 'auth_provider.dart';

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepository();
});

/// StreamProvider exposing the current logged-in user's profile from Firestore
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final authUser = ref.watch(authStateProvider).asData?.value;
  if (authUser == null) return Stream.value(null);

  final repository = ref.watch(userProfileRepositoryProvider);
  return repository.watchProfile(authUser.uid);
});

/// Controller to handle updating user profile in Firestore
class UpdateUserProfileController extends AsyncNotifier<void> {
  late final UserProfileRepository _repository;

  @override
  Future<void> build() async {
    _repository = ref.read(userProfileRepositoryProvider);
  }

  Future<bool> updateProfile({
    required String displayName,
    String? phoneNumber,
    String? defaultTransportPreference,
  }) async {
    final user = ref.read(authStateProvider).asData?.value;
    if (user == null) return false;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updateProfile(user.uid, {
        'displayName': displayName,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (defaultTransportPreference != null)
          'defaultTransportPreference': defaultTransportPreference,
      });
    });

    return !state.hasError;
  }
}

final updateUserProfileControllerProvider =
    AsyncNotifierProvider<UpdateUserProfileController, void>(
  UpdateUserProfileController.new,
);
