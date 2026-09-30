import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/modules/home/shell/main_shell_screen.dart';

/// Shared indices for the floating main bottom bar.
///
/// Order: Profile · Home · Reel · Chatbot · Notifications
/// Chatbot opens as a full-screen route (no bottom bar).
class MainTabNavigation {
  MainTabNavigation._();

  static const int profile = 0;
  static const int home = 1;
  static const int reel = 2;
  static const int chatbot = 3;
  static const int notifications = 4;

  /// Switch tabs inside the main shell, or open chatbot full-screen.
  static void handle(int index, {required int currentIndex}) {
    if (index == chatbot) {
      Get.toNamed(AppRoutes.chatbot);
      return;
    }
    if (index == currentIndex) return;
    goToMainTab(index);
  }
}
