import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blink/presentation/widgets/glass/glass_capsule_nav.dart';
import 'package:blink/presentation/widgets/glass/glass_surface.dart';

void main() {
  group('GlassCapsuleNav', () {
    const items = [
      GlassNavItem(icon: Icons.map_outlined, activeIcon: Icons.map),
      GlassNavItem(
        icon: Icons.people_outline,
        activeIcon: Icons.people,
        badgeCount: 0,
      ),
      GlassNavItem(icon: Icons.person_outline, activeIcon: Icons.person),
    ];

    testWidgets('3 ta tabni render qiladi', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassCapsuleNav(
              currentIndex: 0,
              items: items,
              onTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(GlassSurface), findsOneWidget);
      expect(find.byIcon(Icons.map), findsOneWidget); // active
      expect(find.byIcon(Icons.people_outline), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('tap onTap callbackni indeks bilan chaqiradi', (tester) async {
      int? tapped;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassCapsuleNav(
              currentIndex: 0,
              items: items,
              onTap: (i) => tapped = i,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.people_outline));
      await tester.pumpAndSettle();
      expect(tapped, 1);
    });

    testWidgets('badgeCount > 0 bo\'lsa raqamni ko\'rsatadi', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassCapsuleNav(
              currentIndex: 0,
              items: const [
                GlassNavItem(icon: Icons.map_outlined, activeIcon: Icons.map),
                GlassNavItem(
                  icon: Icons.people_outline,
                  activeIcon: Icons.people,
                  badgeCount: 3,
                ),
                GlassNavItem(
                    icon: Icons.person_outline, activeIcon: Icons.person),
              ],
              onTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('badgeCount = 0 bo\'lsa raqam yo\'q', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassCapsuleNav(
              currentIndex: 0,
              items: items,
              onTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('0'), findsNothing);
    });

    testWidgets('currentIndex tabning activeIcon ko\'rinadi', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassCapsuleNav(
              currentIndex: 2,
              items: items,
              onTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget); // active
      expect(find.byIcon(Icons.map_outlined), findsOneWidget); // inactive
    });
  });
}
