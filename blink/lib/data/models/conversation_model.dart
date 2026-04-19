import '../../domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.otherUserId,
    super.lastMessage,
    super.lastMessageAt,
    super.unreadCount,
  });

  factory ConversationModel.fromApi(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) {
    final participants = ((json['participants'] as List<dynamic>?) ?? const [])
        .map((e) => e.toString())
        .toList();
    final otherUserId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    ConversationLastMessage? last;
    final lastRaw = json['lastMessage'];
    final lastJson = lastRaw is Map ? Map<String, dynamic>.from(lastRaw) : null;
    if (lastJson != null && lastJson['createdAt'] != null) {
      last = ConversationLastMessage(
        text: (lastJson['text'] ?? '').toString(),
        type: (lastJson['type'] ?? 'text').toString(),
        senderId: (lastJson['senderId'] ?? '').toString(),
        createdAt: DateTime.parse(lastJson['createdAt'] as String).toUtc(),
      );
    }

    final unreadRaw = json['unread'];
    final unreadMap =
        unreadRaw is Map ? Map<String, dynamic>.from(unreadRaw) : const {};
    final unreadCount = (unreadMap[currentUserId] as num?)?.toInt() ?? 0;

    return ConversationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      otherUserId: otherUserId,
      lastMessage: last,
      lastMessageAt: json['lastMessageAt'] == null
          ? null
          : DateTime.parse(json['lastMessageAt'] as String).toUtc(),
      unreadCount: unreadCount,
    );
  }
}
