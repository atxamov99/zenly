import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/remote/api_user_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final ApiUserDatasource _datasource;

  UserRepositoryImpl(this._datasource);

  @override
  Future<void> createUser(UserEntity user) async {
    await _datasource.updateProfile(
      displayName: user.displayName,
      username: user.username,
      avatarUrl: user.photoUrl.isEmpty ? null : user.photoUrl,
    );
  }

  @override
  Future<UserEntity> getUserById(String uid) async {
    final model = await _datasource.getMe();
    return model.toEntity();
  }

  @override
  Future<void> updateUser(String uid, Map<String, dynamic> fields) async {
    await _datasource.updateProfile(
      displayName: fields['displayName'] as String?,
      username: fields['username'] as String?,
      email: fields['email'] as String?,
      avatarUrl: fields['photoUrl'] as String? ?? fields['avatarUrl'] as String?,
    );
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    return true;
  }

  @override
  Future<void> deleteUser(String uid) async {
    throw UnimplementedError('Account deletion not supported by backend yet');
  }

  @override
  Stream<UserEntity> watchUser(String uid) async* {
    final model = await _datasource.getMe();
    yield model.toEntity();
  }
}
