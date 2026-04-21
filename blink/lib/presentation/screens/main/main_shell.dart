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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final socketService = ref.read(socketServiceProvider);
      try {
        await socketService.connect();
      } catch (_) {
        // Token yo'q yoki network yo'q — keyin chat ochilganda qayta urinamiz.
      }
      if (!mounted) return;
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
