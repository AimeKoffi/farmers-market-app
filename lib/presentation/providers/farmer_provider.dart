import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'service_providers.dart';

class FarmerSearchNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  FarmerSearchNotifier(this._ref) : super(const AsyncValue.data(null));
  final Ref _ref;

  Future<void> search(String query) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _ref.read(farmerServiceProvider).search(query),
    );
  }

  Future<void> loadDebts(int farmerId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _ref.read(farmerServiceProvider).getDebts(farmerId),
    );
  }

  void clear() => state = const AsyncValue.data(null);
}

final farmerSearchProvider =
    StateNotifierProvider<FarmerSearchNotifier, AsyncValue<Map<String, dynamic>?>>(
  (ref) => FarmerSearchNotifier(ref),
);

// Provider pour un farmer par ID
final farmerDetailProvider = FutureProvider.family<Map<String, dynamic>, int>(
  (ref, id) => ref.read(farmerServiceProvider).getById(id),
);

final farmerDebtsProvider = FutureProvider.family<Map<String, dynamic>, int>(
  (ref, id) => ref.read(farmerServiceProvider).getDebts(id),
);