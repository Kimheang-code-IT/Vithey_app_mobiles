class ApplicationStatusArgs {
  const ApplicationStatusArgs({
    required this.applicationId,
    this.jobPostId,
  });

  final String applicationId;
  final String? jobPostId;

  static ApplicationStatusArgs from(dynamic arguments) {
    if (arguments is ApplicationStatusArgs) return arguments;
    if (arguments is String && arguments.isNotEmpty) {
      return ApplicationStatusArgs(applicationId: arguments);
    }
    throw ArgumentError('ApplicationStatusArgs requires applicationId');
  }
}
