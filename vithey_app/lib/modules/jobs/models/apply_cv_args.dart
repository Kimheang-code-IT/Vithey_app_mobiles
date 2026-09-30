import 'package:aub_connect_app/data/models/feed_post.dart';

class ApplyCvArgs {
  const ApplyCvArgs({
    required this.jobPostId,
    this.jobPreview,
    this.preferredCvFileId,
    this.openOnReview = false,
  });

  final String jobPostId;
  final FeedPost? jobPreview;

  /// When returning from AI Create CV, prefer this saved CV file id.
  final String? preferredCvFileId;

  /// Jump straight to Review after load when CV is already selected.
  final bool openOnReview;

  static ApplyCvArgs from(dynamic arguments) {
    if (arguments is ApplyCvArgs) return arguments;
    if (arguments is String && arguments.isNotEmpty) {
      return ApplyCvArgs(jobPostId: arguments);
    }
    throw ArgumentError('ApplyCvArgs requires a jobPostId');
  }
}
