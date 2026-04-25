import 'package:flutter/material.dart';
import '../../../../core/theme/glass_tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../domain/entities/conversation_entity.dart';
import '../../../../domain/entities/friend_entity.dart';
import '../../../providers/chat_provider.dart';
import '../../../providers/friends_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../widgets/glass/glass_card.dart';
import '../../../widgets/glass/glass_empty_state.dart';
import 'friend_tile.dart';

class FriendsListTab extends ConsumerWidget {
  const FriendsListTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(friendsProvider);
    final conversationsAsync = ref.watch(conversationsProvider);
    final groupsAsync = ref.watch(groupsProvider);
    final convoMap = conversationsAsync.value ?? const {};
    final groups = groupsAsync.value ?? const <ConversationEntity>[];

    return friendsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => GlassEmptyState(
        icon: Icons.cloud_off,
        title: "Do'stlarni yuklab bo'lmadi",
        detail: '$e',
        onRetry: () => ref.read(friendsProvider.notifier).refresh(),
      ),
      data: (friends) {
        return RefreshIndicator(
          onRefresh: () => ref.read(friendsProvider.notifier).refresh(),
          child: ListView(
            children: [
              _NewGroupButton(),
              if (groups.isNotEmpty) ...[
                const _SectionLabel("Guruhlar"),
                ...groups.map(
                  (g) => _GroupTile(
                    group: g,
                    onTap: () =>
                        context.push(AppRoutes.groupFor(g.id), extra: g),
                  ),
                ),
                const _SectionLabel("Do'stlar"),
              ],
              if (friends.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    "Hali do'st yo'q.\nQidirish bo'limidan boshla",
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...friends.map((friend) => FriendTile(
                      friend: friend,
                      conversation: convoMap[friend.userId],
                      onTap: () => context.push(
                        AppRoutes.chatFor(friend.userId),
                        extra: friend,
                      ),
                      onLongPress: () => _showActions(context, ref, friend),
                    )),
            ],
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
              leading: const Icon(Icons.visibility_off_outlined),
              title: const Text("Bu do'stga ko'rinmaslik"),
              subtitle: const Text("Faqat shu do'st sizni xaritada ko'rmaydi"),
              onTap: () async {
                Navigator.of(sheetCtx).pop();
                try {
                  await ref
                      .read(apiProfileDatasourceProvider)
                      .ghostFromAdd(friend.userId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              "${friend.displayName} sizni ko'rmaydi")),
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

class _NewGroupButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: GlassCard(
        onTap: () => context.push(AppRoutes.newGroup),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: const [
            Icon(Icons.group_add_outlined, size: 22),
            SizedBox(width: 12),
            Text(
              "Yangi guruh",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: GlassTokens.onGlassMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  final ConversationEntity group;
  final VoidCallback onTap;

  const _GroupTile({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final preview = _previewLine();
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.deepPurple.shade100,
            child: const Icon(Icons.group, color: Colors.deepPurple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        group.title.isNotEmpty ? group.title : 'Guruh',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (group.lastMessageAt != null)
                      Text(
                        _formatTime(group.lastMessageAt!),
                        style: const TextStyle(
                            fontSize: 11, color: GlassTokens.onGlassMuted),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        preview,
                        style: TextStyle(
                          fontSize: 12,
                          color: group.unreadCount > 0
                              ? GlassTokens.onGlass
                              : GlassTokens.onGlassMuted,
                          fontWeight: group.unreadCount > 0
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (group.unreadCount > 0)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${group.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _previewLine() {
    final last = group.lastMessage;
    if (last != null) {
      if (last.type == 'image') return '📷 Rasm';
      if (last.text.isNotEmpty) return last.text;
    }
    return '${group.members.length} a\'zo';
  }

  String _formatTime(DateTime t) {
    final now = DateTime.now();
    final isSameDay =
        t.year == now.year && t.month == now.month && t.day == now.day;
    if (isSameDay) {
      return '${t.hour.toString().padLeft(2, '0')}:'
          '${t.minute.toString().padLeft(2, '0')}';
    }
    return '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')}';
  }
}
