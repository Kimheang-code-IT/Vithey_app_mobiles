package com.vithey.finance.exception;

import com.vithey.finance.util.ApiResponseWrapper;
import com.vithey.finance.util.ApiResponseWrapper.FieldErrorBody;
import jakarta.validation.ConstraintViolationException;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

  @ExceptionHandler(ApiException.class)
  ResponseEntity<ApiResponseWrapper<Void>> handleApiException(ApiException exception) {
    ErrorCode errorCode = exception.getErrorCode();
    return ResponseEntity
        .status(errorCode.status())
        .body(ApiResponseWrapper.error(errorCode.name(), exception.getMessage()));
  }

  @ExceptionHandler(AccessDeniedException.class)
  ResponseEntity<ApiResponseWrapper<Void>> handleAccessDenied() {
    return ResponseEntity.status(ErrorCode.FORBIDDEN.status())
        .body(ApiResponseWrapper.error(ErrorCode.FORBIDDEN.name(), ErrorCode.FORBIDDEN.defaultMessage()));
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
}
