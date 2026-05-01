import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';

class AuthService {
  final Dio _dio;
  AuthService(ApiClient client) : _dio = client.dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _dio.post(ApiConstants.login, data: {
      'email': email,
      'password': password,
    });
    return res.data['data'];
  }

  Future<void> logout() async {
    await _dio.post(ApiConstants.logout);
  }
}