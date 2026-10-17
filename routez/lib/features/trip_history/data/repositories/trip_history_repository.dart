import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip_model.dart';

class TripHistoryRepository {
  final FirebaseFirestore _firestore;

  TripHistoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _tripsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('tripHistory');
  }

  /// Watch real-time trip history for a user
  Stream<List<TripModel>> watchTripHistory(String uid) {
    return _tripsRef(uid)
        .orderBy('departedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TripModel.fromFirestore(doc)).toList());
  }

  /// Record a new trip to Firestore
  Future<void> addTrip(String uid, TripModel trip) async {
    await _tripsRef(uid).add(trip.toMap());
  }

  /// Clear all trip history for a user
  Future<void> clearAllTrips(String uid) async {
    final docs = await _tripsRef(uid).get();
    final batch = _firestore.batch();
    for (final doc in docs.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
