import 'package:get/get.dart';
import 'package:aub_connect_app/data/repositories/profile_repository.dart';
import 'package:aub_connect_app/modules/settings/account/edit_account_settings_controller.dart';

class EditAccountSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditAccountSettingsController>(
      () => EditAccountSettingsController(Get.find<ProfileRepository>()),
    );
  }
}
