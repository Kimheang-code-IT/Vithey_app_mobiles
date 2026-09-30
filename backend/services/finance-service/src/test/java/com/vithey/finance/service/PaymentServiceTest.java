package com.vithey.finance.service;

import static org.junit.jupiter.api.Assertions.assertEquals;

import com.vithey.finance.entity.Payment;
import com.vithey.finance.entity.PaymentStatus;
import com.vithey.finance.mapper.FinanceMapper;
import com.vithey.finance.repository.FeeRepository;
import com.vithey.finance.repository.PaymentRepository;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class PaymentServiceTest {

  @Mock
  private PaymentRepository paymentRepository;

  @Mock
  private FeeRepository feeRepository;

  @Mock
  private FinanceMapper financeMapper;

  @Mock
  private StudentFinanceAccountService studentFinanceAccountService;

  private PaymentService paymentService;

  @BeforeEach
  void setUp() {
    paymentService = new PaymentService(
        paymentRepository,
        feeRepository,
        financeMapper,
        studentFinanceAccountService,
        7
    );
  }

  @Test
  void effectiveStatus_marksUnpaidPastDueAsOverdue() {
    Payment payment = new Payment();
    payment.setId(UUID.randomUUID());
    payment.setStatus(PaymentStatus.UNPAID);
    payment.setDueDate(LocalDate.now(ZoneOffset.UTC).minusDays(1));

    assertEquals(PaymentStatus.OVERDUE, paymentService.effectiveStatus(payment));
  }

  @Test
  void effectiveStatus_keepsPaidStatus() {
    Payment payment = new Payment();
    payment.setStatus(PaymentStatus.PAID);
    payment.setDueDate(LocalDate.now(ZoneOffset.UTC).minusDays(10));

    assertEquals(PaymentStatus.PAID, paymentService.effectiveStatus(payment));
  }
}
