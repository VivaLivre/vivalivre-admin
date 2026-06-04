import '../entities/paginated_bathrooms_response.dart';

abstract class IBathroomManagementRepository {
  Future<PaginatedBathroomsResponse> getAdminBathrooms({int page = 1, int limit = 20, String? search});
  Future<void> createBathroom(Map<String, dynamic> data);
  Future<void> updateBathroom(String id, Map<String, dynamic> updates);
  Future<void> deleteBathroom(String id);
}
