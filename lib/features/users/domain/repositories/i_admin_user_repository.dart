import '../entities/admin_user.dart';

abstract class IAdminUserRepository {
  Future<PaginatedUsersResponse> getUsers({
    int page = 1,
    int limit = 20,
    String search = '',
  });

  Future<void> updateUserStatus(int userId, String status);
}
