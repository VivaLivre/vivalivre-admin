import 'package:dio/dio.dart';
import '../../data/models/bathroom_request_model.dart';

class AdminRepository {
  final Dio dio;
  final String baseUrl = 'http://localhost:8080/api';

  AdminRepository({Dio? dioClient}) : dio = dioClient ?? Dio();

  Future<List<BathroomRequestModel>> getPendingBathrooms() async {
    try {
      final response = await dio.get('$baseUrl/admin/bathrooms/pending');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => BathroomRequestModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load pending bathrooms');
      }
    } catch (e) {
      throw Exception('Error fetching pending bathrooms: $e');
    }
  }

  Future<void> updateBathroomStatus(String id, String status) async {
    try {
      final response = await dio.patch(
        '$baseUrl/admin/bathrooms/$id/status',
        data: {'status': status},
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to update bathroom status');
      }
    } catch (e) {
      throw Exception('Error updating bathroom status: $e');
    }
  }
}
