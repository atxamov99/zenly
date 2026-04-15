import '../../repositories/auth_repository.dart';

class SignInEmailUseCase {
  final AuthRepository _repo;
  const SignInEmailUseCase(this._repo);

  Future<String> call({
    required String email,
    required String password,
  }) {
    return _repo.signInWithEmail(email: email, password: password);
  }
}

class RegisterEmailUseCase {
  final AuthRepository _repo;
  const RegisterEmailUseCase(this._repo);

  Future<String> call({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) {
    return _repo.registerWithEmail(
      email: email,
      password: password,
      username: username,
      displayName: displayName,
    );
  }
}
