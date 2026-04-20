import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../domain/entities/message_entity.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMine;
  final String friendId;
  final VoidCallback? onLongPress;
  final VoidCallback? onImageTap;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.friendId,
    this.onLongPress,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDeleted = message.deletedAt != null;
    final align = isMine ? Alignment.centerRight : Alignment.centerLeft;
    final bg = isMine
        ? GlassTokens.tintProminent
        : Colors.white.withOpacity(0.85);

    return Align(
      alignment: align,
      child: GestureDetector(
        onLongPress: isDeleted ? null : onLongPress,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
              border: Border.all(
                color: GlassTokens.strokeSpecular,
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isDeleted) ..._deleted()
                else if (message.type == 'image') ..._image(context)
                else _text(),
                const SizedBox(height: 4),
                _meta(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _text() => Text(
        message.text,
        style: const TextStyle(color: Colors.black87, fontSize: 15),
      );

  List<Widget> _image(BuildContext context) => [
        GestureDetector(
          onTap: onImageTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(GlassTokens.radiusCard - 4),
            child: CachedNetworkImage(
              imageUrl: _imageUrlFull(),
              width: 220,
              fit: BoxFit.cover,
              placeholder: (_, __) => const SizedBox(
                width: 220,
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ),
      ];

  List<Widget> _deleted() => const [
        Text(
          "🚫 Bu xabar o'chirildi",
          style: TextStyle(
            color: Colors.black45,
            fontStyle: FontStyle.italic,
            fontSize: 14,
          ),
        ),
      ];

  Widget _meta() {
    final hh = message.createdAt.hour.toString().padLeft(2, '0');
    final mm = message.createdAt.minute.toString().padLeft(2, '0');
    final time = '$hh:$mm';
    final isReadByFriend = message.isReadBy(friendId);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.editedAt != null && message.deletedAt == null)
          const Padding(
            padding: EdgeInsets.only(right: 6),
            child: Text(
              '(tahrirlandi)',
              style: TextStyle(fontSize: 10, color: Colors.black45),
            ),
          ),
        Text(time,
            style: const TextStyle(fontSize: 11, color: Colors.black54)),
        if (isMine && message.deletedAt == null) ...[
          const SizedBox(width: 4),
          if (isReadByFriend)
            const Icon(Icons.done_all,
                key: ValueKey('msg-status-read'),
                size: 14,
                color: Colors.blue)
          else
            const Icon(Icons.done,
                key: ValueKey('msg-status-delivered'),
                size: 14,
                color: Colors.black45),
        ],
      ],
    );
  }

  String _imageUrlFull() {
    if (message.imageUrl.startsWith('http')) return message.imageUrl;
    final host = ApiConstants.socketUrl; // host without /api suffix
    return '$host${message.imageUrl}';
  }
}
