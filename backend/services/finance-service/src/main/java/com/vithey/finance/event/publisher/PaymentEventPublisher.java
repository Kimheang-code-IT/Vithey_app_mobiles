package com.vithey.finance.event.publisher;

import com.vithey.finance.event.payload.PaymentDueEvent;
import com.vithey.finance.event.payload.PaymentOverdueEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.AmqpException;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class PaymentEventPublisher {

  private static final Logger log = LoggerFactory.getLogger(PaymentEventPublisher.class);

  private final RabbitTemplate rabbitTemplate;
  private final String exchangeName;

  public PaymentEventPublisher(
      RabbitTemplate rabbitTemplate,
      @Value("${vithey.events.exchange}") String exchangeName
  ) {
    this.rabbitTemplate = rabbitTemplate;
    this.exchangeName = exchangeName;
  }

  public void publishDue(PaymentDueEvent event) {
    publish("payment.due", event);
  }

  public void publishOverdue(PaymentOverdueEvent event) {
    publish("payment.overdue", event);
  }

  private void publish(String routingKey, Object event) {
    try {
      rabbitTemplate.convertAndSend(exchangeName, routingKey, event);
    } catch (AmqpException exception) {
      log.warn("Unable to publish {} event", routingKey, exception);
    }
  }
}
