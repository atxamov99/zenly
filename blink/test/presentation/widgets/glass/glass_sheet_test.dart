import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blink/presentation/widgets/glass/glass_sheet.dart';
import 'package:blink/presentation/widgets/glass/glass_surface.dart';

void main() {
  group('GlassSheet', () {
    testWidgets('child va GlassSurface ko\'rsatadi', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassSheet(child: Text('Sheet')),
          ),
        ),
      );

      expect(find.text('Sheet'), findsOneWidget);
      expect(find.byType(GlassSurface), findsOneWidget);
    });

    testWidgets('drag handle ko\'rsatadi', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassSheet(child: SizedBox(height: 80)),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('glass-sheet-handle')), findsOneWidget);
    });
  });
}
