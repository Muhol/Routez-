import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String? phoneNumber;
  final String? avatarUrl;
  final String defaultTransportPreference;
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.defaultTransportPreference = 'matatu',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserProfile(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? 'Commuter',
      email: data['email'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String?,
      avatarUrl: data['avatarUrl'] as String?,
      defaultTransportPreference:
          data['defaultTransportPreference'] as String? ?? 'matatu',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'defaultTransportPreference': defaultTransportPreference,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserProfile copyWith({
    String? displayName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    String? defaultTransportPreference,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      defaultTransportPreference:
          defaultTransportPreference ?? this.defaultTransportPreference,
      createdAt: createdAt,
    );
  }
}
