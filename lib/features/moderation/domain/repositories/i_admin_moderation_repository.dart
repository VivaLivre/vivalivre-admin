import '../entities/bathroom_request_entity.dart';

abstract class IAdminModerationRepository {
  Future<List<BathroomRequestEntity>> getPendingRequests();
  Future<void> updateRequestStatus(String id, String status);
}
