import 'package:dio/dio.dart';
import '../../domain/entities/bathroom_request_entity.dart';
import '../../domain/repositories/i_admin_moderation_repository.dart';
import '../models/bathroom_request_model.dart';

class AdminModerationRepositoryImpl implements IAdminModerationRepository {
  final Dio dio;

  AdminModerationRepositoryImpl({required this.dio});

  @override
  Future<List<BathroomRequestEntity>> getPendingRequests() async {
    try {
      final response = await dio.get('/api/admin/bathrooms/pending');
      
      final data = response.data as List?;
      if (data == null) return [];

      return data.map((json) => BathroomRequestModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar locais pendentes: $e');
    }
  }

  @override
  Future<void> updateRequestStatus(String id, String status) async {
    try {
      await dio.patch(
        '/api/admin/bathrooms/$id/status',
        data: {'status': status},
      );
    } catch (e) {
      throw Exception('Erro ao atualizar status do local: $e');
    }
  }
}
