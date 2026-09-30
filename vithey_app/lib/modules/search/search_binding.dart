import 'package:get/get.dart';
import 'package:aub_connect_app/data/repositories/search_repository.dart';
import 'package:aub_connect_app/modules/search/search_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SearchController(Get.find<SearchRepository>()));
  }
}
