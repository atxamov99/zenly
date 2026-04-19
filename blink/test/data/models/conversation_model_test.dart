import 'package:flutter_test/flutter_test.dart';
import 'package:blink/data/models/conversation_model.dart';

void main() {
  group('ConversationModel.fromApi', () {
    test('extracts otherUserId, lastMessage, unreadCount', () {
      final json = {
        '_id': 'c1',
        'participants': ['me', 'friend'],
        'lastMessage': {
          'text': 'hello',
          'type': 'text',
          'senderId': 'me',
          'createdAt': '2026-04-19T12:00:00.000Z'
        },
        'lastMessageAt': '2026-04-19T12:00:00.000Z',
        'unread': {'me': 0, 'friend': 3}
      };
      final c = ConversationModel.fromApi(json, currentUserId: 'me');
      expect(c.id, 'c1');
      expect(c.otherUserId, 'friend');
      expect(c.lastMessage?.text, 'hello');
      expect(c.unreadCount, 0); // unread of CURRENT user (me)
      expect(c.lastMessageAt, isNotNull);
    });

    test('returns null lastMessage when missing', () {
      final json = {
        '_id': 'c2',
        'participants': ['me', 'friend2'],
        'unread': {}
      };
      final c = ConversationModel.fromApi(json, currentUserId: 'me');
      expect(c.lastMessage, isNull);
      expect(c.unreadCount, 0);
    });
  });
}
