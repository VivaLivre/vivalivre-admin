import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final Dio dio;
  final SharedPreferences prefs;

  AuthRepositoryImpl({required this.dio, required this.prefs});

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final response = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data;
      final token = data['token'];
      final user = data['user'];

      // Salva o token localmente para o TokenInterceptor usar
      await prefs.setString('jwt_token', token);

      return UserEntity(
        id: user['id'].toString(),
        name: user['name'],
        email: user['email'],
      );
    } catch (e) {
      throw Exception('Falha no login. Verifique suas credenciais.');
    }
  }
}
