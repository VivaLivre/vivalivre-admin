import 'dart:convert';
import 'package:dio/dio.dart';
import '../../domain/entities/paginated_bathrooms_response.dart';
import '../../domain/repositories/i_bathroom_management_repository.dart';

class BathroomManagementRepositoryImpl implements IBathroomManagementRepository {
  final Dio dio;

  BathroomManagementRepositoryImpl(this.dio);

  @override
  Future<PaginatedBathroomsResponse> getAdminBathrooms({int page = 1, int limit = 20, String? search}) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await dio.get(
        '/api/admin/bathrooms',
        queryParameters: queryParams,
      );

      return PaginatedBathroomsResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['error'] ?? 'Erro ao buscar banheiros: ${e.message}');
      }
      throw Exception('Erro ao buscar banheiros: $e');
    }
  }

  @override
  Future<void> createBathroom(Map<String, dynamic> data) async {
    try {
      final formData = await _convertToFormData(data);
      await dio.post(
        '/api/admin/bathrooms',
        data: formData,
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['error'] ?? 'Erro ao criar banheiro: ${e.message}');
      }
      throw Exception('Erro ao criar banheiro: $e');
    }
  }

  @override
  Future<void> updateBathroom(String id, Map<String, dynamic> updates) async {
    try {
      final formData = await _convertToFormData(updates);
      await dio.patch(
        '/api/admin/bathrooms/$id',
        data: formData,
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['error'] ?? 'Erro ao atualizar banheiro: ${e.message}');
      }
      throw Exception('Erro ao atualizar banheiro: $e');
    }
  }

  Future<FormData> _convertToFormData(Map<String, dynamic> data) async {
    final Map<String, dynamic> formMap = {};
    
    for (var entry in data.entries) {
      if (entry.key == 'photo_file' && entry.value != null) {
        // Handling XFile attachment
        final file = entry.value;
        final bytes = await file.readAsBytes();
        formMap['photo'] = MultipartFile.fromBytes(
          bytes,
          filename: file.name,
        );
      } else if (entry.value != null) {
        if (entry.value is Map || entry.value is List) {
          formMap[entry.key] = jsonEncode(entry.value);
        } else {
          formMap[entry.key] = entry.value.toString();
        }
      }
    }

    return FormData.fromMap(formMap);
  }

  @override
  Future<void> deleteBathroom(String id) async {
    try {
      await dio.delete(
        '/api/admin/bathrooms/$id',
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['error'] ?? 'Erro ao deletar banheiro: ${e.message}');
      }
      throw Exception('Erro ao deletar banheiro: $e');
    }
  }
}

