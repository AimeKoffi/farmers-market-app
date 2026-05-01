import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farmers_market_app/presentation/providers/auth_provider.dart';
import 'package:farmers_market_app/core/constants/storage_keys.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthState', () {
    test('état initial vide', () {
      const state = AuthState();
      expect(state.token, isNull);
      expect(state.user, isNull);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('copyWith met à jour les champs', () {
      const state = AuthState();
      final updated = state.copyWith(token: 'abc', isLoading: true);
      expect(updated.token, 'abc');
      expect(updated.isLoading, isTrue);
      expect(updated.user, isNull);
    });

    test('copyWith préserve les champs non modifiés', () {
      const state = AuthState(token: 'abc', user: {'id': 1});
      final updated = state.copyWith(isLoading: true);
      expect(updated.token, 'abc');
      expect(updated.user, {'id': 1});
      expect(updated.isLoading, isTrue);
    });

    test('copyWith clearToken supprime le token', () {
      const state = AuthState(token: 'abc');
      final updated = state.copyWith(clearToken: true);
      expect(updated.token, isNull);
    });

    test('copyWith efface error si non fourni', () {
      const state = AuthState(error: 'ancien error');
      final updated = state.copyWith(isLoading: true);
      expect(updated.error, isNull);
    });
  });

  group('AuthNotifier — login', () {
    test('succès : stocke le token et met à jour l\'état', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(authProvider.notifier).login(
        'user@test.com',
        'password',
        (e, p) async => {'token': 'tok_123', 'user': {'id': 1, 'name': 'Alice'}},
      );

      expect(result, isTrue);
      final state = container.read(authProvider);
      expect(state.token, 'tok_123');
      expect(state.user?['name'], 'Alice');
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('succès : persiste le token dans SharedPreferences', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(authProvider.notifier).login(
        'user@test.com',
        'password',
        (e, p) async => {'token': 'tok_persist', 'user': {}},
      );

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(StorageKeys.authToken), 'tok_persist');
    });

    test('échec : retourne false et enregistre l\'erreur', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(authProvider.notifier).login(
        'user@test.com',
        'mauvais_mdp',
        (e, p) async => throw Exception('Identifiants incorrects'),
      );

      expect(result, isFalse);
      final state = container.read(authProvider);
      expect(state.token, isNull);
      expect(state.error, isNotNull);
      expect(state.isLoading, isFalse);
    });

    test('isLoading est true pendant l\'appel API', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      bool loadingObserved = false;
      final future = container.read(authProvider.notifier).login(
        'user@test.com',
        'password',
        (e, p) async {
          loadingObserved = container.read(authProvider).isLoading;
          return {'token': 'tok', 'user': {}};
        },
      );

      await future;
      expect(loadingObserved, isTrue);
    });
  });

  group('AuthNotifier — logout', () {
    test('vide l\'état complet', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(authProvider.notifier).login(
        'u@u.com',
        'p',
        (e, p) async => {'token': 'tok', 'user': {'id': 2}},
      );

      await container.read(authProvider.notifier).logout();

      final state = container.read(authProvider);
      expect(state.token, isNull);
      expect(state.user, isNull);
      expect(state.isLoading, isFalse);
    });

    test('supprime le token de SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({StorageKeys.authToken: 'old_tok'});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(authProvider.notifier).logout();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(StorageKeys.authToken), isNull);
    });
  });
}
