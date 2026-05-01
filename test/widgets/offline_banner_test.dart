import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmers_market_app/presentation/widgets/common/offline_banner.dart';

void main() {
  group('OfflineBanner', () {
    testWidgets('se construit sans erreur', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: OfflineBanner())),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('invisible au démarrage — stream sans données initiales', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: OfflineBanner())),
      );
      // Le StreamBuilder n'a pas encore reçu de données → isOffline = false
      expect(find.text('Mode hors ligne — les transactions seront synchronisées'), findsNothing);
      expect(find.byIcon(Icons.wifi_off), findsNothing);
    });

    testWidgets('retourne SizedBox.shrink quand pas de données dans le stream', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: OfflineBanner())),
      );
      // Aucun Container coloré visible (le banner orange)
      final containers = tester.widgetList<Container>(find.byType(Container));
      final hasBannerColor = containers.any((c) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration) return false;
        return c.color != null;
      });
      expect(hasBannerColor, isFalse);
    });
  });
}
