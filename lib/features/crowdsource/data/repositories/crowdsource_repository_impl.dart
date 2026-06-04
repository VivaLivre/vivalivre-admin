import 'package:dio/dio.dart';
import '../../domain/entities/bathroom_report.dart';
import '../../domain/entities/bathroom_suggestion.dart';
import '../../domain/repositories/i_crowdsource_repository.dart';

class CrowdsourceRepositoryImpl implements ICrowdsourceRepository {
  final Dio dio;

  CrowdsourceRepositoryImpl({required this.dio});

  @override
  Future<List<BathroomReport>> getReports() async {
    try {
      final response = await dio.get('/api/admin/reports');
      final data = response.data as List;
      return data.map((e) => BathroomReport.fromJson(e)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<BathroomSuggestion>> getSuggestions() async {
    try {
      final response = await dio.get('/api/admin/suggestions');
      final data = response.data as List;
      return data.map((e) => BathroomSuggestion.fromJson(e)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> updateReportStatus(String id, String status) async {
    try {
      await dio.patch('/api/admin/reports/$id/status', data: {
        'status': status,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> updateSuggestionStatus(String id, String status) async {
    try {
      await dio.patch('/api/admin/suggestions/$id/status', data: {
        'status': status,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic e) {
    if (e is DioException) {
      if (e.response != null) {
        final data = e.response!.data;
        if (data is Map && data['error'] != null) {
          return Exception(data['error']);
        }
      }
      return Exception(e.message ?? 'Erro de conexão.');
    }
    return Exception(e.toString());
  }
}
