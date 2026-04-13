import '../../repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository _repo;
  const SignOutUseCase(this._repo);

  Future<void> call() => _repo.signOut();
}
