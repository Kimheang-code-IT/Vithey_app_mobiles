package com.vithey.chat.event.publisher;

import com.vithey.chat.event.payload.ChatMessageSentEvent;
import com.vithey.chat.event.payload.ChatRequestReceivedEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.AmqpException;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class ChatEventPublisher {

  private static final Logger log = LoggerFactory.getLogger(ChatEventPublisher.class);

  private final RabbitTemplate rabbitTemplate;
  private final String exchangeName;

  public ChatEventPublisher(
      RabbitTemplate rabbitTemplate,
      @Value("${vithey.events.exchange}") String exchangeName
  ) {
    this.rabbitTemplate = rabbitTemplate;
    this.exchangeName = exchangeName;
  }

  public void publishRequestReceived(ChatRequestReceivedEvent event) {
    publish("chat.request.received", event);
  }

  public void publishMessageSent(ChatMessageSentEvent event) {
    publish("chat.message.sent", event);
  }

  private void publish(String routingKey, Object event) {
    try {
      rabbitTemplate.convertAndSend(exchangeName, routingKey, event);
    } catch (AmqpException | IllegalArgumentException exception) {
      log.warn("Unable to publish {} event", routingKey, exception);
    }
  }
}
