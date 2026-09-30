package com.vithey.finance.scheduler;

import com.vithey.finance.entity.Payment;
import com.vithey.finance.entity.PaymentStatus;
import com.vithey.finance.event.payload.PaymentDueEvent;
import com.vithey.finance.event.payload.PaymentOverdueEvent;
import com.vithey.finance.event.publisher.PaymentEventPublisher;
import com.vithey.finance.repository.PaymentRepository;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
public class PaymentAlertScheduler {

  private static final Logger log = LoggerFactory.getLogger(PaymentAlertScheduler.class);

  private final PaymentRepository paymentRepository;
  private final PaymentEventPublisher paymentEventPublisher;
  private final int alertDueDays;

  public PaymentAlertScheduler(
      PaymentRepository paymentRepository,
      PaymentEventPublisher paymentEventPublisher,
      @Value("${vithey.finance.alert-due-days:7}") int alertDueDays
  ) {
    this.paymentRepository = paymentRepository;
    this.paymentEventPublisher = paymentEventPublisher;
    this.alertDueDays = alertDueDays;
  }

  @Scheduled(cron = "${vithey.finance.alert-cron:0 0 8 * * *}")
  @Transactional
  public void publishPaymentAlerts() {
    LocalDate today = LocalDate.now(ZoneOffset.UTC);
    LocalDate dueUntil = today.plusDays(alertDueDays);
    OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);

    List<Payment> overduePayments = paymentRepository.findOverdueCandidates(today);
    for (Payment payment : overduePayments) {
      if (payment.getStatus() != PaymentStatus.OVERDUE) {
        payment.setStatus(PaymentStatus.OVERDUE);
        payment.setUpdatedAt(now);
        paymentRepository.save(payment);
      }
      paymentEventPublisher.publishOverdue(new PaymentOverdueEvent(
          payment.getId(),
          payment.getUserId(),
          payment.getFeeId(),
          payment.getAmount(),
          payment.getCurrency(),
          payment.getDueDate()
      ));
    }

    List<Payment> dueSoonPayments = paymentRepository.findDueSoonCandidates(today, dueUntil);
    for (Payment payment : dueSoonPayments) {
      paymentEventPublisher.publishDue(new PaymentDueEvent(
          payment.getId(),
          payment.getUserId(),
          payment.getFeeId(),
          payment.getAmount(),
          payment.getCurrency(),
          payment.getDueDate()
      ));
    }

    log.info("Published {} overdue and {} due-soon payment events", overduePayments.size(), dueSoonPayments.size());
  }
}
