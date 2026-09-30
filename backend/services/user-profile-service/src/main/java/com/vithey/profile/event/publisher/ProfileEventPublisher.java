package com.vithey.profile.event.publisher;

import com.vithey.profile.event.payload.ProfileUpdatedEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.AmqpException;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class ProfileEventPublisher {

  private static final Logger log = LoggerFactory.getLogger(ProfileEventPublisher.class);

  private final RabbitTemplate rabbitTemplate;
  private final String exchangeName;

  public ProfileEventPublisher(
      RabbitTemplate rabbitTemplate,
      @Value("${vithey.events.exchange}") String exchangeName
  ) {
    this.rabbitTemplate = rabbitTemplate;
    this.exchangeName = exchangeName;
  }

  public void publishUpdated(ProfileUpdatedEvent event) {
    try {
      rabbitTemplate.convertAndSend(exchangeName, "profile.updated", event);
    } catch (AmqpException exception) {
      log.warn("Unable to publish profile.updated event", exception);
    }
  }
}
