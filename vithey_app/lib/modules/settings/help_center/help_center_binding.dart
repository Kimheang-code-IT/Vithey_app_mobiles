import 'package:get/get.dart';
import 'package:aub_connect_app/modules/settings/help_center/help_center_controller.dart';

class HelpCenterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HelpCenterController>(() => HelpCenterController());
  }
}
