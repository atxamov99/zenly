import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/friends_provider.dart';
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
        appBar: AppBar(
          title: const Text("Do'stlar"),
          bottom: TabBar(
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
        body: const TabBarView(
          children: [
            FriendsListTab(),
            RequestsTab(),
            AddFriendTab(),
          ],
        ),
      ),
    );
  }
}
