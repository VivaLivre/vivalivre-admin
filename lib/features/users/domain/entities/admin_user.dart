import 'package:equatable/equatable.dart';

class AdminUser extends Equatable {
  final int id;
  final String name;
  final String email;
  final String role;
  final String status;
  final DateTime createdAt;

  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, email, role, status, createdAt];
}

class PaginationMeta extends Equatable {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const PaginationMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [total, page, limit, totalPages];
}

class PaginatedUsersResponse extends Equatable {
  final List<AdminUser> data;
  final PaginationMeta meta;

  const PaginatedUsersResponse({required this.data, required this.meta});

  @override
  List<Object?> get props => [data, meta];
}
