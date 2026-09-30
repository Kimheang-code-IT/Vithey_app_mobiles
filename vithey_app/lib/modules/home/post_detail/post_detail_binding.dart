import 'package:get/get.dart';
import 'package:aub_connect_app/data/repositories/comment_repository.dart';
import 'package:aub_connect_app/data/repositories/job_application_repository.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';
import 'package:aub_connect_app/modules/home/post_detail/post_detail_controller.dart';

class PostDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostDetailController>(
      () => PostDetailController(
        Get.find<PostRepository>(),
        Get.find<CommentRepository>(),
        Get.find<JobApplicationRepository>(),
      ),
    );
  }
}
