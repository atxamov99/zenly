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

class ConversationEntity {
  final String id;
  final String otherUserId;
  final ConversationLastMessage? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const ConversationEntity({
    required this.id,
    required this.otherUserId,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });
}
