import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blink/core/theme/glass_tokens.dart';
import 'package:blink/presentation/widgets/glass/glass_surface.dart';

void main() {
  group('GlassSurface', () {
    testWidgets('child widgetni ko\'rsatadi', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassSurface(
              child: Text('Salom'),
            ),
          ),
        ),
      );

      expect(find.text('Salom'), findsOneWidget);
    });

    testWidgets('default blur regular ekanligini tekshiradi', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassSurface(child: SizedBox.shrink()),
          ),
        ),
      );

      final surface = tester.widget<GlassSurface>(find.byType(GlassSurface));
      expect(surface.blur, GlassTokens.blurRegular);
      expect(surface.tintOpacity, 0.14);
      expect(surface.radius, GlassTokens.radiusCard);
      expect(surface.specular, isTrue);
    });

    testWidgets('BackdropFilter va ClipRRect hosil qiladi', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassSurface(
              blur: 40,
              radius: 32,
              child: SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(find.byType(ClipRRect), findsOneWidget);
    });
  });
}
