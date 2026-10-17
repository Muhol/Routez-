import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/saved_location_model.dart';

class SavedLocationsRepository {
  final FirebaseFirestore _firestore;

  SavedLocationsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userSavedLocations(String uid) {
    return _firestore.collection('users').doc(uid).collection('savedLocations');
  }

  /// Watch user's saved locations collection in real-time
  Stream<List<SavedLocation>> watchSavedLocations(String uid) {
    return _userSavedLocations(uid)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SavedLocation.fromFirestore(doc))
          .toList();
    });
  }

  /// Add a new saved location to Firestore
  Future<DocumentReference<Map<String, dynamic>>> addSavedLocation(
    String uid,
    SavedLocation location,
  ) async {
    return await _userSavedLocations(uid).add(location.toMap());
  }

  /// Update an existing saved location
  Future<void> updateSavedLocation(
    String uid,
    String locationId,
    Map<String, dynamic> fields,
  ) async {
    await _userSavedLocations(uid).doc(locationId).update(fields);
  }

  /// Delete a saved location
  Future<void> deleteSavedLocation(String uid, String locationId) async {
    await _userSavedLocations(uid).doc(locationId).delete();
  }

  /// Seed initial default locations (Disabled to maintain clean empty state)
  Future<void> seedDefaultLocationsIfEmpty(String uid) async {
    // Clean state - no default dummy locations seeded
  }
}
