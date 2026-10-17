import 'package:cloud_firestore/cloud_firestore.dart';

class SavedLocation {
  final String id;
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;
  final String iconName;
  final String colorHex;
  final String routes;
  final DateTime createdAt;

  SavedLocation({
    required this.id,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
    this.iconName = 'place_outlined',
    this.colorHex = 'FF1E88E5',
    this.routes = 'Direct Matatu Route',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SavedLocation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SavedLocation(
      id: doc.id,
      name: data['name'] as String? ?? 'Saved Location',
      address: data['address'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      iconName: data['iconName'] as String? ?? 'place_outlined',
      colorHex: data['colorHex'] as String? ?? 'FF1E88E5',
      routes: data['routes'] as String? ?? 'Direct Matatu Route',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'iconName': iconName,
      'colorHex': colorHex,
      'routes': routes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  SavedLocation copyWith({
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? iconName,
    String? colorHex,
    String? routes,
  }) {
    return SavedLocation(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      routes: routes ?? this.routes,
      createdAt: createdAt,
    );
  }
}
