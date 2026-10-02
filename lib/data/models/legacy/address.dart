class Address {
  final int id;
  final String? city;
  final List<String>? street;
  final String? zipCode;
  final double? longitude;
  final double? latitude;

  Address({
    required this.id,
    required this.city,
    required this.street,
    required this.zipCode,
    required this.longitude,
    required this.latitude,
  });

  // Optional: JSON serialization
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as int,
      city: json['city'] as String,
      street: (json['street'] as List<dynamic>).cast<String>(),
      zipCode: json['zip_code'] as String,
      longitude: json['longitude'] as double,
      latitude: json['latitude'] as double,
    );
  }

  // Optional: Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city': city,
      'street': street,
      'zip_code': zipCode,
      'longitude': longitude,
      'latitude': latitude,
    };
  }
}
