import 'bathroom.dart';

class PaginationMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginationMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      totalPages: json['total_pages'] ?? 1,
    );
  }
}

class PaginatedBathroomsResponse {
  final List<Bathroom> data;
  final PaginationMeta meta;

  PaginatedBathroomsResponse({
    required this.data,
    required this.meta,
  });

  factory PaginatedBathroomsResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedBathroomsResponse(
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => Bathroom.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      meta: PaginationMeta.fromJson(json['meta'] ?? {}),
    );
  }
}
