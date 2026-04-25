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

  // ── Groups (keyed by conversationId) ─────────────────────────
  final Map<String, List<MessageModel>> _groupMessages = {};
  final Map<String, StreamController<List<MessageEntity>>>
      _groupMessageStreams = {};
  final Map<String, ConversationModel> _groupConversations = {};
  final StreamController<List<ConversationEntity>> _groupsCtrl =
      StreamController.broadcast();

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
    _groupsCtrl.close();
    for (final c in _messageStreams.values) {
      c.close();
    }
    for (final c in _groupMessageStreams.values) {
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
    _conversations.clear();
    _groupConversations.clear();
    for (final c in list) {
      if (c.isGroup) {
        _groupConversations[c.id] = c;
      } else if (c.otherUserId.isNotEmpty) {
        _conversations[c.otherUserId] = c;
      }
    }
    _conversationsCtrl.add(_sortedConversations());
    _groupsCtrl.add(_sortedGroups());
    return list;
  }

  List<ConversationEntity> _sortedGroups() {
    final list = _groupConversations.values.toList();
    list.sort((a, b) {
      final ad = a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bd = b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bd.compareTo(ad);
    });
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
        final isGroup = e.conversationRaw['isGroup'] as bool? ?? false;
        final convModel = ConversationModel.fromApi(
          e.conversationRaw,
          currentUserId: currentUserId,
        );

        if (isGroup) {
          _insertGroupMessage(convModel.id, e.message);
          _groupConversations[convModel.id] = convModel;
          _groupsCtrl.add(_sortedGroups());
          return;
        }

        // DM: route by friendId.
        final participants = ((e.conversationRaw['participants'] as List?) ?? [])
            .map((x) {
          if (x is Map) {
            return (x['_id'] ?? x['id'] ?? '').toString();
          }
          return x.toString();
        }).toList();
        final friendId = participants.firstWhere(
          (id) => id != currentUserId,
          orElse: () => '',
        );
        if (friendId.isEmpty) return;
        _insertMessage(friendId, e.message);
        _conversations[friendId] = convModel;
        _conversationsCtrl.add(_sortedConversations());

      case ChatEditedEvent e:
        _editMessage(e.messageId, e.text, e.editedAt);

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

      case ChatGroupCreatedEvent e:
        final model = ConversationModel.fromApi(
          e.conversationRaw,
          currentUserId: currentUserId,
        );
        _groupConversations[model.id] = model;
        _groupsCtrl.add(_sortedGroups());

      case ChatGroupUpdatedEvent e:
        final existing = _groupConversations[e.conversationId];
        if (existing == null) return;
        _groupConversations[e.conversationId] = ConversationModel(
          id: existing.id,
          isGroup: existing.isGroup,
          title: e.title ?? existing.title,
          avatarUrl: existing.avatarUrl,
          ownerId: existing.ownerId,
          adminIds: existing.adminIds,
          members: existing.members,
          otherUserId: existing.otherUserId,
          lastMessage: existing.lastMessage,
          lastMessageAt: existing.lastMessageAt,
          unreadCount: existing.unreadCount,
        );
        _groupsCtrl.add(_sortedGroups());

      case ChatMemberAddedEvent _:
      case ChatMemberRemovedEvent _:
        // Members changed — easiest is to refetch this group's full data.
        // For now, refetch the conversation list which re-populates members.
        fetchConversations();
    }
  }

  // ── Group chat ──────────────────────────────────────────────

  @override
  Stream<List<ConversationEntity>> watchGroups() {
    if (_groupConversations.isEmpty && _conversations.isEmpty) {
      fetchConversations();
    } else {
      scheduleMicrotask(() => _groupsCtrl.add(_sortedGroups()));
    }
    return _groupsCtrl.stream;
  }

  @override
  Stream<List<MessageEntity>> watchGroupMessages(String conversationId) {
    final ctrl = _groupMessageStreams.putIfAbsent(
      conversationId,
      () => StreamController<List<MessageEntity>>.broadcast(),
    );
    api.fetchGroupMessages(conversationId: conversationId).then((seed) {
      _groupMessages[conversationId] = seed;
      ctrl.add(List.unmodifiable(seed));
    }).catchError((_) {});
    return ctrl.stream;
  }

  @override
  Future<ConversationEntity> createGroup({
    required String title,
    required List<String> memberIds,
  }) async {
    final raw = await api.createGroup(title: title, memberIds: memberIds);
    final model = ConversationModel.fromApi(raw, currentUserId: currentUserId);
    _groupConversations[model.id] = model;
    _groupsCtrl.add(_sortedGroups());
    return model;
  }

  @override
  Future<MessageEntity> sendGroupText({
    required String conversationId,
    required String text,
  }) async {
    final msg =
        await api.sendGroupText(conversationId: conversationId, text: text);
    _insertGroupMessage(conversationId, msg);
    return msg;
  }

  @override
  Future<MessageEntity> sendGroupImage({
    required String conversationId,
    required String imagePath,
  }) async {
    final msg = await api.sendGroupImage(
      conversationId: conversationId,
      imagePath: imagePath,
    );
    _insertGroupMessage(conversationId, msg);
    return msg;
  }

  @override
  Future<void> markGroupAsRead(String conversationId) async {
    await api.markGroupRead(conversationId);
    final conv = _groupConversations[conversationId];
    if (conv != null) {
      _groupConversations[conversationId] = ConversationModel(
        id: conv.id,
        isGroup: conv.isGroup,
        title: conv.title,
        avatarUrl: conv.avatarUrl,
        ownerId: conv.ownerId,
        adminIds: conv.adminIds,
        members: conv.members,
        otherUserId: conv.otherUserId,
        lastMessage: conv.lastMessage,
        lastMessageAt: conv.lastMessageAt,
        unreadCount: 0,
      );
      _groupsCtrl.add(_sortedGroups());
    }
  }

  @override
  Future<void> renameGroup({
    required String conversationId,
    required String title,
  }) async {
    final raw = await api.renameGroup(
      conversationId: conversationId,
      title: title,
    );
    final model = ConversationModel.fromApi(raw, currentUserId: currentUserId);
    _groupConversations[model.id] = model;
    _groupsCtrl.add(_sortedGroups());
  }

  @override
  Future<void> addGroupMember({
    required String conversationId,
    required String userId,
  }) =>
      api.addGroupMember(conversationId: conversationId, userId: userId);

  @override
  Future<void> removeGroupMember({
    required String conversationId,
    required String userId,
  }) =>
      api.removeGroupMember(conversationId: conversationId, userId: userId);

  // ── Helpers ──────────────────────────────────────────────────

  void _insertMessage(String friendId, MessageModel msg) {
    final list = _messages.putIfAbsent(friendId, () => <MessageModel>[]);
    if (list.any((m) => m.id == msg.id)) return; // dedupe
    list.insert(0, msg);
    _messageStreams[friendId]?.add(List.unmodifiable(list));
  }

  void _insertGroupMessage(String conversationId, MessageModel msg) {
    final list =
        _groupMessages.putIfAbsent(conversationId, () => <MessageModel>[]);
    if (list.any((m) => m.id == msg.id)) return;
    list.insert(0, msg);
    _groupMessageStreams[conversationId]?.add(List.unmodifiable(list));
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
    for (final entry in _groupMessages.entries) {
      final idx = entry.value.indexWhere((m) => m.id == messageId);
      if (idx >= 0) {
        final m = entry.value[idx];
        entry.value[idx] = m.copyWith(deletedAt: DateTime.now());
        _groupMessageStreams[entry.key]?.add(List.unmodifiable(entry.value));
        return;
      }
    }
  }

  void _editMessage(String messageId, String text, DateTime editedAt) {
    for (final entry in _messages.entries) {
      final idx = entry.value.indexWhere((m) => m.id == messageId);
      if (idx >= 0) {
        entry.value[idx] = entry.value[idx].copyWith(
          text: text,
          editedAt: editedAt,
        );
        _messageStreams[entry.key]?.add(List.unmodifiable(entry.value));
        return;
      }
    }
    for (final entry in _groupMessages.entries) {
      final idx = entry.value.indexWhere((m) => m.id == messageId);
      if (idx >= 0) {
        entry.value[idx] = entry.value[idx].copyWith(
          text: text,
          editedAt: editedAt,
        );
        _groupMessageStreams[entry.key]?.add(List.unmodifiable(entry.value));
        return;
      }
    }
  }
}
