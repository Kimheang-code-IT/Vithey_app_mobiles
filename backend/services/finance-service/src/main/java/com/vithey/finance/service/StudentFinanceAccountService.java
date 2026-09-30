package com.vithey.finance.service;

import com.vithey.finance.entity.Fee;
import com.vithey.finance.entity.Payment;
import com.vithey.finance.entity.PaymentStatus;
import com.vithey.finance.entity.StudentFinanceAccount;
import com.vithey.finance.event.payload.StudentVerifiedEvent;
import com.vithey.finance.repository.FeeRepository;
import com.vithey.finance.repository.PaymentRepository;
import com.vithey.finance.repository.StudentFinanceAccountRepository;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class StudentFinanceAccountService {

  private static final UUID TUITION_SEMESTER_1 = UUID.fromString("22222222-2222-2222-2222-222222222201");
  private static final UUID TUITION_SEMESTER_2 = UUID.fromString("22222222-2222-2222-2222-222222222202");
  private static final UUID LIBRARY_MEMBERSHIP = UUID.fromString("22222222-2222-2222-2222-222222222203");

  private final StudentFinanceAccountRepository studentFinanceAccountRepository;
  private final PaymentRepository paymentRepository;
  private final FeeRepository feeRepository;

  public StudentFinanceAccountService(
      StudentFinanceAccountRepository studentFinanceAccountRepository,
      PaymentRepository paymentRepository,
      FeeRepository feeRepository
  ) {
    this.studentFinanceAccountRepository = studentFinanceAccountRepository;
    this.paymentRepository = paymentRepository;
    this.feeRepository = feeRepository;
  }

  @Transactional
  public void createFromVerification(StudentVerifiedEvent event) {
    if (studentFinanceAccountRepository.existsById(event.userId())) {
      return;
    }

    OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
    StudentFinanceAccount account = new StudentFinanceAccount();
    account.setUserId(event.userId());
    account.setStudentId(event.studentId());
    account.setLinkedAt(event.occurredAt() != null ? event.occurredAt() : now);
    studentFinanceAccountRepository.save(account);

    if (!paymentRepository.existsByUserId(event.userId())) {
      seedDemoPayments(event.userId(), now);
    }
  }

  @Transactional(readOnly = true)
  public void requireAccount(UUID userId) {
    if (!studentFinanceAccountRepository.existsById(userId)) {
      throw new com.vithey.finance.exception.ApiException(
          com.vithey.finance.exception.ErrorCode.FORBIDDEN,
          "Finance access is not enabled for this account"
      );
    }
  }

  private void seedDemoPayments(UUID userId, OffsetDateTime now) {
    LocalDate today = LocalDate.now(ZoneOffset.UTC);
    List<Fee> fees = feeRepository.findAllById(List.of(TUITION_SEMESTER_1, TUITION_SEMESTER_2, LIBRARY_MEMBERSHIP));
    if (fees.isEmpty()) {
      return;
    }

    createPayment(userId, findFee(fees, TUITION_SEMESTER_1), today.minusDays(3), PaymentStatus.UNPAID, now);
    createPayment(userId, findFee(fees, TUITION_SEMESTER_2), today.plusDays(5), PaymentStatus.UNPAID, now);
    createPayment(userId, findFee(fees, LIBRARY_MEMBERSHIP), today.minusMonths(1), PaymentStatus.PAID, now);
  }

  private Fee findFee(List<Fee> fees, UUID feeId) {
    return fees.stream()
        .filter(fee -> fee.getId().equals(feeId))
        .findFirst()
        .orElseThrow();
  }

  private void createPayment(
      UUID userId,
      Fee fee,
      LocalDate dueDate,
      PaymentStatus status,
      OffsetDateTime now
  ) {
    Payment payment = new Payment();
    payment.setId(UUID.randomUUID());
    payment.setUserId(userId);
    payment.setFeeId(fee.getId());
    payment.setAmount(fee.getAmount());
    payment.setCurrency(fee.getCurrency());
    payment.setStatus(status);
    payment.setDueDate(dueDate);
    payment.setPaidAt(status == PaymentStatus.PAID ? now : null);
    payment.setCreatedAt(now);
    payment.setUpdatedAt(now);
    paymentRepository.save(payment);
  }
}
