import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/api_user_datasource.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/user/create_user_profile_usecase.dart';
import 'auth_provider.dart';

// ── Datasource ──────────────────────────────────────────────

final apiUserDatasourceProvider = Provider<ApiUserDatasource>((ref) {
  return ApiUserDatasource(ref.watch(apiClientProvider));
});

// ── Repository ──────────────────────────────────────────────

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.watch(apiUserDatasourceProvider));
});

// ── Use Cases ───────────────────────────────────────────────

final createUserProfileUseCaseProvider = Provider((ref) {
  return CreateUserProfileUseCase(ref.watch(userRepositoryProvider));
});

// ── Current User ────────────────────────────────────────────

final currentUserProvider = FutureProvider<UserEntity?>((ref) async {
  final auth = ref.watch(authStateProvider);
  final uid = auth.value;
  if (uid == null) return null;
  try {
    return await ref.watch(userRepositoryProvider).getUserById(uid);
  } catch (_) {
    return null;
  }
});

/// Backend tomondan profil yaratilganligini tekshiradi.
final userProfileExistsProvider = FutureProvider<bool>((ref) async {
  final uid = ref.watch(authStateProvider).value;
  if (uid == null) return false;
  try {
    final user = await ref.watch(userRepositoryProvider).getUserById(uid);
    return user.username.isNotEmpty && user.displayName.isNotEmpty;
  } catch (_) {
    return false;
  }
});
