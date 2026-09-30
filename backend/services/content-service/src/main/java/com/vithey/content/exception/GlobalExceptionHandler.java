package com.vithey.content.exception;

import com.vithey.content.util.ApiResponseWrapper;
import com.vithey.content.util.ApiResponseWrapper.FieldErrorBody;
import feign.FeignException;
import jakarta.validation.ConstraintViolationException;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

@RestControllerAdvice
public class GlobalExceptionHandler {

  private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

  @ExceptionHandler(ApiException.class)
  ResponseEntity<ApiResponseWrapper<Void>> handleApiException(ApiException exception) {
    ErrorCode errorCode = exception.getErrorCode();
    return ResponseEntity
        .status(errorCode.status())
        .body(ApiResponseWrapper.error(errorCode.name(), exception.getMessage()));
  }

  @ExceptionHandler(MethodArgumentNotValidException.class)
  ResponseEntity<ApiResponseWrapper<Void>> handleValidation(MethodArgumentNotValidException exception) {
    List<FieldErrorBody> details = exception.getBindingResult().getFieldErrors().stream()
        .map(error -> new FieldErrorBody(error.getField(), error.getDefaultMessage()))
        .toList();
    return ResponseEntity.badRequest()
        .body(ApiResponseWrapper.error(ErrorCode.VALIDATION_ERROR.name(), ErrorCode.VALIDATION_ERROR.defaultMessage(), details));
  }

  @ExceptionHandler(ConstraintViolationException.class)
  ResponseEntity<ApiResponseWrapper<Void>> handleConstraintViolation(ConstraintViolationException exception) {
    List<FieldErrorBody> details = exception.getConstraintViolations().stream()
        .map(error -> new FieldErrorBody(error.getPropertyPath().toString(), error.getMessage()))
        .toList();
    return ResponseEntity.badRequest()
        .body(ApiResponseWrapper.error(ErrorCode.VALIDATION_ERROR.name(), ErrorCode.VALIDATION_ERROR.defaultMessage(), details));
  }

  @ExceptionHandler({HttpMessageNotReadableException.class, MethodArgumentTypeMismatchException.class})
  ResponseEntity<ApiResponseWrapper<Void>> handleUnreadable(Exception exception) {
    return ResponseEntity.badRequest()
        .body(ApiResponseWrapper.error(ErrorCode.VALIDATION_ERROR.name(), ErrorCode.VALIDATION_ERROR.defaultMessage()));
  }

  @ExceptionHandler(FeignException.NotFound.class)
  ResponseEntity<ApiResponseWrapper<Void>> handleRemoteNotFound(FeignException.NotFound exception) {
    String path = exception.request() == null ? "" : exception.request().url();
    if (path.contains("/api/v1/files/")) {
      return ResponseEntity.badRequest()
          .body(ApiResponseWrapper.error(ErrorCode.INVALID_FILE.name(), ErrorCode.INVALID_FILE.defaultMessage()));
    }
    return ResponseEntity.status(ErrorCode.NOT_FOUND.status())
        .body(ApiResponseWrapper.error(ErrorCode.NOT_FOUND.name(), ErrorCode.NOT_FOUND.defaultMessage()));
  }

  @ExceptionHandler(FeignException.Unauthorized.class)
  ResponseEntity<ApiResponseWrapper<Void>> handleRemoteUnauthorized() {
    return ResponseEntity.status(ErrorCode.INTERNAL_ERROR.status())
        .body(ApiResponseWrapper.error(ErrorCode.INTERNAL_ERROR.name(), "Dependent service authentication failed"));
  }

  @ExceptionHandler(FeignException.class)
  ResponseEntity<ApiResponseWrapper<Void>> handleFeign(FeignException exception) {
    log.warn("Downstream Feign call failed with status {}", exception.status(), exception);
    return ResponseEntity.status(ErrorCode.INTERNAL_ERROR.status())
        .body(ApiResponseWrapper.error(ErrorCode.INTERNAL_ERROR.name(), ErrorCode.INTERNAL_ERROR.defaultMessage()));
  }

  @ExceptionHandler(Exception.class)
  ResponseEntity<ApiResponseWrapper<Void>> handleUnexpected(Exception exception) {
    log.error("Unhandled exception", exception);
    return ResponseEntity.status(ErrorCode.INTERNAL_ERROR.status())
        .body(ApiResponseWrapper.error(ErrorCode.INTERNAL_ERROR.name(), ErrorCode.INTERNAL_ERROR.defaultMessage()));
  }
}
