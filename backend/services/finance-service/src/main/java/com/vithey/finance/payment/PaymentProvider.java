package com.vithey.finance.payment;

/**
 * Abstraction over an external payment provider.
 *
 * <p>Only this interface is referenced by finance business logic, so the fake
 * provider can later be replaced by a real one (a new {@code @Component}
 * implementation) without changing {@code PaymentProcessingService}.
 */
public interface PaymentProvider {

  ProviderChargeResult charge(ProviderChargeRequest request);
}
