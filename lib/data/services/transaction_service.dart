import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/storage_keys.dart';

class TransactionService {
  final Dio _dio;
  TransactionService(ApiClient client) : _dio = client.dio;

  Future<Map<String, dynamic>> createTransaction(Map<String, dynamic> data) async {
    final connectivity = await Connectivity().checkConnectivity();
    final isOnline = connectivity != ConnectivityResult.none;

    if (!isOnline) {
      // Sauvegarde offline
      final box = await Hive.openBox('cache');
      final queue = List<Map>.from(box.get(StorageKeys.offlineQueue) ?? []);
      queue.add({...data, '_queued_at': DateTime.now().toIso8601String()});
      await box.put(StorageKeys.offlineQueue, queue);
      return {'offline': true, 'message': 'Transaction sauvegardée hors ligne.'};
    }

    final res = await _dio.post(ApiConstants.transactions, data: data);
    return res.data['data'];
  }

  Future<void> syncOfflineQueue() async {
    final box = await Hive.openBox('cache');
    final queue = List<Map>.from(box.get(StorageKeys.offlineQueue) ?? []);
    if (queue.isEmpty) return;

    final synced = <Map>[];
    for (final tx in queue) {
      try {
        final payload = Map<String, dynamic>.from(tx)..remove('_queued_at');
        await _dio.post(ApiConstants.transactions, data: payload);
        synced.add(tx);
      } catch (_) {
        break; // On arrête au premier échec
      }
    }

    queue.removeWhere((tx) => synced.contains(tx));
    await box.put(StorageKeys.offlineQueue, queue);
  }
}