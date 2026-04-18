import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blink/core/theme/glass_tokens.dart';
import 'package:blink/presentation/widgets/glass/glass_card.dart';
import 'package:blink/presentation/widgets/glass/glass_surface.dart';

void main() {
  group('GlassCard', () {
    testWidgets('child widgetni ko\'rsatadi', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(child: Text('Salom')),
          ),
        ),
      );

      expect(find.text('Salom'), findsOneWidget);
      expect(find.byType(GlassSurface), findsOneWidget);
    });

    testWidgets('default radius radiusCard', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(child: SizedBox.shrink()),
          ),
        ),
      );

      final card = tester.widget<GlassCard>(find.byType(GlassCard));
      expect(card.radius, GlassTokens.radiusCard);
    });

    testWidgets('onTap berilsa InkWell hosil qiladi', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassCard(
              onTap: () => tapped = true,
              child: const SizedBox(width: 100, height: 50),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GlassCard));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });
}
