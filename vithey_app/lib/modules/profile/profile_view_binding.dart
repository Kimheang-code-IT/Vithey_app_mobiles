import 'package:get/get.dart';
import 'package:aub_connect_app/data/repositories/profile_repository.dart';
import 'package:aub_connect_app/modules/profile/profile_view_controller.dart';

class ProfileViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileViewController>(
      () => ProfileViewController(Get.find<ProfileRepository>()),
      fenix: true,
    );
  }
}
