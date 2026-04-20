import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blink/domain/entities/conversation_entity.dart';
import 'package:blink/domain/entities/friend_entity.dart';
import 'package:blink/presentation/screens/friends/widgets/friend_tile.dart';

FriendEntity _friend({bool online = false}) => FriendEntity(
      userId: 'f1',
      username: 'john',
      displayName: 'John Doe',
      avatarUrl: null,
      isOnline: online,
      smartStatus: 'idle',
    );

void main() {
  group('FriendTile', () {
    testWidgets('shows last message preview when conversation exists',
        (tester) async {
      final convo = ConversationEntity(
        id: 'c1',
        otherUserId: 'f1',
        lastMessage: ConversationLastMessage(
          text: 'Salom',
          type: 'text',
          senderId: 'f1',
          createdAt: DateTime.now(),
        ),
        lastMessageAt: DateTime.now(),
        unreadCount: 2,
      );
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FriendTile(friend: _friend(), conversation: convo),
        ),
      ));
      expect(find.text('Salom'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('falls back to status when no conversation', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FriendTile(friend: _friend()),
        ),
      ));
      expect(find.textContaining('@john'), findsOneWidget);
      expect(find.textContaining('idle'), findsOneWidget);
    });

    testWidgets('image-only last message shows "📷 Rasm"', (tester) async {
      final convo = ConversationEntity(
        id: 'c1',
        otherUserId: 'f1',
        lastMessage: ConversationLastMessage(
          text: '',
          type: 'image',
          senderId: 'f1',
          createdAt: DateTime.now(),
        ),
        lastMessageAt: DateTime.now(),
        unreadCount: 0,
      );
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FriendTile(friend: _friend(), conversation: convo),
        ),
      ));
      expect(find.text('📷 Rasm'), findsOneWidget);
    });
  });
}
