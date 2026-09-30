package com.vithey.finance.payment;

/**
 * Raised when the external payment provider cannot be reached or returns an
 * unusable response. {@code code} is a stable, non-sensitive identifier.
 */
public class ProviderException extends RuntimeException {

  private final String code;

  public ProviderException(String code, String message) {
    super(message);
    this.code = code;
  }

  public ProviderException(String code, String message, Throwable cause) {
    super(message, cause);
    this.code = code;
  }

  public String getCode() {
    return code;
  }
}
