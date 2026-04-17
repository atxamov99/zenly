import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/friends_provider.dart';
import '../../providers/socket_provider.dart';
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
      body: IndexedStack(
        index: _index,
        children: const [
          MapScreen(),
          FriendsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Xarita',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.people_outline),
                if (incomingCount > 0)
                  Positioned(
                    top: -4,
                    right: -6,
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
                        '$incomingCount',
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
            activeIcon: const Icon(Icons.people),
            label: "Do'stlar",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
