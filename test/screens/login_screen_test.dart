import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farmers_market_app/presentation/screens/auth/login_screen.dart';
import 'package:farmers_market_app/presentation/providers/service_providers.dart';
import 'package:farmers_market_app/presentation/widgets/common/app_button.dart';
import 'package:farmers_market_app/data/services/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}

// Construit l'app avec /login et un stub /farmers pour la navigation.
Widget _buildApp(MockAuthService authService) {
  final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/farmers',
        builder: (_, __) => const Scaffold(body: Text('Page agriculteurs')),
      ),
    ],
  );
  return ProviderScope(
    overrides: [authServiceProvider.overrideWithValue(authService)],
    child: MaterialApp.router(routerConfig: router),
  );
}

Future<void> _fillForm(
  WidgetTester tester, {
  String email = 'user@test.com',
  String password = 'password123',
}) async {
  await tester.enterText(find.byType(TextFormField).first, email);
  await tester.enterText(find.byType(TextFormField).last, password);
}

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockAuthService = MockAuthService();
  });

  // ─── Rendu initial ────────────────────────────────────────────────────────

  group('LoginScreen — rendu initial', () {
    testWidgets('affiche "Farmers Market"', (tester) async {
      await tester.pumpWidget(_buildApp(mockAuthService));
      await tester.pumpAndSettle();
      expect(find.text('Farmers Market'), findsOneWidget);
    });

    testWidgets('affiche le titre "Connexion"', (tester) async {
      await tester.pumpWidget(_buildApp(mockAuthService));
      await tester.pumpAndSettle();
      expect(find.text('Connexion'), findsOneWidget);
    });

    testWidgets('affiche l\'icône e-mail', (tester) async {
      await tester.pumpWidget(_buildApp(mockAuthService));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('affiche l\'icône cadenas (mot de passe)', (tester) async {
      await tester.pumpWidget(_buildApp(mockAuthService));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('affiche le bouton "Se connecter"', (tester) async {
      await tester.pumpWidget(_buildApp(mockAuthService));
      await tester.pumpAndSettle();
      expect(find.text('Se connecter'), findsOneWidget);
    });

    testWidgets('n\'affiche pas de message d\'erreur au démarrage', (tester) async {
      await tester.pumpWidget(_buildApp(mockAuthService));
      await tester.pumpAndSettle();
      expect(find.text('Identifiants incorrects.'), findsNothing);
    });
  });

  // ─── Validation ───────────────────────────────────────────────────────────

  group('LoginScreen — validation formulaire', () {
    testWidgets('email vide → "Email invalide"', (tester) async {
      await tester.pumpWidget(_buildApp(mockAuthService));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.text('Email invalide'), findsOneWidget);
    });

    testWidgets('email sans @ → "Email invalide"', (tester) async {
      await tester.pumpWidget(_buildApp(mockAuthService));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'pasunemail');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.text('Email invalide'), findsOneWidget);
    });

    testWidgets('mot de passe vide → "Mot de passe requis"', (tester) async {
      await tester.pumpWidget(_buildApp(mockAuthService));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'user@test.com');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.text('Mot de passe requis'), findsOneWidget);
    });

    testWidgets('mot de passe < 4 caractères → "Mot de passe requis"', (tester) async {
      await tester.pumpWidget(_buildApp(mockAuthService));
      await tester.pumpAndSettle();
      await _fillForm(tester, password: 'abc');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.text('Mot de passe requis'), findsOneWidget);
    });

    testWidgets('formulaire valide → aucune erreur de validation', (tester) async {
      when(() => mockAuthService.login(any(), any()))
          .thenAnswer((_) async => {'token': 'tok', 'user': {'id': 1}});
      await tester.pumpWidget(_buildApp(mockAuthService));
      await tester.pumpAndSettle();
      await _fillForm(tester);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.text('Email invalide'), findsNothing);
      expect(find.text('Mot de passe requis'), findsNothing);
    });
  });

  // ─── Visibilité du mot de passe ───────────────────────────────────────────

  group('LoginScreen — visibilité du mot de passe', () {
    testWidgets('masqué par défaut', (tester) async {
      await tester.pumpWidget(_buildApp(mockAuthService));
      await tester.pumpAndSettle();
      final fields = tester.widgetList<TextField>(find.byType(TextField)).toList();
      expect(fields.last.obscureText, isTrue);
    });

    testWidgets('tap icône → mot de passe visible', (tester) async {
      await tester.pumpWidget(_buildApp(mockAuthService));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      final fields = tester.widgetList<TextField>(find.byType(TextField)).toList();
      expect(fields.last.obscureText, isFalse);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('second tap → mot de passe re-masqué', (tester) async {
      await tester.pumpWidget(_buildApp(mockAuthService));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();
      final fields = tester.widgetList<TextField>(find.byType(TextField)).toList();
      expect(fields.last.obscureText, isTrue);
    });
  });

  // ─── Erreur d'authentification ────────────────────────────────────────────

  group('LoginScreen — erreur d\'authentification', () {
    testWidgets('affiche "Identifiants incorrects." après un échec', (tester) async {
      when(() => mockAuthService.login(any(), any()))
          .thenThrow(Exception('Unauthorized'));
      await tester.pumpWidget(_buildApp(mockAuthService));
      await tester.pumpAndSettle();
      await _fillForm(tester);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.text('Identifiants incorrects.'), findsOneWidget);
    });

    testWidgets('icône d\'erreur présente avec le message', (tester) async {
      when(() => mockAuthService.login(any(), any()))
          .thenThrow(Exception('Unauthorized'));
      await tester.pumpWidget(_buildApp(mockAuthService));
      await tester.pumpAndSettle();
      await _fillForm(tester);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });

  // ─── État de chargement ───────────────────────────────────────────────────

  group('LoginScreen — état de chargement', () {
    testWidgets('bouton en loading pendant la requête API', (tester) async {
      final completer = Completer<Map<String, dynamic>>();
      when(() => mockAuthService.login(any(), any()))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(_buildApp(mockAuthService));
      await tester.pumpAndSettle();
      await _fillForm(tester);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // démarre l'appel sans le terminer

      final btn = tester.widget<AppButton>(find.byType(AppButton));
      expect(btn.isLoading, isTrue);

      completer.complete({'token': 'tok', 'user': {'id': 1}});
      await tester.pumpAndSettle();
    });

    testWidgets('spinner visible pendant le chargement', (tester) async {
      final completer = Completer<Map<String, dynamic>>();
      when(() => mockAuthService.login(any(), any()))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(_buildApp(mockAuthService));
      await tester.pumpAndSettle();
      await _fillForm(tester);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete({'token': 'tok', 'user': {'id': 1}});
      await tester.pumpAndSettle();
    });
  });

  // ─── Navigation ───────────────────────────────────────────────────────────

  group('LoginScreen — navigation', () {
    testWidgets('navigue vers /farmers après un login réussi', (tester) async {
      when(() => mockAuthService.login(any(), any())).thenAnswer(
        (_) async => {'token': 'tok_nav', 'user': {'id': 1, 'name': 'Alice'}},
      );
      await tester.pumpWidget(_buildApp(mockAuthService));
      await tester.pumpAndSettle();
      await _fillForm(tester);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Page agriculteurs'), findsOneWidget);
    });

    testWidgets('reste sur /login après un échec', (tester) async {
      when(() => mockAuthService.login(any(), any()))
          .thenThrow(Exception('Unauthorized'));
      await tester.pumpWidget(_buildApp(mockAuthService));
      await tester.pumpAndSettle();
      await _fillForm(tester);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Connexion'), findsOneWidget);
      expect(find.text('Page agriculteurs'), findsNothing);
    });
  });
}
