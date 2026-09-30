package com.vithey.finance.service;

import com.vithey.finance.config.PaymentProviderProperties;
import com.vithey.finance.dto.response.PaymentTransactionResponse;
import com.vithey.finance.entity.Payment;
import com.vithey.finance.entity.PaymentStatus;
import com.vithey.finance.entity.PaymentTransaction;
import com.vithey.finance.entity.PaymentTransactionStatus;
import com.vithey.finance.exception.ApiException;
import com.vithey.finance.exception.ErrorCode;
import com.vithey.finance.payment.PaymentProvider;
import com.vithey.finance.payment.ProviderChargeRequest;
import com.vithey.finance.payment.ProviderChargeResult;
import com.vithey.finance.payment.ProviderException;
import com.vithey.finance.payment.ProviderPaymentStatus;
import com.vithey.finance.repository.PaymentRepository;
import com.vithey.finance.repository.PaymentTransactionRepository;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.Locale;
import java.util.Optional;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

/**
 * Orchestrates paying an invoice through an external {@link PaymentProvider}.
 *
 * <p>finance-service owns the invoice, the authoritative amount, authorization,
 * and the persisted transaction. The provider only simulates a charge.
 *
 * <p>Intentionally not {@code @Transactional}: the outbound HTTP call must not
 * run inside a database transaction, and a failed attempt must still be
 * persisted. Each repository call is transactional on its own.
 */
@Service
public class PaymentProcessingService {

  private static final Logger log = LoggerFactory.getLogger(PaymentProcessingService.class);
  private static final String PROVIDER_NAME = "FAKE";
  private static final int FAILURE_MESSAGE_MAX = 255;

  private final PaymentRepository paymentRepository;
  private final PaymentTransactionRepository transactionRepository;
  private final StudentFinanceAccountService studentFinanceAccountService;
  private final PaymentProvider paymentProvider;
  private final PaymentProviderProperties properties;

  public PaymentProcessingService(
      PaymentRepository paymentRepository,
      PaymentTransactionRepository transactionRepository,
      StudentFinanceAccountService studentFinanceAccountService,
      PaymentProvider paymentProvider,
      PaymentProviderProperties properties
  ) {
    this.paymentRepository = paymentRepository;
    this.transactionRepository = transactionRepository;
    this.studentFinanceAccountService = studentFinanceAccountService;
    this.paymentProvider = paymentProvider;
    this.properties = properties;
  }

  public PaymentTransactionResponse payInvoice(
      UUID userId,
      UUID paymentId,
      String scenarioOverride,
      String methodOverride,
      String idempotencyKey
  ) {
    studentFinanceAccountService.requireAccount(userId);

    Payment payment = paymentRepository.findById(paymentId)
        .filter(value -> value.getUserId().equals(userId))
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND));

    if (payment.getStatus() == PaymentStatus.PAID) {
      throw new ApiException(ErrorCode.CONFLICT, "Invoice is already paid");
    }

    String key = normalizeKey(idempotencyKey);
    if (key != null) {
      Optional<PaymentTransaction> existing = transactionRepository.findByIdempotencyKey(key);
      if (existing.isPresent()) {
        PaymentTransaction replay = existing.get();
        if (!replay.getPaymentId().equals(paymentId)) {
          throw new ApiException(ErrorCode.CONFLICT, "Idempotency key already used for another invoice");
        }
        log.info("idempotent replay paymentId={} transactionId={}", paymentId, replay.getId());
        return toResponse(replay);
      }
    }

    String scenario = resolve(scenarioOverride, properties.getScenario(), "SUCCESS");
    String method = resolve(methodOverride, properties.getPaymentMethod(), "DEMO_CARD");
    String merchantReference = "INV-" + payment.getId();

    OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
    PaymentTransaction transaction = new PaymentTransaction();
    transaction.setId(UUID.randomUUID());
    transaction.setPaymentId(payment.getId());
    transaction.setUserId(userId);
    transaction.setMerchantReference(merchantReference);
    transaction.setAmount(payment.getAmount());
    transaction.setCurrency(payment.getCurrency());
    transaction.setProviderName(PROVIDER_NAME);
    transaction.setStatus(PaymentTransactionStatus.PENDING);
    transaction.setPaymentMethod(method);
    transaction.setScenario(scenario);
    transaction.setIdempotencyKey(key);
    transaction.setCreatedAt(now);
    transaction.setUpdatedAt(now);
    transactionRepository.save(transaction);

    ProviderChargeResult result;
    try {
      result = paymentProvider.charge(new ProviderChargeRequest(
          merchantReference,
          payment.getAmount(),
          payment.getCurrency().name(),
          method,
          scenario,
          properties.isIdempotencyEnabled() ? (key != null ? key : transaction.getId().toString()) : null
      ));
    } catch (ProviderException exception) {
      markFailed(transaction, exception.getCode(), exception.getMessage());
      log.warn("provider failure paymentId={} code={}", paymentId, exception.getCode());
      throw new ApiException(
          mapProviderError(exception.getCode()),
          "Payment provider error: " + exception.getMessage()
      );
    }

    applyProviderResult(transaction, result, payment);
    PaymentTransaction saved = transactionRepository.save(transaction);
    log.info(
        "payment processed paymentId={} transactionId={} status={}",
        paymentId,
        saved.getId(),
        saved.getStatus()
    );
    return toResponse(saved);
  }

  private void applyProviderResult(
      PaymentTransaction transaction,
      ProviderChargeResult result,
      Payment payment
  ) {
    OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
    transaction.setProviderPaymentId(result.providerPaymentId());
    transaction.setProviderReference(result.providerReference());
    transaction.setStatus(mapStatus(result.status()));
    transaction.setFailureCode(result.failureCode());
    transaction.setFailureMessage(truncate(result.failureMessage()));
    transaction.setUpdatedAt(now);
    if (result.status() != ProviderPaymentStatus.PROCESSING
        && result.status() != ProviderPaymentStatus.PENDING) {
      transaction.setCompletedAt(now);
    }

    if (result.isSuccess()) {
      payment.setStatus(PaymentStatus.PAID);
      payment.setPaidAt(now);
      payment.setUpdatedAt(now);
      paymentRepository.save(payment);
    }
  }

  private void markFailed(PaymentTransaction transaction, String code, String message) {
    OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
    transaction.setStatus(PaymentTransactionStatus.FAILED);
    transaction.setFailureCode(code);
    transaction.setFailureMessage(truncate(message));
    transaction.setUpdatedAt(now);
    transaction.setCompletedAt(now);
    transactionRepository.save(transaction);
  }

  private static PaymentTransactionStatus mapStatus(ProviderPaymentStatus status) {
    return switch (status) {
      case PENDING -> PaymentTransactionStatus.PENDING;
      case PROCESSING -> PaymentTransactionStatus.PROCESSING;
      case SUCCESS -> PaymentTransactionStatus.SUCCESS;
      case CANCELLED -> PaymentTransactionStatus.CANCELLED;
      case FAILED -> PaymentTransactionStatus.FAILED;
    };
  }

  private static ErrorCode mapProviderError(String code) {
    if ("PROVIDER_TIMEOUT".equals(code)) {
      return ErrorCode.UPSTREAM_TIMEOUT;
    }
    return ErrorCode.UPSTREAM_ERROR;
  }

  private static String resolve(String override, String configured, String fallback) {
    if (override != null && !override.isBlank()) {
      return override.trim().toUpperCase(Locale.ROOT);
    }
    if (configured != null && !configured.isBlank()) {
      return configured.trim().toUpperCase(Locale.ROOT);
    }
    return fallback;
  }

  private static String normalizeKey(String key) {
    return (key == null || key.isBlank()) ? null : key.trim();
  }

  private static String truncate(String value) {
    if (value == null) {
      return null;
    }
    return value.length() <= FAILURE_MESSAGE_MAX ? value : value.substring(0, FAILURE_MESSAGE_MAX);
  }

  private static PaymentTransactionResponse toResponse(PaymentTransaction transaction) {
    return new PaymentTransactionResponse(
        transaction.getId(),
        transaction.getPaymentId(),
        transaction.getMerchantReference(),
        transaction.getAmount(),
        transaction.getCurrency(),
        transaction.getProviderName(),
        transaction.getProviderPaymentId(),
        transaction.getProviderReference(),
        transaction.getStatus(),
        transaction.getFailureCode(),
        transaction.getFailureMessage(),
        transaction.getCreatedAt(),
        transaction.getCompletedAt()
    );
  }
}
