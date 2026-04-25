class ConversationLastMessage {
  final String text;
  final String type;
  final String senderId;
  final DateTime? createdAt;
  const ConversationLastMessage({
    required this.text,
    required this.type,
    required this.senderId,
    this.createdAt,
  });
}

class ConversationMember {
  final String userId;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final bool isOnline;

  const ConversationMember({
    required this.userId,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.isOnline = false,
  });
}

class ConversationEntity {
  final String id;
  final bool isGroup;
  final String title;
  final String avatarUrl;
  final String? ownerId;
  final List<String> adminIds;
  final List<ConversationMember> members;
  /// For DMs: the other user's id. For groups: empty string.
  final String otherUserId;
  final ConversationLastMessage? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const ConversationEntity({
    required this.id,
    this.isGroup = false,
    this.title = '',
    this.avatarUrl = '',
    this.ownerId,
    this.adminIds = const [],
    this.members = const [],
    required this.otherUserId,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });
}
