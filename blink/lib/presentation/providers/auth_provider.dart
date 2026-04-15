import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/token_storage.dart';
import '../../data/datasources/remote/api_auth_datasource.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth/sign_in_email_usecase.dart';
import '../../domain/usecases/auth/sign_in_google_usecase.dart';
import '../../domain/usecases/auth/sign_out_usecase.dart';

// ── Local Storage ───────────────────────────────────────────

final tokenStorageProvider = Provider<TokenStorage>((_) {
  return TokenStorage();
});

// ── HTTP Client ─────────────────────────────────────────────

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(tokenStorageProvider));
});

// ── Datasource ──────────────────────────────────────────────

final apiAuthDatasourceProvider = Provider<ApiAuthDatasource>((ref) {
  return ApiAuthDatasource(
    client: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

// ── Repository ──────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(apiAuthDatasourceProvider));
});

// ── Use Cases ───────────────────────────────────────────────

final signInEmailUseCaseProvider = Provider((ref) {
  return SignInEmailUseCase(ref.watch(authRepositoryProvider));
});

final registerEmailUseCaseProvider = Provider((ref) {
  return RegisterEmailUseCase(ref.watch(authRepositoryProvider));
});

final signInGoogleUseCaseProvider = Provider((ref) {
  return SignInGoogleUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

// ── Auth State ──────────────────────────────────────────────

class AuthNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    final repo = ref.watch(authRepositoryProvider);
    final hasSession = await repo.hasValidSession();
    if (!hasSession) return null;
    return repo.getStoredUid();
  }

  Future<void> setAuthenticated(String uid) async {
    state = AsyncData(uid);
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signOut();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final hasSession = await repo.hasValidSession();
      if (!hasSession) return null;
      return repo.getStoredUid();
    });
  }
}

final authStateProvider = AsyncNotifierProvider<AuthNotifier, String?>(
  AuthNotifier.new,
);

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).value != null;
});

final currentUidProvider = Provider<String>((ref) {
  final uid = ref.watch(authStateProvider).value;
  if (uid == null) throw StateError('No authenticated user');
  return uid;
});
