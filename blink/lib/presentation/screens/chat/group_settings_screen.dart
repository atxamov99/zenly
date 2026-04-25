import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/conversation_entity.dart';
import '../../../domain/entities/friend_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/friends_provider.dart';
import '../../widgets/glass/glass_app_bar.dart';
import '../../widgets/glass/glass_card.dart';

class GroupSettingsScreen extends ConsumerStatefulWidget {
  final ConversationEntity group;
  const GroupSettingsScreen({super.key, required this.group});

  @override
  ConsumerState<GroupSettingsScreen> createState() =>
      _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends ConsumerState<GroupSettingsScreen> {
  late ConversationEntity _group;

  @override
  void initState() {
    super.initState();
    _group = widget.group;
  }

  bool get _isOwner =>
      _group.ownerId == ref.read(authStateProvider).value;

  bool get _isAdmin {
    final myUid = ref.read(authStateProvider).value;
    if (myUid == null) return false;
    return _group.ownerId == myUid || _group.adminIds.contains(myUid);
  }

  Future<void> _renameDialog() async {
    final ctrl = TextEditingController(text: _group.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Guruh nomini o'zgartirish"),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 80,
          decoration: const InputDecoration(counterText: ''),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );
    if (newTitle == null || newTitle.isEmpty || newTitle == _group.title) return;
    try {
      await ref
          .read(chatRepositoryProvider)
          .renameGroup(conversationId: _group.id, title: newTitle);
      if (!mounted) return;
      setState(() {
        _group = ConversationEntity(
          id: _group.id,
          isGroup: _group.isGroup,
          title: newTitle,
          avatarUrl: _group.avatarUrl,
          ownerId: _group.ownerId,
          adminIds: _group.adminIds,
          members: _group.members,
          otherUserId: _group.otherUserId,
          lastMessage: _group.lastMessage,
          lastMessageAt: _group.lastMessageAt,
          unreadCount: _group.unreadCount,
        );
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Xato: $e')));
      }
    }
  }

  Future<void> _addMember() async {
    final friends = ref.read(friendsProvider).value ?? const <FriendEntity>[];
    final memberIds = _group.members.map((m) => m.userId).toSet();
    final candidates =
        friends.where((f) => !memberIds.contains(f.userId)).toList();
    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Qo'shadigan do'st qolmadi")),
      );
      return;
    }
    final picked = await showModalBottomSheet<FriendEntity>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Qo'shish uchun do'st tanlang",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            for (final f in candidates)
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: f.avatarUrl != null
                      ? CachedNetworkImageProvider(f.avatarUrl!)
                      : null,
                  child: f.avatarUrl == null
                      ? Text(f.displayName.isNotEmpty
                          ? f.displayName[0].toUpperCase()
                          : '?')
                      : null,
                ),
                title: Text(f.displayName.isNotEmpty
                    ? f.displayName
                    : f.username),
                subtitle: Text('@${f.username}'),
                onTap: () => Navigator.of(ctx).pop(f),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    try {
      await ref.read(chatRepositoryProvider).addGroupMember(
            conversationId: _group.id,
            userId: picked.userId,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${picked.displayName} qo'shildi")),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Xato: $e')));
      }
    }
  }

  Future<void> _removeMember(ConversationMember member) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("${member.displayName}ni o'chirish?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Bekor'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("O'chirish"),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(chatRepositoryProvider).removeGroupMember(
            conversationId: _group.id,
            userId: member.userId,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Xato: $e')));
      }
    }
  }

  Future<void> _leaveGroup() async {
    final myUid = ref.read(authStateProvider).value;
    if (myUid == null) return;
    if (_isOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Egasi chiqolmaydi. Avval boshqasiga bering")),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Guruhdan chiqish?"),
        content: const Text("Bu guruhni tark etasiz. Qaytarib bo'lmaydi."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Bekor'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Chiqish"),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(chatRepositoryProvider).removeGroupMember(
            conversationId: _group.id,
            userId: myUid,
          );
      if (!mounted) return;
      // Pop both settings + chat screen.
      context.go('/main');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Xato: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final myUid = ref.watch(authStateProvider).value;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(title: const Text('Guruh sozlamalari')),
      body: ListView(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
          bottom: 120,
        ),
        children: [
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.deepPurple.shade100,
                  child:
                      const Icon(Icons.group, size: 48, color: Colors.deepPurple),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        _group.title,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (_isAdmin)
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: _renameDialog,
                      ),
                  ],
                ),
                Text("${_group.members.length} a'zo",
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                if (_isAdmin)
                  ListTile(
                    leading: const Icon(Icons.person_add, color: Colors.blue),
                    title: const Text("A'zo qo'shish"),
                    onTap: _addMember,
                  ),
                for (final member in _group.members)
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: member.avatarUrl != null
                          ? CachedNetworkImageProvider(member.avatarUrl!)
                          : null,
                      child: member.avatarUrl == null
                          ? Text(member.displayName.isNotEmpty
                              ? member.displayName[0].toUpperCase()
                              : '?')
                          : null,
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            member.displayName.isNotEmpty
                                ? member.displayName
                                : member.username,
                          ),
                        ),
                        if (_group.ownerId == member.userId)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Text('👑',
                                style: TextStyle(fontSize: 14)),
                          )
                        else if (_group.adminIds.contains(member.userId))
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Text('admin',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.blue)),
                          ),
                      ],
                    ),
                    subtitle: Text('@${member.username}'),
                    trailing: (_isOwner && member.userId != myUid)
                        ? IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: Colors.red),
                            onPressed: () => _removeMember(member),
                          )
                        : null,
                  ),
              ],
            ),
          ),
          GlassCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text("Guruhdan chiqish",
                  style: TextStyle(color: Colors.red)),
              onTap: _leaveGroup,
            ),
          ),
        ],
      ),
    );
  }
}
