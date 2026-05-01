import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:farmers_market_app/presentation/providers/farmer_provider.dart';
import 'package:farmers_market_app/presentation/providers/service_providers.dart';
import 'package:farmers_market_app/data/services/farmer_service.dart';

class MockFarmerService extends Mock implements FarmerService {}

void main() {
  late MockFarmerService mockService;
  late ProviderContainer container;

  setUp(() {
    mockService = MockFarmerService();
    container = ProviderContainer(
      overrides: [
        farmerServiceProvider.overrideWithValue(mockService),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('FarmerSearchNotifier', () {
    test('état initial est data(null)', () {
      expect(container.read(farmerSearchProvider).value, isNull);
      expect(container.read(farmerSearchProvider).isLoading, isFalse);
    });

    test('search — passe en loading puis retourne les données', () async {
      final farmer = {'id': 1, 'name': 'Jean Dupont', 'phone': '0612'};
      when(() => mockService.search('Jean')).thenAnswer((_) async => farmer);

      final future = container.read(farmerSearchProvider.notifier).search('Jean');
      expect(container.read(farmerSearchProvider).isLoading, isTrue);

      await future;

      expect(container.read(farmerSearchProvider).value, farmer);
      expect(container.read(farmerSearchProvider).isLoading, isFalse);
    });

    test('search — enregistre l\'erreur en cas d\'échec réseau', () async {
      when(() => mockService.search(any())).thenThrow(Exception('Erreur réseau'));

      await container.read(farmerSearchProvider.notifier).search('test');

      expect(container.read(farmerSearchProvider).hasError, isTrue);
      expect(container.read(farmerSearchProvider).isLoading, isFalse);
    });

    test('search — appelle le service avec le bon query', () async {
      when(() => mockService.search('Marie')).thenAnswer((_) async => {'id': 2});

      await container.read(farmerSearchProvider.notifier).search('Marie');

      verify(() => mockService.search('Marie')).called(1);
    });

    test('clear — remet l\'état à data(null)', () async {
      when(() => mockService.search('Jean')).thenAnswer((_) async => {'id': 1});
      await container.read(farmerSearchProvider.notifier).search('Jean');

      container.read(farmerSearchProvider.notifier).clear();

      expect(container.read(farmerSearchProvider).value, isNull);
      expect(container.read(farmerSearchProvider).hasError, isFalse);
    });

    test('clear depuis un état d\'erreur remet data(null)', () async {
      when(() => mockService.search(any())).thenThrow(Exception('fail'));
      await container.read(farmerSearchProvider.notifier).search('x');

      container.read(farmerSearchProvider.notifier).clear();

      expect(container.read(farmerSearchProvider).value, isNull);
      expect(container.read(farmerSearchProvider).hasError, isFalse);
    });
  });

  group('farmerDetailProvider', () {
    test('retourne les détails du farmer', () async {
      final detail = {'id': 5, 'name': 'Pierre Martin'};
      when(() => mockService.getById(5)).thenAnswer((_) async => detail);

      final result = await container.read(farmerDetailProvider(5).future);

      expect(result, detail);
      verify(() => mockService.getById(5)).called(1);
    });
  });

  group('farmerDebtsProvider', () {
    test('retourne les dettes du farmer', () async {
      final debts = {'total': 150.0, 'items': []};
      when(() => mockService.getDebts(3)).thenAnswer((_) async => debts);

      final result = await container.read(farmerDebtsProvider(3).future);

      expect(result, debts);
      verify(() => mockService.getDebts(3)).called(1);
    });
  });
}
