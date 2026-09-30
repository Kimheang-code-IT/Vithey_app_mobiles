import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/data/models/app_notification_model.dart';
import 'package:aub_connect_app/data/models/chat_args.dart';
import 'package:aub_connect_app/data/models/profile_args.dart';
import 'package:aub_connect_app/modules/profile/profile_navigation.dart';
import 'package:aub_connect_app/data/services/notification_service.dart';
import 'package:aub_connect_app/modules/jobs/models/application_status_args.dart';
import 'package:aub_connect_app/modules/home/notification/utils/notification_display_text.dart';

/// Deep-link routing for in-app notifications and FCM push payloads.
class NotificationRouter {
  static void routeToNotification(AppNotification item) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _routeToDestination(item));
  }

  static void routeFromPushData(Map<String, dynamic> data) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notification = _parsePushData(data);
      if (notification != null) {
        _routeToDestination(notification);
      }
    });
  }

  static AppNotification? _parsePushData(Map<String, dynamic> data) {
    final id = data['notification_id']?.toString() ?? data['id']?.toString();
    if (id == null || id.isEmpty) return null;

    return NotificationService.fromJson({
      'id': id,
      'type': data['type'],
      'event': data['event'],
      'title': data['title'] ?? '',
      'body': data['body'] ?? '',
      'is_read': false,
      'created_at': DateTime.now().toIso8601String(),
      'actor': {
        if (data['actor_id'] != null) 'id': data['actor_id'],
        if (data['actor_name'] != null) 'full_name': data['actor_name'],
      },
      'destination': {
        'reference_type': data['reference_type'],
        'reference_id': data['reference_id'],
        'post_id': data['post_id'],
        'comment_id': data['comment_id'],
        'user_id': data['user_id'],
        'conversation_id': data['conversation_id'],
        'job_post_id': data['job_post_id'],
        'application_id': data['application_id'],
        'payment_id': data['payment_id'],
        'ai_thread_id': data['ai_thread_id'],
      },
      'dedupe_key': data['dedupe_key'],
    });
  }

  static void _routeToDestination(AppNotification item) {
    final dest = item.destination;
    switch (item.type) {
      case NotificationType.postLike:
      case NotificationType.postComment:
      case NotificationType.postMention:
      case NotificationType.postShare:
        final postId = dest.postId ?? dest.referenceId;
        if (postId != null && postId.isNotEmpty) {
          Get.toNamed(AppRoutes.postDetail, arguments: postId);
        }
        break;
      case NotificationType.newFollower:
        final userId = dest.userId ?? dest.referenceId;
        if (userId != null && userId.isNotEmpty) {
          openUserProfile(userId);
        }
        break;
      case NotificationType.jobApplicationReceived:
        if (dest.jobPostId != null) {
          Get.toNamed(
            AppRoutes.jobApplicants,
            arguments: JobApplicantsArgs(jobPostId: dest.jobPostId!, jobTitle: 'Job'),
          );
        }
        break;
      case NotificationType.jobApplicationStatus:
        final applicationId = dest.applicationId ?? dest.referenceId;
        if (applicationId != null && applicationId.isNotEmpty) {
          Get.toNamed(
            AppRoutes.applicationStatus,
            arguments: ApplicationStatusArgs(
              applicationId: applicationId,
              jobPostId: dest.jobPostId,
            ),
          );
        }
        break;
      case NotificationType.chatRequest:
        Get.toNamed(AppRoutes.chat);
        break;
      case NotificationType.chatMessage:
        final conversationId = dest.conversationId ?? dest.referenceId;
        if (conversationId != null && conversationId.isNotEmpty) {
          Get.toNamed(
            AppRoutes.chatDetail,
            arguments: ChatDetailArgs(conversationId: conversationId),
          );
        }
        break;
      case NotificationType.paymentDue:
      case NotificationType.paymentOverdue:
        Get.toNamed(AppRoutes.finance);
        break;
      case NotificationType.aiAssistantResponse:
        Get.toNamed(AppRoutes.chatbot);
        break;
      case NotificationType.studentVerification:
        Get.toNamed(AppRoutes.verificationStatus);
        break;
      case NotificationType.system:
        final route = dest.routeName;
        if (route != null && route.isNotEmpty && route.startsWith('/')) {
          Get.toNamed(route);
        } else {
          Get.snackbar(AppStrings.appName, NotificationDisplayText.build(item));
        }
        break;
    }
  }
}
