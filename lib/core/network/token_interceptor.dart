import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';

class TokenInterceptor extends Interceptor {
  final SharedPreferences prefs;

  TokenInterceptor({required this.prefs});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = prefs.getString('jwt_token');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      prefs.remove('jwt_token');
      globalNavigatorKey.currentState?.pushReplacementNamed('/admin/login');
    }
    super.onError(err, handler);
  }
}
