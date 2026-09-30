import 'package:get/get.dart';
import 'package:aub_connect_app/data/repositories/profile_repository.dart';
import 'package:aub_connect_app/modules/profile/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<ProfileController>()) return;
    Get.put<ProfileController>(
      ProfileController(Get.find<ProfileRepository>()),
      permanent: true,
    );
  }
}
