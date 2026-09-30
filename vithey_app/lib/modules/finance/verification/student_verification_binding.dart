import 'package:get/get.dart';
import 'package:aub_connect_app/data/repositories/student_verification_repository.dart';
import 'package:aub_connect_app/modules/finance/verification/student_verification_screen.dart';
import 'package:aub_connect_app/modules/finance/verification/verification_status_screen.dart';

class StudentVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => StudentVerificationController(Get.find<StudentVerificationRepository>()),
      fenix: true,
    );
  }
}

class VerificationStatusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => VerificationStatusController(Get.find<StudentVerificationRepository>()),
      fenix: true,
    );
  }
}
