package com.vithey.finance.payment;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.vithey.finance.config.PaymentProviderProperties;
import java.util.LinkedHashMap;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.MediaType;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientResponseException;

/**
 * {@link PaymentProvider} backed by the Vithey fake payment gateway (FastAPI).
 *
 * <p>DEMO ONLY. The fake gateway simulates a bank; it never processes real
 * money. Base URL and API key come from {@link PaymentProviderProperties}, so no
 * host is hardcoded and Docker uses the Compose service name.
 */
@Component
public class FakePaymentProvider implements PaymentProvider {

  private static final Logger log = LoggerFactory.getLogger(FakePaymentProvider.class);

  private final PaymentProviderProperties properties;
  private final RestClient restClient;

  public FakePaymentProvider(PaymentProviderProperties properties) {
    this.properties = properties;
    SimpleClientHttpRequestFactory requestFactory = new SimpleClientHttpRequestFactory();
    requestFactory.setConnectTimeout(properties.getConnectTimeoutMs());
    requestFactory.setReadTimeout(properties.getReadTimeoutMs());
    this.restClient = RestClient.builder()
        .baseUrl(properties.getBaseUrl())
        .requestFactory(requestFactory)
        .defaultHeader("Accept", MediaType.APPLICATION_JSON_VALUE)
        .build();
  }

  @Override
  public ProviderChargeResult charge(ProviderChargeRequest request) {
    Map<String, Object> body = new LinkedHashMap<>();
    body.put("merchant_reference", request.merchantReference());
    body.put("amount", request.amount().toPlainString());
    body.put("currency", request.currency());
    body.put("payment_method", request.paymentMethod());
    body.put("scenario", request.scenario());

    try {
      ProviderPaymentResponse response = restClient.post()
          .uri("/api/v1/payments")
          .header("X-Demo-API-Key", properties.getApiKey())
          .headers(headers -> {
            if (request.idempotencyKey() != null && !request.idempotencyKey().isBlank()) {
              headers.set("Idempotency-Key", request.idempotencyKey());
            }
          })
          .contentType(MediaType.APPLICATION_JSON)
          .body(body)
          .retrieve()
          .body(ProviderPaymentResponse.class);

      if (response == null) {
        throw new ProviderException("PROVIDER_ERROR", "Empty response from payment provider");
      }
      return new ProviderChargeResult(
          response.paymentId(),
          response.providerReference(),
          parseStatus(response.status()),
          response.failureCode(),
          response.failureMessage()
      );
    } catch (RestClientResponseException exception) {
      int status = exception.getStatusCode().value();
      if (status == 504 || status == 408) {
        throw new ProviderException("PROVIDER_TIMEOUT", "Payment provider timed out", exception);
      }
      log.warn("payment provider rejected charge: status={}", status);
      throw new ProviderException("PROVIDER_ERROR", "Payment provider rejected the request", exception);
    } catch (ResourceAccessException exception) {
      throw new ProviderException("PROVIDER_TIMEOUT", "Payment provider timed out", exception);
    }
  }

  private static ProviderPaymentStatus parseStatus(String raw) {
    if (raw == null || raw.isBlank()) {
      return ProviderPaymentStatus.FAILED;
    }
    try {
      return ProviderPaymentStatus.valueOf(raw.trim().toUpperCase(java.util.Locale.ROOT));
    } catch (IllegalArgumentException exception) {
      return ProviderPaymentStatus.FAILED;
    }
  }

  /** Snake_case response from the fake gateway. */
  private record ProviderPaymentResponse(
      @JsonProperty("payment_id") String paymentId,
      @JsonProperty("provider_reference") String providerReference,
      @JsonProperty("merchant_reference") String merchantReference,
      @JsonProperty("amount") String amount,
      @JsonProperty("currency") String currency,
      @JsonProperty("status") String status,
      @JsonProperty("failure_code") String failureCode,
      @JsonProperty("failure_message") String failureMessage
  ) {
  }
}
