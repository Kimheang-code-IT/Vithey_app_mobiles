package com.vithey.auth.event.publisher;

import com.vithey.auth.event.payload.UserRegisteredEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class UserRegisteredEventPublisher {

  private static final Logger log = LoggerFactory.getLogger(UserRegisteredEventPublisher.class);
  private static final String ROUTING_KEY = "user.registered";

  private final RabbitTemplate rabbitTemplate;
  private final String exchangeName;

  public UserRegisteredEventPublisher(
      RabbitTemplate rabbitTemplate,
      @Value("${vithey.events.exchange}") String exchangeName
  ) {
    this.rabbitTemplate = rabbitTemplate;
    this.exchangeName = exchangeName;
  }

  public void publish(UserRegisteredEvent event) {
    try {
      rabbitTemplate.convertAndSend(exchangeName, ROUTING_KEY, event);
    } catch (RuntimeException exception) {
      log.warn("Unable to publish {} event for user {}", ROUTING_KEY, event.userId(), exception);
    }
  }
}
