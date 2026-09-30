package com.vithey.notification.event.listener;

import com.vithey.notification.config.RabbitMqConfig;
import com.vithey.notification.event.payload.ChatMessageSentEvent;
import com.vithey.notification.event.payload.ChatRequestReceivedEvent;
import com.vithey.notification.service.EventNotificationService;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

@Component
public class ChatEventListener {

  private final EventNotificationService eventNotificationService;

  public ChatEventListener(EventNotificationService eventNotificationService) {
    this.eventNotificationService = eventNotificationService;
  }

  @RabbitListener(queues = RabbitMqConfig.CHAT_REQUEST_QUEUE)
  public void onChatRequest(ChatRequestReceivedEvent event) {
    eventNotificationService.onChatRequestReceived(event);
  }

  @RabbitListener(queues = RabbitMqConfig.CHAT_MESSAGE_QUEUE)
  public void onChatMessage(ChatMessageSentEvent event) {
    eventNotificationService.onChatMessageSent(event);
  }
}
