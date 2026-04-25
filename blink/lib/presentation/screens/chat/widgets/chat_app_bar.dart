import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/glass_tokens.dart';

import '../../../widgets/glass/glass_app_bar.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String displayName;
  final String? avatarUrl;
  final bool isOnline;
  final bool isTyping;

  const ChatAppBar({
    super.key,
    required this.displayName,
    required this.isOnline,
    required this.isTyping,
    this.avatarUrl,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final subtitle = isTyping
        ? 'yozmoqda…'
        : (isOnline ? 'online' : 'offline');
    return GlassAppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: avatarUrl != null
                ? CachedNetworkImageProvider(avatarUrl!)
                : null,
            child: avatarUrl == null
                ? Text(
                    displayName.isNotEmpty
                        ? displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(fontSize: 14),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(displayName,
                  style: const TextStyle(fontSize: 15)),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 11, color: GlassTokens.onGlassMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
