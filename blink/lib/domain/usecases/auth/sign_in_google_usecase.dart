import '../../repositories/auth_repository.dart';

class SignInGoogleUseCase {
  final AuthRepository _repo;
  const SignInGoogleUseCase(this._repo);

  Future<String> call() => _repo.signInWithGoogle();
}
