import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/api_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiAuthDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  Future<String> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _datasource.signInWithEmail(email: email, password: password);

  @override
  Future<String> registerWithEmail({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) =>
      _datasource.registerWithEmail(
        email: email,
        password: password,
        username: username,
        displayName: displayName,
      );

  @override
  Future<String> signInWithGoogle() => _datasource.signInWithGoogle();

  @override
  Future<void> signOut() => _datasource.signOut();

  @override
  Future<String?> getStoredUid() => _datasource.getStoredUid();

  @override
  Future<bool> hasValidSession() => _datasource.hasValidSession();
}
