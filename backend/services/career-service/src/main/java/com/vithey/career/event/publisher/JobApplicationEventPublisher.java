package com.vithey.career.event.publisher;

import com.vithey.career.event.payload.JobApplicationStatusChangedEvent;
import com.vithey.career.event.payload.JobApplicationSubmittedEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.AmqpException;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class JobApplicationEventPublisher {

  private static final Logger log = LoggerFactory.getLogger(JobApplicationEventPublisher.class);

  private final RabbitTemplate rabbitTemplate;
  private final String exchangeName;

  public JobApplicationEventPublisher(
      RabbitTemplate rabbitTemplate,
      @Value("${vithey.events.exchange}") String exchangeName
  ) {
    this.rabbitTemplate = rabbitTemplate;
    this.exchangeName = exchangeName;
  }

  public void publishSubmitted(JobApplicationSubmittedEvent event) {
    publish("job.application.submitted", event);
  }

  public void publishStatusChanged(JobApplicationStatusChangedEvent event) {
    publish("job.application.status_changed", event);
  }

  private void publish(String routingKey, Object event) {
    try {
      rabbitTemplate.convertAndSend(exchangeName, routingKey, event);
    } catch (AmqpException exception) {
      log.warn("Unable to publish {} event", routingKey, exception);
    }
  }
}
