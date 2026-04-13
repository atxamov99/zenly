import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/remote/firestore_user_datasource.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final FirestoreUserDatasource _datasource;

  UserRepositoryImpl(this._datasource);

  @override
  Future<void> createUser(UserEntity user) =>
      _datasource.createUser(UserModel.fromEntity(user));

  @override
  Future<UserEntity> getUserById(String uid) async {
    final model = await _datasource.getUserById(uid);
    return model.toEntity();
  }

  @override
  Future<void> updateUser(String uid, Map<String, dynamic> fields) =>
      _datasource.updateUser(uid, fields);

  @override
  Future<bool> isUsernameAvailable(String username) =>
      _datasource.isUsernameAvailable(username);

  @override
  Future<void> deleteUser(String uid) => _datasource.deleteUser(uid);

  @override
  Stream<UserEntity> watchUser(String uid) =>
      _datasource.watchUser(uid).map((model) => model.toEntity());
}
