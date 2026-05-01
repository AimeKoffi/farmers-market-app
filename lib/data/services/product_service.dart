import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/storage_keys.dart';

class ProductService {
  final Dio _dio;
  ProductService(ApiClient client) : _dio = client.dio;

  Future<List<dynamic>> getCategories() async {
    try {
      final res = await _dio.get(ApiConstants.categories);
      final data = res.data['data'] as List;
      // Cache local pour offline
      final box = await Hive.openBox('cache');
      await box.put(StorageKeys.categories, data);
      return data;
    } catch (_) {
      // Fallback offline
      final box = await Hive.openBox('cache');
      return (box.get(StorageKeys.categories) as List?) ?? [];
    }
  }

  Future<List<dynamic>> getProducts() async {
    try {
      final res = await _dio.get(ApiConstants.products);
      final data = res.data['data'] as List;
      final box = await Hive.openBox('cache');
      await box.put(StorageKeys.products, data);
      return data;
    } catch (_) {
      final box = await Hive.openBox('cache');
      return (box.get(StorageKeys.products) as List?) ?? [];
    }
  }
}