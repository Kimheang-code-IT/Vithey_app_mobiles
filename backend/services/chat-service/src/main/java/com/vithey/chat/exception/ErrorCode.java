package com.vithey.chat.exception;

import org.springframework.http.HttpStatus;

public enum ErrorCode {
  VALIDATION_ERROR(HttpStatus.BAD_REQUEST, "Validation failed"),
  UNAUTHORIZED(HttpStatus.UNAUTHORIZED, "Authentication is required"),
  NOT_FOUND(HttpStatus.NOT_FOUND, "Resource not found"),
  FORBIDDEN(HttpStatus.FORBIDDEN, "You do not have permission to perform this action"),
  CONFLICT(HttpStatus.CONFLICT, "Resource already exists"),
  BUSINESS_RULE_VIOLATION(HttpStatus.UNPROCESSABLE_ENTITY, "Business rule violation"),
  INTERNAL_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "Unexpected server error");

  private final HttpStatus status;
  private final String defaultMessage;

  ErrorCode(HttpStatus status, String defaultMessage) {
    this.status = status;
    this.defaultMessage = defaultMessage;
  }

  public HttpStatus status() {
    return status;
  }

  public String defaultMessage() {
    return defaultMessage;
  }
}
