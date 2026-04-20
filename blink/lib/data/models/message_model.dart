import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.type,
    required super.text,
    required super.imageUrl,
    required super.createdAt,
    super.editedAt,
    super.deletedAt,
    super.readBy,
    super.clientMessageId,
  });

  @override
  MessageModel copyWith({
    String? id,
    String? text,
    DateTime? editedAt,
    DateTime? deletedAt,
    List<MessageReadReceipt>? readBy,
  }) {
    return MessageModel(
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

  factory MessageModel.fromApi(Map<String, dynamic> json) {
    final readByRaw = (json['readBy'] as List<dynamic>?) ?? const [];
    return MessageModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      type: json['type']?.toString() ?? 'text',
      text: (json['text'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
      editedAt: json['editedAt'] == null
          ? null
          : DateTime.parse(json['editedAt'] as String).toUtc(),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String).toUtc(),
      readBy: readByRaw
          .map((e) => MessageReadReceipt(
                userId: (e as Map<String, dynamic>)['userId'].toString(),
                readAt: DateTime.parse(e['readAt'] as String).toUtc(),
              ))
          .toList(),
    );
  }
}
