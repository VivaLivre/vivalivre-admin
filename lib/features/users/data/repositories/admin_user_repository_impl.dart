import 'package:dio/dio.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/repositories/i_admin_user_repository.dart';

class AdminUserRepositoryImpl implements IAdminUserRepository {
  final Dio dio;

  AdminUserRepositoryImpl({required this.dio});

  @override
  Future<PaginatedUsersResponse> getUsers({
    int page = 1,
    int limit = 20,
    String search = '',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await dio.get(
      '/api/admin/users',
      queryParameters: queryParams,
    );

    final List<dynamic> rawData = response.data['data'] as List<dynamic>? ?? [];
    final rawMeta = response.data['meta'] as Map<String, dynamic>? ?? {};

    final users = rawData
        .map((item) => AdminUser(
              id: item['id'] as int,
              name: item['name'] as String? ?? '',
              email: item['email'] as String? ?? '',
              role: item['role'] as String? ?? 'user',
              status: item['status'] as String? ?? 'active',
              createdAt: DateTime.tryParse(item['created_at'] as String? ?? '') ??
                  DateTime.now(),
            ))
        .toList();

    final meta = PaginationMeta(
      total: rawMeta['total'] as int? ?? 0,
      page: rawMeta['page'] as int? ?? page,
      limit: rawMeta['limit'] as int? ?? limit,
      totalPages: rawMeta['total_pages'] as int? ?? 1,
    );

    return PaginatedUsersResponse(data: users, meta: meta);
  }

  @override
  Future<void> updateUserStatus(int userId, String status) async {
    await dio.patch(
      '/api/admin/users/$userId/status',
      data: {'status': status},
    );
  }
}
