import 'package:get/get.dart';
import 'package:aub_connect_app/data/repositories/finance_repository.dart';
import 'package:aub_connect_app/data/repositories/student_verification_repository.dart';
import 'package:aub_connect_app/modules/finance/finance_controller.dart';

class FinanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => FinanceController(Get.find<FinanceRepository>(), Get.find<StudentVerificationRepository>()),
    );
  }
}
