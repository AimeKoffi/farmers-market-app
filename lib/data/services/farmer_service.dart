import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';

class FarmerService {
  final Dio _dio;
  FarmerService(ApiClient client) : _dio = client.dio;

  Future<Map<String, dynamic>> search(String query) async {
    final res = await _dio.get(ApiConstants.farmerSearch, queryParameters: {'q': query});
    return res.data['data'];
  }

  Future<Map<String, dynamic>> getById(int id) async {
    final res = await _dio.get('${ApiConstants.farmers}/$id');
    return res.data['data'];
  }

  Future<Map<String, dynamic>> getDebts(int id) async {
    final res = await _dio.get('${ApiConstants.farmers}/$id/debts');
    return res.data['data'];
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final res = await _dio.post(ApiConstants.farmers, data: data);
    return res.data['data'];
  }
}