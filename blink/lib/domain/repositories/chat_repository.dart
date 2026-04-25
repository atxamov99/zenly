// blink/lib/domain/repositories/chat_repository.dart
import '../entities/conversation_entity.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  /// One-shot snapshot of the chat list (REST).
  Future<List<ConversationEntity>> fetchConversations();

  /// Live stream of the chat list (REST seed + socket updates).
  Stream<List<ConversationEntity>> watchConversations();

  /// Live stream of messages for a single conversation (REST seed + socket updates).
  /// Newest message at index 0.
  Stream<List<MessageEntity>> watchMessages(String friendId);

  /// Returns the persisted message (with server id, createdAt).
  Future<MessageEntity> sendTextMessage({
    required String friendId,
    required String text,
    required String clientMessageId,
  });

  Future<MessageEntity> sendImageMessage({
    required String friendId,
    required String imagePath,
    required String clientMessageId,
  });

  Future<MessageEntity> editMessage({
    required String messageId,
    required String newText,
  });

  Future<void> deleteMessage(String messageId);

  Future<void> markAsRead(String friendId);

  /// Live "is friend currently typing?" stream.
  Stream<bool> watchTyping(String friendId);

  void emitTypingStart(String friendId);
  void emitTypingStop(String friendId);

  /// Loads older messages (for pagination).
  Future<List<MessageEntity>> loadOlderMessages({
    required String friendId,
    required DateTime before,
    int limit = 30,
  });

  // ─── Group chat ──────────────────────────────────────────────────

  /// Live stream of all groups the user belongs to.
  Stream<List<ConversationEntity>> watchGroups();

  /// Live stream of messages for a single group (REST seed + socket updates).
  Stream<List<MessageEntity>> watchGroupMessages(String conversationId);

  Future<ConversationEntity> createGroup({
    required String title,
    required List<String> memberIds,
  });

  Future<MessageEntity> sendGroupText({
    required String conversationId,
    required String text,
  });

  Future<MessageEntity> sendGroupImage({
    required String conversationId,
    required String imagePath,
  });

  Future<void> markGroupAsRead(String conversationId);

  Future<void> renameGroup({
    required String conversationId,
    required String title,
  });

  Future<void> addGroupMember({
    required String conversationId,
    required String userId,
  });

  Future<void> removeGroupMember({
    required String conversationId,
    required String userId,
  });
}
