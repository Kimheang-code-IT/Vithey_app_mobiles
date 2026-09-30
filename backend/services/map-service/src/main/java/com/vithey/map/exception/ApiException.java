package com.vithey.map.exception;

import org.springframework.http.HttpStatus;

public class ApiException extends RuntimeException {

  private final ErrorCode errorCode;
  private final HttpStatus statusOverride;

  public ApiException(ErrorCode errorCode) {
    super(errorCode.defaultMessage());
    this.errorCode = errorCode;
    this.statusOverride = null;
  }

  public ApiException(ErrorCode errorCode, String message) {
    super(message);
    this.errorCode = errorCode;
    this.statusOverride = null;
  }

  private ApiException(ErrorCode errorCode, String message, HttpStatus statusOverride) {
    super(message);
    this.errorCode = errorCode;
    this.statusOverride = statusOverride;
  }

  /**
   * Upstream failure with the standard {@code UPSTREAM_ERROR} code but a
   * custom HTTP status (e.g. 503 when the circuit breaker is open).
   */
  public static ApiException upstreamError(String message, HttpStatus status) {
    return new ApiException(ErrorCode.UPSTREAM_ERROR, message, status);
  }

  public ErrorCode getErrorCode() {
    return errorCode;
  }

  public HttpStatus getStatus() {
    return statusOverride == null ? errorCode.status() : statusOverride;
  }
}
