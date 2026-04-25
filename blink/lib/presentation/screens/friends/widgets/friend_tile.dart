import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/glass_tokens.dart';

import '../../../../domain/entities/conversation_entity.dart';
import '../../../../domain/entities/friend_entity.dart';
import '../../../widgets/glass/glass_card.dart';

class FriendTile extends StatelessWidget {
  final FriendEntity friend;
  final ConversationEntity? conversation;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;

  const FriendTile({
    super.key,
    required this.friend,
    this.conversation,
    this.onTap,
    this.onLongPress,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final unread = conversation?.unreadCount ?? 0;
    final preview = _previewLine();

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: friend.avatarUrl != null
                    ? CachedNetworkImageProvider(friend.avatarUrl!)
                    : null,
                child: friend.avatarUrl == null
                    ? Text(
                        friend.displayName.isNotEmpty
                            ? friend.displayName[0].toUpperCase()
                            : '?',
                      )
                    : null,
              ),
              if (friend.isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onLongPress: onLongPress,
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          friend.displayName.isNotEmpty
                              ? friend.displayName
                              : friend.username,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation?.lastMessageAt != null)
                        Text(
                          _formatTime(conversation!.lastMessageAt!),
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
                            color: unread > 0
                                ? GlassTokens.onGlass
                                : GlassTokens.onGlassMuted,
                            fontWeight: unread > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unread > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$unread',
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
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }

  String _previewLine() {
    final last = conversation?.lastMessage;
    if (last != null) {
      if (last.type == 'image') return '📷 Rasm';
      if (last.text.isNotEmpty) return last.text;
    }
    return '@${friend.username} · ${friend.smartStatus}';
  }

  String _formatTime(DateTime t) {
    final now = DateTime.now();
    final isSameDay =
        t.year == now.year && t.month == now.month && t.day == now.day;
    if (isSameDay) {
      return '${t.hour.toString().padLeft(2, '0')}:'
          '${t.minute.toString().padLeft(2, '0')}';
    }
    final yest = now.subtract(const Duration(days: 1));
    final isYesterday =
        t.year == yest.year && t.month == yest.month && t.day == yest.day;
    if (isYesterday) return 'Kecha';
    return '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')}';
  }
}
