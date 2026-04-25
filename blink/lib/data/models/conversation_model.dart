import '../../domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    super.isGroup,
    super.title,
    super.avatarUrl,
    super.ownerId,
    super.adminIds,
    super.members,
    required super.otherUserId,
    super.lastMessage,
    super.lastMessageAt,
    super.unreadCount,
  });

  factory ConversationModel.fromApi(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) {
    final isGroup = json['isGroup'] as bool? ?? false;

    // participants may be either an array of ObjectId strings or populated user objects.
    final rawParticipants = (json['participants'] as List<dynamic>?) ?? const [];
    final participantIds = <String>[];
    final members = <ConversationMember>[];
    for (final raw in rawParticipants) {
      if (raw is Map) {
        final id = (raw['_id'] ?? raw['id'] ?? '').toString();
        if (id.isEmpty) continue;
        participantIds.add(id);
        members.add(ConversationMember(
          userId: id,
          username: (raw['username'] ?? '').toString(),
          displayName: (raw['displayName'] ?? '').toString(),
          avatarUrl: raw['avatarUrl']?.toString(),
          isOnline: (raw['presence'] as Map?)?['isOnline'] as bool? ?? false,
        ));
      } else {
        participantIds.add(raw.toString());
      }
    }

    // For DMs, otherUserId is the participant that isn't the current user.
    String otherUserId = '';
    if (!isGroup) {
      otherUserId = participantIds.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );
    }

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

    final adminIds = ((json['adminIds'] as List<dynamic>?) ?? const [])
        .map((e) => e.toString())
        .toList();

    return ConversationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      isGroup: isGroup,
      title: (json['title'] ?? '').toString(),
      avatarUrl: (json['avatarUrl'] ?? '').toString(),
      ownerId: json['ownerId']?.toString(),
      adminIds: adminIds,
      members: members,
      otherUserId: otherUserId,
      lastMessage: last,
      lastMessageAt: json['lastMessageAt'] == null
          ? null
          : DateTime.parse(json['lastMessageAt'] as String).toUtc(),
      unreadCount: unreadCount,
    );
  }
}
