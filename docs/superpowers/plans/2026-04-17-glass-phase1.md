# Glass Phase 1 — GlassSurface + Capsule BottomNav Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Liquid Glass dizayn tilining poydevorini qurish — `GlassSurface` reusable widget + design tokens — va birinchi vizual migratsiya sifatida `BottomNavigationBar`'ni floating glass capsule bilan almashtirish.

**Architecture:** Bitta atom widget (`GlassSurface`) `BackdropFilter` + tint + specular border'ni inkapsulyatsiya qiladi. Barcha keyingi glass komponentlar shu widget ustiga quriladi. BottomNav `GlassCapsuleNav` ichida 3 ta tab + selected pellet'ni hosil qiladi va `MainShell` Scaffold'i `extendBody: true` bilan content nav ortidan o'tadigan qilib sozlanadi. `OpenStreetMap` (flutter_map) o'zgarmaydi — faqat ustidagi UI qatlamlari glass'lanadi.

**Tech Stack:** Flutter (Material), `dart:ui` `BackdropFilter` / `ImageFilter.blur`, `flutter_riverpod` (mavjud), Material `BottomNavigationBar` o'rniga custom widget. Yangi `pubspec` paketlari **yo'q** (Phase 1 MVP).

---

## Tegishli fayllar

**Yaratiladi:**
- `blink/lib/core/theme/glass_tokens.dart` — barcha blur / tint / radius / spring konstantalari
- `blink/lib/presentation/widgets/glass/glass_surface.dart` — atom `GlassSurface` widget
- `blink/lib/presentation/widgets/glass/glass_capsule_nav.dart` — pastki capsule navigation
- `blink/test/presentation/widgets/glass/glass_surface_test.dart` — widget testlari
- `blink/test/presentation/widgets/glass/glass_capsule_nav_test.dart` — widget testlari

**O'zgartiriladi:**
- `blink/lib/presentation/screens/main/main_shell.dart` — `Scaffold` `extendBody: true`, `BottomNavigationBar` → `GlassCapsuleNav`

---

## Task 1: Design tokens fayli

**Files:**
- Create: `blink/lib/core/theme/glass_tokens.dart`

- [ ] **Step 1: Faylni yaratish — design tokens**

`blink/lib/core/theme/glass_tokens.dart` faylini quyidagi tarkib bilan yarating:

```dart
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

/// Liquid Glass dizayn tili konstantalari.
/// Ma'lumotnoma: docs/superpowers/specs/2026-04-17-blink-ux-vision.md
class GlassTokens {
  GlassTokens._();

  // Blur hierarchy
  static const double blurThin = 8;
  static const double blurRegular = 20;
  static const double blurThick = 40;
  static const double blurUltra = 80;

  // Tint system (light mode — oq asosli)
  static const Color tintBase = Color(0x0FFFFFFF); // 6%
  static const Color tintElevated = Color(0x24FFFFFF); // 14%
  static const Color tintProminent = Color(0x3DFFFFFF); // 24%

  // Strokes
  static const Color strokeSpecular = Color(0x6BFFFFFF); // 42%
  static const Color strokeContour = Color(0x14000000); // 8%

  // Concentric corner radii
  static const double radiusOuter = 32;
  static const double radiusCard = 24;
  static const double radiusButton = 16;
  static const double radiusIconBg = 10;

  // Capsule (bottom nav)
  static const double capsuleHeight = 56;
  static const double capsuleRadius = 28;
  static const double capsuleHorizontalMargin = 16;
  static const double capsuleBottomGap = 12;

  // Spring physics
  static const Cubic spring = Cubic(0.32, 0.72, 0, 1);
  static const Duration springDuration = Duration(milliseconds: 450);
}
```

- [ ] **Step 2: Statik tahlilni o'tkazish**

Run: `cd blink && flutter analyze lib/core/theme/glass_tokens.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add blink/lib/core/theme/glass_tokens.dart
git commit -m "feat(blink): add Liquid Glass design tokens"
```

---

## Task 2: GlassSurface widget — failing widget test

**Files:**
- Create: `blink/test/presentation/widgets/glass/glass_surface_test.dart`

- [ ] **Step 1: Test faylini yaratish**

`blink/test/presentation/widgets/glass/glass_surface_test.dart`:

```dart
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

    testWidgets('BackdropFilter va Container hosil qiladi', (tester) async {
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
```

- [ ] **Step 2: Testni ishga tushirish — fail bo'lishi kerak**

Run: `cd blink && flutter test test/presentation/widgets/glass/glass_surface_test.dart`
Expected: FAIL — "Target of URI doesn't exist: 'package:blink/presentation/widgets/glass/glass_surface.dart'"

---

## Task 3: GlassSurface widget — implementatsiya

**Files:**
- Create: `blink/lib/presentation/widgets/glass/glass_surface.dart`

- [ ] **Step 1: Widget implementatsiyasi**

`blink/lib/presentation/widgets/glass/glass_surface.dart`:

```dart
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/glass_tokens.dart';

/// Liquid Glass'ning atom widget'i.
///
/// Ostidagi kontentni blur qiladi, tint qatlamini qo'shadi va
/// (ixtiyoriy) yuqorida 1pt specular highlight chizadi.
///
/// Barcha glass komponentlar shu widget ustiga quriladi.
class GlassSurface extends StatelessWidget {
  final Widget child;
  final double blur;
  final double tintOpacity;
  final double radius;
  final bool specular;
  final EdgeInsetsGeometry? padding;

  const GlassSurface({
    super.key,
    required this.child,
    this.blur = GlassTokens.blurRegular,
    this.tintOpacity = 0.14,
    this.radius = GlassTokens.radiusCard,
    this.specular = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(tintOpacity),
            borderRadius: borderRadius,
            border: Border(
              top: specular
                  ? const BorderSide(
                      color: GlassTokens.strokeSpecular,
                      width: 1,
                    )
                  : BorderSide.none,
              bottom: const BorderSide(
                color: GlassTokens.strokeContour,
                width: 0.5,
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Testni qayta ishga tushirish — pass bo'lishi kerak**

Run: `cd blink && flutter test test/presentation/widgets/glass/glass_surface_test.dart`
Expected: All 3 tests PASS.

- [ ] **Step 3: Statik tahlil**

Run: `cd blink && flutter analyze lib/presentation/widgets/glass/glass_surface.dart test/presentation/widgets/glass/glass_surface_test.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add blink/lib/presentation/widgets/glass/glass_surface.dart blink/test/presentation/widgets/glass/glass_surface_test.dart
git commit -m "feat(blink): add GlassSurface atom widget"
```

---

## Task 4: GlassCapsuleNav — failing widget test

**Files:**
- Create: `blink/test/presentation/widgets/glass/glass_capsule_nav_test.dart`

- [ ] **Step 1: Test faylini yaratish**

`blink/test/presentation/widgets/glass/glass_capsule_nav_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blink/presentation/widgets/glass/glass_capsule_nav.dart';
import 'package:blink/presentation/widgets/glass/glass_surface.dart';

void main() {
  group('GlassCapsuleNav', () {
    final items = const [
      GlassNavItem(icon: Icons.map_outlined, activeIcon: Icons.map),
      GlassNavItem(icon: Icons.people_outline, activeIcon: Icons.people, badgeCount: 0),
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
                GlassNavItem(icon: Icons.person_outline, activeIcon: Icons.person),
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
```

- [ ] **Step 2: Testni ishga tushirish — fail bo'lishi kerak**

Run: `cd blink && flutter test test/presentation/widgets/glass/glass_capsule_nav_test.dart`
Expected: FAIL — "Target of URI doesn't exist: 'package:blink/presentation/widgets/glass/glass_capsule_nav.dart'"

---

## Task 5: GlassCapsuleNav — implementatsiya

**Files:**
- Create: `blink/lib/presentation/widgets/glass/glass_capsule_nav.dart`

- [ ] **Step 1: Widget implementatsiyasi**

`blink/lib/presentation/widgets/glass/glass_capsule_nav.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../core/theme/glass_tokens.dart';
import 'glass_surface.dart';

/// BottomNav'dagi bitta tab elementi.
class GlassNavItem {
  final IconData icon;
  final IconData activeIcon;
  final int badgeCount;

  const GlassNavItem({
    required this.icon,
    required this.activeIcon,
    this.badgeCount = 0,
  });
}

/// Pastdan suzayotgan glass capsule navigation bar.
///
/// Selected pellet `Stack` ichida `AnimatedAlign` orqali tab orasida
/// liquid morph bilan suriladi.
class GlassCapsuleNav extends StatelessWidget {
  final int currentIndex;
  final List<GlassNavItem> items;
  final ValueChanged<int> onTap;

  const GlassCapsuleNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        GlassTokens.capsuleHorizontalMargin,
        0,
        GlassTokens.capsuleHorizontalMargin,
        bottomInset + GlassTokens.capsuleBottomGap,
      ),
      child: SizedBox(
        height: GlassTokens.capsuleHeight,
        child: GlassSurface(
          blur: GlassTokens.blurRegular + 10,
          tintOpacity: 0.18,
          radius: GlassTokens.capsuleRadius,
          child: Stack(
            children: [
              _Pellet(
                index: currentIndex,
                count: items.length,
              ),
              Row(
                children: [
                  for (int i = 0; i < items.length; i++)
                    Expanded(
                      child: _NavTab(
                        item: items[i],
                        active: i == currentIndex,
                        onTap: () => onTap(i),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pellet extends StatelessWidget {
  final int index;
  final int count;
  const _Pellet({required this.index, required this.count});

  @override
  Widget build(BuildContext context) {
    final alignmentX = count == 1 ? 0.0 : -1.0 + (2.0 * index / (count - 1));
    return AnimatedAlign(
      duration: GlassTokens.springDuration,
      curve: GlassTokens.spring,
      alignment: Alignment(alignmentX, 0),
      child: FractionallySizedBox(
        widthFactor: 1 / count,
        heightFactor: 1,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Container(
            decoration: BoxDecoration(
              color: GlassTokens.tintProminent,
              borderRadius: BorderRadius.circular(GlassTokens.radiusButton + 4),
              border: Border.all(
                color: GlassTokens.strokeSpecular,
                width: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final GlassNavItem item;
  final bool active;
  final VoidCallback onTap;

  const _NavTab({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GlassTokens.radiusButton + 4),
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                active ? item.activeIcon : item.icon,
                key: ValueKey(active),
                size: 26,
                color: active ? Colors.black87 : Colors.black54,
              ),
            ),
            if (item.badgeCount > 0)
              Positioned(
                top: -4,
                right: -10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints:
                      const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '${item.badgeCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Testni qayta ishga tushirish — pass bo'lishi kerak**

Run: `cd blink && flutter test test/presentation/widgets/glass/glass_capsule_nav_test.dart`
Expected: All 5 tests PASS.

- [ ] **Step 3: Statik tahlil**

Run: `cd blink && flutter analyze lib/presentation/widgets/glass/glass_capsule_nav.dart test/presentation/widgets/glass/glass_capsule_nav_test.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add blink/lib/presentation/widgets/glass/glass_capsule_nav.dart blink/test/presentation/widgets/glass/glass_capsule_nav_test.dart
git commit -m "feat(blink): add GlassCapsuleNav with sliding pellet"
```

---

## Task 6: MainShell — Material BottomNav'ni glass capsule bilan almashtirish

**Files:**
- Modify: `blink/lib/presentation/screens/main/main_shell.dart`

- [ ] **Step 1: MainShell'ni yangi nav bilan yangilash**

`blink/lib/presentation/screens/main/main_shell.dart` ning to'liq mazmunini quyidagi bilan almashtiring:

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/friends_provider.dart';
import '../../providers/socket_provider.dart';
import '../../widgets/glass/glass_capsule_nav.dart';
import '../../widgets/in_app_banner.dart';
import '../friends/friends_screen.dart';
import '../map/map_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;
  StreamSubscription<Map<String, dynamic>>? _notifSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(friendsProvider);
      ref.read(friendRequestsProvider);
      _subscribeNotifications();
    });
  }

  void _subscribeNotifications() {
    final socket = ref.read(socketServiceProvider);
    _notifSub = socket.onNotification.listen((data) {
      final notif = data['notification'] as Map<String, dynamic>?;
      if (notif == null) return;
      final type = notif['type']?.toString();
      final title = notif['title']?.toString() ?? '';
      final body = notif['body']?.toString() ?? '';
      if (!mounted) return;
      if (type == 'friend_request_received' ||
          type == 'friend_request_accepted') {
        InAppBanner.show(
          context: context,
          title: title.isNotEmpty ? title : "Yangi xabar",
          subtitle: body,
          onTap: () => setState(() => _index = 1),
        );
      }
    });
  }

  @override
  void dispose() {
    _notifSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final incomingCount = ref.watch(incomingRequestCountProvider);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _index,
        children: const [
          MapScreen(),
          FriendsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: GlassCapsuleNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          const GlassNavItem(
            icon: Icons.map_outlined,
            activeIcon: Icons.map,
          ),
          GlassNavItem(
            icon: Icons.people_outline,
            activeIcon: Icons.people,
            badgeCount: incomingCount,
          ),
          const GlassNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Statik tahlil**

Run: `cd blink && flutter analyze lib/presentation/screens/main/main_shell.dart`
Expected: `No issues found!`

- [ ] **Step 3: Butun loyiha tahlili**

Run: `cd blink && flutter analyze`
Expected: `No issues found!`

- [ ] **Step 4: Butun test to'plamini ishga tushirish**

Run: `cd blink && flutter test`
Expected: All tests PASS (yangi 8 ta widget testi + mavjudlari).

- [ ] **Step 5: Commit**

```bash
git add blink/lib/presentation/screens/main/main_shell.dart
git commit -m "feat(blink): migrate BottomNav to GlassCapsuleNav"
```

---

## Task 7: Qo'lda QA — vizual tasdiqlash

**Files:** (kod o'zgarmaydi — faqat ko'z bilan tekshirish)

- [ ] **Step 1: Ilovani Android emulyator yoki qurilmada ishga tushirish**

Run: `cd blink && flutter run`

- [ ] **Step 2: Login → Map ekranida nav capsule'ni tekshirish**

Quyidagi vizual mezonlarni ko'z bilan tasdiqlang:
- Bottom nav **suzib turadi**, ekran chetiga yopishmaydi (16pt yon margin, ~12pt+safe-area pastdan)
- Nav **shisha** ko'rinishida — ostidagi xarita biroz blur bilan ko'rinadi (qattiq oq emas)
- Yuqori qirrasida **nozik oq chiziq** (specular) ko'rinadi
- Faol tab (Xarita) ostida **glass pellet** turadi
- Pellet ichidagi ikon **plombalangan** (filled) variantda

- [ ] **Step 3: Tab almashtirishni tekshirish**

- "Do'stlar" tabga teging — pellet **suyuqlik kabi suriladi** (snap emas, ~450ms davomida)
- "Profil" tabga teging — pellet yana suriladi
- Xarita tabga qayting — pellet teskari yo'l bo'ylab suriladi

- [ ] **Step 4: Badge'ni tekshirish (agar do'stlik so'rovi bo'lsa)**

- Boshqa hisobdan friend request yuboring
- "Do'stlar" ikoni ustida **qizil badge** raqam bilan ko'rinishi kerak
- Badge nav capsule ichida joylashganini tekshiring (nav tashqarisida emas)

- [ ] **Step 5: Content nav ortidan o'tishini tekshirish**

- Xarita tabda — xarita **butun ekranni** to'ldiradi, nav ostidan ham (nav ostida xarita ko'rinadi)
- Friends tabga o'tib, ro'yxat oxiriga scroll qiling — oxirgi tile nav ortidan **suzib o'tadi**, kesilmaydi

- [ ] **Step 6: Agar muammolar bo'lsa**

Agar quyidagilardan biri yuz bersa — STOP, qayta tahlil qiling:
- Nav qattiq oq chiqib turibdi (blur ishlamayapti) → `BackdropFilter` joylashuvini tekshiring
- Pellet sakraydi (smooth emas) → `AnimatedAlign` `curve` parametrini tekshiring
- Content nav ostidan ko'rinmayapti → `Scaffold(extendBody: true)` o'rnatilganini tekshiring
- Statusbar ostida UI kesiladi → bu ekspektatsiya, Phase 2 (Vanishing Glass AppBar)da hal etiladi

- [ ] **Step 7: Tasdiqlanganidan so'ng — commit qilinadigan o'zgarish yo'q**

QA bosqichi vizual tasdiq, kod commit'i yo'q. Davom etishni tasdiqlang.

---

## Tugatish

Glass Phase 1 tugadi. Quyidagilar yetkazib berildi:
- `GlassTokens` — barcha kelajakdagi glass komponentlar uchun bitta haqiqat manbai
- `GlassSurface` — qayta ishlatiladigan atom widget
- `GlassCapsuleNav` — birinchi vizual ko'chish
- 8 ta passing widget testi
- 0 lint warnings

**Keyingi qadam (Glass Phase 2):**
- Vanishing Glass AppBar (Profil + Friends ekranlarida)
- Floating Glass Card (`InAppBanner` migratsiyasi)
- Tab Pellet (FriendsScreen TabBar)

Glass Phase 2 plan'i alohida hujjatda yoziladi.
