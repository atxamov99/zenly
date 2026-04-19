class MessageReadReceipt {
  final String userId;
  final DateTime readAt;
  const MessageReadReceipt({required this.userId, required this.readAt});
}

class MessageEntity {
  final String id;
  final String conversationId;
  final String senderId;
  final String type; // "text" | "image"
  final String text;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime? editedAt;
  final DateTime? deletedAt;
  final List<MessageReadReceipt> readBy;
  final String? clientMessageId; // optimistic-send dedupe key

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.type,
    required this.text,
    required this.imageUrl,
    required this.createdAt,
    this.editedAt,
    this.deletedAt,
    this.readBy = const [],
    this.clientMessageId,
  });

  bool isReadBy(String userId) =>
      readBy.any((r) => r.userId == userId);

  MessageEntity copyWith({
    String? id,
    String? text,
    DateTime? editedAt,
    DateTime? deletedAt,
    List<MessageReadReceipt>? readBy,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      conversationId: conversationId,
      senderId: senderId,
      type: type,
      text: text ?? this.text,
      imageUrl: imageUrl,
      createdAt: createdAt,
      editedAt: editedAt ?? this.editedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      readBy: readBy ?? this.readBy,
      clientMessageId: clientMessageId,
    );
  }
}
