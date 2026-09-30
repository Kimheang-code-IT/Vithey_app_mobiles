package com.vithey.finance.event.listener;

import com.vithey.finance.config.RabbitMqConfig;
import com.vithey.finance.event.payload.StudentVerifiedEvent;
import com.vithey.finance.service.StudentFinanceAccountService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

@Component
public class StudentVerifiedEventListener {

  private static final Logger log = LoggerFactory.getLogger(StudentVerifiedEventListener.class);

  private final StudentFinanceAccountService studentFinanceAccountService;

  public StudentVerifiedEventListener(StudentFinanceAccountService studentFinanceAccountService) {
    this.studentFinanceAccountService = studentFinanceAccountService;
  }

  @RabbitListener(queues = RabbitMqConfig.STUDENT_VERIFIED_QUEUE)
  public void handleStudentVerified(StudentVerifiedEvent event) {
    log.info("Linking finance account for verified student {}", event.userId());
    studentFinanceAccountService.createFromVerification(event);
  }
}
