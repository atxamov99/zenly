import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blink/domain/entities/conversation_entity.dart';
import 'package:blink/domain/entities/friend_entity.dart';
import 'package:blink/domain/entities/message_entity.dart';
import 'package:blink/domain/repositories/chat_repository.dart';
import 'package:blink/presentation/providers/auth_provider.dart';
import 'package:blink/presentation/providers/chat_provider.dart';
import 'package:blink/presentation/screens/chat/chat_screen.dart';
import 'package:blink/presentation/screens/chat/widgets/chat_app_bar.dart';
import 'package:blink/presentation/screens/chat/widgets/message_input.dart';

class _FakeChatRepository implements ChatRepository {
  @override
  Stream<List<MessageEntity>> watchMessages(String friendId) =>
      Stream.value(const <MessageEntity>[]);

  @override
  Stream<bool> watchTyping(String friendId) => Stream.value(false);

  @override
  Stream<List<ConversationEntity>> watchConversations() =>
      Stream.value(const <ConversationEntity>[]);

  @override
  Future<List<ConversationEntity>> fetchConversations() async => const [];

  @override
  Future<List<MessageEntity>> loadOlderMessages({
    required String friendId,
    required DateTime before,
    int limit = 30,
  }) async =>
      const [];

  @override
  Future<MessageEntity> sendTextMessage({
    required String friendId,
    required String text,
    required String clientMessageId,
  }) =>
      Completer<MessageEntity>().future;

  @override
  Future<MessageEntity> sendImageMessage({
    required String friendId,
    required String imagePath,
    required String clientMessageId,
  }) =>
      Completer<MessageEntity>().future;

  @override
  Future<MessageEntity> editMessage({
    required String messageId,
    required String newText,
  }) =>
      Completer<MessageEntity>().future;

  @override
  Future<void> deleteMessage(String messageId) async {}

  @override
  Future<void> markAsRead(String friendId) async {}

  @override
  void emitTypingStart(String friendId) {}

  @override
  void emitTypingStop(String friendId) {}

  @override
  Stream<List<ConversationEntity>> watchGroups() =>
      Stream.value(const <ConversationEntity>[]);

  @override
  Stream<List<MessageEntity>> watchGroupMessages(String conversationId) =>
      Stream.value(const <MessageEntity>[]);

  @override
  Future<ConversationEntity> createGroup({
    required String title,
    required List<String> memberIds,
  }) =>
      Completer<ConversationEntity>().future;

  @override
  Future<MessageEntity> sendGroupText({
    required String conversationId,
    required String text,
  }) =>
      Completer<MessageEntity>().future;

  @override
  Future<MessageEntity> sendGroupImage({
    required String conversationId,
    required String imagePath,
  }) =>
      Completer<MessageEntity>().future;

  @override
  Future<void> markGroupAsRead(String conversationId) async {}

  @override
  Future<void> renameGroup({
    required String conversationId,
    required String title,
  }) async {}

  @override
  Future<void> addGroupMember({
    required String conversationId,
    required String userId,
  }) async {}

  @override
  Future<void> removeGroupMember({
    required String conversationId,
    required String userId,
  }) async {}
}

void main() {
  testWidgets('ChatScreen renders empty state without crashing',
      (tester) async {
    const friend = FriendEntity(
      userId: 'f1',
      username: 'john',
      displayName: 'John',
      avatarUrl: null,
      isOnline: false,
      smartStatus: 'offline',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(_StubAuthNotifier.new),
          chatRepositoryProvider.overrideWithValue(_FakeChatRepository()),
        ],
        child: const MaterialApp(
          home: ChatScreen(friend: friend),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(ChatAppBar), findsOneWidget);
    expect(find.byType(MessageInput), findsOneWidget);
  });
}

class _StubAuthNotifier extends AuthNotifier {
  @override
  Future<String?> build() async => 'me';
}
