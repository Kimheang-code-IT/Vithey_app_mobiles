package com.vithey.finance.service;

import com.vithey.finance.dto.response.PaymentAlertsResponse;
import com.vithey.finance.dto.response.PaymentResponse;
import com.vithey.finance.entity.Fee;
import com.vithey.finance.entity.Payment;
import com.vithey.finance.entity.PaymentStatus;
import com.vithey.finance.exception.ApiException;
import com.vithey.finance.exception.ErrorCode;
import com.vithey.finance.mapper.FinanceMapper;
import com.vithey.finance.repository.FeeRepository;
import com.vithey.finance.repository.PaymentRepository;
import com.vithey.finance.util.ApiResponseWrapper;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PaymentService {

  private static final int MAX_LIMIT = 50;

  private final PaymentRepository paymentRepository;
  private final FeeRepository feeRepository;
  private final FinanceMapper financeMapper;
  private final StudentFinanceAccountService studentFinanceAccountService;
  private final int alertDueDays;

  public PaymentService(
      PaymentRepository paymentRepository,
      FeeRepository feeRepository,
      FinanceMapper financeMapper,
      StudentFinanceAccountService studentFinanceAccountService,
      @Value("${vithey.finance.alert-due-days:7}") int alertDueDays
  ) {
    this.paymentRepository = paymentRepository;
    this.feeRepository = feeRepository;
    this.financeMapper = financeMapper;
    this.studentFinanceAccountService = studentFinanceAccountService;
    this.alertDueDays = alertDueDays;
  }

  @Transactional(readOnly = true)
  public ApiResponseWrapper<List<PaymentResponse>> listPayments(UUID userId, int page, int limit) {
    studentFinanceAccountService.requireAccount(userId);

    int safePage = Math.max(page, 1);
    int safeLimit = Math.min(Math.max(limit, 1), MAX_LIMIT);
    PageRequest pageable = PageRequest.of(safePage - 1, safeLimit);

    Page<Payment> payments = paymentRepository.findByUserIdOrderByDueDateAscCreatedAtDesc(userId, pageable);
    Map<UUID, Fee> feesById = loadFees(payments.getContent());

    List<PaymentResponse> content = payments.getContent().stream()
        .map(payment -> toResponse(payment, feesById.get(payment.getFeeId())))
        .toList();

    return ApiResponseWrapper.paginated(
        content,
        new ApiResponseWrapper.Meta(safePage, safeLimit, payments.getTotalElements(), payments.getTotalPages())
    );
  }

  @Transactional(readOnly = true)
  public PaymentResponse getPayment(UUID paymentId, UUID userId) {
    studentFinanceAccountService.requireAccount(userId);

    Payment payment = paymentRepository.findById(paymentId)
        .filter(value -> value.getUserId().equals(userId))
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND));

    Fee fee = feeRepository.findById(payment.getFeeId())
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND));
    return toResponse(payment, fee);
  }

  @Transactional(readOnly = true)
  public PaymentAlertsResponse getAlerts(UUID userId) {
    studentFinanceAccountService.requireAccount(userId);

    LocalDate today = LocalDate.now(ZoneOffset.UTC);
    List<Payment> unpaid = paymentRepository.findByUserIdAndStatusNotOrderByDueDateAsc(userId, PaymentStatus.PAID);
    Map<UUID, Fee> feesById = loadFees(unpaid);

    List<PaymentAlertsResponse.PaymentAlertItem> alerts = new ArrayList<>();
    for (Payment payment : unpaid) {
      if (payment.getDueDate() == null) {
        continue;
      }
      Fee fee = feesById.get(payment.getFeeId());
      if (fee == null) {
        continue;
      }
      long daysRemaining = ChronoUnit.DAYS.between(today, payment.getDueDate());
      if (daysRemaining < 0 || daysRemaining <= alertDueDays) {
        alerts.add(new PaymentAlertsResponse.PaymentAlertItem(
            payment.getId(),
            fee.getName(),
            payment.getDueDate(),
            daysRemaining,
            payment.getAmount(),
            payment.getCurrency()
        ));
      }
    }

    alerts.sort(Comparator.comparing(PaymentAlertsResponse.PaymentAlertItem::dueDate));
    return new PaymentAlertsResponse(alerts);
  }

  public PaymentStatus effectiveStatus(Payment payment) {
    if (payment.getStatus() == PaymentStatus.PAID) {
      return PaymentStatus.PAID;
    }
    if (payment.getDueDate() != null && payment.getDueDate().isBefore(LocalDate.now(ZoneOffset.UTC))) {
      return PaymentStatus.OVERDUE;
    }
    return payment.getStatus();
  }

  private PaymentResponse toResponse(Payment payment, Fee fee) {
    if (fee == null) {
      throw new ApiException(ErrorCode.NOT_FOUND);
    }
    return financeMapper.toPaymentResponse(payment, fee, effectiveStatus(payment));
  }

  private Map<UUID, Fee> loadFees(List<Payment> payments) {
    List<UUID> feeIds = payments.stream().map(Payment::getFeeId).distinct().toList();
    return feeRepository.findAllById(feeIds).stream()
        .collect(Collectors.toMap(Fee::getId, Function.identity()));
  }
}
