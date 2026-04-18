import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blink/presentation/widgets/glass/glass_fab.dart';
import 'package:blink/presentation/widgets/glass/glass_surface.dart';

void main() {
  group('GlassFab', () {
    testWidgets('icon va GlassSurface ko\'rsatadi', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassFab(
              icon: Icons.my_location,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.my_location), findsOneWidget);
      expect(find.byType(GlassSurface), findsOneWidget);
    });

    testWidgets('tap onPressedni chaqiradi', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassFab(
              icon: Icons.refresh,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('size parametri o\'lchamni belgilaydi', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassFab(
              icon: Icons.add,
              size: 48,
              onPressed: () {},
            ),
          ),
        ),
      );

      final box = tester.getSize(find.byType(GlassFab));
      expect(box.width, 48);
      expect(box.height, 48);
    });
  });
}
