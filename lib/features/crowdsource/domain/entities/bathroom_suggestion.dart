class BathroomSuggestion {
  final String id;
  final int bathroomId;
  final String? bathroomName;
  final int userId;
  final String? userEmail;
  final Map<String, dynamic> suggestedUpdates;
  final String status;
  final DateTime createdAt;

  BathroomSuggestion({
    required this.id,
    required this.bathroomId,
    this.bathroomName,
    required this.userId,
    this.userEmail,
    required this.suggestedUpdates,
    required this.status,
    required this.createdAt,
  });

  factory BathroomSuggestion.fromJson(Map<String, dynamic> json) {
    return BathroomSuggestion(
      id: json['id'] as String,
      bathroomId: json['bathroom_id'] as int,
      bathroomName: json['bathroom_name'] as String?,
      userId: json['user_id'] as int,
      userEmail: json['user_email'] as String?,
      suggestedUpdates: json['suggested_updates'] as Map<String, dynamic>? ?? {},
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
