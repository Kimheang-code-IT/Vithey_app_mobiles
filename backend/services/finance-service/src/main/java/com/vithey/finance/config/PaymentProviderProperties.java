package com.vithey.finance.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * Configuration for the (demo) external payment provider.
 *
 * <p>Bound from {@code vithey.payment.provider.*}. The base URL and API key are
 * environment driven so Docker can point to the Compose service name without any
 * hardcoded host in application code.
 */
@Component
@ConfigurationProperties(prefix = "vithey.payment.provider")
@Getter
@Setter
public class PaymentProviderProperties {

  /** Base URL, e.g. {@code http://fake-payment-service:8090}. */
  private String baseUrl = "http://localhost:8090";

  /** Demo service credential sent as {@code X-Demo-API-Key}. Never a real key. */
  private String apiKey = "change-me";

  private int connectTimeoutMs = 3000;

  private int readTimeoutMs = 10000;

  /** Default demo scenario when the client does not override it. */
  private String scenario = "SUCCESS";

  /** Default demo payment method when the client does not override it. */
  private String paymentMethod = "DEMO_CARD";

  /** Forward an Idempotency-Key header to the provider on each charge. */
  private boolean idempotencyEnabled = true;
}
