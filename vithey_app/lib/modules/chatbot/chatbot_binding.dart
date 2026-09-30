import 'package:get/get.dart';
import 'package:aub_connect_app/data/repositories/ai_repository.dart';
import 'package:aub_connect_app/modules/chatbot/chatbot_controller.dart';

class ChatbotBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatbotController(Get.find<AiRepository>()));
  }
}
