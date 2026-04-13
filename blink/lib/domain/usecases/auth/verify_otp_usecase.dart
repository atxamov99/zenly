import '../../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository _repo;
  const VerifyOtpUseCase(this._repo);

  Future<String> call({
    required String verificationId,
    required String smsCode,
  }) {
    return _repo.verifyOtp(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }
}
