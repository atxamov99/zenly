import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/firebase_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth/verify_phone_usecase.dart';
import '../../domain/usecases/auth/verify_otp_usecase.dart';
import '../../domain/usecases/auth/sign_in_email_usecase.dart';
import '../../domain/usecases/auth/sign_in_google_usecase.dart';
import '../../domain/usecases/auth/sign_out_usecase.dart';

// ── Datasource ──────────────────────────────────────────────

final firebaseAuthDatasourceProvider = Provider<FirebaseAuthDatasource>((_) {
  return FirebaseAuthDatasource();
});

// ── Repository ──────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(firebaseAuthDatasourceProvider));
});

// ── Use Cases ───────────────────────────────────────────────

final verifyPhoneUseCaseProvider = Provider((ref) {
  return VerifyPhoneUseCase(ref.watch(authRepositoryProvider));
});

final verifyOtpUseCaseProvider = Provider((ref) {
  return VerifyOtpUseCase(ref.watch(authRepositoryProvider));
});

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

/// Emits current uid or null. Used for routing and auth checks.
final authStateProvider = StreamProvider<String?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

/// Convenience: true if user is signed in.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).value != null;
});

/// Current uid. Throws if not authenticated.
final currentUidProvider = Provider<String>((ref) {
  final uid = ref.watch(authStateProvider).value;
  if (uid == null) throw StateError('No authenticated user');
  return uid;
});
