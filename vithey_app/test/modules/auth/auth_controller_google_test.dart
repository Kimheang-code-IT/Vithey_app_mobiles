import 'package:aub_connect_app/data/repositories/auth_repository.dart';
import 'package:aub_connect_app/data/services/auth_service.dart';
import 'package:aub_connect_app/data/services/google_auth_service.dart';
import 'package:aub_connect_app/modules/auth/auth_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late AuthController controller;

  setUp(() {
    repository = _MockAuthRepository();
    controller = AuthController(repository);
  });

  test('Continue with Google triggers the repository once', () async {
    when(() => repository.signInWithGoogle())
        .thenThrow(const GoogleSignInCancelledException());

    await controller.continueWithGoogle(intent: AuthIntent.register);

    verify(() => repository.signInWithGoogle()).called(1);
  });

  test('cancellation returns cleanly with no error message', () async {
    when(() => repository.signInWithGoogle())
        .thenThrow(const GoogleSignInCancelledException());

    await controller.continueWithGoogle(intent: AuthIntent.signIn);

    expect(controller.errorMessage.value, isEmpty);
    expect(controller.isGoogleLoading.value, isFalse);
  });

  test('backend failure shows a user-friendly error message', () async {
    when(() => repository.signInWithGoogle())
        .thenThrow(AuthServiceException('Google token is invalid or expired'));

    await controller.continueWithGoogle(intent: AuthIntent.signIn);

    expect(controller.errorMessage.value, 'Google token is invalid or expired');
    expect(controller.isGoogleLoading.value, isFalse);
  });

  test('unexpected failure falls back to the generic error message', () async {
    when(() => repository.signInWithGoogle()).thenThrow(Exception('boom'));

    await controller.continueWithGoogle(intent: AuthIntent.signIn);

    expect(controller.errorMessage.value, isNotEmpty);
    expect(controller.isGoogleLoading.value, isFalse);
  });
}
