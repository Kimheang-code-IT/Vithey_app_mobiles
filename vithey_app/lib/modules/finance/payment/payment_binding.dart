import 'package:get/get.dart';
import 'package:aub_connect_app/data/models/payment_args.dart';
import 'package:aub_connect_app/modules/finance/payment/payment_controller.dart';

class PaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(PaymentController(Get.arguments as PaymentArgs));
  }
}
