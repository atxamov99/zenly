import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../domain/entities/friend_location_entity.dart';

class FriendLocationSheet extends StatelessWidget {
  final FriendLocationEntity friend;

  const FriendLocationSheet({super.key, required this.friend});

  String _statusLabel(String status) {
    switch (status) {
      case 'home':
        return '🏠 Uyda';
      case 'traveling':
        return '🚗 Yo\'lda';
      case 'idle':
        return '💤 Bo\'sh';
      case 'offline':
      default:
        return '⚫ Offline';
    }
  }

  String _lastSeenLabel(DateTime? lastSeen) {
    if (lastSeen == null) return '';
    final diff = DateTime.now().difference(lastSeen);
    if (diff.inMinutes < 1) return 'Hozirgina';
    if (diff.inMinutes < 60) return '${diff.inMinutes} daqiqa oldin';
    if (diff.inHours < 24) return '${diff.inHours} soat oldin';
    return '${diff.inDays} kun oldin';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: friend.avatarUrl != null
                  ? CachedNetworkImageProvider(friend.avatarUrl!)
                  : null,
              child: friend.avatarUrl == null
                  ? Text(
                      friend.displayName.isNotEmpty
                          ? friend.displayName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(fontSize: 24),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.displayName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(_statusLabel(friend.smartStatus)),
                  if (friend.batteryPercent != null)
                    Text('🔋 ${friend.batteryPercent}%'),
                  if (friend.lastSeenAt != null)
                    Text(
                      _lastSeenLabel(friend.lastSeenAt),
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
