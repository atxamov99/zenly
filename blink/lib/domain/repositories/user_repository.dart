import '../entities/user_entity.dart';

abstract class UserRepository {
  /// Creates a new user document in Firestore.
  Future<void> createUser(UserEntity user);

  /// Returns user by uid. Throws if not found.
  Future<UserEntity> getUserById(String uid);

  /// Updates specific fields of the user document.
  Future<void> updateUser(String uid, Map<String, dynamic> fields);

  /// Returns true if username is available.
  Future<bool> isUsernameAvailable(String username);

  /// Deletes all user data (Firestore + Storage).
  Future<void> deleteUser(String uid);

  /// Watches user document changes in real-time.
  Stream<UserEntity> watchUser(String uid);
}
