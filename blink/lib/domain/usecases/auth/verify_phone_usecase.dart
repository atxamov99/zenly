import '../../repositories/auth_repository.dart';

class VerifyPhoneUseCase {
  final AuthRepository _repo;
  const VerifyPhoneUseCase(this._repo);

  /// Sends OTP to [phoneNumber]. Returns verificationId.
  Future<String> call(String phoneNumber) {
    return _repo.verifyPhoneNumber(phoneNumber);
  }
}
