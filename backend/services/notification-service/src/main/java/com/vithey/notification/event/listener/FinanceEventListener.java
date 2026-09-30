package com.vithey.notification.event.listener;

import com.vithey.notification.config.RabbitMqConfig;
import com.vithey.notification.event.payload.PaymentDueEvent;
import com.vithey.notification.event.payload.PaymentOverdueEvent;
import com.vithey.notification.service.EventNotificationService;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

@Component
public class FinanceEventListener {

  private final EventNotificationService eventNotificationService;

  public FinanceEventListener(EventNotificationService eventNotificationService) {
    this.eventNotificationService = eventNotificationService;
  }

  @RabbitListener(queues = RabbitMqConfig.PAYMENT_DUE_QUEUE)
  public void onPaymentDue(PaymentDueEvent event) {
    eventNotificationService.onPaymentDue(event);
  }

  @RabbitListener(queues = RabbitMqConfig.PAYMENT_OVERDUE_QUEUE)
  public void onPaymentOverdue(PaymentOverdueEvent event) {
    eventNotificationService.onPaymentOverdue(event);
  }
}
