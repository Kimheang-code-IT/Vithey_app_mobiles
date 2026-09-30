import 'package:aub_connect_app/modules/jobs/models/apply_cv_result.dart';

class ApplySuccessArgs {
  const ApplySuccessArgs({
    required this.applicationId,
    required this.jobPostId,
    required this.jobTitle,
    required this.result,
  });

  final String applicationId;
  final String jobPostId;
  final String jobTitle;
  final ApplyCvResult result;

  static ApplySuccessArgs from(dynamic arguments) {
    if (arguments is ApplySuccessArgs) return arguments;
    throw ArgumentError('ApplySuccessArgs required');
  }
}
