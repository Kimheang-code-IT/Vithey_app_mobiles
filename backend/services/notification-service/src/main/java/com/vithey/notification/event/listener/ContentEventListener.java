package com.vithey.notification.event.listener;

import com.vithey.notification.config.RabbitMqConfig;
import com.vithey.notification.event.payload.CommentAddedEvent;
import com.vithey.notification.event.payload.FollowCreatedEvent;
import com.vithey.notification.event.payload.MentionCreatedEvent;
import com.vithey.notification.event.payload.ReactionAddedEvent;
import com.vithey.notification.service.EventNotificationService;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

@Component
public class ContentEventListener {

  private final EventNotificationService eventNotificationService;

  public ContentEventListener(EventNotificationService eventNotificationService) {
    this.eventNotificationService = eventNotificationService;
  }

  @RabbitListener(queues = RabbitMqConfig.COMMENT_ADDED_QUEUE)
  public void onCommentAdded(CommentAddedEvent event) {
    eventNotificationService.onCommentAdded(event);
  }

  @RabbitListener(queues = RabbitMqConfig.REACTION_ADDED_QUEUE)
  public void onReactionAdded(ReactionAddedEvent event) {
    eventNotificationService.onReactionAdded(event);
  }

  @RabbitListener(queues = RabbitMqConfig.FOLLOW_CREATED_QUEUE)
  public void onFollowCreated(FollowCreatedEvent event) {
    eventNotificationService.onFollowCreated(event);
  }

  @RabbitListener(queues = RabbitMqConfig.MENTION_CREATED_QUEUE)
  public void onMentionCreated(MentionCreatedEvent event) {
    eventNotificationService.onMentionCreated(event);
  }
}
