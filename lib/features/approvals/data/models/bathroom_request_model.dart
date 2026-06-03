class BathroomRequestModel {
  final String id;
  final String name;
  final String address;
  final String? photoUrl;
  final bool isAccessible;
  final bool hasChangingTable;
  final bool isFree;
  final String? comment;
  final DateTime createdAt;

  BathroomRequestModel({
    required this.id,
    required this.name,
    required this.address,
    this.photoUrl,
    required this.isAccessible,
    required this.hasChangingTable,
    required this.isFree,
    this.comment,
    required this.createdAt,
  });

  factory BathroomRequestModel.fromJson(Map<String, dynamic> json) {
    return BathroomRequestModel(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      photoUrl: json['photo_url'] as String?,
      isAccessible: json['is_accessible'] as bool? ?? false,
      hasChangingTable: json['has_changing_table'] as bool? ?? false,
      isFree: json['is_free'] as bool? ?? false,
      comment: json['comment'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
    );
  }
}
