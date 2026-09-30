package com.vithey.finance.controller;

import com.vithey.finance.dto.request.PayInvoiceRequest;
import com.vithey.finance.dto.response.PaymentAlertsResponse;
import com.vithey.finance.dto.response.PaymentResponse;
import com.vithey.finance.dto.response.PaymentTransactionResponse;
import com.vithey.finance.security.CurrentUserProvider;
import com.vithey.finance.service.PaymentProcessingService;
import com.vithey.finance.service.PaymentService;
import com.vithey.finance.util.ApiResponseWrapper;
import java.util.List;
import java.util.UUID;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/payments")
@PreAuthorize("hasRole('STUDENT')")
public class PaymentController {

  private final PaymentService paymentService;
  private final PaymentProcessingService paymentProcessingService;
  private final CurrentUserProvider currentUserProvider;

  public PaymentController(
      PaymentService paymentService,
      PaymentProcessingService paymentProcessingService,
      CurrentUserProvider currentUserProvider
  ) {
    this.paymentService = paymentService;
    this.paymentProcessingService = paymentProcessingService;
    this.currentUserProvider = currentUserProvider;
  }

  @GetMapping
  ResponseEntity<ApiResponseWrapper<List<PaymentResponse>>> listPayments(
      @RequestParam(defaultValue = "1") int page,
      @RequestParam(defaultValue = "20") int limit
  ) {
    UUID userId = currentUserProvider.requireStudent().userId();
    return ResponseEntity.ok(paymentService.listPayments(userId, page, limit));
  }

  @GetMapping("/alerts")
  ResponseEntity<ApiResponseWrapper<PaymentAlertsResponse>> getAlerts() {
    UUID userId = currentUserProvider.requireStudent().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(paymentService.getAlerts(userId)));
  }

  @GetMapping("/{paymentId}")
  ResponseEntity<ApiResponseWrapper<PaymentResponse>> getPayment(@PathVariable UUID paymentId) {
    UUID userId = currentUserProvider.requireStudent().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(paymentService.getPayment(paymentId, userId)));
  }

  /**
   * Pay an invoice through the (demo) external payment provider. The invoice,
   * amount, and ownership are resolved server-side; the client cannot influence
   * the charged amount. Invoice is marked PAID only on provider SUCCESS.
   */
  @PostMapping("/{paymentId}/pay")
  ResponseEntity<ApiResponseWrapper<PaymentTransactionResponse>> pay(
      @PathVariable UUID paymentId,
      @RequestHeader(name = "Idempotency-Key", required = false) String idempotencyKey,
      @RequestBody(required = false) PayInvoiceRequest request
  ) {
    UUID userId = currentUserProvider.requireStudent().userId();
    PaymentTransactionResponse response = paymentProcessingService.payInvoice(
        userId,
        paymentId,
        request == null ? null : request.scenario(),
        request == null ? null : request.paymentMethod(),
        idempotencyKey
    );
    return ResponseEntity.ok(ApiResponseWrapper.success(response));
  }
}
