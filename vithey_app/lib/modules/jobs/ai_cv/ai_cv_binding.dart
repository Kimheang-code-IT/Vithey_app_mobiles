import 'package:aub_connect_app/data/repositories/ai_repository.dart';
import 'package:aub_connect_app/data/repositories/cv_repository.dart';
import 'package:aub_connect_app/modules/jobs/ai_cv/ai_cv_controller.dart';
import 'package:get/get.dart';

class AiCvBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => AiCvController(
        Get.find<AiRepository>(),
        Get.find<CvRepository>(),
      ),
    );
  }
}
