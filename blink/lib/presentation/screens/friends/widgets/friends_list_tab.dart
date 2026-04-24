import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../domain/entities/friend_entity.dart';
import '../../../providers/chat_provider.dart';
import '../../../providers/friends_provider.dart';
import '../../../widgets/glass/glass_empty_state.dart';
import 'friend_tile.dart';

class FriendsListTab extends ConsumerWidget {
  const FriendsListTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(friendsProvider);
    final conversationsAsync = ref.watch(conversationsProvider);
    final convoMap = conversationsAsync.value ?? const {};

    return friendsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => GlassEmptyState(
        icon: Icons.cloud_off,
        title: "Do'stlarni yuklab bo'lmadi",
        detail: '$e',
        onRetry: () => ref.read(friendsProvider.notifier).refresh(),
      ),
      data: (friends) {
        if (friends.isEmpty) {
          return const GlassEmptyState(
            icon: Icons.people_outline,
            title: "Hali do'st yo'q",
            detail: "Qidirish bo'limidan boshlang",
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(friendsProvider.notifier).refresh(),
          child: ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, i) {
              final friend = friends[i];
              return FriendTile(
                friend: friend,
                conversation: convoMap[friend.userId],
                onTap: () => context.push(
                  AppRoutes.chatFor(friend.userId),
                  extra: friend,
                ),
                onLongPress: () => _showActions(context, ref, friend),
              );
            },
          ),
        );
      },
    );
  }

  void _showActions(BuildContext context, WidgetRef ref, FriendEntity friend) {
    showModalBottomSheet(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('Joylashuvga borish'),
              onTap: () {
                Navigator.of(sheetCtx).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_remove_outlined,
                  color: Colors.orange),
              title: const Text("Do'stlikni bekor qilish"),
              onTap: () async {
                Navigator.of(sheetCtx).pop();
                try {
                  await ref
                      .read(friendsProvider.notifier)
                      .unfriend(friend.userId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${friend.displayName} o'chirildi")),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Xato: $e')),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Bloklash'),
              onTap: () async {
                Navigator.of(sheetCtx).pop();
                try {
                  await ref
                      .read(apiBlockDatasourceProvider)
                      .block(friend.userId);
                  await ref.read(friendsProvider.notifier).refresh();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${friend.displayName} bloklandi")),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Xato: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
