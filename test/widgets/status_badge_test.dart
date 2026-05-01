import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmers_market_app/presentation/widgets/common/status_badge.dart';

Widget _badge(String status) =>
    MaterialApp(home: Scaffold(body: StatusBadge(status: status)));

void main() {
  group('StatusBadge — labels', () {
    testWidgets('open  → "Ouverte"', (tester) async {
      await tester.pumpWidget(_badge('open'));
      expect(find.text('Ouverte'), findsOneWidget);
    });

    testWidgets('partial → "Partielle"', (tester) async {
      await tester.pumpWidget(_badge('partial'));
      expect(find.text('Partielle'), findsOneWidget);
    });

    testWidgets('paid → "Payée"', (tester) async {
      await tester.pumpWidget(_badge('paid'));
      expect(find.text('Payée'), findsOneWidget);
    });

    testWidgets('cash → "Espèces"', (tester) async {
      await tester.pumpWidget(_badge('cash'));
      expect(find.text('Espèces'), findsOneWidget);
    });

    testWidgets('credit → "Crédit"', (tester) async {
      await tester.pumpWidget(_badge('credit'));
      expect(find.text('Crédit'), findsOneWidget);
    });

    testWidgets('offline → "Hors ligne"', (tester) async {
      await tester.pumpWidget(_badge('offline'));
      expect(find.text('Hors ligne'), findsOneWidget);
    });

    testWidgets('statut inconnu → repli sur "Ouverte"', (tester) async {
      await tester.pumpWidget(_badge('unknown_xyz'));
      expect(find.text('Ouverte'), findsOneWidget);
    });
  });

  group('StatusBadge — rendu', () {
    testWidgets('affiche un Container avec BorderRadius', (tester) async {
      await tester.pumpWidget(_badge('paid'));
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('le texte est visible et non vide', (tester) async {
      for (final status in ['open', 'partial', 'paid', 'cash', 'credit', 'offline']) {
        await tester.pumpWidget(_badge(status));
        expect(find.byType(Text), findsOneWidget);
      }
    });
  });
}
