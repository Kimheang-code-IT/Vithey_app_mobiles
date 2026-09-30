import 'package:get/get.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/data/repositories/chat_repository.dart';
import 'package:aub_connect_app/modules/chat/chat_detail_controller.dart';
import 'package:aub_connect_app/modules/chat/chat_list_controller.dart';
import 'package:aub_connect_app/modules/chat/chat_profile_screen.dart';

class ChatListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ChatListController(
        Get.find<ChatRepository>(),
        Get.find<LocalStorageService>(),
      ),
    );
  }
}

class ChatDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatDetailController(Get.find<ChatRepository>()));
  }
}

class ChatProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ChatProfileController(
        Get.find<ChatRepository>(),
        Get.find<LocalStorageService>(),
      ),
    );
  }
}
