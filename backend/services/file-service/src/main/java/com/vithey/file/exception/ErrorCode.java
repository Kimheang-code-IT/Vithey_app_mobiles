package com.vithey.file.exception;

import org.springframework.http.HttpStatus;

public enum ErrorCode {
  VALIDATION_ERROR(HttpStatus.BAD_REQUEST, "Validation failed"),
  INVALID_FILE_TYPE(HttpStatus.BAD_REQUEST, "Invalid file type or MIME type"),
  FILE_TOO_LARGE(HttpStatus.BAD_REQUEST, "File exceeds the allowed size"),
  UNAUTHORIZED(HttpStatus.UNAUTHORIZED, "Authentication is required"),
  FORBIDDEN(HttpStatus.FORBIDDEN, "You do not have permission to access this file"),
  NOT_FOUND(HttpStatus.NOT_FOUND, "File not found"),
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
