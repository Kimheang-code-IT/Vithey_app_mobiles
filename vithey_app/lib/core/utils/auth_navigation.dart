import 'package:get/get.dart';
import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/data/push/fcm_service.dart';
import 'package:aub_connect_app/data/repositories/notification_repository.dart';

class AuthNavigation {
  AuthNavigation._();

  /// After auth:
  /// - New registration → startup (skills / interests) once.
  /// - Returning login → home; mark first-run funnel done so splash
  ///   does not show language / onboarding / startup again.
  static Future<void> goAfterAuth({bool isNewUser = false}) async {
    final localStorage = Get.find<LocalStorageService>();
    final flags =
        Get.isRegistered<FeatureFlags>() ? Get.find<FeatureFlags>() : null;
    final forceStartup =
        flags != null && (flags.forceDevFunnel || flags.forceShowStartup);
    await _bootstrapNotifications();

    if (forceStartup || isNewUser) {
      Get.offAllNamed(AppRoutes.startupSkills);
      return;
    }

    // Returning user: skip first-run screens and persist so cold start is home.
    await localStorage.setLanguageSelected(true);
    await localStorage.setOnboardingCompleted(true);
    await localStorage.setStartupCompleted(true);
    Get.offAllNamed(AppRoutes.home);
  }

  static Future<void> bootstrapNotificationsIfNeeded() => _bootstrapNotifications();

  static Future<void> _bootstrapNotifications() async {
    if (!Get.isRegistered<NotificationRepository>()) return;
    final repository = Get.find<NotificationRepository>();
    await repository.onUserAuthenticated();
    if (Get.isRegistered<FcmService>()) {
      await Get.find<FcmService>().registerToken();
    }
  }
}
