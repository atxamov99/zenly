import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/entities/conversation_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/glass/glass_app_bar.dart';
import 'widgets/image_message_viewer.dart';
import 'widgets/message_bubble.dart';
import 'widgets/message_input.dart';

class GroupChatScreen extends ConsumerStatefulWidget {
  final ConversationEntity group;
  const GroupChatScreen({super.key, required this.group});

  @override
  ConsumerState<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends ConsumerState<GroupChatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(chatRepositoryProvider)
          .markGroupAsRead(widget.group.id)
          .catchError((_) {});
    });
  }

  String _imageUrlFull(String urlOrPath) {
    if (urlOrPath.startsWith('http')) return urlOrPath;
    return '${ApiConstants.socketUrl}$urlOrPath';
  }

  String _senderName(String senderId) {
    if (senderId == ref.read(authStateProvider).value) return '';
    final member = widget.group.members.firstWhere(
      (m) => m.userId == senderId,
      orElse: () => const ConversationMember(
        userId: '',
        username: '',
        displayName: '',
      ),
    );
    return member.displayName.isNotEmpty
        ? member.displayName
        : member.username;
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(groupMessagesProvider(widget.group.id));
    final myUid = ref.watch(authStateProvider).value;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: GestureDetector(
          onTap: () => context.push(
            AppRoutes.groupSettingsFor(widget.group.id),
            extra: widget.group,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.group.title, style: const TextStyle(fontSize: 16)),
              Text(
                '${widget.group.members.length} a\'zo',
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => context.push(
              AppRoutes.groupSettingsFor(widget.group.id),
              extra: widget.group,
            ),
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
              Expanded(
                child: messagesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Xato: $e')),
                  data: (messages) {
                    if (messages.isEmpty) {
                      return const Center(
                        child: Text("Hali xabar yo'q. Birinchi bo'ling!"),
                      );
                    }
                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: messages.length,
                      itemBuilder: (_, i) {
                        final m = messages[i];
                        final isMine = m.senderId == myUid;
                        final senderName =
                            isMine ? '' : _senderName(m.senderId);
                        return Column(
                          crossAxisAlignment: isMine
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (!isMine && senderName.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, top: 4, bottom: 2),
                                child: Text(
                                  senderName,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            MessageBubble(
                              message: m,
                              isMine: isMine,
                              friendId: '',
                              onImageTap:
                                  m.type == 'image' && m.imageUrl.isNotEmpty
                                      ? () => Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ImageMessageViewer(
                                                imageUrl:
                                                    _imageUrlFull(m.imageUrl),
                                              ),
                                            ),
                                          )
                                      : null,
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              MessageInput(
                onSendText: (text) {
                  ref.read(chatRepositoryProvider).sendGroupText(
                        conversationId: widget.group.id,
                        text: text,
                      );
                },
                onSendImage: (path) {
                  ref.read(chatRepositoryProvider).sendGroupImage(
                        conversationId: widget.group.id,
                        imagePath: path,
                      );
                },
                onTypingChanged: (_) {/* group typing not in MVP */},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

