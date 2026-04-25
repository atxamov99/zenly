import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/glass_tokens.dart';
import '../../providers/friends_provider.dart';
import '../../widgets/glass/glass_app_bar.dart';
import '../../widgets/glass/glass_background.dart';
import 'widgets/add_friend_tab.dart';
import 'widgets/friends_list_tab.dart';
import 'widgets/requests_tab.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  bool _appBarVisible = true;

  bool _onScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      if (delta > 8 && _appBarVisible) {
        setState(() => _appBarVisible = false);
      } else if (delta < -8 && !_appBarVisible) {
        setState(() => _appBarVisible = true);
      }
    }
    if (notification is ScrollEndNotification &&
        notification.metrics.pixels <= 0) {
      if (!_appBarVisible) setState(() => _appBarVisible = true);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final incomingCount = ref.watch(incomingRequestCountProvider);
    final topPad = MediaQuery.of(context).padding.top;
    const tabBarHeight = 54.0;
    final appBarHeight = kToolbarHeight + tabBarHeight;

    final tabBar = TabBar(
      indicator: BoxDecoration(
        color: GlassTokens.tintProminent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GlassTokens.strokeSpecular, width: 0.5),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorPadding: const EdgeInsets.symmetric(vertical: 4),
      labelColor: GlassTokens.onGlass,
      unselectedLabelColor: GlassTokens.onGlassMuted,
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      unselectedLabelStyle:
          const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      dividerColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      tabs: [
        const Tab(text: "Do'stlarim"),
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("So'rovlar"),
              if (incomingCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$incomingCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const Tab(text: "Qo'shish"),
      ],
    );

    return GlassBackground(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: _onScroll,
                child: Padding(
                  padding: EdgeInsets.only(top: topPad + appBarHeight),
                  child: const TabBarView(
                    children: [
                      FriendsListTab(),
                      RequestsTab(),
                      AddFriendTab(),
                    ],
                  ),
                ),
              ),
              AnimatedSlide(
                offset: _appBarVisible ? Offset.zero : const Offset(0, -1),
                duration: GlassTokens.springDuration,
                curve: GlassTokens.spring,
                child: GlassAppBar(
                  title: const Text("Do'stlar"),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(tabBarHeight),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                      child: tabBar,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
