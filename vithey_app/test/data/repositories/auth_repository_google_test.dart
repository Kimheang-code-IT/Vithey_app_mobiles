import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/core/session/current_user_service.dart';
import 'package:aub_connect_app/core/storage/secure_storage_service.dart';
import 'package:aub_connect_app/data/models/auth_result_model.dart';
import 'package:aub_connect_app/data/models/auth_token_model.dart';
import 'package:aub_connect_app/data/models/user_model.dart';
import 'package:aub_connect_app/data/repositories/auth_repository.dart';
import 'package:aub_connect_app/data/services/auth_service.dart';
import 'package:aub_connect_app/data/services/google_auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthService extends Mock implements AuthService {}

class _MockGoogleAuthService extends Mock implements GoogleAuthService {}

class _MockSecureStorageService extends Mock implements SecureStorageService {}

class _MockCurrentUserService extends Mock implements CurrentUserService {}

class _MockFeatureFlags extends Mock implements FeatureFlags {}

void main() {
  late _MockAuthService authService;
  late _MockGoogleAuthService googleAuthService;
  late _MockSecureStorageService secureStorage;
  late _MockCurrentUserService currentUser;
  late _MockFeatureFlags flags;
  late AuthRepository repository;

  final result = AuthResultModel(
    user: const UserModel(id: 'user-1', email: 'student@aub.edu.kh', fullName: 'Student'),
    tokens: const AuthTokenModel(accessToken: 'vithey-access', refreshToken: 'vithey-refresh', expiresIn: 900),
  );

  setUpAll(() {
    registerFallbackValue(result.user);
  });

  setUp(() {
    authService = _MockAuthService();
    googleAuthService = _MockGoogleAuthService();
    secureStorage = _MockSecureStorageService();
    currentUser = _MockCurrentUserService();
    flags = _MockFeatureFlags();
    when(() => flags.useMockAuth).thenReturn(false);
    repository = AuthRepository(
      authService,
      googleAuthService,
      secureStorage,
      currentUser,
      flags,
    );
  });

  test('successful Google sign-in stores Vithey tokens and sets the session user', () async {
    when(() => googleAuthService.obtainIdToken()).thenAnswer((_) async => 'google-id-token');
    when(() => authService.googleLogin(idToken: 'google-id-token')).thenAnswer((_) async => result);
    when(() => secureStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        )).thenAnswer((_) async {});
    when(() => currentUser.setUser(any())).thenReturn(null);

    final returned = await repository.signInWithGoogle();

    expect(returned.tokens.accessToken, 'vithey-access');
    verify(() => authService.googleLogin(idToken: 'google-id-token')).called(1);
    verify(() => secureStorage.saveTokens(
          accessToken: 'vithey-access',
          refreshToken: 'vithey-refresh',
        )).called(1);
    verify(() => currentUser.setUser(result.user)).called(1);
  });

  test('user cancellation propagates without touching the backend', () async {
    when(() => googleAuthService.obtainIdToken())
        .thenThrow(const GoogleSignInCancelledException());

    await expectLater(
      repository.signInWithGoogle(),
      throwsA(isA<GoogleSignInCancelledException>()),
    );

    verifyNever(() => authService.googleLogin(idToken: any(named: 'idToken')));
    verifyNever(() => secureStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ));
  });

  test('backend rejection surfaces an AuthServiceException without saving tokens', () async {
    when(() => googleAuthService.obtainIdToken()).thenAnswer((_) async => 'google-id-token');
    when(() => authService.googleLogin(idToken: 'google-id-token'))
        .thenThrow(AuthServiceException('Google token is invalid or expired'));

    await expectLater(
      repository.signInWithGoogle(),
      throwsA(isA<AuthServiceException>().having(
        (e) => e.message,
        'message',
        'Google token is invalid or expired',
      )),
    );

    verifyNever(() => secureStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ));
  });

  test('network failure surfaces an AuthServiceException', () async {
    when(() => googleAuthService.obtainIdToken()).thenAnswer((_) async => 'google-id-token');
    when(() => authService.googleLogin(idToken: 'google-id-token'))
        .thenThrow(AuthServiceException('Network request failed'));

    await expectLater(
      repository.signInWithGoogle(),
      throwsA(isA<AuthServiceException>().having(
        (e) => e.message,
        'message',
        'Network request failed',
      )),
    );
  });

  test('googleEmailForAccountChange delegates to the Google service', () async {
    when(() => googleAuthService.obtainEmail()).thenAnswer((_) async => 'student@aub.edu.kh');

    expect(await repository.googleEmailForAccountChange(), 'student@aub.edu.kh');
  });
}
