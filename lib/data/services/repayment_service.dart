import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';

class RepaymentService {
  final Dio _dio;
  RepaymentService(ApiClient client) : _dio = client.dio;

  Future<Map<String, dynamic>> recordRepayment({
    required int farmerId,
    required double kgReceived,
  }) async {
    final res = await _dio.post(ApiConstants.repayments, data: {
      'farmer_id': farmerId,
      'kg_received': kgReceived,
    });
    return res.data['data'];
  }
}