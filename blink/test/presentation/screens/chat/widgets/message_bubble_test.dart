import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blink/domain/entities/message_entity.dart';
import 'package:blink/presentation/screens/chat/widgets/message_bubble.dart';

MessageEntity _msg({
  String text = 'hello',
  String type = 'text',
  String imageUrl = '',
  DateTime? editedAt,
  DateTime? deletedAt,
  List<MessageReadReceipt> readBy = const [],
  String senderId = 'me',
}) =>
    MessageEntity(
      id: 'm1',
      conversationId: 'c1',
      senderId: senderId,
      type: type,
      text: text,
      imageUrl: imageUrl,
      createdAt: DateTime.parse('2026-04-19T12:00:00Z'),
      editedAt: editedAt,
      deletedAt: deletedAt,
      readBy: readBy,
    );

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('MessageBubble', () {
    testWidgets('text message shows text and time', (tester) async {
      await tester.pumpWidget(_wrap(
        MessageBubble(message: _msg(), isMine: true, friendId: 'f1'),
      ));
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('mine + read shows ✓✓ blue', (tester) async {
      await tester.pumpWidget(_wrap(
        MessageBubble(
          message: _msg(readBy: [
            MessageReadReceipt(userId: 'f1', readAt: DateTime.now())
          ]),
          isMine: true,
          friendId: 'f1',
        ),
      ));
      expect(find.byKey(const ValueKey('msg-status-read')), findsOneWidget);
    });

    testWidgets('mine + unread shows ✓ grey', (tester) async {
      await tester.pumpWidget(_wrap(
        MessageBubble(
          message: _msg(),
          isMine: true,
          friendId: 'f1',
        ),
      ));
      expect(find.byKey(const ValueKey('msg-status-delivered')), findsOneWidget);
    });

    testWidgets('editedAt shows "(tahrirlandi)" tag', (tester) async {
      await tester.pumpWidget(_wrap(
        MessageBubble(
          message: _msg(editedAt: DateTime.now()),
          isMine: true,
          friendId: 'f1',
        ),
      ));
      expect(find.textContaining('tahrirlandi'), findsOneWidget);
    });

    testWidgets('deleted shows deleted placeholder', (tester) async {
      await tester.pumpWidget(_wrap(
        MessageBubble(
          message: _msg(deletedAt: DateTime.now()),
          isMine: true,
          friendId: 'f1',
        ),
      ));
      expect(find.textContaining("o'chirildi"), findsOneWidget);
    });
  });
}
