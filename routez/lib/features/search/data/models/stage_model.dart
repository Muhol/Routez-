class StageModel {
  final String id;
  final String name;
  final String area;
  final double latitude;
  final double longitude;

  StageModel({
    required this.id,
    required this.name,
    required this.area,
    required this.latitude,
    required this.longitude,
  });

  factory StageModel.fromJson(Map<String, dynamic> json) {
    return StageModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Stage',
      area: json['area'] as String? ?? 'Nairobi',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'area': area,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
