import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../domain/entities/message_entity.dart';

class MessageBubble extends StatefulWidget {
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
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final FocusNode _imageFocusNode = FocusNode(debugLabel: 'chat-image-bubble');
  bool _isImageFocused = false;

  @override
  void dispose() {
    _imageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDeleted = widget.message.deletedAt != null;
    final align =
        widget.isMine ? Alignment.centerRight : Alignment.centerLeft;
    final bg = widget.isMine
        ? GlassTokens.tintProminent
        : Colors.white.withOpacity(0.85);

    return Align(
      alignment: align,
      child: GestureDetector(
        onLongPress: isDeleted ? null : widget.onLongPress,
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
                else if (widget.message.type == 'image') ..._image(context)
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
        widget.message.text,
        style: const TextStyle(color: GlassTokens.onGlass, fontSize: 15),
      );

  List<Widget> _image(BuildContext context) => [
        FocusableActionDetector(
          focusNode: _imageFocusNode,
          mouseCursor: SystemMouseCursors.click,
          onShowFocusHighlight: (value) {
            if (_isImageFocused == value) return;
            setState(() => _isImageFocused = value);
          },
          child: GestureDetector(
            onTap: () {
              if (_supportsKeyboardPreview) {
                _imageFocusNode.requestFocus();
                return;
              }
              widget.onImageTap?.call();
            },
            onDoubleTap: widget.onImageTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(GlassTokens.radiusCard - 4),
                border: Border.all(
                  color: _isImageFocused
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(GlassTokens.radiusCard - 4),
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
          ),
        ),
      ];

  List<Widget> _deleted() => const [
        Text(
          "🚫 Bu xabar o'chirildi",
          style: TextStyle(
            color: GlassTokens.onGlassFaint,
            fontStyle: FontStyle.italic,
            fontSize: 14,
          ),
        ),
      ];

  Widget _meta() {
    final hh = widget.message.createdAt.hour.toString().padLeft(2, '0');
    final mm = widget.message.createdAt.minute.toString().padLeft(2, '0');
    final time = '$hh:$mm';
    final isReadByFriend = widget.message.isReadBy(widget.friendId);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.message.editedAt != null && widget.message.deletedAt == null)
          const Padding(
            padding: EdgeInsets.only(right: 6),
            child: Text(
              '(tahrirlandi)',
              style: TextStyle(fontSize: 10, color: GlassTokens.onGlassFaint),
            ),
          ),
        Text(time,
            style: const TextStyle(fontSize: 11, color: GlassTokens.onGlassMuted)),
        if (widget.isMine && widget.message.deletedAt == null) ...[
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
                color: GlassTokens.onGlassFaint),
        ],
      ],
    );
  }

  String _imageUrlFull() {
    if (widget.message.imageUrl.startsWith('http')) {
      return widget.message.imageUrl;
    }
    final host = ApiConstants.socketUrl; // host without /api suffix
    return '$host${widget.message.imageUrl}';
  }

  bool get _supportsKeyboardPreview {
    if (kIsWeb) return true;
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return true;
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return false;
    }
  }
}
