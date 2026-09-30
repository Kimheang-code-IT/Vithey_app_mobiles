import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/mock_identities.dart';
import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/data/models/post_author.dart';
import 'package:aub_connect_app/data/models/user_model.dart';
import 'package:aub_connect_app/data/repositories/student_verification_repository.dart';
import 'package:aub_connect_app/data/services/auth_service.dart';
import 'package:aub_connect_app/core/storage/secure_storage_service.dart';

/// Holds the authenticated user — single source for `userId` across the app.
class CurrentUserService extends GetxService {
  CurrentUserService(this._secureStorage, this._authService, this._flags);

  final SecureStorageService _secureStorage;
  final AuthService _authService;
  final FeatureFlags _flags;

  final user = Rxn<UserModel>();

  String get userId => user.value?.id ?? MockIdentities.mockUserId;

  String get displayName =>
      user.value?.fullName?.trim().isNotEmpty == true
          ? user.value!.fullName!.trim()
          : MockIdentities.mockUserFullName;

  String? get avatarUrl => user.value?.avatarUrl;

  PostAuthor get postAuthor => PostAuthor(
        id: userId,
        fullName: displayName,
        avatarUrl: avatarUrl,
      );

  bool get isAuthenticated => user.value != null;

  void setUser(UserModel? value) => user.value = value;

  void clear() => user.value = null;

  /// Restore session on cold start (splash). Safe to call when no token exists.
  Future<void> restoreSession() async {
    final hasToken = await _secureStorage.hasAccessToken();
    if (!hasToken) {
      clear();
      return;
    }

    if (_flags.useMockAuth) {
      setUser(
        const UserModel(
          id: MockIdentities.mockUserId,
          email: MockIdentities.mockUserEmail,
          fullName: MockIdentities.mockUserFullName,
          role: 'USER',
        ),
      );
      return;
    }

    try {
      final me = await _authService.getMe();
      setUser(me);
      if (Get.isRegistered<StudentVerificationRepository>()) {
        await Get.find<StudentVerificationRepository>().refreshVerifiedFlag();
      }
    } catch (_) {
      clear();
    }
  }
}
