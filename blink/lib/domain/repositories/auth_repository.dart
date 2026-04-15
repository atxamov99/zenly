abstract class AuthRepository {
  /// Email + parol bilan tizimga kiradi. Backend uid ni qaytaradi.
  Future<String> signInWithEmail({
    required String email,
    required String password,
  });

  /// Yangi foydalanuvchini ro'yxatdan o'tkazadi. Backend uid ni qaytaradi.
  Future<String> registerWithEmail({
    required String email,
    required String password,
    required String username,
    required String displayName,
  });

  /// Google Sign-In orqali kiradi. Backend uid ni qaytaradi.
  Future<String> signInWithGoogle();

  /// Tizimdan chiqadi va saqlangan tokenlarni tozalaydi.
  Future<void> signOut();

  /// Saqlangan uid ni qaytaradi (lokal storagedan), aks holda null.
  Future<String?> getStoredUid();

  /// Lokal storage da token bormi.
  Future<bool> hasValidSession();
}
