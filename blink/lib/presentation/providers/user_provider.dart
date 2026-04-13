import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/firestore_user_datasource.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/user/create_user_profile_usecase.dart';
import 'auth_provider.dart';

// ── Datasource ──────────────────────────────────────────────

final firestoreUserDatasourceProvider = Provider<FirestoreUserDatasource>((_) {
  return FirestoreUserDatasource();
});

// ── Repository ──────────────────────────────────────────────

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.watch(firestoreUserDatasourceProvider));
});

// ── Use Cases ───────────────────────────────────────────────

final createUserProfileUseCaseProvider = Provider((ref) {
  return CreateUserProfileUseCase(ref.watch(userRepositoryProvider));
});

// ── Current User Stream ─────────────────────────────────────

final currentUserProvider = StreamProvider<UserEntity?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (uid) {
      if (uid == null) return Stream.value(null);
      return ref.watch(userRepositoryProvider).watchUser(uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

/// Check if user profile exists in Firestore (for profile setup redirect).
final userProfileExistsProvider = FutureProvider<bool>((ref) async {
  final uid = ref.watch(authStateProvider).value;
  if (uid == null) return false;

  try {
    await ref.watch(userRepositoryProvider).getUserById(uid);
    return true;
  } catch (_) {
    return false;
  }
});
