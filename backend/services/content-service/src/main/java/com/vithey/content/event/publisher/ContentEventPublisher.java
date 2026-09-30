package com.vithey.content.event.publisher;

import com.vithey.content.event.payload.CommentAddedEvent;
import com.vithey.content.event.payload.FollowCreatedEvent;
import com.vithey.content.event.payload.MentionCreatedEvent;
import com.vithey.content.event.payload.PostCreatedEvent;
import com.vithey.content.event.payload.ReactionAddedEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.AmqpException;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class ContentEventPublisher {

  private static final Logger log = LoggerFactory.getLogger(ContentEventPublisher.class);

  private final RabbitTemplate rabbitTemplate;
  private final String exchangeName;

  public ContentEventPublisher(
      RabbitTemplate rabbitTemplate,
      @Value("${vithey.events.exchange}") String exchangeName
  ) {
    this.rabbitTemplate = rabbitTemplate;
    this.exchangeName = exchangeName;
  }

  public void publishPostCreated(PostCreatedEvent event) {
    publish("post.created", event);
  }

  public void publishCommentAdded(CommentAddedEvent event) {
    publish("comment.added", event);
  }

  public void publishReactionAdded(ReactionAddedEvent event) {
    publish("reaction.added", event);
  }

  public void publishFollowCreated(FollowCreatedEvent event) {
    publish("follow.created", event);
  }

  public void publishMentionCreated(MentionCreatedEvent event) {
    publish("mention.created", event);
  }

  private void publish(String routingKey, Object event) {
    try {
      rabbitTemplate.convertAndSend(exchangeName, routingKey, event);
    } catch (AmqpException | IllegalArgumentException exception) {
      log.warn("Unable to publish {} event", routingKey, exception);
    }
  }
}
