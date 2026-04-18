import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/glass_tokens.dart';
import '../../providers/friends_provider.dart';
import '../../widgets/glass/glass_app_bar.dart';
import 'widgets/add_friend_tab.dart';
import 'widgets/friends_list_tab.dart';
import 'widgets/requests_tab.dart';

class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomingCount = ref.watch(incomingRequestCountProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: GlassAppBar(
          title: const Text("Do'stlar"),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(54),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: TabBar(
                indicator: BoxDecoration(
                  color: GlassTokens.tintProminent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: GlassTokens.strokeSpecular,
                    width: 0.5,
                  ),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.symmetric(vertical: 4),
                labelColor: Colors.black87,
                unselectedLabelColor: Colors.black54,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
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
              ),
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top +
                kToolbarHeight +
                kTextTabBarHeight,
          ),
          child: const TabBarView(
            children: [
              FriendsListTab(),
              RequestsTab(),
              AddFriendTab(),
            ],
          ),
        ),
      ),
    );
  }
}
