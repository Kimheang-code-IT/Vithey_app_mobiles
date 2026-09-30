package com.vithey.finance.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

/**
 * Local record of an attempt to pay an invoice through an external provider.
 * Owned and persisted by finance-service (the fake provider does not persist).
 */
@Entity
@Table(name = "payment_transactions")
@Getter
@Setter
public class PaymentTransaction {

  @Id
  private UUID id;

  @Column(name = "payment_id", nullable = false)
  private UUID paymentId;

  @Column(name = "user_id", nullable = false)
  private UUID userId;

  @Column(name = "merchant_reference", nullable = false, length = 120)
  private String merchantReference;

  @Column(nullable = false, precision = 14, scale = 2)
  private BigDecimal amount;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, length = 8)
  private CurrencyCode currency;

  @Column(name = "provider_name", nullable = false, length = 40)
  private String providerName;

  @Column(name = "provider_payment_id", length = 80)
  private String providerPaymentId;

  @Column(name = "provider_reference", length = 80)
  private String providerReference;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, length = 32)
  private PaymentTransactionStatus status;

  @Column(name = "failure_code", length = 64)
  private String failureCode;

  @Column(name = "failure_message", length = 255)
  private String failureMessage;

  @Column(name = "payment_method", length = 32)
  private String paymentMethod;

  @Column(name = "scenario", length = 32)
  private String scenario;

  @Column(name = "idempotency_key", length = 120)
  private String idempotencyKey;

  @Column(name = "created_at", nullable = false)
  private OffsetDateTime createdAt;

  @Column(name = "updated_at", nullable = false)
  private OffsetDateTime updatedAt;

  @Column(name = "completed_at")
  private OffsetDateTime completedAt;
}
