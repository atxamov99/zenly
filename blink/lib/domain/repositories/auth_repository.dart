abstract class AuthRepository {
  /// Sends OTP SMS to phone number. Returns verificationId on success.
  Future<String> verifyPhoneNumber(String phoneNumber);

  /// Signs in with phone credential. Returns firebase uid.
  Future<String> verifyOtp({
    required String verificationId,
    required String smsCode,
  });

  /// Signs in with email and password. Returns firebase uid.
  Future<String> signInWithEmail({
    required String email,
    required String password,
  });

  /// Registers with email and password. Returns firebase uid.
  Future<String> registerWithEmail({
    required String email,
    required String password,
  });

  /// Signs in with Google. Returns firebase uid.
  Future<String> signInWithGoogle();

  /// Signs out from all providers.
  Future<void> signOut();

  /// Returns current firebase uid or null.
  String? get currentUid;

  /// Stream of auth state changes. Emits uid or null.
  Stream<String?> get authStateChanges;
}
