import 'package:get/get.dart';
import 'package:aub_connect_app/modules/settings/about/about_controller.dart';

class AboutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AboutController>(() => AboutController());
  }
}
