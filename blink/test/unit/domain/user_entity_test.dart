import 'package:blink/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserEntity', () {
    test('creates with required fields', () {
      const user = UserEntity(
        uid: 'uid-123',
        displayName: 'Abdulaziz',
        username: 'abdulaziz',
        email: 'test@test.com',
        phone: '+998901234567',
        photoUrl: '',
        isOnline: true,
        ghostMode: false,
        batteryPercent: 80,
        isCharging: false,
        locationSharingMode: 'precise',
      );

      expect(user.uid, 'uid-123');
      expect(user.displayName, 'Abdulaziz');
      expect(user.isGhost, false);
    });

    test('copyWith updates fields', () {
      const user = UserEntity(
        uid: 'uid-123',
        displayName: 'Abdulaziz',
        username: 'abdulaziz',
        email: '',
        phone: '',
        photoUrl: '',
        isOnline: false,
        ghostMode: false,
        batteryPercent: 50,
        isCharging: false,
        locationSharingMode: 'precise',
      );

      final updated = user.copyWith(ghostMode: true, batteryPercent: 30);
      expect(updated.ghostMode, true);
      expect(updated.batteryPercent, 30);
      expect(updated.uid, 'uid-123'); // unchanged
    });
  });
}
