class BathroomRequestEntity {
  final String id;
  final String name;
  final String address;
  final String photoUrl;
  final bool isAccessible;
  final bool hasChangingTable;
  final bool isFree;
  final String comment;
  final DateTime createdAt;

  const BathroomRequestEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.photoUrl,
    required this.isAccessible,
    required this.hasChangingTable,
    required this.isFree,
    required this.comment,
    required this.createdAt,
  });
}
