import 'package:flutter_test/flutter_test.dart';
import 'package:blink/data/models/message_model.dart';

void main() {
  group('MessageModel.fromApi', () {
    test('parses a text message', () {
      final json = {
        '_id': 'm1',
        'conversationId': 'c1',
        'senderId': 'u1',
        'type': 'text',
        'text': 'Salom',
        'imageUrl': '',
        'createdAt': '2026-04-19T12:00:00.000Z',
        'editedAt': null,
        'deletedAt': null,
        'readBy': [
          {'userId': 'u2', 'readAt': '2026-04-19T12:01:00.000Z'}
        ]
      };
      final m = MessageModel.fromApi(json);
      expect(m.id, 'm1');
      expect(m.text, 'Salom');
      expect(m.type, 'text');
      expect(m.readBy, hasLength(1));
      expect(m.readBy.first.userId, 'u2');
      expect(m.editedAt, isNull);
      expect(m.deletedAt, isNull);
    });

    test('parses an image message and edit/delete timestamps', () {
      final json = {
        '_id': 'm2',
        'conversationId': 'c1',
        'senderId': 'u1',
        'type': 'image',
        'text': '',
        'imageUrl': '/uploads/messages/u1-1.jpg',
        'createdAt': '2026-04-19T12:00:00.000Z',
        'editedAt': '2026-04-19T12:05:00.000Z',
        'deletedAt': '2026-04-19T12:10:00.000Z',
        'readBy': []
      };
      final m = MessageModel.fromApi(json);
      expect(m.type, 'image');
      expect(m.imageUrl, '/uploads/messages/u1-1.jpg');
      expect(m.editedAt, isNotNull);
      expect(m.deletedAt, isNotNull);
    });
  });
}
