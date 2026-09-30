import 'package:aub_connect_app/data/models/feed_post.dart';

class AiCvArgs {
  const AiCvArgs({
    this.jobPostId,
    this.jobPreview,
    this.returnToApply = true,
    this.templateId,
    this.blank = false,
  });

  /// Null when the wizard is opened from Profile (no job context).
  final String? jobPostId;
  final FeedPost? jobPreview;

  /// True: save + return to Apply for [jobPostId].
  /// False: profile entry — save CV only and pop back.
  final bool returnToApply;

  /// Gallery template id to render / save with.
  final String? templateId;

  /// When true, skip AI fill and open an empty draft on the blank/minimal layout.
  final bool blank;

  static AiCvArgs from(dynamic arguments) {
    if (arguments is AiCvArgs) return arguments;
    if (arguments is String && arguments.isNotEmpty) {
      return AiCvArgs(jobPostId: arguments);
    }
    // No args → Profile "Generate with AI" entry (save-only).
    return const AiCvArgs(returnToApply: false);
  }

  bool get hasJobContext => returnToApply && jobPostId != null;

  AiCvArgs copyWith({
    String? jobPostId,
    FeedPost? jobPreview,
    bool? returnToApply,
    String? templateId,
    bool? blank,
  }) {
    return AiCvArgs(
      jobPostId: jobPostId ?? this.jobPostId,
      jobPreview: jobPreview ?? this.jobPreview,
      returnToApply: returnToApply ?? this.returnToApply,
      templateId: templateId ?? this.templateId,
      blank: blank ?? this.blank,
    );
  }
}
