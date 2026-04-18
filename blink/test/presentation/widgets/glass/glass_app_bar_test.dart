import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blink/presentation/widgets/glass/glass_app_bar.dart';
import 'package:blink/presentation/widgets/glass/glass_surface.dart';

void main() {
  group('GlassAppBar', () {
    testWidgets('title va GlassSurface ko\'rsatadi', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: GlassAppBar(title: Text('Sozlamalar')),
            body: SizedBox.expand(),
          ),
        ),
      );

      expect(find.text('Sozlamalar'), findsOneWidget);
      expect(find.byType(GlassSurface), findsOneWidget);
    });

    testWidgets('actions widgetlarini render qiladi', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: GlassAppBar(
              title: const Text('X'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {},
                ),
              ],
            ),
            body: const SizedBox.expand(),
          ),
        ),
      );

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('preferredSize standart AppBar balandligi', (tester) async {
      const bar = GlassAppBar(title: Text('X'));
      expect(bar.preferredSize.height, kToolbarHeight);
    });
  });
}
