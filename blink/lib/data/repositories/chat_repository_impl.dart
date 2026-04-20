import 'dart:async';

import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/remote/api_chat_datasource.dart';
import '../datasources/remote/socket_chat_datasource.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ApiChatDatasource api;
  final SocketChatDatasource socket;
  final String currentUserId;

  /// In-memory caches keyed by friendId for messages, by friendId for conversations.
  final Map<String, List<MessageModel>> _messages = {};
  final Map<String, StreamController<List<MessageEntity>>> _messageStreams = {};
  final Map<String, ConversationModel> _conversations = {};
  final StreamController<List<ConversationEntity>> _conversationsCtrl =
      StreamController.broadcast();
  final Map<String, StreamController<bool>> _typing = {};

  late final StreamSubscription _socketSub;

  ChatRepositoryImpl({
    required this.api,
    required this.socket,
    required this.currentUserId,
  }) {
    _socketSub = socket.events.listen(_onSocketEvent);
  }

  void dispose() {
    _socketSub.cancel();
    _conversationsCtrl.close();
    for (final c in _messageStreams.values) {
      c.close();
    }
    for (final c in _typing.values) {
      c.close();
    }
  }

  // ── Conversations ────────────────────────────────────────────

  @override
  Future<List<ConversationEntity>> fetchConversations() async {
    final raw = await api.fetchConversationsRaw();
    final list = raw
        .map((e) => ConversationModel.fromApi(
              e as Map<String, dynamic>,
              currentUserId: currentUserId,
            ))
        .toList();
    _conversations
      ..clear()
      ..addEntries(list.map((c) => MapEntry(c.otherUserId, c)));
    _conversationsCtrl.add(_sortedConversations());
    return list;
  }

  @override
  Stream<List<ConversationEntity>> watchConversations() {
    if (_conversations.isEmpty) {
      // seed lazily
      fetchConversations();
    } else {
      // Re-emit current snapshot for late subscribers.
      scheduleMicrotask(
        () => _conversationsCtrl.add(_sortedConversations()),
      );
    }
    return _conversationsCtrl.stream;
  }

  List<ConversationEntity> _sortedConversations() {
    final list = _conversations.values.toList();
    list.sort((a, b) {
      final ad = a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bd = b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bd.compareTo(ad);
    });
    return list;
  }

  // ── Messages ─────────────────────────────────────────────────

  @override
  Stream<List<MessageEntity>> watchMessages(String friendId) {
    final ctrl = _messageStreams.putIfAbsent(
      friendId,
      () => StreamController<List<MessageEntity>>.broadcast(),
    );
    // Lazy seed
    api.fetchMessages(friendId: friendId).then((seed) {
      _messages[friendId] = seed;
      ctrl.add(List.unmodifiable(seed));
    }).catchError((_) {/* swallow — UI shows empty */});
    return ctrl.stream;
  }

  @override
  Future<List<MessageEntity>> loadOlderMessages({
    required String friendId,
    required DateTime before,
    int limit = 30,
  }) async {
    final older = await api.fetchMessages(
      friendId: friendId,
      before: before,
      limit: limit,
    );
    final cache = _messages[friendId] ?? <MessageModel>[];
    final merged = [...cache, ...older];
    _messages[friendId] = merged;
    _messageStreams[friendId]?.add(List.unmodifiable(merged));
    return older;
  }

  @override
  Future<MessageEntity> sendTextMessage({
    required String friendId,
    required String text,
    required String clientMessageId,
  }) async {
    final msg = await api.sendText(friendId: friendId, text: text);
    _insertMessage(friendId, msg);
    return msg;
  }

  @override
  Future<MessageEntity> sendImageMessage({
    required String friendId,
    required String imagePath,
    required String clientMessageId,
  }) async {
    final msg = await api.sendImage(friendId: friendId, imagePath: imagePath);
    _insertMessage(friendId, msg);
    return msg;
  }

  @override
  Future<MessageEntity> editMessage({
    required String messageId,
    required String newText,
  }) async {
    final updated = await api.editMessage(
      messageId: messageId,
      newText: newText,
    );
    _replaceMessage(updated);
    return updated;
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await api.deleteMessage(messageId);
    _markDeleted(messageId);
  }

  @override
  Future<void> markAsRead(String friendId) async {
    await api.markRead(friendId);
    final conv = _conversations[friendId];
    if (conv != null) {
      _conversations[friendId] = ConversationModel(
        id: conv.id,
        otherUserId: conv.otherUserId,
        lastMessage: conv.lastMessage is ConversationLastMessage
            ? conv.lastMessage as ConversationLastMessage
            : null,
        lastMessageAt: conv.lastMessageAt,
        unreadCount: 0,
      );
      _conversationsCtrl.add(_sortedConversations());
    }
  }

  // ── Typing ───────────────────────────────────────────────────

  @override
  Stream<bool> watchTyping(String friendId) {
    final ctrl = _typing.putIfAbsent(
      friendId,
      () => StreamController<bool>.broadcast(),
    );
    return ctrl.stream;
  }

  @override
  void emitTypingStart(String friendId) => socket.emitTypingStart(friendId);
  @override
  void emitTypingStop(String friendId) => socket.emitTypingStop(friendId);

  // ── Socket events → caches ───────────────────────────────────

  void _onSocketEvent(ChatEvent event) {
    switch (event) {
      case ChatMessageEvent e:
        // Determine friendId from the conversation participants.
        final participants = ((e.conversationRaw['participants'] as List?) ?? [])
            .map((x) => x.toString())
            .toList();
        final friendId = participants.firstWhere(
          (id) => id != currentUserId,
          orElse: () => '',
        );
        if (friendId.isEmpty) return;
        _insertMessage(friendId, e.message);
        // Refresh conversation cache from raw.
        _conversations[friendId] = ConversationModel.fromApi(
          e.conversationRaw,
          currentUserId: currentUserId,
        );
        _conversationsCtrl.add(_sortedConversations());

      case ChatEditedEvent e:
        for (final msgs in _messages.entries) {
          final idx = msgs.value.indexWhere((m) => m.id == e.messageId);
          if (idx >= 0) {
            final updated = msgs.value[idx].copyWith(
              text: e.text,
              editedAt: e.editedAt,
            );
            msgs.value[idx] = updated;
            _messageStreams[msgs.key]?.add(List.unmodifiable(msgs.value));
          }
        }

      case ChatDeletedEvent e:
        _markDeleted(e.messageId);

      case ChatReadEvent e:
        // Mark our outbound messages as read by the friend.
        for (final entry in _messages.entries) {
          var mutated = false;
          final updated = entry.value.map((m) {
            if (m.senderId == currentUserId &&
                !m.isReadBy(e.friendId)) {
              mutated = true;
              return m.copyWith(readBy: [
                ...m.readBy,
                MessageReadReceipt(userId: e.friendId, readAt: e.readAt),
              ]);
            }
            return m;
          }).toList();
          if (mutated) {
            _messages[entry.key] = updated;
            _messageStreams[entry.key]?.add(List.unmodifiable(updated));
          }
        }

      case ChatTypingEvent e:
        final ctrl = _typing.putIfAbsent(
          e.friendId,
          () => StreamController<bool>.broadcast(),
        );
        ctrl.add(e.isTyping);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────

  void _insertMessage(String friendId, MessageModel msg) {
    final list = _messages.putIfAbsent(friendId, () => <MessageModel>[]);
    if (list.any((m) => m.id == msg.id)) return; // dedupe
    list.insert(0, msg);
    _messageStreams[friendId]?.add(List.unmodifiable(list));
  }

  void _replaceMessage(MessageModel msg) {
    for (final entry in _messages.entries) {
      final idx = entry.value.indexWhere((m) => m.id == msg.id);
      if (idx >= 0) {
        entry.value[idx] = msg;
        _messageStreams[entry.key]?.add(List.unmodifiable(entry.value));
        return;
      }
    }
  }

  void _markDeleted(String messageId) {
    for (final entry in _messages.entries) {
      final idx = entry.value.indexWhere((m) => m.id == messageId);
      if (idx >= 0) {
        final m = entry.value[idx];
        entry.value[idx] = m.copyWith(deletedAt: DateTime.now());
        _messageStreams[entry.key]?.add(List.unmodifiable(entry.value));
        return;
      }
    }
  }
}
