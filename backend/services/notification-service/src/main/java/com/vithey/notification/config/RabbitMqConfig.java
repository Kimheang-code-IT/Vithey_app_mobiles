package com.vithey.notification.config;

import org.springframework.amqp.core.Binding;
import org.springframework.amqp.core.BindingBuilder;
import org.springframework.amqp.core.Queue;
import org.springframework.amqp.core.TopicExchange;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.amqp.support.converter.MessageConverter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RabbitMqConfig {

  public static final String COMMENT_ADDED_QUEUE = "notification.comment.added";
  public static final String REACTION_ADDED_QUEUE = "notification.reaction.added";
  public static final String FOLLOW_CREATED_QUEUE = "notification.follow.created";
  public static final String MENTION_CREATED_QUEUE = "notification.mention.created";
  public static final String CHAT_REQUEST_QUEUE = "notification.chat.request.received";
  public static final String CHAT_MESSAGE_QUEUE = "notification.chat.message.sent";
  public static final String PAYMENT_DUE_QUEUE = "notification.payment.due";
  public static final String PAYMENT_OVERDUE_QUEUE = "notification.payment.overdue";
  public static final String JOB_SUBMITTED_QUEUE = "notification.job.application.submitted";
  public static final String JOB_STATUS_QUEUE = "notification.job.application.status_changed";

  @Bean
  TopicExchange vitheyEventsExchange(@Value("${vithey.events.exchange}") String exchangeName) {
    return new TopicExchange(exchangeName, true, false);
  }

  @Bean
  MessageConverter jsonMessageConverter() {
    return new Jackson2JsonMessageConverter();
  }

  @Bean Queue commentAddedQueue() { return new Queue(COMMENT_ADDED_QUEUE, true); }
  @Bean Queue reactionAddedQueue() { return new Queue(REACTION_ADDED_QUEUE, true); }
  @Bean Queue followCreatedQueue() { return new Queue(FOLLOW_CREATED_QUEUE, true); }
  @Bean Queue mentionCreatedQueue() { return new Queue(MENTION_CREATED_QUEUE, true); }
  @Bean Queue chatRequestQueue() { return new Queue(CHAT_REQUEST_QUEUE, true); }
  @Bean Queue chatMessageQueue() { return new Queue(CHAT_MESSAGE_QUEUE, true); }
  @Bean Queue paymentDueQueue() { return new Queue(PAYMENT_DUE_QUEUE, true); }
  @Bean Queue paymentOverdueQueue() { return new Queue(PAYMENT_OVERDUE_QUEUE, true); }
  @Bean Queue jobSubmittedQueue() { return new Queue(JOB_SUBMITTED_QUEUE, true); }
  @Bean Queue jobStatusQueue() { return new Queue(JOB_STATUS_QUEUE, true); }

  @Bean Binding commentAddedBinding(Queue commentAddedQueue, TopicExchange vitheyEventsExchange) {
    return BindingBuilder.bind(commentAddedQueue).to(vitheyEventsExchange).with("comment.added");
  }

  @Bean Binding reactionAddedBinding(Queue reactionAddedQueue, TopicExchange vitheyEventsExchange) {
    return BindingBuilder.bind(reactionAddedQueue).to(vitheyEventsExchange).with("reaction.added");
  }

  @Bean Binding followCreatedBinding(Queue followCreatedQueue, TopicExchange vitheyEventsExchange) {
    return BindingBuilder.bind(followCreatedQueue).to(vitheyEventsExchange).with("follow.created");
  }

  @Bean Binding mentionCreatedBinding(Queue mentionCreatedQueue, TopicExchange vitheyEventsExchange) {
    return BindingBuilder.bind(mentionCreatedQueue).to(vitheyEventsExchange).with("mention.created");
  }

  @Bean Binding chatRequestBinding(Queue chatRequestQueue, TopicExchange vitheyEventsExchange) {
    return BindingBuilder.bind(chatRequestQueue).to(vitheyEventsExchange).with("chat.request.received");
  }

  @Bean Binding chatMessageBinding(Queue chatMessageQueue, TopicExchange vitheyEventsExchange) {
    return BindingBuilder.bind(chatMessageQueue).to(vitheyEventsExchange).with("chat.message.sent");
  }

  @Bean Binding paymentDueBinding(Queue paymentDueQueue, TopicExchange vitheyEventsExchange) {
    return BindingBuilder.bind(paymentDueQueue).to(vitheyEventsExchange).with("payment.due");
  }

  @Bean Binding paymentOverdueBinding(Queue paymentOverdueQueue, TopicExchange vitheyEventsExchange) {
    return BindingBuilder.bind(paymentOverdueQueue).to(vitheyEventsExchange).with("payment.overdue");
  }

  @Bean Binding jobSubmittedBinding(Queue jobSubmittedQueue, TopicExchange vitheyEventsExchange) {
    return BindingBuilder.bind(jobSubmittedQueue).to(vitheyEventsExchange).with("job.application.submitted");
  }

  @Bean Binding jobStatusBinding(Queue jobStatusQueue, TopicExchange vitheyEventsExchange) {
    return BindingBuilder.bind(jobStatusQueue).to(vitheyEventsExchange).with("job.application.status_changed");
  }
}
