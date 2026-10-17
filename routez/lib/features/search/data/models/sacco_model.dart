class SaccoModel {
  final String id;
  final String name;
  final String? logoUrl;
  final String? contactPhone;
  final double rating;

  SaccoModel({
    required this.id,
    required this.name,
    this.logoUrl,
    this.contactPhone,
    this.rating = 4.5,
  });

  factory SaccoModel.fromJson(Map<String, dynamic> json) {
    return SaccoModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Matatu Sacco',
      logoUrl: json['logo_url'] as String?,
      contactPhone: json['contact_phone'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo_url': logoUrl,
      'contact_phone': contactPhone,
      'rating': rating,
    };
  }
}
