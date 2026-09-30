import 'package:get/get.dart';
import 'package:aub_connect_app/data/repositories/cv_repository.dart';
import 'package:aub_connect_app/data/repositories/job_application_repository.dart';
import 'package:aub_connect_app/modules/jobs/apply_cv_controller.dart';
import 'package:aub_connect_app/modules/jobs/application_status_screen.dart';

class ApplyCvBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ApplyCvController(Get.find<CvRepository>(), Get.find<JobApplicationRepository>()));
  }
}

class ApplicationStatusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ApplicationStatusController(Get.find<JobApplicationRepository>()));
  }
}
