enum NotificationType {
  postLike,
  postComment,
  postMention,
  postShare,
  newFollower,
  jobApplicationReceived,
  jobApplicationStatus,
  chatRequest,
  chatMessage,
  paymentDue,
  paymentOverdue,
  studentVerification,
  aiAssistantResponse,
  system,
}

enum NotificationFilter { all, read, unread }

class NotificationActor {
  const NotificationActor({
    required this.id,
    required this.fullName,
    this.avatarUrl,
  });

  final String id;
  final String fullName;
  final String? avatarUrl;
}

class NotificationDestination {
  const NotificationDestination({
    this.referenceType,
    this.referenceId,
    this.postId,
    this.commentId,
    this.userId,
    this.conversationId,
    this.jobPostId,
    this.applicationId,
    this.paymentId,
    this.aiThreadId,
    this.routeName,
  });

  final String? referenceType;
  final String? referenceId;
  final String? postId;
  final String? commentId;
  final String? userId;
  final String? conversationId;
  final String? jobPostId;
  final String? applicationId;
  final String? paymentId;
  final String? aiThreadId;
  final String? routeName;
}

class AppNotification {
  AppNotification({
    required this.id,
    required this.type,
    this.event,
    required this.title,
    required this.body,
    this.actor,
    required this.destination,
    this.isRead = false,
    this.dedupeKey,
    required this.createdAt,
  });

  final String id;
  final NotificationType type;
  final String? event;
  final String title;
  final String body;
  final NotificationActor? actor;
  final NotificationDestination destination;
  final bool isRead;
  final String? dedupeKey;
  final DateTime createdAt;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      event: event,
      title: title,
      body: body,
      actor: actor,
      destination: destination,
      isRead: isRead ?? this.isRead,
      dedupeKey: dedupeKey,
      createdAt: createdAt,
    );
  }

  String get displayText => body.isNotEmpty ? body : title;
}
