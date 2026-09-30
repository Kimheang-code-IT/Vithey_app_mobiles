package com.vithey.notification.service;

import com.vithey.notification.client.ContentServiceClient;
import com.vithey.notification.entity.NotificationType;
import com.vithey.notification.event.payload.ChatMessageSentEvent;
import com.vithey.notification.event.payload.ChatRequestReceivedEvent;
import com.vithey.notification.event.payload.CommentAddedEvent;
import com.vithey.notification.event.payload.FollowCreatedEvent;
import com.vithey.notification.event.payload.JobApplicationStatusChangedEvent;
import com.vithey.notification.event.payload.JobApplicationSubmittedEvent;
import com.vithey.notification.event.payload.MentionCreatedEvent;
import com.vithey.notification.event.payload.PaymentDueEvent;
import com.vithey.notification.event.payload.PaymentOverdueEvent;
import com.vithey.notification.event.payload.ReactionAddedEvent;
import feign.FeignException;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
public class EventNotificationService {

  private final NotificationService notificationService;
  private final ContentServiceClient contentServiceClient;

  public EventNotificationService(
      NotificationService notificationService,
      ContentServiceClient contentServiceClient
  ) {
    this.notificationService = notificationService;
    this.contentServiceClient = contentServiceClient;
  }

  public void onCommentAdded(CommentAddedEvent event) {
    UUID postAuthorId = resolvePostAuthor(event.postId());
    if (postAuthorId == null || postAuthorId.equals(event.authorId())) {
      return;
    }
    notificationService.createAndPush(
        postAuthorId,
        NotificationType.COMMENT,
        "comment.added",
        "New comment",
        "Someone commented on your post.",
        event.authorId(),
        null,
        null,
        postDestination(event.postId(), event.commentId()),
        "comment.added:" + event.commentId()
    );
  }

  public void onReactionAdded(ReactionAddedEvent event) {
    UUID postAuthorId = resolvePostAuthor(event.postId());
    if (postAuthorId == null || postAuthorId.equals(event.userId())) {
      return;
    }
    notificationService.createAndPush(
        postAuthorId,
        NotificationType.LIKE,
        "reaction.added",
        "New like",
        "Someone liked your post.",
        event.userId(),
        null,
        null,
        postDestination(event.postId(), null),
        "reaction.added:" + event.reactionId()
    );
  }

  public void onFollowCreated(FollowCreatedEvent event) {
    notificationService.createAndPush(
        event.followingId(),
        NotificationType.FOLLOW,
        "follow.created",
        "New follower",
        "You have a new follower.",
        event.followerId(),
        null,
        null,
        destination("USER", event.followerId(), "user_id", event.followerId()),
        "follow.created:" + event.followId()
    );
  }

  public void onMentionCreated(MentionCreatedEvent event) {
    notificationService.createAndPush(
        event.mentionedUserId(),
        NotificationType.MENTION,
        "mention.created",
        "You were mentioned",
        "Someone mentioned you in a comment.",
        null,
        null,
        null,
        postDestination(event.postId(), event.commentId()),
        "mention.created:" + event.mentionId()
    );
  }

  public void onChatRequestReceived(ChatRequestReceivedEvent event) {
    notificationService.createAndPush(
        event.recipientId(),
        NotificationType.CHAT_REQUEST,
        "chat.request.received",
        "New message request",
        "Someone sent you a message request.",
        event.requesterId(),
        null,
        null,
        conversationDestination(event.conversationId()),
        "chat.request.received:" + event.conversationId()
    );
  }

  public void onChatMessageSent(ChatMessageSentEvent event) {
    if (event.recipientId() == null || event.recipientId().equals(event.senderId())) {
      return;
    }
    // Privacy: never include the chat message body in the notification or push.
    notificationService.createAndPush(
        event.recipientId(),
        NotificationType.CHAT,
        "chat.message.sent",
        "New message",
        "Someone sent you a message.",
        event.senderId(),
        null,
        null,
        conversationDestination(event.conversationId()),
        "chat.message.sent:" + event.messageId()
    );
  }

  public void onPaymentDue(PaymentDueEvent event) {
    notificationService.createAndPush(
        event.userId(),
        NotificationType.PAYMENT,
        "payment.due",
        "Payment due soon",
        "Payment of " + event.amount() + " " + event.currency() + " is due on " + event.dueDate() + ".",
        null,
        null,
        null,
        paymentDestination(event.paymentId()),
        "payment.due:" + event.paymentId()
    );
  }

  public void onPaymentOverdue(PaymentOverdueEvent event) {
    notificationService.createAndPush(
        event.userId(),
        NotificationType.PAYMENT,
        "payment.overdue",
        "Payment overdue",
        "Your payment of " + event.amount() + " " + event.currency() + " is overdue.",
        null,
        null,
        null,
        paymentDestination(event.paymentId()),
        "payment.overdue:" + event.paymentId()
    );
  }

  public void onJobApplicationSubmitted(JobApplicationSubmittedEvent event) {
    UUID posterId = resolvePostAuthor(event.jobPostId());
    if (posterId == null || posterId.equals(event.applicantId())) {
      return;
    }
    // Privacy: never include CV file URLs in notification bodies.
    notificationService.createAndPush(
        posterId,
        NotificationType.JOB,
        "job.application.submitted",
        "New job application",
        "Someone applied to your job post.",
        event.applicantId(),
        null,
        null,
        jobApplicationDestination(event.applicationId(), event.jobPostId()),
        "job.application.submitted:" + event.applicationId()
    );
  }

  public void onJobApplicationStatusChanged(JobApplicationStatusChangedEvent event) {
    notificationService.createAndPush(
        event.applicantId(),
        NotificationType.JOB,
        "job.application.status_changed",
        "Application status updated",
        "Your application status is now " + event.newStatus() + ".",
        event.updatedBy(),
        null,
        null,
        jobApplicationDestination(event.applicationId(), event.jobPostId()),
        "job.application.status_changed:" + event.applicationId() + ":" + event.newStatus()
    );
  }

  private Map<String, Object> postDestination(UUID postId, UUID commentId) {
    Map<String, Object> destination = destination("POST", postId, "post_id", postId);
    if (commentId != null) {
      destination.put("comment_id", commentId);
    }
    return destination;
  }

  private Map<String, Object> conversationDestination(UUID conversationId) {
    return destination("CONVERSATION", conversationId, "conversation_id", conversationId);
  }

  private Map<String, Object> paymentDestination(UUID paymentId) {
    return destination("PAYMENT", paymentId, "payment_id", paymentId);
  }

  private Map<String, Object> jobApplicationDestination(UUID applicationId, UUID jobPostId) {
    Map<String, Object> destination =
        destination("JOB_APPLICATION", applicationId, "application_id", applicationId);
    if (jobPostId != null) {
      destination.put("job_post_id", jobPostId);
    }
    return destination;
  }

  private Map<String, Object> destination(String referenceType, UUID referenceId, String idKey, UUID idValue) {
    Map<String, Object> destination = new HashMap<>();
    destination.put("reference_type", referenceType);
    if (referenceId != null) {
      destination.put("reference_id", referenceId.toString());
    }
    if (idValue != null) {
      destination.put(idKey, idValue.toString());
    }
    return destination;
  }

  private UUID resolvePostAuthor(UUID postId) {
    try {
      var response = contentServiceClient.getPost(postId);
      if (response == null || response.data() == null || response.data().author() == null) {
        return null;
      }
      return response.data().author().userId();
    } catch (FeignException exception) {
      return null;
    }
  }
}
