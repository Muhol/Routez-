import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile_model.dart';

class UserProfileRepository {
  final FirebaseFirestore _firestore;

  UserProfileRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// Create a new user profile doc in Firestore
  Future<void> createProfile(UserProfile profile) async {
    await _usersCollection.doc(profile.uid).set(profile.toMap());
  }

  /// Fetch user profile once
  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  /// Watch user profile doc in real-time
  Stream<UserProfile?> watchProfile(String uid) {
    return _usersCollection.doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return UserProfile.fromFirestore(snapshot);
    });
  }

  /// Update fields in user profile
  Future<void> updateProfile(String uid, Map<String, dynamic> fields) async {
    await _usersCollection.doc(uid).update(fields);
  }
}
