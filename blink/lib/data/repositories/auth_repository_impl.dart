import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  String? get currentUid => _datasource.currentUid;

  @override
  Stream<String?> get authStateChanges => _datasource.authStateChanges;

  @override
  Future<String> verifyPhoneNumber(String phoneNumber) =>
      _datasource.verifyPhoneNumber(phoneNumber);

  @override
  Future<String> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) =>
      _datasource.verifyOtp(
        verificationId: verificationId,
        smsCode: smsCode,
      );

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
  }) =>
      _datasource.registerWithEmail(email: email, password: password);

  @override
  Future<String> signInWithGoogle() => _datasource.signInWithGoogle();

  @override
  Future<void> signOut() => _datasource.signOut();
}
