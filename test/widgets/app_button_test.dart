import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmers_market_app/presentation/widgets/common/app_button.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('AppButton — variant normal (ElevatedButton)', () {
    testWidgets('affiche le label', (tester) async {
      await tester.pumpWidget(_wrap(const AppButton(label: 'Connexion')));
      expect(find.text('Connexion'), findsOneWidget);
    });

    testWidgets('appelle onPressed au tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrap(AppButton(label: 'Tap', onPressed: () => tapped = true)),
      );
      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, isTrue);
    });

    testWidgets('bouton désactivé quand isLoading=true', (tester) async {
      await tester.pumpWidget(
        _wrap(AppButton(label: 'Chargement', isLoading: true, onPressed: () {})),
      );
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('affiche CircularProgressIndicator et cache le label quand isLoading', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppButton(label: 'Connexion', isLoading: true)),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Connexion'), findsNothing);
    });

    testWidgets('affiche l\'icône quand fournie', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppButton(label: 'Ajouter', icon: Icons.add)),
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('n\'affiche pas d\'icône par défaut', (tester) async {
      await tester.pumpWidget(_wrap(const AppButton(label: 'Sans icône')));
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('bouton désactivé sans onPressed (null)', (tester) async {
      await tester.pumpWidget(_wrap(const AppButton(label: 'Inactif')));
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    });
  });

  group('AppButton — variant outlined (OutlinedButton)', () {
    testWidgets('utilise OutlinedButton quand outlined=true', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppButton(label: 'Annuler', outlined: true)),
      );
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('affiche le label', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppButton(label: 'Annuler', outlined: true)),
      );
      expect(find.text('Annuler'), findsOneWidget);
    });

    testWidgets('désactivé quand isLoading=true', (tester) async {
      await tester.pumpWidget(
        _wrap(AppButton(label: 'Wait', outlined: true, isLoading: true, onPressed: () {})),
      );
      final btn = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(btn.onPressed, isNull);
    });
  });
}
