import '../../domain/entities/bathroom_request_entity.dart';

class BathroomRequestModel extends BathroomRequestEntity {
  const BathroomRequestModel({
    required super.id,
    required super.name,
    required super.address,
    required super.photoUrl,
    required super.isAccessible,
    required super.hasChangingTable,
    required super.isFree,
    required super.comment,
    required super.createdAt,
  });

  factory BathroomRequestModel.fromJson(Map<String, dynamic> json) {
    return BathroomRequestModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Sem Nome',
      address: json['address'] ?? 'Endereço não informado',
      photoUrl: json['photo_url'] ?? '',
      isAccessible: json['is_accessible'] ?? false,
      hasChangingTable: json['has_changing_table'] ?? false,
      isFree: json['is_free'] ?? false,
      comment: json['comment'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'photo_url': photoUrl,
      'is_accessible': isAccessible,
      'has_changing_table': hasChangingTable,
      'is_free': isFree,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
