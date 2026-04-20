import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:blink/data/datasources/remote/api_chat_datasource.dart';
import 'package:blink/data/datasources/remote/socket_chat_datasource.dart';
import 'package:blink/data/models/message_model.dart';
import 'package:blink/data/repositories/chat_repository_impl.dart';

class _MockApi extends Mock implements ApiChatDatasource {}
class _MockSocket extends Mock implements SocketChatDatasource {}

MessageModel _msg(String id, String convId, String sender, String text) =>
    MessageModel(
      id: id,
      conversationId: convId,
      senderId: sender,
      type: 'text',
      text: text,
      imageUrl: '',
      createdAt: DateTime.parse('2026-04-19T12:00:00Z'),
    );

void main() {
  late _MockApi api;
  late _MockSocket socket;
  late StreamController<ChatEvent> events;
  late ChatRepositoryImpl repo;

  setUp(() {
    api = _MockApi();
    socket = _MockSocket();
    events = StreamController<ChatEvent>.broadcast();
    when(() => socket.events).thenAnswer((_) => events.stream);
    repo = ChatRepositoryImpl(
      api: api,
      socket: socket,
      currentUserId: 'me',
    );
  });

  tearDown(() => events.close());

  test('watchMessages emits REST seed then socket-pushed message', () async {
    when(() => api.fetchMessages(friendId: 'f1', limit: any(named: 'limit')))
        .thenAnswer((_) async => [_msg('m1', 'c1', 'f1', 'hi')]);

    final stream = repo.watchMessages('f1');
    final seed = await stream.first;
    expect(seed.map((m) => m.id).toList(), ['m1']);

    final next = stream.first; // wait for next emission
    final pushed = _msg('m2', 'c1', 'f1', 'second');
    events.add(ChatMessageEvent(pushed, {
      '_id': 'c1',
      'participants': ['me', 'f1'],
      'unread': {'me': 1, 'f1': 0}
    }));
    final updated = await next;
    expect(updated.map((m) => m.id).toList(), ['m2', 'm1']);
  });
}
