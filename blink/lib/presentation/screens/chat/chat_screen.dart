import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../domain/entities/friend_entity.dart';
import '../../../domain/entities/message_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/glass/glass_background.dart';
import '../../widgets/glass/glass_empty_state.dart';
import 'widgets/chat_app_bar.dart';
import 'widgets/image_message_viewer.dart';
import 'widgets/message_bubble.dart';
import 'widgets/message_input.dart';
import 'widgets/typing_indicator.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final FriendEntity friend;
  const ChatScreen({super.key, required this.friend});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(markAsReadUseCaseProvider).call(widget.friend.userId);
    });
  }

  Future<void> _onLongPress(MessageEntity msg, bool isMine) async {
    final isText = msg.type == 'text';
    final canEdit = isMine &&
        isText &&
        DateTime.now().difference(msg.createdAt).inHours < 24;
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            if (isText)
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Nusxa olish'),
                onTap: () => Navigator.pop(context, 'copy'),
              ),
            if (canEdit)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Tahrirlash'),
                onTap: () => Navigator.pop(context, 'edit'),
              ),
            if (isMine)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("O'chirish",
                    style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.pop(context, 'delete'),
              ),
          ],
        ),
      ),
    );

    if (!mounted) return;
    if (action == 'edit') {
      await _openEditDialog(msg);
    } else if (action == 'delete') {
      await ref.read(deleteMessageUseCaseProvider).call(msg.id);
    }
  }

  Future<void> _openEditDialog(MessageEntity msg) async {
    final ctrl = TextEditingController(text: msg.text);
    final newText = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tahrirlash'),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Bekor qilish'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );
    if (newText != null && newText.isNotEmpty && newText != msg.text) {
      await ref
          .read(editMessageUseCaseProvider)
          .call(messageId: msg.id, newText: newText);
    }
  }

  String _imageUrlFull(String urlOrPath) {
    if (urlOrPath.startsWith('http')) return urlOrPath;
    return '${ApiConstants.socketUrl}$urlOrPath';
  }

  @override
  Widget build(BuildContext context) {
    final friendId = widget.friend.userId;
    final messagesAsync = ref.watch(messagesProvider(friendId));
    final typingAsync = ref.watch(typingProvider(friendId));
    final myUid = ref.watch(authStateProvider).value;

    return GlassBackground(
      child: Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: ChatAppBar(
        displayName: widget.friend.displayName.isNotEmpty
            ? widget.friend.displayName
            : widget.friend.username,
        avatarUrl: widget.friend.avatarUrl,
        isOnline: widget.friend.isOnline,
        isTyping: typingAsync.value ?? false,
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight,
          ),
          child: Column(
            children: [
              Expanded(
                child: messagesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => GlassEmptyState(
                    icon: Icons.cloud_off,
                    title: "Xabarlarni yuklab bo'lmadi",
                    detail: '$e',
                    onRetry: () => ref.invalidate(messagesProvider(friendId)),
                  ),
                  data: (messages) {
                    if (messages.isEmpty) {
                      return const GlassEmptyState(
                        icon: Icons.chat_bubble_outline,
                        title: "Xabarlar yo'q",
                        detail: "Birinchi bo'lib salom yozing.",
                      );
                    }
                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: messages.length,
                      itemBuilder: (_, i) {
                        final m = messages[i];
                        final isMine = m.senderId == myUid;
                        return MessageBubble(
                          message: m,
                          isMine: isMine,
                          friendId: friendId,
                          onLongPress: () => _onLongPress(m, isMine),
                          onImageTap:
                              m.type == 'image' && m.imageUrl.isNotEmpty
                                  ? () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ImageMessageViewer(
                                            imageUrl:
                                                _imageUrlFull(m.imageUrl),
                                          ),
                                        ),
                                      )
                                  : null,
                        );
                      },
                    );
                  },
                ),
              ),
              if (typingAsync.value == true) const TypingIndicator(),
              MessageInput(
                onSendText: (text) {
                  ref.read(sendMessageUseCaseProvider).sendText(
                        friendId: friendId,
                        text: text,
                        clientMessageId:
                            DateTime.now().microsecondsSinceEpoch.toString(),
                      );
                },
                onSendImage: (path) {
                  ref.read(sendMessageUseCaseProvider).sendImage(
                        friendId: friendId,
                        imagePath: path,
                        clientMessageId:
                            DateTime.now().microsecondsSinceEpoch.toString(),
                      );
                },
                onTypingChanged: (isTyping) {
                  final repo = ref.read(chatRepositoryProvider);
                  if (isTyping) {
                    repo.emitTypingStart(friendId);
                  } else {
                    repo.emitTypingStop(friendId);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
