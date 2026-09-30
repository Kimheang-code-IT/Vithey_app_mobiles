import 'package:aub_connect_app/data/services/google_auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

class _FakeGoogleSignInPlatform extends GoogleSignInPlatform {
  _FakeGoogleSignInPlatform({
    this.supported = true,
    this.result,
    this.error,
  });

  final bool supported;
  final AuthenticationResults? result;
  final GoogleSignInException? error;

  InitParameters? initParameters;
  int authenticateCalls = 0;

  @override
  Future<void> init(InitParameters params) async {
    initParameters = params;
  }

  @override
  bool supportsAuthenticate() => supported;

  @override
  Future<AuthenticationResults> authenticate(AuthenticateParameters params) async {
    authenticateCalls++;
    if (error != null) {
      throw error!;
    }
    return result!;
  }

  @override
  Future<AuthenticationResults?>? attemptLightweightAuthentication(
    AttemptLightweightAuthenticationParameters params,
  ) async {
    return null;
  }

  @override
  bool authorizationRequiresUserInteraction() => false;

  @override
  Future<ClientAuthorizationTokenData?> clientAuthorizationTokensForScopes(
    ClientAuthorizationTokensForScopesParameters params,
  ) async {
    return null;
  }

  @override
  Future<ServerAuthorizationTokenData?> serverAuthorizationTokensForScopes(
    ServerAuthorizationTokensForScopesParameters params,
  ) async {
    return null;
  }

  @override
  Future<void> signOut(SignOutParams params) async {}

  @override
  Future<void> disconnect(DisconnectParams params) async {}
}

AuthenticationResults _result({String? idToken, String email = 'student@aub.edu.kh'}) {
  return AuthenticationResults(
    user: GoogleSignInUserData(id: 'google-sub-1', email: email),
    authenticationTokens: AuthenticationTokenData(idToken: idToken),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('initializes with the configured server client ID and returns the ID token', () async {
    final fake = _FakeGoogleSignInPlatform(result: _result(idToken: 'google-id-token'));
    GoogleSignInPlatform.instance = fake;

    final service = GoogleAuthService(serverClientId: 'web-client-id.apps.googleusercontent.com');
    final token = await service.obtainIdToken();

    expect(token, 'google-id-token');
    expect(fake.initParameters?.serverClientId, 'web-client-id.apps.googleusercontent.com');
    expect(fake.authenticateCalls, 1);
  });

  test('throws GoogleSignInCancelledException when the user cancels', () async {
    GoogleSignInPlatform.instance = _FakeGoogleSignInPlatform(
      error: const GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
    );

    final service = GoogleAuthService(serverClientId: 'client');
    expect(service.obtainIdToken(), throwsA(isA<GoogleSignInCancelledException>()));
  });

  test('throws GoogleAuthException when the platform does not support authenticate', () async {
    GoogleSignInPlatform.instance = _FakeGoogleSignInPlatform(supported: false);

    final service = GoogleAuthService(serverClientId: 'client');
    expect(service.obtainIdToken(), throwsA(isA<GoogleAuthException>()));
  });

  test('throws GoogleAuthException when Google returns no ID token', () async {
    GoogleSignInPlatform.instance = _FakeGoogleSignInPlatform(result: _result(idToken: null));

    final service = GoogleAuthService(serverClientId: 'client');
    expect(service.obtainIdToken(), throwsA(isA<GoogleAuthException>()));
  });

  test('maps non-cancel failures to GoogleAuthException', () async {
    GoogleSignInPlatform.instance = _FakeGoogleSignInPlatform(
      error: const GoogleSignInException(code: GoogleSignInExceptionCode.unknownError),
    );

    final service = GoogleAuthService(serverClientId: 'client');
    expect(service.obtainIdToken(), throwsA(isA<GoogleAuthException>()));
  });

  test('obtainEmail returns the account email and null on cancel', () async {
    GoogleSignInPlatform.instance = _FakeGoogleSignInPlatform(
      result: _result(email: 'student@aub.edu.kh'),
    );
    final service = GoogleAuthService(serverClientId: 'client');
    expect(await service.obtainEmail(), 'student@aub.edu.kh');

    GoogleSignInPlatform.instance = _FakeGoogleSignInPlatform(
      error: const GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
    );
    final cancelled = GoogleAuthService(serverClientId: 'client');
    expect(await cancelled.obtainEmail(), isNull);
  });
}
