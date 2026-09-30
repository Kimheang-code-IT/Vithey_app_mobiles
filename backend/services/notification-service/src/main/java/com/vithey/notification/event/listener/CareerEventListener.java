package com.vithey.notification.event.listener;

import com.vithey.notification.config.RabbitMqConfig;
import com.vithey.notification.event.payload.JobApplicationStatusChangedEvent;
import com.vithey.notification.event.payload.JobApplicationSubmittedEvent;
import com.vithey.notification.service.EventNotificationService;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

@Component
public class CareerEventListener {

  private final EventNotificationService eventNotificationService;

  public CareerEventListener(EventNotificationService eventNotificationService) {
    this.eventNotificationService = eventNotificationService;
  }

  @RabbitListener(queues = RabbitMqConfig.JOB_SUBMITTED_QUEUE)
  public void onJobSubmitted(JobApplicationSubmittedEvent event) {
    eventNotificationService.onJobApplicationSubmitted(event);
  }

  @RabbitListener(queues = RabbitMqConfig.JOB_STATUS_QUEUE)
  public void onJobStatusChanged(JobApplicationStatusChangedEvent event) {
    eventNotificationService.onJobApplicationStatusChanged(event);
  }
}
