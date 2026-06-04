class Bathroom {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final bool isAccessible;
  final bool hasChangingTable;
  final bool isFree;
  final String status;
  final String? photoUrl;
  final dynamic operatingHours;
  final double? cleanlinessRating;
  final double? accessibilityRating;

  Bathroom({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.isAccessible,
    required this.hasChangingTable,
    required this.isFree,
    required this.status,
    this.photoUrl,
    this.operatingHours,
    this.cleanlinessRating,
    this.accessibilityRating,
  });

  factory Bathroom.fromJson(Map<String, dynamic> json) {
    return Bathroom(
      id: json['id'].toString(), // Go backend ID is int, so convert to string
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      isAccessible: json['is_accessible'] ?? false,
      hasChangingTable: json['has_changing_table'] ?? false,
      isFree: json['is_free'] ?? false,
      status: json['status'] ?? 'pending',
      photoUrl: json['photo_url'],
      operatingHours: json['operating_hours'],
      cleanlinessRating: json['cleanliness_rating']?.toDouble(),
      accessibilityRating: json['accessibility_rating']?.toDouble(),
    );
  }
}
