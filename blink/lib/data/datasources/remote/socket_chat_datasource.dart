import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../models/message_model.dart';
import '../../models/conversation_model.dart';

/// Streams normalized chat events. The repository merges these with REST data.
sealed class ChatEvent {}

class ChatMessageEvent extends ChatEvent {
  final MessageModel message;
  final Map<String, dynamic> conversationRaw;
  ChatMessageEvent(this.message, this.conversationRaw);
}

class ChatReadEvent extends ChatEvent {
  final String conversationId;
  final String friendId;
  final DateTime readAt;
  ChatReadEvent(this.conversationId, this.friendId, this.readAt);
}

class ChatEditedEvent extends ChatEvent {
  final String messageId;
  final String text;
  final DateTime editedAt;
  ChatEditedEvent(this.messageId, this.text, this.editedAt);
}

class ChatDeletedEvent extends ChatEvent {
  final String messageId;
  ChatDeletedEvent(this.messageId);
}

class ChatTypingEvent extends ChatEvent {
  final String friendId;
  final bool isTyping;
  ChatTypingEvent(this.friendId, this.isTyping);
}

class SocketChatDatasource {
  final io.Socket _socket;
  final _events = StreamController<ChatEvent>.broadcast();
  bool _bound = false;

  SocketChatDatasource(this._socket) {
    _bind();
  }

  Stream<ChatEvent> get events => _events.stream;

  void _bind() {
    if (_bound) return;
    _bound = true;

    _socket.on('chat:message', (data) {
      try {
        final raw = data as Map<String, dynamic>;
        _events.add(ChatMessageEvent(
          MessageModel.fromApi(raw['message'] as Map<String, dynamic>),
          raw['conversation'] as Map<String, dynamic>,
        ));
      } catch (_) {/* malformed payload — ignore */}
    });

    _socket.on('chat:read', (data) {
      try {
        final raw = data as Map<String, dynamic>;
        _events.add(ChatReadEvent(
          raw['conversationId'] as String,
          raw['friendId'] as String,
          DateTime.parse(raw['readAt'] as String).toUtc(),
        ));
      } catch (_) {}
    });

    _socket.on('chat:edited', (data) {
      try {
        final raw = data as Map<String, dynamic>;
        _events.add(ChatEditedEvent(
          raw['messageId'] as String,
          raw['text'] as String,
          DateTime.parse(raw['editedAt'] as String).toUtc(),
        ));
      } catch (_) {}
    });

    _socket.on('chat:deleted', (data) {
      try {
        final raw = data as Map<String, dynamic>;
        _events.add(ChatDeletedEvent(raw['messageId'] as String));
      } catch (_) {}
    });

    _socket.on('chat:typing', (data) {
      try {
        final raw = data as Map<String, dynamic>;
        _events.add(ChatTypingEvent(
          raw['friendId'] as String,
          raw['isTyping'] as bool,
        ));
      } catch (_) {}
    });
  }

  void emitTypingStart(String friendId) {
    _socket.emit('chat:typing_start', {'friendId': friendId});
  }

  void emitTypingStop(String friendId) {
    _socket.emit('chat:typing_stop', {'friendId': friendId});
  }

  Future<void> dispose() async {
    await _events.close();
  }
}
