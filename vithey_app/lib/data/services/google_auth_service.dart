import 'package:google_sign_in/google_sign_in.dart';

/// Thrown when the user dismisses the Google sign-in sheet.
///
/// Callers should treat this as a clean, non-error return to the login screen.
class GoogleSignInCancelledException implements Exception {
  const GoogleSignInCancelledException();
}

/// Thrown when Google sign-in fails for any reason other than cancellation.
class GoogleAuthException implements Exception {
  GoogleAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Wraps the `google_sign_in` (v7) plugin for the app.
///
/// Uses [GoogleSignIn.instance] and the current async initialization API.
/// Only public client identifiers are used here — no OAuth client secret is
/// ever embedded in the app.
class GoogleAuthService {
  GoogleAuthService({String? serverClientId})
      : _serverClientId = (serverClientId ?? '').trim();

  final String _serverClientId;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: _serverClientId.isEmpty ? null : _serverClientId,
      );
      _initialized = true;
    } on GoogleSignInException {
      throw GoogleAuthException(
        'Google sign-in is unavailable right now. Please try again later.',
      );
    } catch (_) {
      throw GoogleAuthException(
        'Google sign-in is unavailable right now. Please try again later.',
      );
    }
  }

  /// Runs the interactive Google flow and returns the Google ID token.
  ///
  /// Throws [GoogleSignInCancelledException] if the user cancels, and
  /// [GoogleAuthException] for any other failure.
  Future<String> obtainIdToken() async {
    await _ensureInitialized();
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw GoogleAuthException('Google sign-in is not supported on this device.');
    }

    try {
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw GoogleAuthException(
          'Google did not return an identity token. Please try again.',
        );
      }
      return idToken;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const GoogleSignInCancelledException();
      }
      throw GoogleAuthException('Could not sign in with Google. Please try again.');
    }
  }

  /// Runs the Google flow and returns the account email, or null on cancel.
  ///
  /// Used only for the account "change email" affordance; never used as proof
  /// of identity (the backend only trusts the verified ID token).
  Future<String?> obtainEmail() async {
    await _ensureInitialized();
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      return null;
    }
    try {
      final account = await GoogleSignIn.instance.authenticate();
      return account.email;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      throw GoogleAuthException('Could not sign in with Google. Please try again.');
    }
  }
}
