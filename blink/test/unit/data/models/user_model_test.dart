import 'package:blink/data/models/user_model.dart';
import 'package:blink/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserModel', () {
    final json = {
      'uid': 'uid-123',
      'displayName': 'Abdulaziz',
      'username': 'abdulaziz',
      'email': 'a@b.com',
      'phone': '+998901234567',
      'photoUrl': '',
      'emoji': '🦊',
      'statusMessage': 'Hey!',
      'isOnline': true,
      'lastSeen': null,
      'ghostMode': false,
      'ghostFromList': <String>[],
      'batteryPercent': 80,
      'isCharging': false,
      'locationSharingMode': 'precise',
      'fcmToken': 'token-abc',
      'createdAt': null,
    };

    test('fromJson creates correct model', () {
      final model = UserModel.fromJson(json);
      expect(model.uid, 'uid-123');
      expect(model.emoji, '🦊');
      expect(model.batteryPercent, 80);
    });

    test('toJson produces correct map', () {
      final model = UserModel.fromJson(json);
      final result = model.toJson();
      expect(result['uid'], 'uid-123');
      expect(result['ghostMode'], false);
    });

    test('toEntity converts to domain entity', () {
      final model = UserModel.fromJson(json);
      final entity = model.toEntity();
      expect(entity, isA<UserEntity>());
      expect(entity.uid, 'uid-123');
    });
  });
}
