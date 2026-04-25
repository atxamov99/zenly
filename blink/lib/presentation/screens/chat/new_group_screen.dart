import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/glass_tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../domain/entities/friend_entity.dart';
import '../../providers/chat_provider.dart';
import '../../providers/friends_provider.dart';
import '../../widgets/glass/glass_app_bar.dart';

class NewGroupScreen extends ConsumerStatefulWidget {
  const NewGroupScreen({super.key});

  @override
  ConsumerState<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends ConsumerState<NewGroupScreen> {
  final _titleCtrl = TextEditingController();
  final Set<String> _selected = {};
  bool _busy = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Nom kiriting')));
      return;
    }
    if (_selected.length < 1) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Kamida 1 do'st tanlang")));
      return;
    }
    setState(() => _busy = true);
    try {
      final group =
          await ref.read(chatRepositoryProvider).createGroup(
                title: title,
                memberIds: _selected.toList(),
              );
      if (!mounted) return;
      context.pushReplacement(AppRoutes.groupFor(group.id), extra: group);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Xato: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(friendsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: const Text('Yangi guruh'),
        actions: [
          TextButton(
            onPressed: _busy ? null : _createGroup,
            child: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Yaratish',
                    style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _titleCtrl,
                  maxLength: 80,
                  decoration: const InputDecoration(
                    hintText: 'Guruh nomi',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                ),
              ),
              if (_selected.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${_selected.length} ta tanlandi",
                      style: const TextStyle(color: GlassTokens.onGlassMuted),
                    ),
                  ),
                ),
              Expanded(
                child: friendsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Xato: $e')),
                  data: (friends) {
                    if (friends.isEmpty) {
                      return const Center(
                        child: Text("Sizda hali do'st yo'q"),
                      );
                    }
                    return ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (_, i) {
                        final f = friends[i];
                        return _FriendCheckTile(
                          friend: f,
                          checked: _selected.contains(f.userId),
                          onChanged: (v) {
                            setState(() {
                              if (v) {
                                _selected.add(f.userId);
                              } else {
                                _selected.remove(f.userId);
                              }
                            });
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FriendCheckTile extends StatelessWidget {
  final FriendEntity friend;
  final bool checked;
  final ValueChanged<bool> onChanged;

  const _FriendCheckTile({
    required this.friend,
    required this.checked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: checked,
      onChanged: (v) => onChanged(v ?? false),
      controlAffinity: ListTileControlAffinity.trailing,
      secondary: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        backgroundImage: friend.avatarUrl != null
            ? CachedNetworkImageProvider(friend.avatarUrl!)
            : null,
        child: friend.avatarUrl == null
            ? Text(friend.displayName.isNotEmpty
                ? friend.displayName[0].toUpperCase()
                : '?')
            : null,
      ),
      title: Text(friend.displayName.isNotEmpty
          ? friend.displayName
          : friend.username),
      subtitle: Text('@${friend.username}'),
    );
  }
}
