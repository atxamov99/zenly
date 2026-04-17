import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../domain/entities/friend_entity.dart';

class FriendTile extends StatelessWidget {
  final FriendEntity friend;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;

  const FriendTile({
    super.key,
    required this.friend,
    this.onTap,
    this.onLongPress,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      leading: Stack(
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
      title: Text(
        friend.displayName.isNotEmpty ? friend.displayName : friend.username,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('@${friend.username} · ${friend.smartStatus}'),
      trailing: trailing,
    );
  }
}
