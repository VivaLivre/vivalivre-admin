class BathroomReport {
  final String id;
  final int bathroomId;
  final String? bathroomName;
  final int userId;
  final String? userEmail;
  final String reason;
  final String? description;
  final String status;
  final DateTime createdAt;

  BathroomReport({
    required this.id,
    required this.bathroomId,
    this.bathroomName,
    required this.userId,
    this.userEmail,
    required this.reason,
    this.description,
    required this.status,
    required this.createdAt,
  });

  factory BathroomReport.fromJson(Map<String, dynamic> json) {
    return BathroomReport(
      id: json['id'] as String,
      bathroomId: json['bathroom_id'] as int,
      bathroomName: json['bathroom_name'] as String?,
      userId: json['user_id'] as int,
      userEmail: json['user_email'] as String?,
      reason: json['reason'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
