package com.vithey.finance.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.atLeast;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.vithey.finance.config.PaymentProviderProperties;
import com.vithey.finance.dto.response.PaymentTransactionResponse;
import com.vithey.finance.entity.CurrencyCode;
import com.vithey.finance.entity.Payment;
import com.vithey.finance.entity.PaymentStatus;
import com.vithey.finance.entity.PaymentTransaction;
import com.vithey.finance.entity.PaymentTransactionStatus;
import com.vithey.finance.exception.ApiException;
import com.vithey.finance.exception.ErrorCode;
import com.vithey.finance.payment.PaymentProvider;
import com.vithey.finance.payment.ProviderChargeResult;
import com.vithey.finance.payment.ProviderException;
import com.vithey.finance.payment.ProviderPaymentStatus;
import com.vithey.finance.repository.PaymentRepository;
import com.vithey.finance.repository.PaymentTransactionRepository;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class PaymentProcessingServiceTest {

  @Mock
  private PaymentRepository paymentRepository;

  @Mock
  private PaymentTransactionRepository transactionRepository;

  @Mock
  private StudentFinanceAccountService studentFinanceAccountService;

  @Mock
  private PaymentProvider paymentProvider;

  private PaymentProcessingService service;

  private final UUID userId = UUID.randomUUID();
  private final UUID paymentId = UUID.randomUUID();

  @BeforeEach
  void setUp() {
    service = new PaymentProcessingService(
        paymentRepository,
        transactionRepository,
        studentFinanceAccountService,
        paymentProvider,
        new PaymentProviderProperties()
    );
    lenient().when(transactionRepository.save(any(PaymentTransaction.class)))
        .thenAnswer(invocation -> invocation.getArgument(0));
  }

  @Test
  void successMarksInvoicePaidAndTransactionSuccess() {
    Payment payment = unpaidPayment();
    when(paymentRepository.findById(paymentId)).thenReturn(Optional.of(payment));
    when(paymentProvider.charge(any())).thenReturn(
        new ProviderChargeResult("pay_1", "demo_1", ProviderPaymentStatus.SUCCESS, null, null));

    PaymentTransactionResponse response =
        service.payInvoice(userId, paymentId, "SUCCESS", "DEMO_CARD", "key-1");

    assertEquals(PaymentTransactionStatus.SUCCESS, response.status());
    assertEquals(PaymentStatus.PAID, payment.getStatus());
    assertNotNull(payment.getPaidAt());
    verify(paymentRepository).save(payment);

    ArgumentCaptor<PaymentTransaction> captor = ArgumentCaptor.forClass(PaymentTransaction.class);
    verify(transactionRepository, atLeast(1)).save(captor.capture());
    assertEquals(PaymentTransactionStatus.SUCCESS, captor.getValue().getStatus());
  }

  @Test
  void declinedLeavesInvoiceUnpaid() {
    Payment payment = unpaidPayment();
    when(paymentRepository.findById(paymentId)).thenReturn(Optional.of(payment));
    when(paymentProvider.charge(any())).thenReturn(new ProviderChargeResult(
        "pay_2", "demo_2", ProviderPaymentStatus.FAILED, "PAYMENT_DECLINED", "Demo payment was declined."));

    PaymentTransactionResponse response =
        service.payInvoice(userId, paymentId, "DECLINED", null, null);

    assertEquals(PaymentTransactionStatus.FAILED, response.status());
    assertEquals("PAYMENT_DECLINED", response.failureCode());
    assertNotEquals(PaymentStatus.PAID, payment.getStatus());
    verify(paymentRepository, never()).save(any());
  }

  @Test
  void providerTimeoutFailsTransactionAndKeepsInvoiceUnpaid() {
    Payment payment = unpaidPayment();
    when(paymentRepository.findById(paymentId)).thenReturn(Optional.of(payment));
    when(paymentProvider.charge(any()))
        .thenThrow(new ProviderException("PROVIDER_TIMEOUT", "Payment provider timed out"));

    ApiException exception = assertThrows(
        ApiException.class,
        () -> service.payInvoice(userId, paymentId, "TIMEOUT", null, null)
    );

    assertEquals(ErrorCode.UPSTREAM_TIMEOUT, exception.getErrorCode());
    assertNotEquals(PaymentStatus.PAID, payment.getStatus());
    verify(paymentRepository, never()).save(any());

    ArgumentCaptor<PaymentTransaction> captor = ArgumentCaptor.forClass(PaymentTransaction.class);
    verify(transactionRepository, atLeast(1)).save(captor.capture());
    assertEquals(PaymentTransactionStatus.FAILED, captor.getValue().getStatus());
    assertEquals("PROVIDER_TIMEOUT", captor.getValue().getFailureCode());
  }

  @Test
  void processingKeepsInvoiceUnpaid() {
    Payment payment = unpaidPayment();
    when(paymentRepository.findById(paymentId)).thenReturn(Optional.of(payment));
    when(paymentProvider.charge(any())).thenReturn(
        new ProviderChargeResult("pay_3", "demo_3", ProviderPaymentStatus.PROCESSING, null, null));

    PaymentTransactionResponse response =
        service.payInvoice(userId, paymentId, "PROCESSING", null, null);

    assertEquals(PaymentTransactionStatus.PROCESSING, response.status());
    assertNull(response.completedAt());
    assertNotEquals(PaymentStatus.PAID, payment.getStatus());
    verify(paymentRepository, never()).save(any());
  }

  @Test
  void alreadyPaidInvoiceConflicts() {
    Payment payment = unpaidPayment();
    payment.setStatus(PaymentStatus.PAID);
    when(paymentRepository.findById(paymentId)).thenReturn(Optional.of(payment));

    ApiException exception = assertThrows(
        ApiException.class,
        () -> service.payInvoice(userId, paymentId, "SUCCESS", null, null)
    );

    assertEquals(ErrorCode.CONFLICT, exception.getErrorCode());
    verify(paymentProvider, never()).charge(any());
  }

  @Test
  void invoiceNotOwnedByUserIsNotFound() {
    Payment payment = unpaidPayment();
    payment.setUserId(UUID.randomUUID());
    when(paymentRepository.findById(paymentId)).thenReturn(Optional.of(payment));

    ApiException exception = assertThrows(
        ApiException.class,
        () -> service.payInvoice(userId, paymentId, "SUCCESS", null, null)
    );

    assertEquals(ErrorCode.NOT_FOUND, exception.getErrorCode());
    verify(paymentProvider, never()).charge(any());
  }

  @Test
  void idempotentReplayDoesNotCallProviderAgain() {
    when(paymentRepository.findById(paymentId)).thenReturn(Optional.of(unpaidPayment()));
    PaymentTransaction existing = new PaymentTransaction();
    existing.setId(UUID.randomUUID());
    existing.setPaymentId(paymentId);
    existing.setStatus(PaymentTransactionStatus.SUCCESS);
    when(transactionRepository.findByIdempotencyKey("key-replay")).thenReturn(Optional.of(existing));

    PaymentTransactionResponse response =
        service.payInvoice(userId, paymentId, "SUCCESS", null, "key-replay");

    assertEquals(PaymentTransactionStatus.SUCCESS, response.status());
    verify(paymentProvider, never()).charge(any());
    verify(paymentRepository, never()).save(any());
  }

  @Test
  void idempotencyKeyForAnotherInvoiceConflicts() {
    when(paymentRepository.findById(paymentId)).thenReturn(Optional.of(unpaidPayment()));
    PaymentTransaction existing = new PaymentTransaction();
    existing.setId(UUID.randomUUID());
    existing.setPaymentId(UUID.randomUUID());
    existing.setStatus(PaymentTransactionStatus.SUCCESS);
    when(transactionRepository.findByIdempotencyKey("key-x")).thenReturn(Optional.of(existing));

    ApiException exception = assertThrows(
        ApiException.class,
        () -> service.payInvoice(userId, paymentId, "SUCCESS", null, "key-x")
    );

    assertEquals(ErrorCode.CONFLICT, exception.getErrorCode());
    verify(paymentProvider, never()).charge(any());
  }

  private Payment unpaidPayment() {
    OffsetDateTime now = OffsetDateTime.now();
    Payment payment = new Payment();
    payment.setId(paymentId);
    payment.setUserId(userId);
    payment.setFeeId(UUID.randomUUID());
    payment.setAmount(new BigDecimal("25.00"));
    payment.setCurrency(CurrencyCode.USD);
    payment.setStatus(PaymentStatus.UNPAID);
    payment.setCreatedAt(now);
    payment.setUpdatedAt(now);
    return payment;
  }
}
