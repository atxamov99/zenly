import '../../entities/user_entity.dart';
import '../../repositories/user_repository.dart';

class CreateUserProfileUseCase {
  final UserRepository _repo;
  const CreateUserProfileUseCase(this._repo);

  Future<void> call(UserEntity user) => _repo.createUser(user);
}
