package com.vithey.auth.event.publisher;

import com.vithey.auth.event.payload.StudentVerifiedEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.AmqpException;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class StudentVerifiedEventPublisher {

  private static final Logger log = LoggerFactory.getLogger(StudentVerifiedEventPublisher.class);
  private static final String ROUTING_KEY = "student.verified";

  private final RabbitTemplate rabbitTemplate;
  private final String exchangeName;

  public StudentVerifiedEventPublisher(
      RabbitTemplate rabbitTemplate,
      @Value("${vithey.events.exchange}") String exchangeName
  ) {
    this.rabbitTemplate = rabbitTemplate;
    this.exchangeName = exchangeName;
  }

  public void publish(StudentVerifiedEvent event) {
    try {
      rabbitTemplate.convertAndSend(exchangeName, ROUTING_KEY, event);
    } catch (AmqpException exception) {
      log.warn("Unable to publish {} event for user {}", ROUTING_KEY, event.userId(), exception);
    }
  }
}
