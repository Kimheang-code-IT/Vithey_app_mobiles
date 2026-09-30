import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/data/models/payment_args.dart';

enum PaymentFlowStatus { collecting, processing, success }

class PaymentController extends GetxController {
  PaymentController(this.args);

  final PaymentArgs args;

  final status = PaymentFlowStatus.collecting.obs;

  /// Mock / v1 UI — no real gateway call yet, just a fixed processing delay.
  Future<void> confirmPayment() async {
    status.value = PaymentFlowStatus.processing;
    await Future<void>.delayed(const Duration(seconds: 2));
    status.value = PaymentFlowStatus.success;
  }

  void backToFinance() => Get.offNamed(AppRoutes.finance);
}
