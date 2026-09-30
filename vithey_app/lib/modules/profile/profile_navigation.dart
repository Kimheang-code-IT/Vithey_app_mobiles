import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/navigation/main_tab_navigation.dart';
import 'package:aub_connect_app/data/models/profile_args.dart';
import 'package:aub_connect_app/data/repositories/profile_repository.dart';
import 'package:aub_connect_app/modules/home/shell/main_shell_screen.dart';

/// Opens own profile tab or the visitor profile screen.
void openUserProfile(String userId) {
  if (userId == ProfileRepository.currentUserId) {
    if (Get.currentRoute != AppRoutes.home) {
      goToMainTab(MainTabNavigation.profile);
    } else {
      goToMainTab(MainTabNavigation.profile);
    }
    return;
  }
  Get.toNamed(AppRoutes.profileView, arguments: ProfileArgs(userId: userId));
}
