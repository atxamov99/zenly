import 'package:blink/domain/repositories/auth_repository.dart';
import 'package:blink/domain/usecases/auth/verify_otp_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;
  late VerifyOtpUseCase useCase;

  setUp(() {
    mockRepo = MockAuthRepository();
    useCase = VerifyOtpUseCase(mockRepo);
  });

  test('returns uid when OTP is valid', () async {
    when(() => mockRepo.verifyOtp(
          verificationId: 'vid-123',
          smsCode: '123456',
        )).thenAnswer((_) async => 'user-uid-abc');

    final uid = await useCase.call(
      verificationId: 'vid-123',
      smsCode: '123456',
    );

    expect(uid, 'user-uid-abc');
    verify(() => mockRepo.verifyOtp(
          verificationId: 'vid-123',
          smsCode: '123456',
        )).called(1);
  });

  test('propagates exception from repository', () async {
    when(() => mockRepo.verifyOtp(
          verificationId: any(named: 'verificationId'),
          smsCode: any(named: 'smsCode'),
        )).thenThrow(Exception('invalid-verification-code'));

    expect(
      () => useCase.call(verificationId: 'bad', smsCode: '000000'),
      throwsException,
    );
  });
}
